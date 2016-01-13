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
package exporters.JSExporter {
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	
	import model.InstanceData;
	import model.MovieClipData;
	import model.TweenData;
	import model.frameAction.BaseFrameAction;
	import model.frameAction.PlaceElementAction;
	import model.frameAction.RemoveElementAction;
	import model.frameAction.TweenAction;

	public class MovieClipExporter {
		public function MovieClipExporter() {
		}
		
		public static function export (mcData : MovieClipData) : Object {
			var mcObj : Object;
			var actions : Array = [];
			mcObj = {"totalFrames":mcData.totalFrames, "frameActionList":actions};
			
			var actionsFramesRaw : Vector.<Vector.<BaseFrameAction>> = mcData.frameActionList;
			var actionsRaw : Vector.<BaseFrameAction>;
			var actionRaw : BaseFrameAction;
			for (var i : int = 0; i < actionsFramesRaw.length; i++) {
				actionsRaw = actionsFramesRaw[i];
				if (actionsRaw.length > 0) {
					for (var j : int = 0; j < actionsRaw.length; j++) {
						actionRaw = actionsRaw[j];
						if (actions.length == 0 || actions[actions.length - 1][0] != i) {
							actions.push([i]);
						}
						actions[actions.length - 1].push(exportAction(actionsRaw[j]));
					}
				}
			}
			return mcObj;
		}
		
		private static function exportAction (action : BaseFrameAction) : Array {
			if (action is PlaceElementAction) {
				return ["pE", exportPlaceElementAc(action as PlaceElementAction)];
			} else if (action is TweenAction) {
				return ["tE", (action as TweenAction).instanceData.InstanceID, (action as TweenAction).duration, exportTweenData(action as TweenAction)];
			} else if (action is RemoveElementAction) {
				return ["rE", (action as RemoveElementAction).instanceID];
			}
			return [];
		}
		
		private static function exportTweenData (action : TweenAction) : Object {
			var tweenData : TweenData = action.tweenData;
			var instanceData : InstanceData = action.instanceData;
			var tweenObj : Object = {};
			if (tweenData.x != 0) {
				tweenObj.x = JSUtil.toPrecision(instanceData.x, 1);
			}
			if (tweenData.y != 0) {
				tweenObj.y = JSUtil.toPrecision(instanceData.y, 1);
			}
			if (tweenData.skewX != 0) {
				tweenObj.skewX = JSUtil.toPrecision(instanceData.skewX, 2);
			}
			if (tweenData.skewY != 0) {
				tweenObj.skewY = JSUtil.toPrecision(instanceData.skewY, 2);
			}
			if (tweenData.alpha != 1) {
				tweenObj.alpha = JSUtil.toPrecision(instanceData.alpha, 2);
			}
			if (tweenData.scaleX != 1) {
				tweenObj.scaleX = JSUtil.toPrecision(instanceData.scaleX, 2);
			}
			if (tweenData.scaleY != 1) {
				tweenObj.scaleY = JSUtil.toPrecision(instanceData.scaleY, 2);
			}
			return tweenObj;
		}
		
		private static function exportPlaceElementAc (action : PlaceElementAction) : Object {
			var instanceObj : Object = {};
			var instanceData : InstanceData = action.instanceData;
			instanceObj.n = instanceData.InstanceID;
			if (instanceData.isPlaceElement) {
				instanceObj.id = instanceData.defIndex;
				instanceObj.t = instanceData.type;
				instanceObj.d = instanceData.depth;
			}
			if (instanceData.matrix && instanceData.x != 0) {
				instanceObj.x = JSUtil.toPrecision(instanceData.x, 1);
			}
			if (instanceData.matrix && instanceData.y != 0) {
				instanceObj.y = JSUtil.toPrecision(instanceData.y, 1);
			}
			if (instanceData.matrix && instanceData.skewX != 0) {
				instanceObj.skX = JSUtil.toPrecision(instanceData.skewX, 2);
			}
			if (instanceData.matrix && instanceData.skewY != 0) {
				instanceObj.skY = JSUtil.toPrecision(instanceData.skewY, 2);
			}
			if (instanceData.matrix && instanceData.scaleX != 1) {
				instanceObj.sX = JSUtil.toPrecision(instanceData.scaleX, 2);
			}
			if (instanceData.matrix && instanceData.scaleY != 1) {
				instanceObj.sY = JSUtil.toPrecision(instanceData.scaleY, 2);
			}
			if (instanceData.alpha != 1) {
				instanceObj.a = JSUtil.toPrecision(instanceData.alpha, 2);
			}
			if (instanceData.maskDepth > 0) {
				instanceObj.md = instanceData.maskDepth;
			}
			if (instanceData.clipDepth > 0) {
				instanceObj.cd = instanceData.clipDepth;
			}
			
			exportFilters (instanceObj, instanceData);
			return instanceObj;
		}
		
		private static function exportFilters (instanceObj : Object, instanceData : InstanceData) : void {
			if (instanceData.colorTransform) {
				var colorTransform : ColorTransform = instanceData.colorTransform;
				var matrixStr : String = colorTransform.redMultiplier+"_"+colorTransform.greenMultiplier+"_"+colorTransform.blueMultiplier+"_"+
					colorTransform.redOffset+"_"+colorTransform.greenOffset+"_"+colorTransform.blueOffset+"_"+colorTransform.alphaOffset;
				if (matrixStr != "1_1_1_0_0_0_0") {
					var tranceForm : Object = {};
					tranceForm.data = [JSUtil.toPrecision(colorTransform.redMultiplier, 2), JSUtil.toPrecision(colorTransform.greenMultiplier, 2), 
						JSUtil.toPrecision(colorTransform.blueMultiplier, 2), JSUtil.toPrecision(colorTransform.alphaMultiplier, 2), 
						JSUtil.toPrecision(colorTransform.redOffset, 1), JSUtil.toPrecision(colorTransform.greenOffset, 1), 
						JSUtil.toPrecision(colorTransform.blueOffset, 1), JSUtil.toPrecision(colorTransform.alphaOffset, 1)];
					tranceForm.type = "CF";
					pushFilter (tranceForm, instanceObj);
				}
			}
			var rawFilters : Array = instanceData.filters;
			if (!rawFilters) 
				return;
			var filterObj : Object;
			for (var i : int = 0; i < rawFilters.length; i++) {
				filterObj = {};
				if (rawFilters[i] is GlowFilter) {
					var glowFilterRaw : GlowFilter = rawFilters[i] as GlowFilter;
					filterObj.color = JSUtil.getJSColor(glowFilterRaw.color, glowFilterRaw.alpha);
					filterObj.blur = JSUtil.toPrecision(0.5*(glowFilterRaw.blurX + glowFilterRaw.blurY), 1);
					instanceObj.shadow = filterObj;
				} else if (rawFilters[i] is DropShadowFilter) {
					var dropShadowFilterRaw : DropShadowFilter = rawFilters[i] as DropShadowFilter;
					filterObj.color = JSUtil.getJSColor(dropShadowFilterRaw.color, dropShadowFilterRaw.alpha);
					filterObj.blur = JSUtil.toPrecision(0.5*(dropShadowFilterRaw.blurX + dropShadowFilterRaw.blurY), 1);
					filterObj.offsetX = JSUtil.toPrecision(dropShadowFilterRaw.distance * Math.cos(dropShadowFilterRaw.angle * Math.PI / 180), 1);
					filterObj.offsetY = JSUtil.toPrecision(dropShadowFilterRaw.distance * Math.sin(dropShadowFilterRaw.angle * Math.PI / 180), 1);
					instanceObj.shadow = filterObj;
				} else if (rawFilters[i] is BlurFilter) {
					var blurFilterRaw : BlurFilter = rawFilters[i] as BlurFilter;
					filterObj.quality = JSUtil.toPrecision(blurFilterRaw.quality, 1);
					filterObj.blurX = JSUtil.toPrecision(blurFilterRaw.blurX, 1);
					filterObj.blurY = JSUtil.toPrecision(blurFilterRaw.blurY, 1);
					filterObj.type = "BF";
					pushFilter (filterObj, instanceObj);
				} else if (rawFilters[i] is ColorMatrixFilter) {
					var colorMatrixFilterRaw : ColorMatrixFilter = rawFilters[i] as ColorMatrixFilter;
					filterObj.matrix = colorMatrixFilterRaw.matrix;
					filterObj.type = "CMF";
					pushFilter (filterObj, instanceObj);
				}
			}
			function pushFilter (filter : Object, instance : Object) : void {
				if (!instance.filters) {
					instance.filters = [];
				}
				(instance.filters as Array).push(filter);
			}
		}
		
	}
}