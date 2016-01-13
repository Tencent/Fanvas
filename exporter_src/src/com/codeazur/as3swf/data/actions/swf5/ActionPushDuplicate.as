package com.codeazur.as3swf.data.actions.swf5
{
	import com.codeazur.as3swf.data.actions.*;
	
	public class ActionPushDuplicate extends Action implements IAction
	{
		public static const CODE:uint = 0x4c;
		
		public function ActionPushDuplicate(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionPushDuplicate]";
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "pushDuplicate";
		}
	}
}
