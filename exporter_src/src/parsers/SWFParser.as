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
package parsers
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.TagDefineShape;
	
	import flash.display.Loader;
	
	import model.ElementDefinitionPool;
	import model.SWFData;

	/**
	 * 
	 * @author tencent
	 * @date Jul 11, 2014
	 */
	public class SWFParser
	{
		private var _swf:Loader;
		/**
		 * 加载外部swf的Loader。需要Loader.contentLoaderInfo的complete事件之后调用
		 */
		public function SWFParser(loader:Loader)
		{
			_swf = loader;
		}
		
		public function parse():SWFData
		{
			var swf:SWF = new SWF(_swf.contentLoaderInfo.bytes);		//依赖外部库读取二进制信息
			var swfData:SWFData = new SWFData();
			swfData.swf = swf;
			swfData.backgroundColor = swf.backgroundColor;
			swfData.frameRate = swf.frameRate;
			swfData.stageWidth = _swf.contentLoaderInfo.width;
			swfData.stageHeight = _swf.contentLoaderInfo.height;
			swfData.elementDefinitionPool = new ElementDefinitionPool();
			new MovieClipParser().parse(swf, swfData.elementDefinitionPool);
			return swfData;
		}
	}
}