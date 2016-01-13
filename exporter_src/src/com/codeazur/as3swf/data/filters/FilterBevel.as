package com.codeazur.as3swf.data.filters
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.utils.ColorUtils;

	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterType;
	
	public class FilterBevel extends Filter implements IFilter
	{
		public var shadowColor:uint;
		public var highlightColor:uint;
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
		
		public function FilterBevel(id:uint) {
			super(id);
		}
		
		override public function get filter():BitmapFilter {
			var filterType:String;
			if(onTop) {
				filterType = BitmapFilterType.FULL;
			} else {
				filterType = (innerShadow) ? BitmapFilterType.INNER : BitmapFilterType.OUTER;
			}
			return new BevelFilter(
				distance,
				angle * 180 / Math.PI,
				ColorUtils.rgb(highlightColor),
				ColorUtils.alpha(highlightColor),
				ColorUtils.rgb(shadowColor),
				ColorUtils.alpha(shadowColor),
				blurX,
				blurY,
				strength,
				passes,
				filterType,
				knockout
			);
		}
		
		override public function parse(data:SWFData):void {
			shadowColor = data.readRGBA();
			highlightColor = data.readRGBA();
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
			data.writeRGBA(shadowColor);
			data.writeRGBA(highlightColor);
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
			var filter:FilterBevel = new FilterBevel(id);
			filter.shadowColor = shadowColor;
			filter.highlightColor = highlightColor;
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
			var str:String = "[BevelFilter] " +
				"ShadowColor: " + ColorUtils.rgbToString(shadowColor) + ", " +
				"HighlightColor: " + ColorUtils.rgbToString(highlightColor) + ", " +
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
			return str;
		}
	}
}
