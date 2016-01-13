package com.codeazur.as3swf.data.actions.swf4
{
	import com.codeazur.as3swf.data.actions.*;
	
	public class ActionMBStringExtract extends Action implements IAction
	{
		public static const CODE:uint = 0x35;
		
		public function ActionMBStringExtract(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionMBStringExtract]";
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "mbStringExtract";
		}
	}
}
