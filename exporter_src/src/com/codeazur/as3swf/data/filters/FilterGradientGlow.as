package com.codeazur.as3swf.data.filters
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.utils.ColorUtils;
	import com.codeazur.utils.StringUtils;

	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientGlowFilter;
	
	public class FilterGradientGlow extends Filter implements IFilter
	{
		public var numColors:uint;
		public var blurX:Number;
		public var blurY:Number;
		public var angle:Number;
		public var distance:Number;
		public var strength:Number;
		public var innerShadow:Boolean;
		public var knockout:Boolean;
		public var compositeSource:Boolean;
		public var onTop:Boolean;
		public var passes:uint;
		
		protected var _gradientColors:Vector.<uint>;
		protected var _gradientRatios:Vector.<uint>;
		
		public function FilterGradientGlow(id:uint) {
			super(id);
			_gradientColors = new Vector.<uint>();
			_gradientRatios = new Vector.<uint>();
		}
		
		public function get gradientColors():Vector.<uint> { return _gradientColors; }
		public function get gradientRatios():Vector.<uint> { return _gradientRatios; }
		
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
			return new GradientGlowFilter(
				distance,
				angle * 180 / Math.PI,
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
		
		override public function parse(data:SWFData):void {
			numColors = data.readUI8();
			var i:uint;
			for (i = 0; i < numColors; i++) {
				_gradientColors.push(data.readRGBA());
			}
			for (i = 0; i < numColors; i++) {
				_gradientRatios.push(data.readUI8());
			}
			blurX = data.readFIXED();
			blurY = data.readFIXED();
			angle = data.readFIXED();
			distance = data.readFIXED();
			strength = data.readFIXED8();
			var flags:uint = data.readUI8();
			innerShadow = ((flags & 0x80) != 0);
			knockout = ((flags & 0x40) != 0);
			compositeSource = ((flags & 0x20) != 0);
			onTop = ((flags & 0x10) != 0);
			passes = flags & 0x0f;
		}
		
		override public function publish(data:SWFData):void {
			data.writeUI8(numColors);
			var i:uint;
			for (i = 0; i < numColors; i++) {
				data.writeRGBA(gradientColors[i]);
			}
			for (i = 0; i < numColors; i++) {
				data.writeUI8(gradientRatios[i]);
			}
			data.writeFIXED(blurX);
			data.writeFIXED(blurY);
			data.writeFIXED(angle);
			data.writeFIXED(distance);
			data.writeFIXED8(strength);
			var flags:uint = (passes & 0x0f);
			if(innerShadow) { flags |= 0x80; }
			if(knockout) { flags |= 0x40; }
			if(compositeSource) { flags |= 0x20; }
			if(onTop) { flags |= 0x10; }
			data.writeUI8(flags);
		}
		
		override public function clone():IFilter {
			var filter:FilterGradientGlow = new FilterGradientGlow(id);
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
		
		override public function toString(indent:uint = 0):String {
			var i:uint;
			var str:String = "[" + filterName + "] " +
				"BlurX: " + blurX + ", " +
				"BlurY: " + blurY + ", " +
				"Angle: " + angle + ", " +
				"Distance: " + distance + ", " +
				"Strength: " + strength + ", " +
				"Passes: " + passes;
			var flags:Array = [];
			if(innerShadow) { flags.push("InnerShadow"); }
			if(knockout) { flags.push("Knockout"); }
			if(compositeSource) { flags.push("CompositeSource"); }
			if(onTop) { flags.push("OnTop"); }
			if(flags.length > 0) {
				str += ", Flags: " + flags.join(", ");
			}
			if(gradientColors.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "GradientColors:";
				for(i = 0; i < gradientColors.length; i++) {
					str += ((i > 0) ? ", " : " ") + ColorUtils.rgbToString(gradientColors[i]);
				}
			}
			if(gradientRatios.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "GradientRatios:";
				for(i = 0; i < gradientRatios.length; i++) {
					str += ((i > 0) ? ", " : " ") + gradientRatios[i];
				}
			}
			return str;
		}
		
		protected function get filterName():String { return "GradientGlowFilter"; }
	}
}
