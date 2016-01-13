package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFZoneData
	{
		public var alignmentCoordinate:Number;
		public var range:Number;
		
		public function SWFZoneData(data:SWFData = null) {
			if (data != null) {
				parse(data);
			}
		}
		
		public function parse(data:SWFData):void {
			alignmentCoordinate = data.readFLOAT16();
			range = data.readFLOAT16();
		}
		
		public function publish(data:SWFData):void {
			data.writeFLOAT16(alignmentCoordinate);
			data.writeFLOAT16(range);
		}
		
		public function toString():String {
			return "(" + alignmentCoordinate + "," + range + ")";
		}
	}
}
