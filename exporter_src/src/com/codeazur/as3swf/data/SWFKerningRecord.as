package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFKerningRecord
	{
		public var code1:uint;
		public var code2:uint;
		public var adjustment:int;

		public function SWFKerningRecord(data:SWFData = null, wideCodes:Boolean = false) {
			if (data != null) {
				parse(data, wideCodes);
			}
		}

		public function parse(data:SWFData, wideCodes:Boolean):void {
			code1 = wideCodes ? data.readUI16() : data.readUI8();
			code2 = wideCodes ? data.readUI16() : data.readUI8();
			adjustment = data.readSI16();
		}
		
		public function publish(data:SWFData, wideCodes:Boolean):void {
			if(wideCodes) { data.writeUI16(code1); } else { data.writeUI8(code1); }
			if(wideCodes) { data.writeUI16(code2); } else { data.writeUI8(code2); }
			data.writeSI16(adjustment);
		}
		
		public function toString(indent:uint = 0):String {
			return "Code1: " + code1 + ", " + "Code2: " + code2 + ", " + "Adjustment: " + adjustment;
		}
	}
}
