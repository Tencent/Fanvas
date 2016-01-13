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
package exporters.JSExporter
{
	import model.DisplayObjectData;
	import model.MovieClipData;
	import model.SWFData;
	import model.ShapeData;
	
	/**
	 * 
	 * @author tencent
	 * @date Jul 17, 2014
	 */
	public class SWFDataExporter
	{
		/**
		 * 用于存储导出过程中遇到的位图
		 */
		private var _imageList:Array;
		private var _definitionPool:Array;
		
		public function SWFDataExporter()
		{
		}
		
		public function export(swfData:SWFData, finish:Function):void
		{
			_imageList = new Array();
			_definitionPool = new Array();
			exportPoolElements(swfData, function():void
			{
				var swfObj : Object = {"bgColor":JSUtil.getJSColor(swfData.backgroundColor, 1), "stageWidth":swfData.stageWidth, "stageHeight":swfData.stageHeight, 
					"frameRate":swfData.frameRate, "definitionPool":_definitionPool};
				if(_imageList.length)
				{
					swfObj.images = [];		//用于js预加载
					for (var i:int = 0; i < _imageList.length; i++) 
					{
						swfObj.images.push(_imageList[i].name);
					}
				}
				finish({data:JSON.stringify(swfObj), images:_imageList});
			});
		}
		
		private function exportPoolElements (swfData : SWFData, finish:Function) : void 
		{
			var elements : Vector.<DisplayObjectData> = swfData.elementDefinitionPool.definitionList;
			var element : DisplayObjectData;
			var shapeCount:int = 0;
			var shapeFinishCount:int = 0;
			var loopOver:Boolean = false;
			for (var i : int = 0; i < elements.length; i++) {
				element = elements[i];
				var displayObjectData:Object = new Object();
				if (element is MovieClipData) {
					displayObjectData = MovieClipExporter.export(element as MovieClipData);
					addDisplayObject(element, displayObjectData, i);
				} else {
					exportShape(element, i);
				}
			}
			loopOver = true;
			if(shapeCount == shapeFinishCount && loopOver)
				finish();
			
			function exportShape(element:DisplayObjectData, index:int):void
			{
				shapeCount++;
				//由于shape导出图片是异步的，所以这里不得不跟着改为异步。囧！！！！尝试过同步的jpg类库，但发现不可靠
				ShapeDataExporter.export(element as ShapeData, swfData.swf, _imageList, function(d:Object):void
				{
					addDisplayObject(element, d, index);
					shapeFinishCount++;
					if(shapeCount == shapeFinishCount && loopOver)
						finish();
				});
			}
			
			function addDisplayObject(element:DisplayObjectData, displayObjectData:Object, index:int):void
			{
				if(element.rect)
				{
					displayObjectData.rect = {"x":JSUtil.toPrecision(element.rect.x,1), "y":JSUtil.toPrecision(element.rect.y,1), 
						"width":JSUtil.toPrecision(element.rect.width,1), "height":JSUtil.toPrecision(element.rect.height,1)};
				}
				_definitionPool[index] = displayObjectData;
			}
		}
		
	}	
}



	