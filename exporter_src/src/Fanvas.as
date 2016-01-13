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
	import exporters.JSExporter.JSExporter;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	import parsers.SWFParser;

	/**
	 *
	 * @author tencent
	 * @date Jul 3, 2014
	 */
	[SWF(width = "510", height = "690", frameRate = "24", backgroundColor = "0xFFFFFF")]
	public class Fanvas extends Sprite
	{
		public static var warningMessage:String;
		private var _data:* = null;

		public function Fanvas()
		{
			var ui:UI = new UI();
			addChild(ui);
			ui.uploadButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{
				var file:FileReference = new FileReference();
				file.browse([new FileFilter("swf", "*.swf")]);
				file.addEventListener(Event.SELECT, function(e:Event):void
				{
					ui.errorText.visible = false;
					ui.exportDataButton.visible = false;
					ui.loadingMask.visible = true;
					file.load();
					file.addEventListener(Event.COMPLETE, function(e1:Event):void
					{
						var loader:Loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e2:Event):void
						{
							warningMessage = "";
							new JSExporter().export(new SWFParser(loader).parse(), function(data:*):void
							{
								 _data = data;
								 if(_data is String && ExternalInterface.available)
									 ExternalInterface.call("show", _data);
								 if(warningMessage != "")
								 {
									 ui.errorText.visible = true;
									 ui.errorText.text = warningMessage;
								 }
								 ui.exportDataButton.visible = true;
								 ui.loadingMask.visible = false;
							});
						});
						loader.loadBytes(file.data);
					});
				});
			});
			ui.exportDataButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
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
			ui.exportDataButton.visible = false;
			ui.loadingMask.visible = false;
		}
		
		
	}
}







