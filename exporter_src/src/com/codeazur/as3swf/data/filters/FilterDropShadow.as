package com.codeazur.as3swf.data.filters
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.utils.ColorUtils;

	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	
	public class FilterDropShadow extends Filter implements IFilter
	{
		public var dropShadowColor:uint;
		public var blurX:Number;
		public var blurY:Number;
		public var angle:Number;
		public var distance:Number;
		public var strength:Number;
		public var innerShadow:Boolean;
		public var knockout:Boolean;
		public var compositeSource:Boolean;
		public var passes:uint;
		
		public function FilterDropShadow(id:uint) {
			super(id);
		}
		
		override public function get filter():BitmapFilter {
			return new DropShadowFilter(
				distance,
				angle * 180 / Math.PI,
				ColorUtils.rgb(dropShadowColor),
				ColorUtils.alpha(dropShadowColor),
				blurX,
				blurY,
				strength,
				passes,
				innerShadow,
				knockout
			);
		}
		
		override public function parse(data:SWFData):void {
			dropShadowColor = data.readRGBA();
			blurX = data.readFIXED();
			blurY = data.readFIXED();
			angle = data.readFIXED();
			distance = data.readFIXED();
			strength = data.readFIXED8();
			var flags:uint = data.readUI8();
			innerShadow = ((flags & 0x80) != 0);
			knockout = ((flags & 0x40) != 0);
			compositeSource = ((flags & 0x20) != 0);
			passes = flags & 0x1f;
		}
		
		override public function publish(data:SWFData):void {
			data.writeRGBA(dropShadowColor);
			data.writeFIXED(blurX);
			data.writeFIXED(blurY);
			data.writeFIXED(angle);
			data.writeFIXED(distance);
			data.writeFIXED8(strength);
			var flags:uint = (passes & 0x1f);
			if(innerShadow) { flags |= 0x80; }
			if(knockout) { flags |= 0x40; }
			if(compositeSource) { flags |= 0x20; }
			data.writeUI8(flags);
		}
		
		override public function clone():IFilter {
			var filter:FilterDropShadow = new FilterDropShadow(id);
			filter.dropShadowColor = dropShadowColor;
			filter.blurX = blurX;
			filter.blurY = blurY;
			filter.angle = angle;
			filter.distance = distance;
			filter.strength = strength;
			filter.passes = passes;
			filter.innerShadow = innerShadow;
			filter.knockout = knockout;
			filter.compositeSource = compositeSource;
			return filter;
		}
		
		override public function toString(indent:uint = 0):String {
			var str:String = "[DropShadowFilter] " +
				"DropShadowColor: " + ColorUtils.rgbToString(dropShadowColor) + ", " +
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
			if(flags.length > 0) {
				str += ", Flags: " + flags.join(", ");
			}
			return str;
		}
	}
}
