package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFRegisterParam
	{
		public var register:uint;
		public var name:String;
		
		public function SWFRegisterParam(data:SWFData = null) {
			if (data != null) {
				parse(data);
			}
		}

		public function parse(data:SWFData):void {
			register = data.readUI8();
			name = data.readString();
		}
		
		public function publish(data:SWFData):void {
			data.writeUI8(register);
			data.writeString(name);
		}
		
		public function toString():String {
			return "$" + register + ":" + name;
		}
	}
}
