package com.codeazur.as3swf.data.actions.swf4
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.actions.*;
	
	public class ActionWaitForFrame2 extends Action implements IAction
	{
		public static const CODE:uint = 0x8d;
		
		public var skipCount:uint;
		
		public function ActionWaitForFrame2(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function parse(data:SWFData):void {
			skipCount = data.readUI8();
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			body.writeUI8(skipCount);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionWaitForFrame2 = new ActionWaitForFrame2(code, length, pos);
			action.skipCount = skipCount;
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionWaitForFrame2] SkipCount: " + skipCount;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "waitForFrame2 (" + skipCount + ")";
		}
	}
}
