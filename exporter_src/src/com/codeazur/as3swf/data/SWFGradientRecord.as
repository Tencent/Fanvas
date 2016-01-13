package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.utils.ColorUtils;
	
	public class SWFGradientRecord
	{
		public var ratio:uint;
		public var color:uint;
		
		protected var _level:uint;
		
		public function SWFGradientRecord(data:SWFData = null, level:uint = 1) {
			if (data != null) {
				parse(data, level);
			}
		}
		
		public function parse(data:SWFData, level:uint):void {
			_level = level;
			ratio = data.readUI8();
			color = (level <= 2) ? data.readRGB() : data.readRGBA();
		}
		
		public function publish(data:SWFData, level:uint):void {
			data.writeUI8(ratio);
			if(level <= 2) {
				data.writeRGB(color);
			} else {
				data.writeRGBA(color);
			}
		}
		
		public function clone():SWFGradientRecord {
			var gradientRecord:SWFGradientRecord = new SWFGradientRecord();
			gradientRecord.ratio = ratio;
			gradientRecord.color = color;
			return gradientRecord;
		}
		
		public function toString():String {
			return "[" + ratio + "," + ((_level <= 2) ? ColorUtils.rgbToString(color) : ColorUtils.rgbaToString(color)) + "]";
		}
	}
}
