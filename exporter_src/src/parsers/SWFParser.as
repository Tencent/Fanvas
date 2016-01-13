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
	
	import flash.utils.ByteArray;
	
	import model.ElementDefinitionPool;
	import model.SWFData;

	/**
	 * 
	 * @author tencent
	 * @date Jul 11, 2014
	 */
	public class SWFParser
	{
		private var _by:ByteArray;
		/**
		 * 加载外部swf的Loader。需要Loader.contentLoaderInfo的complete事件之后调用
		 */
		public function SWFParser(by:ByteArray)
		{
			_by = by;
		}
		
		
		/**
		 * 调用parse开始解析，返回转化后的中间数据和警告信息（如果有）
		 * @return Object{	<br>
		 * 		swfData: SWFData,	<br>
		 * 		warning: [String]	<br>
		 * }
		 */
		public function parse():Object
		{
			var swf:SWF = new SWF(_by);		//依赖外部库读取二进制信息
			var swfData:SWFData = new SWFData();
			swfData.swf = swf;
			swfData.backgroundColor = swf.backgroundColor;
			swfData.frameRate = swf.frameRate;
			swfData.stageWidth = swf.frameSize.rect.width;
			swfData.stageHeight = swf.frameSize.rect.height;
			swfData.elementDefinitionPool = new ElementDefinitionPool();
			var warningMessage:Array = new MovieClipParser().parse(swfData);
			return {
				warning: warningMessage,
				swfData: swfData
			};
		}
	}
}