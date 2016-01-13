package com.codeazur.as3swf.data.actions.swf6
{
	import com.codeazur.as3swf.data.actions.*;
	
	public class ActionEnumerate2 extends Action implements IAction
	{
		public static const CODE:uint = 0x55;
		
		public function ActionEnumerate2(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionEnumerate2]";
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "enumerate2";
		}
	}
}
