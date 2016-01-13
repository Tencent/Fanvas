package com.codeazur.as3swf.data.actions.swf3
{
	import com.codeazur.as3swf.data.actions.*;
	import com.codeazur.as3swf.SWFData;
	
	public class ActionPlay extends Action implements IAction
	{
		public static const CODE:uint = 0x06;
		
		public function ActionPlay(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionPlay]";
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "play";
		}
	}
}
