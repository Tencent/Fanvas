package com.codeazur.as3swf.data.filters
{
	import com.codeazur.as3swf.utils.ColorUtils;

	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientBevelFilter;
	
	public class FilterGradientBevel extends FilterGradientGlow implements IFilter
	{
		public function FilterGradientBevel(id:uint) {
			super(id);
		}
		
		override public function get filter():BitmapFilter {
			var gradientGlowColors:Array = [];
			var gradientGlowAlphas:Array = [];
			var gradientGlowRatios:Array = [];
			for (var i:int = 0; i < numColors; i++) {
				gradientGlowColors.push(ColorUtils.rgb(gradientColors[i]));
				gradientGlowAlphas.push(ColorUtils.alpha(gradientColors[i]));
				gradientGlowRatios.push(gradientRatios[i]);
			}
			var filterType:String;
			if(onTop) {
				filterType = BitmapFilterType.FULL;
			} else {
				filterType = (innerShadow) ? BitmapFilterType.INNER : BitmapFilterType.OUTER;
			}
			return new GradientBevelFilter(
				distance,
				angle,
				gradientGlowColors,
				gradientGlowAlphas,
				gradientGlowRatios,
				blurX,
				blurY,
				strength,
				passes,
				filterType,
				knockout
			);
		}
		
		override public function clone():IFilter {
			var filter:FilterGradientBevel = new FilterGradientBevel(id);
			filter.numColors = numColors;
			var i:uint;
			for (i = 0; i < numColors; i++) {
				filter.gradientColors.push(gradientColors[i]);
			}
			for (i = 0; i < numColors; i++) {
				filter.gradientRatios.push(gradientRatios[i]);
			}
			filter.blurX = blurX;
			filter.blurY = blurY;
			filter.angle = angle;
			filter.distance = distance;
			filter.strength = strength;
			filter.passes = passes;
			filter.innerShadow = innerShadow;
			filter.knockout = knockout;
			filter.compositeSource = compositeSource;
			filter.onTop = onTop;
			return filter;
		}
		
		override protected function get filterName():String { return "GradientBevelFilter"; }
	}
}
