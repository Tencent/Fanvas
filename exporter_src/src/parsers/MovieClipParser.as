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
	import com.codeazur.as3swf.SWFTimelineContainer;
	import com.codeazur.as3swf.data.filters.Filter;
	import com.codeazur.as3swf.data.filters.FilterBlur;
	import com.codeazur.as3swf.data.filters.FilterColorMatrix;
	import com.codeazur.as3swf.data.filters.FilterDropShadow;
	import com.codeazur.as3swf.data.filters.FilterGlow;
	import com.codeazur.as3swf.data.filters.IFilter;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagCSMTextSettings;
	import com.codeazur.as3swf.tags.TagDefineBits;
	import com.codeazur.as3swf.tags.TagDefineBitsLossless;
	import com.codeazur.as3swf.tags.TagDefineButton;
	import com.codeazur.as3swf.tags.TagDefineButton2;
	import com.codeazur.as3swf.tags.TagDefineButtonCxform;
	import com.codeazur.as3swf.tags.TagDefineButtonSound;
	import com.codeazur.as3swf.tags.TagDefineEditText;
	import com.codeazur.as3swf.tags.TagDefineFont;
	import com.codeazur.as3swf.tags.TagDefineFontAlignZones;
	import com.codeazur.as3swf.tags.TagDefineFontInfo;
	import com.codeazur.as3swf.tags.TagDefineFontName;
	import com.codeazur.as3swf.tags.TagDefineMorphShape;
	import com.codeazur.as3swf.tags.TagDefineSceneAndFrameLabelData;
	import com.codeazur.as3swf.tags.TagDefineShape;
	import com.codeazur.as3swf.tags.TagDefineSound;
	import com.codeazur.as3swf.tags.TagDefineSprite;
	import com.codeazur.as3swf.tags.TagDefineText;
	import com.codeazur.as3swf.tags.TagDoABC;
	import com.codeazur.as3swf.tags.TagDoABCDeprecated;
	import com.codeazur.as3swf.tags.TagDoAction;
	import com.codeazur.as3swf.tags.TagEnd;
	import com.codeazur.as3swf.tags.TagFileAttributes;
	import com.codeazur.as3swf.tags.TagJPEGTables;
	import com.codeazur.as3swf.tags.TagMetadata;
	import com.codeazur.as3swf.tags.TagPlaceObject2;
	import com.codeazur.as3swf.tags.TagPlaceObject3;
	import com.codeazur.as3swf.tags.TagRemoveObject2;
	import com.codeazur.as3swf.tags.TagSetBackgroundColor;
	import com.codeazur.as3swf.tags.TagShowFrame;
	import com.codeazur.as3swf.tags.TagSoundStreamBlock;
	import com.codeazur.as3swf.tags.TagSoundStreamHead;
	import com.codeazur.as3swf.tags.TagSymbolClass;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import fl.motion.MatrixTransformer;
	
	import model.ElementDefinitionPool;
	import model.InstanceData;
	import model.MovieClipData;
	import model.TweenData;
	import model.frameAction.BaseFrameAction;
	import model.frameAction.PlaceElementAction;
	import model.frameAction.RemoveElementAction;
	import model.frameAction.TweenAction;

	/**
	 * 解析一个swf，需要new一个MovieClipParser
	 * @author tencent
	 * @date Dec 15, 2014
	 */
	public class MovieClipParser
	{
		private var _elementPool:ElementDefinitionPool;
		
		/**
		 * 调用parse开始解析
		 * @param movieClip
		 */
		public function MovieClipParser()
		{
		}
		
		public function parse(swf:SWF, elementPool:ElementDefinitionPool):void
		{
			_elementPool = elementPool;
			parseElementDefinitions(swf);
			trace ("aa");
		}

		/**
		 * 递归分析MovieClip中每个元件的定义
		 */
		private function parseElementDefinitions(movieClip:SWFTimelineContainer):MovieClipData
		{
			var movieClipData:MovieClipData = new MovieClipData();
			if(movieClip is TagDefineSprite)
				movieClipData.characterId = (movieClip as TagDefineSprite).characterId;
			_elementPool.push(movieClipData);
			
			var error:Boolean = false;
			var tags:Vector.<ITag> = new Vector.<ITag>();
			for (var i:int = 0; i < movieClip.tags.length; i++) 
			{
				var tag:ITag = movieClip.tags[i];
				if(tag is TagFileAttributes || tag is TagMetadata || tag is TagSetBackgroundColor || tag is TagDefineSceneAndFrameLabelData)
					continue;
				
				if(tag is TagDefineShape) {
					_elementPool.push(ShapeParser.parse(tag as TagDefineShape));
				} else if(tag is TagDefineSprite) {
					parseElementDefinitions(tag as TagDefineSprite);
				} else if(tag is TagEnd || tag is TagRemoveObject2 || tag is TagPlaceObject2 || tag is TagPlaceObject3 || tag is TagShowFrame) {
					tags.push(tag);
				} else if (tag is TagDefineBits || tag is TagDefineBitsLossless || tag is TagJPEGTables) {
					//不作处理，bitmap处理
				} else if(tag is TagDefineMorphShape) {
					Fanvas.warningMessage += "暂时不支持补间形状，跳过。";
				} else if (tag is TagDoABC || tag is TagDoAction || tag is TagSymbolClass || tag is TagDoABCDeprecated) {
					Fanvas.warningMessage += "暂时不支持链接和代码,跳过。";
				} else if (tag is TagCSMTextSettings || tag is TagDefineEditText || tag is TagDefineFont || tag is TagDefineFontAlignZones || tag is TagDefineFontInfo || tag is TagDefineFontName || tag is TagDefineText) {
					Fanvas.warningMessage += "暂时不支持文字，跳过。";
				} else if (tag is TagDefineButton || tag is TagDefineButton2 || tag is TagDefineButtonCxform || tag is TagDefineButtonSound) {
					Fanvas.warningMessage += "暂时不支持按钮，跳过。";
				} else if (tag is TagSoundStreamBlock || tag is TagSoundStreamHead || tag is TagDefineSound) {
					Fanvas.warningMessage += "暂时不支持声音，跳过。";
				} else {
					Fanvas.warningMessage += "未知tag，跳过。";
				}
			}
			
			if(!error) {
				var obj : Object = parseFrameActions(tags);
				movieClipData.frameActionList = obj.actions;
				movieClipData.totalFrames = obj.totalFrame;
				movieClipData.rect = obj.rect;
			} else {
				movieClipData.frameActionList = new Vector.<Vector.<BaseFrameAction>>();
			}
			return movieClipData;
		}
		
		/**
		 * parseElementDefinitions并没有完全完成每个元件定义的细化，需要在这个函数中对FrameAction做细化处理
		 */
		private function parseFrameActions(tags:Vector.<ITag>):Object
		{
			//最终的action数组
			var finalActions : Vector.<Vector.<BaseFrameAction>> = new Vector.<Vector.<BaseFrameAction>>();//action列表
			var action : BaseFrameAction;
			
			var tag : ITag;
			var tagRemoveObject2 : TagRemoveObject2;
			var tagPlaceObject2 : TagPlaceObject2;
			var tagPlaceObject3 : TagPlaceObject3;
			var tagShowFrame : TagShowFrame;
			var tagEnd : TagEnd;
			
			var layerInfoArr : Array = [];//按层分散tag信息，同时把tag信息转化成BaseFrameAction
			var layerInfo : LayerInfo;
			
			var nowFrame : int = 0;
			var depth : int;
			var characterID : int;
			var clipDic : Dictionary = new Dictionary();
			
			for (var i:int=0; i<tags.length; i++) {
				tag = tags[i];
				if (tag is TagRemoveObject2) {
					tagRemoveObject2 = tag as TagRemoveObject2;
					depth = tagRemoveObject2.depth;
					layerInfo = getLayerInfo (depth, layerInfoArr);
					if (layerInfo) {
						//过滤掉不支持的元件类型
						if (!layerInfo.hasContent) 
							continue;
						
						layerInfo.hasContent = false;
						//真正的移出时，要清掉matrix和colorTransform
						layerInfo.lastMatrix = null;
						layerInfo.lastColorTansform = null;
						
						action = new RemoveElementAction(layerInfo.instanceName);
						addAction(finalActions, nowFrame, action);//移出指令直接存入finalActions
						addTweenAction(layerInfo);
						
						//mask处理，当mask被移除时要清除mask信息（mask元件被移除时被mask遮罩的MC元件会同时被移除，并加载到新的层，Shape元件不会被移除。）
						for (var clipName1 : String in clipDic) {
							if (clipName1 == layerInfo.instanceName) {
								clipDic[clipName1] = null;
								delete clipDic[clipName1];
								break;
							}
						}
					}
				} else if (tag is TagPlaceObject2 || tag is TagPlaceObject3) {
					//新生成了元件的标志（区别于移动元件）
					var needUpdate : Boolean = false;
					tagPlaceObject2 = tag as TagPlaceObject2;
					depth = tagPlaceObject2.depth;
					characterID = tagPlaceObject2.characterId;
					layerInfo = getLayerInfo (depth, layerInfoArr);
					//第一次出现的层
					if (!layerInfo) {
						layerInfo = new LayerInfo();
						layerInfoArr.splice(getDepth(depth, layerInfoArr, false), 0, layerInfo);
						layerInfo.depth = depth;
						layerInfo.actions = [];
					}
					
					if (characterID > 0) {
						//放置新元件
						//shape的内容变了，移出之前的shape，对于不存在的元素也适用
						if(layerInfo.hasContent){
							action = new RemoveElementAction(layerInfo.instanceName);
							addAction(finalActions, nowFrame, action);//移出指令直接存入finalActions
							addTweenAction(layerInfo);
						}
						
						//新放置一个新元素，属性更新，但不一定存在
						layerInfo.characterID = characterID;
						if (tagPlaceObject2.instanceName == null) {
							layerInfo.instanceName = depth + "-" + _elementPool.getIndexByCharacterId(characterID);
						} else {
							layerInfo.instanceName = tagPlaceObject2.instanceName;
						}
						layerInfo.lastKeyFrame = nowFrame;
						needUpdate = true;
						//过滤新添加的不存在元素
						if(!_elementPool.getDefinitionByCharacterId(characterID)) {
							layerInfo.hasContent = false;
							continue;
						} else {
							layerInfo.hasContent = true;
						}
					} else {
						//刷新元件属性
						//过滤改变属性的不存在元素
						if (!_elementPool.getDefinitionByCharacterId(layerInfo.characterID)) {
							continue;
						}
					}
					
					//将tag信息转化成运行时信息，包装在placeElementAction里，用来生成tweenAction。
					var elementData:InstanceData = new InstanceData();
					elementData.InstanceID = layerInfo.instanceName;
					elementData.isPlaceElement = needUpdate;//用来优化输出
					if (needUpdate) {
						elementData.definitionID = characterID;
						elementData.defIndex = _elementPool.getIndexByCharacterId(characterID);
						elementData.depth = getDepth (depth, layerInfoArr, true);
						elementData.type = (_elementPool.getDefinitionByCharacterId (characterID)  is MovieClipData) ? "MC" : "SH";
						
						if (tagPlaceObject2.clipDepth > 0) {
							elementData.maskDepth = tagPlaceObject2.depth;
							elementData.clipDepth = tagPlaceObject2.clipDepth;
							clipDic[layerInfo.instanceName] = [tagPlaceObject2.depth, tagPlaceObject2.clipDepth]
						} else {
							for (var clipName : String in clipDic) {
								if(clipDic[clipName][0] > 0 && clipDic[clipName][1] > 0 && tagPlaceObject2.depth > clipDic[clipName][0] && tagPlaceObject2.depth <= clipDic[clipName][1]) {
									elementData.maskDepth = tagPlaceObject2.depth;
									break;
								}
							}
						}
					}
					
					//shape内容变化时colortansform如无变化不会更新，不考虑matrix（shape不能使用matrix）
					if (tagPlaceObject2.hasColorTransform) {
						elementData.colorTransform = tagPlaceObject2.colorTransform.colorTransform;
						layerInfo.lastColorTansform = elementData.colorTransform;
					} else {
						elementData.colorTransform = layerInfo.lastColorTansform;
					}
					elementData.alpha = elementData.colorTransform ? elementData.colorTransform.alphaMultiplier : 1;
					
					//lastMatrix保证每个place指令都有matrix信息，1是简化JS库的运行代码量，2是保证生成tweenAction时的位置信息是正确的
					if (tagPlaceObject2.hasMatrix) {
						elementData.matrix = tagPlaceObject2.matrix.matrix;
						elementData.matrix.tx *= 0.05;
						elementData.matrix.ty *= 0.05;
						layerInfo.lastMatrix = elementData.matrix;
					} else {
						elementData.matrix = layerInfo.lastMatrix;
					}
					elementData.x = elementData.matrix.tx;
					elementData.y = elementData.matrix.ty;
					elementData.scaleX = MatrixTransformer.getScaleX(elementData.matrix);
					elementData.scaleY = MatrixTransformer.getScaleY(elementData.matrix);
					elementData.skewX = MatrixTransformer.getSkewX(elementData.matrix);
					elementData.skewY = MatrixTransformer.getSkewY(elementData.matrix);
					
					if (tag is TagPlaceObject3) {
						tagPlaceObject3 = tag as TagPlaceObject3;
						if (tagPlaceObject3.hasCacheAsBitmap) {
							elementData.cacheAsBitmap = true;
						}
						if (tagPlaceObject3.hasFilterList) {
							elementData.filters = getFilters(tagPlaceObject3.surfaceFilterList);
						}
					}
					action = new PlaceElementAction (elementData);
					if (!layerInfo.actions[nowFrame]) {
						layerInfo.actions[nowFrame] = new Vector.<BaseFrameAction>();
					}
					(layerInfo.actions[nowFrame] as Vector.<BaseFrameAction>).push(action);
				} else if (tag is TagShowFrame) {
					nowFrame++;
				} else if (tag is TagEnd) {
					for (var j:int=0; j<layerInfoArr.length; j++) {
						layerInfo = layerInfoArr[j] as LayerInfo;
						if (layerInfo && layerInfo.hasContent) {
							addTweenAction(layerInfo);
						}
					}
				}
			}
			
			var actions : Array;
			var actArray : Vector.<BaseFrameAction>;
			for (i=0; i<nowFrame; i++) {
				for (j=0; j<layerInfoArr.length; j++) {
					layerInfo = layerInfoArr[j];
					actions = layerInfo.actions;
					actArray = actions[i];
					addAction(finalActions, i, actArray);
				}
			}
			return {"totalFrame":nowFrame, "actions":finalActions, "rect":getRect(finalActions)};
		}
		
		private function addTweenAction (layerInfo : LayerInfo) : void {
			var actions : Array = layerInfo.actions;
			var lastKeyFrame : int = layerInfo.lastKeyFrame;
			var needNewKeyFrame : Boolean = false;
			var action : BaseFrameAction;
			
			var preTween : TweenData;
			var nextTween : TweenData;
			for (var i:int=lastKeyFrame + 1; i<actions.length; i++) {
				action = actions[i]?actions[i][0]:null;
				if (!action) {
					preTween = null;
					needNewKeyFrame = true;
					continue;
				}
				//初次出现非空action，或
				if (needNewKeyFrame) {
					preTween = null;
					lastKeyFrame = i;
					needNewKeyFrame = false;
					continue;
				}
				//多次出现非空action，或
				if (!preTween) {
					preTween = TweenData.getTweenData((actions[i-1][0] as PlaceElementAction).instanceData, (actions[i][0] as PlaceElementAction).instanceData);
				}
				//与之前不同filter，不同的filter就是不同的tween
				if (preTween.diffFilter) {
					preTween = null;
					lastKeyFrame = i;
					continue;
				}
				//与pre相同filter了，比较next
				if (i+1 < actions.length && actions[i+1] != null && actions[i+1][0] != null) {
					nextTween = TweenData.getTweenData((actions[i][0] as PlaceElementAction).instanceData, (actions[i+1][0] as PlaceElementAction).instanceData);
					if (nextTween.diffFilter || !TweenData.sameTween(preTween, nextTween)) {
						if (i > lastKeyFrame + 2) {
							getTweenAction (actions, lastKeyFrame, i, preTween);
						}
						lastKeyFrame = i;
					}
					preTween = nextTween;
				} else {
					if (i > lastKeyFrame + 2) {
						getTweenAction (actions, lastKeyFrame, i, preTween);
					}
					//结尾或空白
					needNewKeyFrame = true;
				}
			}
			function getTweenAction (actions : Array, lastKeyFrame : int, currentkeyFrame : int, tweenData : TweenData) : void {
				for (var j:int=lastKeyFrame + 1; j<currentkeyFrame; j++) {
					if (j == (currentkeyFrame - 1)) {
						(actions[lastKeyFrame] as Vector.<BaseFrameAction>).push(new TweenAction(
							((actions[j] as Vector.<BaseFrameAction>)[0] as PlaceElementAction).instanceData, tweenData, (currentkeyFrame - lastKeyFrame - 1)));
					}
					actions[j] = null;
				}
			}
		}
		
		//公用方法，插入layerinfo（getRealDepth false）和获取元件真实深度时使用（getRealDepth true）
		private function getDepth (depth : int, layerInfoArr : Array, getRealDepth : Boolean) : int {
			var realDepth : int = 0;
			for (var i:int=0; i<layerInfoArr.length; i++) {
				if (getRealDepth && !(layerInfoArr[i] as LayerInfo).hasContent) {
					continue;
				}
				//等于是因为在计算实际层深的时候，自己的layerInfo已经在数组里了
				if (depth <= (layerInfoArr[i] as LayerInfo).depth) {
					return realDepth;
				}
				realDepth++;
			}
			return realDepth;
		}
		
		//查找layerInfo，还没有的返回null
		private function getLayerInfo (depth : int, layerInfoArr : Array) : LayerInfo {
			for (var i:int=0; i<layerInfoArr.length; i++) {
				if ((layerInfoArr[i] as LayerInfo).depth == depth) {
					return layerInfoArr[i];
				}
			}
			return null;
		}
		
		/**
		 * 向vector非顺序插入数据的方法
		 * @param actionlist
		 * @param index
		 * @param action
		 */		
		private function addAction (actionlist : Vector.<Vector.<BaseFrameAction>>, index : int, insertObj : Object) : void {
			if (!insertObj) 
				return;
			if (index >= actionlist.length) {
				for (var i : int = actionlist.length; i <= index; i++){
					actionlist.push(new Vector.<BaseFrameAction>());
				}
			}
			if (insertObj is Vector.<BaseFrameAction>) {
				actionlist[index] = actionlist[index].concat(insertObj);
			} else {
				actionlist[index].push(insertObj);
			}
		}
		
		private function getFilters(filters : Vector.<IFilter>) : Array {
			var filter : Filter;
			var finalFilters : Array = [];
			var rawFilter : BitmapFilter;
			for (var i:int=0;i<filters.length;i++) {
				filter = filters[i] as Filter;
				if (filter is FilterBlur) {
					rawFilter = (filter as FilterBlur).filter;
				} else if (filter is FilterColorMatrix) {
					rawFilter = (filter as FilterColorMatrix).filter;
				} else if (filter is FilterDropShadow) {
					rawFilter = (filter as FilterDropShadow).filter;
				} else if (filter is FilterGlow) {
					rawFilter = (filter as FilterGlow).filter;
				}
				finalFilters.push(rawFilter);
			}
			return finalFilters;
		}
		
		private function getRect (finalAction : Vector.<Vector.<BaseFrameAction>>) : Rectangle {
			var rect : Rectangle = new Rectangle(0,0,0,0);
			var actions : Vector.<BaseFrameAction>;
			if (finalAction.length > 0 && finalAction[0] != null) {
				actions = finalAction[0];
			} else {
				return rect;
			}
			
			var sp : Sprite = new Sprite();
			var sh : Shape;
			var instanceData : InstanceData;
			for (var i:int=0;i<actions.length;i++) {
				if (actions[i] is PlaceElementAction) {
					instanceData = (actions[i] as PlaceElementAction).instanceData;
					if (!(instanceData.maskDepth > 0 && instanceData.clipDepth == 0) && _elementPool.getDefinitionByCharacterId(instanceData.definitionID)) {
						rect = _elementPool.getDefinitionByCharacterId(instanceData.definitionID).rect;
						sh = new Shape();
						sh.graphics.beginFill(0x0, 1);
						sh.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
						sh.transform.matrix = instanceData.matrix;
						sp.addChild(sh);
					}
				}
			}
			return sp.getRect(sp);
		}
		
	}
}
import flash.geom.ColorTransform;
import flash.geom.Matrix;

internal class LayerInfo {
	public var instanceName : String;
	public var depth : int;
	public var characterID : int;
	public var hasContent : Boolean;
	public var lastKeyFrame : int;
	public var actions : Array;
	public var lastMatrix : Matrix;
	public var lastColorTansform : ColorTransform;
}
