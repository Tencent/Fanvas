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

	/**
	 * 存储所有库元件、MovieClip临时建立的Shape
	 * @author tencent
	 * @date Jul 8, 2014
	 */
	public class ElementDefinitionPool
	{
		/**
		 * 已经定义过的元件（MovieClip或者Shape）
		 */
		public var definitionList:Vector.<DisplayObjectData>;
		
		public function ElementDefinitionPool()
		{
			definitionList = new Vector.<DisplayObjectData>();
		}
		
		public function getDefinitionByCharacterId(characterId:uint):DisplayObjectData
		{
			for (var i:int = 0; i < definitionList.length; i++) 
			{
				if(definitionList[i].characterId == characterId)
					return definitionList[i]
			}
			return null;
		}
		
		public function getIndexByCharacterId(characterId:uint):int{
			for (var i:int = 0; i < definitionList.length; i++) 
			{
				if(definitionList[i].characterId == characterId)
					return i;
			}
			return -1;
		}
		
		public function push(displayObjectData:DisplayObjectData):void
		{
			definitionList.push(displayObjectData);
		}
		
		public function get length():uint
		{
			return definitionList.length;
		}
	}
}





