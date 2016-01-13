package com.codeazur.as3swf.data.filters
{
	import com.codeazur.as3swf.SWFData;

	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	
	public class FilterBlur extends Filter implements IFilter
	{
		public var blurX:Number;
		public var blurY:Number;
		public var passes:uint;
		
		public function FilterBlur(id:uint) {
			super(id);
		}
		
		override public function get filter():BitmapFilter {
			return new BlurFilter(
				blurX,
				blurY,
				passes
			);
		}
		
		override public function parse(data:SWFData):void {
			blurX = data.readFIXED();
			blurY = data.readFIXED();
			passes = data.readUI8() >> 3;
		}
		
		override public function publish(data:SWFData):void {
			data.writeFIXED(blurX);
			data.writeFIXED(blurY);
			data.writeUI8(passes << 3);
		}
		
		override public function clone():IFilter {
			var filter:FilterBlur = new FilterBlur(id);
			filter.blurX = blurX;
			filter.blurY = blurY;
			filter.passes = passes;
			return filter;
		}
		
		override public function toString(indent:uint = 0):String {
			return "[BlurFilter] " +
				"BlurX: " + blurX + ", " +
				"BlurY: " + blurY + ", " +
				"Passes: " + passes;
		}
	}
}
