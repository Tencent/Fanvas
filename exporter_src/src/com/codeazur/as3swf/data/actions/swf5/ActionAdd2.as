package com.codeazur.as3swf.data.actions.swf5
{
	import com.codeazur.as3swf.data.actions.*;
	
	public class ActionAdd2 extends Action implements IAction
	{
		public static const CODE:uint = 0x47;
		
		public function ActionAdd2(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionAdd2]";
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "add2";
		}
	}
}
