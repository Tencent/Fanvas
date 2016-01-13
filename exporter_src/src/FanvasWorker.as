/*
* Tencent is pleased to support the open source community by making Fanvas available.
* Copyright (C) 2015 THL A29 Limited, a Tencent company. All rights reserved.
*
* Licensed under the MIT License (the "License"); you may not use this file except in compliance with the 
* License. You may obtain a copy of the License at
* http://opensource.org/licenses/MIT
*
* Unless required by applicable law or agreed to in writing, software distributed under the License is 
* distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
* implied. See the License for the specific language governing permissions and limitations under the 
* License.
*/
package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	
	import exporters.JSExporter.JSExporter;
	
	import parsers.SWFParser;
	
	/**
	 * 多线程版的fanvas
	 * @author tencent
	 * @date 2015-10-14
	 */
	[SWF(width = "510", height = "690", frameRate = "24", backgroundColor = "0xFFFFFF")]
	public class FanvasWorker extends Sprite
	{
		private var _data:* = null;
		private var _mainToWorker:MessageChannel;
		private var _workerToMain:MessageChannel;
		private var _worker:Worker;
		private var _ui:UI;
		
		public function FanvasWorker()
		{
			/**
			 * Start Main thread
			 **/
			if(Worker.current.isPrimordial)
			{
				//Create worker from our own loaderInfo.bytes
				_worker = WorkerDomain.current.createWorker(this.loaderInfo.bytes, true);
				
				//Create messaging channels for 2-way messaging
				_workerToMain = _worker.createMessageChannel(Worker.current);
				_mainToWorker = Worker.current.createMessageChannel(_worker);
				_worker.setSharedProperty("workerToMain", _workerToMain);
				_worker.setSharedProperty("mainToWorker", _mainToWorker);
				
				//Listen to the response from our worker
				_workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
				_worker.start();		//re-run Fanvas()
				
				createUI();
			}
			/**
			 * Start Worker thread
			 **/
			else {
				_workerToMain = Worker.current.getSharedProperty("workerToMain");		
				_mainToWorker = Worker.current.getSharedProperty("mainToWorker");		
				//Listen for messages from the server
				_mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
			}
			
		}
		
		/**
		 * Main thread
		 */
		private function createUI():void
		{
			_ui = new UI();
			addChild(_ui);
			_ui.uploadButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				var file:FileReference = new FileReference();
				file.browse([new FileFilter("swf", "*.swf")]);
				file.addEventListener(Event.SELECT, function(e:Event):void
				{
					_ui.errorText.text = '';
					_ui.exportDataButton.visible = false;
					_ui.loadingMask.visible = true;
					file.load();
					file.addEventListener(Event.COMPLETE, function(e1:Event):void
					{
						file.data.shareable = true;
						_mainToWorker.send(file.data);	//data 将直接传引用过去，而不是复制，因为设置了shareable
					});
				});
			});
			_ui.exportDataButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				if(_data)
				{
					var file1:FileReference = new FileReference();
					if(_data is String)
						file1.save(_data, "swfData.js");
					else
						file1.save(_data, "js_images.zip");
				}
			});
			_ui.exportDataButton.visible = false;
			_ui.loadingMask.visible = false;
		}
		
		/**
		 * Main thread 
		 * 
		 * 处理worker线程的消息（swf解析完毕）
		 */
		protected function onWorkerToMain(event:Event): void {
			_data = _workerToMain.receive();
			if(_data.warning && _data.warning.length > 0)
			{
				_ui.errorText.text = _data.warning.join('\n');
			}
			_data = _data.result;
			_ui.exportDataButton.visible = true;
			_ui.loadingMask.visible = false;
			if(ExternalInterface.available && _data is String)
				ExternalInterface.call("show", _data);
		}
		
		
		/**
		 * Worker Thread 真正处理swf的线程
		 */
		protected function onMainToWorker(event:Event): void {
			var file:ByteArray = _mainToWorker.receive();
			var parseResult:Object = new SWFParser(file).parse();
			new JSExporter().export(parseResult.swfData, function(result:*):void
			{
				var data:Object = {
					result:result,
					warning:parseResult.warning
				};
				_workerToMain.send(data);
			});
		}
		
	}
}







