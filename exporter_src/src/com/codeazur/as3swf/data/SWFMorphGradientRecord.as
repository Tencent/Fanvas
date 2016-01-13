package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.utils.ColorUtils;
	
	public class SWFMorphGradientRecord
	{
		public var startRatio:uint;
		public var startColor:uint;
		public var endRatio:uint;
		public var endColor:uint;
		
		public function SWFMorphGradientRecord(data:SWFData = null) {
			if (data != null) {
				parse(data);
			}
		}
		
		public function parse(data:SWFData):void {
			startRatio = data.readUI8();
			startColor = data.readRGBA();
			endRatio = data.readUI8();
			endColor = data.readRGBA();
		}
		
		public function publish(data:SWFData):void {
			data.writeUI8(startRatio);
			data.writeRGBA(startColor);
			data.writeUI8(endRatio);
			data.writeRGBA(endColor);
		}
		
		public function getMorphedGradientRecord(ratio:Number = 0):SWFGradientRecord {
			var gradientRecord:SWFGradientRecord = new SWFGradientRecord();
			gradientRecord.color = ColorUtils.interpolate(startColor, endColor, ratio);
			gradientRecord.ratio = startRatio + (endRatio - startRatio) * ratio;
			return gradientRecord;
		}
		
		public function toString():String {
			return "[" + startRatio + "," + ColorUtils.rgbaToString(startColor) + "," + endRatio + "," + ColorUtils.rgbaToString(endColor) + "]";
		}
	}
}
