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
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	
	import exporters.JSExporter.JSExporter;
	
	import parsers.SWFParser;
	
	/**
	 * js接口版的fanvas，无界面
	 * @author tencent
	 * @date 2015-10-15
	 */
	[SWF(width = "1", height = "1", frameRate = "24", backgroundColor = "0xFFFFFF")]
	public class FanvasService extends Sprite
	{
		private const XSSREG:RegExp = /^[0-9a-zA-Z_.]*$/;
		
		private var _data:* = null;
		private var _mainToWorker:MessageChannel;
		private var _workerToMain:MessageChannel;
		private var _worker:Worker;
		
		/**
		 * main thread的变量
		 */
		private var _finish:Function;
		private var _fail:Function;
		private var _logger:Function;
		private var _uploadURL:String;
		
		/**
		 * worker thread的变量
		 */
		private var _dataObjectName:String;
		
		public function FanvasService()
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
				
				createService();
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
		private function createService():void
		{
			if(ExternalInterface.available && XSSREG.test(ExternalInterface.objectID))
			{
				ExternalInterface.addCallback("parse", parseSWF);
			}
		}
		
		/**
		 * Main thread 
		 */
		private function parseSWF(swfURL:String, uploadURL:String, finish:String, fail:String, dataObjectName:String = "swfData", logger:String = "console.log"):void
		{
			if(XSSREG.test(finish + fail + logger))
			{
				_uploadURL = uploadURL;
				_finish = function():void{
					ExternalInterface.call(finish);
				};
				_fail = function():void{
					ExternalInterface.call(fail);
				};
				_logger = function(msg:String):void{
					ExternalInterface.call(logger, msg);
				};
				
				_logger("Fanvas start. Target SWF: " + encodeURI(swfURL));
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, function(e:Event):void
				{
					_logger("fetch swf, done");
					loader.data.shareable = true;
					_mainToWorker.send(dataObjectName);
					_mainToWorker.send(loader.data);	//data 将直接传引用过去，而不是复制，因为设置了shareable
					_logger("parsing swf...");
				});
				loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
				{
					_logger("fetch swf, IO_ERROR");
					_fail();
				});
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:Event):void
				{
					_logger("fetch swf, SECURITY_ERROR, check crossdomain.xml");
					_fail();
				});
				loader.load(new URLRequest(swfURL));
			}
		}
		
		/**
		 * Main thread 
		 */
		private function upload(zipFile:ByteArray):void {
			_logger("start upload file");
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(_uploadURL);
			request.data = zipFile;	
			request.contentType = "application/octet-stream";
			request.method = URLRequestMethod.POST;
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				_logger("upload file, done");
				_finish();
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void {
				_logger("upload file, ioerror");
				_fail();
			});
			loader.load(request);
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
				for (var i:int = 0; i < _data.warning.length; i++) 
				{
					_logger(_data.warning[i]);
				}
			}
			_logger("parse swf, done");
			upload(_data.result);
		}
		
		
		/**
		 * Worker Thread 真正处理swf的线程
		 */
		protected function onMainToWorker(event:Event): void {
			var data:* = _mainToWorker.receive();
			if(data is String)
			{
				_dataObjectName = data;
			}
			else
			{
				var parseResult:Object = new SWFParser(data).parse();
				new JSExporter().export(parseResult.swfData, function(result:*):void
				{
					var data:Object = {
						result:result,
						warning:parseResult.warning
					};
					_workerToMain.send(data);
				}, _dataObjectName, true);
			}
		}
		
	}
}







