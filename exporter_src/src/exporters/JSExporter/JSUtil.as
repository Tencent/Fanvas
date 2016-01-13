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
	/**
	 * 
	 * @author tencent
	 * @date Jul 18, 2014
	 */
	public class JSUtil
	{
		public function JSUtil()
		{
		}
		
		/**
		 * 转换为js的color表示，0xFFFFFF变为#FFFFFF，如果有alpha，则用rgba(r,g,b,a)表示
		 * @param color rgb
		 * @param alpha
		 * @return 
		 */
		public static function getJSColor(color:uint, alpha:Number):String
		{
			if(alpha == 1)
			{
				var hex:String = (color&0xffffff).toString(16).toUpperCase();
				while(hex.length < 6)
					hex = "0" + hex;
				return "#" + hex;
			}
			else
			{
				var r:int = (color>>16)&0xFF;
				var g:int = (color>>8)&0xFF;
				var b:int = color&0xFF;
				return "rgba(" + r + "," + g + "," + b + "," + alpha.toPrecision(1) + ")";
			}
		}
		
		/**
		 * 跟getJSColor类似，但传入argb
		 * @param argb 
		 * @return 
		 */
		public static function getJSColorByARGB(argb:uint):String
		{
			return getJSColor(argb&0xffffff, Number((argb/2)>>23)/255);	//直接右移24会出现-1，被当作int处理了
		}
		
		/**
		 * 控制number小数后位数
		 * @param value
		 * @param precision 小数点后位数
		 * @return 
		 */
		public static function toPrecision(value:Number, precision:int):Number
		{
			var pow:Number = Math.pow(10, precision);
			return Math.round(value*pow)/pow;
		}
	}
}