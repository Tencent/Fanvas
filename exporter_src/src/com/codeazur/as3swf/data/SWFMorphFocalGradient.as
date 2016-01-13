package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFMorphFocalGradient extends SWFMorphGradient
	{
		public function SWFMorphFocalGradient(data:SWFData = null, level:uint = 1) {
			super(data, level);
		}
		
		override public function parse(data:SWFData, level:uint):void {
			super.parse(data, level);
			startFocalPoint = data.readFIXED8();
			endFocalPoint = data.readFIXED8();
		}
		
		override public function publish(data:SWFData, level:uint):void {
			super.publish(data, level);
			data.writeFIXED8(startFocalPoint);
			data.writeFIXED8(endFocalPoint);
		}
		
		override public function getMorphedGradient(ratio:Number = 0):SWFGradient {
			var gradient:SWFGradient = new SWFGradient();
			// TODO: focalPoint
			for(var i:uint = 0; i < records.length; i++) {
				gradient.records.push(records[i].getMorphedGradientRecord(ratio)); 
			}
			return gradient;
		}
		
		override public function toString():String {
			return "FocalPoint: " + startFocalPoint + "," + endFocalPoint + " (" + _records.join(",") + ")";
		}
	}
}
