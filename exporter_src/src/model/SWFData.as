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
package model
{
	import com.codeazur.as3swf.SWF;

	/**
	 * @author tencent
	 * @date Jul 11, 2014
	 */
	public class SWFData
	{
		public var backgroundColor:uint;
		public var stageWidth:int;
		public var stageHeight:int;
		public var frameRate:Number;
		/**
		 * 存储所有定义，包括主MovieClip，默认0是第一个
		 */
		public var elementDefinitionPool:ElementDefinitionPool;
		public var swf:SWF;
		
		public function SWFData()
		{
		}
	}
}