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
	import flash.utils.ByteArray;
	
	import deng.fzip.FZip;
	
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
		 * @param dataObjectName 导出的js数据对象的名称，默认是swfData，如果批量导出多个就可以通过这个参数区分不同的swf
		 * @param allZip 是否把所有文件都打包为zip，即使没有图片，只有js的情况也打包为zip。默认是false，只有js的时候不打包zip
		 * @return 返回对应的HTML5 js代码或者zip（包括图片）
		 */
		public function export(swfData:SWFData, finish:Function, dataObjectName:String = "swfData", allZip:Boolean = false):void
		{
			new SWFDataExporter().export(swfData, function(data:Object):void
			{
				var js:String = "var " + dataObjectName + " = " + data.data + ";";
				
				if(data.images.length == 0 && allZip == false)
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