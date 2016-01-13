package com.codeazur.as3swf.data.actions
{
	import com.codeazur.as3swf.SWFData;
	
	public class ActionUnknown extends Action implements IAction
	{
		public function ActionUnknown(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function parse(data:SWFData):void {
			if (_length > 0) {
				data.skipBytes(_length);
			}
		}
		
		override public function toString(indent:uint = 0):String {
			return "[????] Code: " + _code.toString(16) + ", Length: " + _length;
		}
	}
}
