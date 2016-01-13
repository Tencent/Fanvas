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
package model {
	
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;

	public class TweenData {
		//所有属性为两帧之间的变化值，即x=dx，y=dy...
		public var hasTween : Boolean = false;
		public var diffFilter : Boolean = false;
		public var x : Number = 0;
		public var y : Number = 0;
		public var skewX : Number = 0;
		public var skewY : Number = 0;
		public var alpha : Number = 0;
		public var scaleX : Number = 0;
		public var scaleY : Number = 0;
		public var filters : Array;
		public var colorTransform : ColorTransform;
		
		public function TweenData() {
			
		}
		
		/**
		 * 生成TweenData，暂未处理filter
		 * @param lastInstanceData
		 * @param nowInstanceData
		 * @return 
		 */		
		public static function getTweenData (lastInstanceData : InstanceData, nowInstanceData : InstanceData) : TweenData {
			var tweenData : TweenData = new TweenData();
			if (Math.abs(nowInstanceData.x - lastInstanceData.x) >= 0.01) {
				tweenData.x = nowInstanceData.x - lastInstanceData.x;
				tweenData.hasTween = true;
			}
			if (Math.abs(nowInstanceData.y - lastInstanceData.y) >= 0.01) {
				tweenData.y = nowInstanceData.y - lastInstanceData.y;
				tweenData.hasTween = true;
			}
			if (Math.abs(nowInstanceData.skewX - lastInstanceData.skewX) >= 0.01) {
				tweenData.skewX = nowInstanceData.skewX - lastInstanceData.skewX;
				tweenData.hasTween = true;
			}
			if (Math.abs(nowInstanceData.skewY - lastInstanceData.skewY) >= 0.01) {
				tweenData.skewY = nowInstanceData.skewY - lastInstanceData.skewY;
				tweenData.hasTween = true;
			}
			if (Math.abs(nowInstanceData.alpha - lastInstanceData.alpha) >= 0.001) {
				tweenData.alpha = nowInstanceData.alpha - lastInstanceData.alpha;
				tweenData.hasTween = true;
			}
			if (Math.abs(nowInstanceData.scaleX - lastInstanceData.scaleX) >= 0.001) {
				tweenData.scaleX = nowInstanceData.scaleX - lastInstanceData.scaleX;
				tweenData.hasTween = true;
			}
			if (Math.abs(nowInstanceData.scaleY - lastInstanceData.scaleY) >= 0.001) {
				tweenData.scaleY = nowInstanceData.scaleY - lastInstanceData.scaleY;
				tweenData.hasTween = true;
			}
			//filter
			if (!sameFilter(lastInstanceData, nowInstanceData)) {
				tweenData.diffFilter = true;
				tweenData.hasTween = true;
			}
			return tweenData;
		}
		
		/**
		 * 判断是否同一Tween，精度控制
		 * @param lastTweenData
		 * @param nowTweenData
		 * @return 
		 */		
		public static function sameTween (lastTweenData : TweenData, nowTweenData : TweenData) : Boolean {
			if (!lastTweenData) {
				return false;
			}
			if (Math.abs(nowTweenData.x - lastTweenData.x) > 0.1) {
				return false;
			}
			if (Math.abs(nowTweenData.y - lastTweenData.y) > 0.1) {
				return false;
			}
			if (Math.abs(nowTweenData.skewX - lastTweenData.skewX) > 1) {
				return false;
			}
			if (Math.abs(nowTweenData.skewY - lastTweenData.skewY) > 1) {
				return false;
			}
			if (Math.abs(nowTweenData.alpha - lastTweenData.alpha) > 0.01) {
				return false;
			}
			if (Math.abs(nowTweenData.scaleX - lastTweenData.scaleX) > 0.01) {
				return false;
			}
			if (Math.abs(nowTweenData.scaleY - lastTweenData.scaleY) > 0.01) {
				return false;
			}
			return true;
		}
		
		private static function sameFilter (lastInstanceData : InstanceData, nowInstanceData : InstanceData) : Boolean {
			var lastColorTransform : String = getColorTarnsForm(lastInstanceData.colorTransform);
			var nowColorTransform : String = getColorTarnsForm(nowInstanceData.colorTransform);
			if (nowColorTransform != lastColorTransform) {
				return false;
			}
			
			var lastFilters : Array = sortFilters(lastInstanceData.filters);
			var nowFilters : Array = sortFilters(nowInstanceData.filters);
			if (!hasFilter(lastFilters, nowFilters)) {
				return false;
			}
			return true;
		}
		
		private static function hasFilter (rawArray : Array, targetArray : Array) : Boolean {
			var rawStr : String;
			var targetStr : String;
			var hasSameFilter : Boolean;
			for (var i : int = 0; i < rawArray.length; i++) {
				rawStr = rawArray[i];
				hasSameFilter = false;
				for (var j : int = 0; j < targetArray.length; j++) {
					targetStr =  targetArray[j];
					if (targetStr == rawStr) {
						targetArray.splice(j, 1);
						hasSameFilter = true;
						break;
					}
				}
				if (!hasSameFilter) {
					return false;
				}
			}
			if (targetArray.length > 0) 
				return false;
			return true;
		}
		
		private static function sortFilters (filters : Array) : Array {
			if (!filters) {
				return [];
			}
			var filterArray : Array = [];
			var filter : BitmapFilter;
			for (var i : int = 0; i < filters.length; i++) {
				filter = filters[i];
				if (filter is GlowFilter) {
					filterArray.push(getGlowFilter(filter as GlowFilter));
				} else if (filter is DropShadowFilter) {
					filterArray.push(getDropShadowFilter(filter as DropShadowFilter));
				} else if (filter is BlurFilter) {
					filterArray.push(getBlurFilter(filter as BlurFilter));
				} else if (filter is ColorMatrixFilter) {
					filterArray.push(getColorMatrixFilter(filter as ColorMatrixFilter));
				}
				
			}
			return filterArray;
		}
		
		private static function getDropShadowFilter (dropShadowFilter : DropShadowFilter) : String {
			var array : Array = ["DropShadowFilter", dropShadowFilter.alpha, dropShadowFilter.blurX, dropShadowFilter.blurY, dropShadowFilter.color,
				dropShadowFilter.inner, dropShadowFilter.knockout, dropShadowFilter.quality, dropShadowFilter.strength, dropShadowFilter.angle,
				dropShadowFilter.distance, dropShadowFilter.hideObject];
			return array.join("-");
		}
		
		private static function getGlowFilter (glowFilter : GlowFilter) : String {
			var array : Array = ["DropShadowFilter", glowFilter.alpha, glowFilter.blurX, glowFilter.blurY, glowFilter.color,
				glowFilter.inner, glowFilter.knockout, glowFilter.quality, glowFilter.strength, 0,
				0, false];
			return array.join("-");
		}
		
		private static function getBlurFilter (blurFilter : BlurFilter) : String {
			var array : Array = ["BlurFilter", blurFilter.blurX, blurFilter.blurY, blurFilter.quality];
			return array.join("-");
		}
		
		private static function getColorMatrixFilter (colorMatrixFilter : ColorMatrixFilter) : String {
			var array : Array = colorMatrixFilter.matrix;
			array.unshift("ColorMatrixFilter");
			return array.join("-");
		}
		
		private static function getColorTarnsForm (colorTransform : ColorTransform) : String {
			if (colorTransform) {
				//专门去掉alphamultiplier，和alpha属性重复了
				var array : Array = ["ColorTransform", colorTransform.color, colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, 
					colorTransform.redOffset, colorTransform.greenOffset, colorTransform.blueOffset, colorTransform.alphaOffset];
				return array.join("-");
			} else {
				return "";
			}
		}
		
	}
}