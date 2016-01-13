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
	import com.codeazur.as3swf.tags.TagDefineShape;
	
	import model.ShapeData;
	

	/**
	 * @author tencent
	 * @date Jul 7, 2014
	 */
	public class ShapeParser
	{
		public function ShapeParser()
		{
		}
		
		public static function parse(shapeTag:TagDefineShape):ShapeData
		{
			var shapeData:ShapeData = new ShapeData();
			shapeData.data = shapeTag;
			shapeData.characterId = shapeTag.characterId;
			shapeData.rect = shapeTag.shapeBounds.rect;
			return shapeData;
		}
	}
}