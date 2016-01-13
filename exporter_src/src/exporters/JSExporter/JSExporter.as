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
	import deng.fzip.FZip;
	
	import flash.utils.ByteArray;
	
	import model.SWFData;
	
	/**
	 * 
	 * @author tencent
	 * @date Jul 17, 2014
	 */
	public class JSExporter
	{
		public function JSExporter()
		{
		}
		
		/**
		 * @return 返回对应的HTML5 js代码或者zip（包括图片）
		 */
		public function export(swfData:SWFData, finish:Function):void
		{
			new SWFDataExporter().export(swfData, function(data:Object):void
			{
				var js:String = "var swfData = " + data.data + ";";
				
				if(data.images.length == 0)
				{
					finish(js);
				}
				else
				{
					var zipData:ByteArray = new ByteArray();
					var zip:FZip = new FZip();
					zip.addFileFromString("swfData.js", js);
					for (var i:int = 0; i < data.images.length; i++) 
					{
						zip.addFile(data.images[i].name, data.images[i].file);
					}
					zip.serialize(zipData);
					finish(zipData);
				}
			});
		}
	}
}