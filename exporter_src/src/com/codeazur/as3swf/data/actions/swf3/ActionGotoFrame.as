package com.codeazur.as3swf.data.actions.swf3
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.actions.*;
	
	public class ActionGotoFrame extends Action implements IAction
	{
		public static const CODE:uint = 0x81;
		
		public var frame:uint;
		
		public function ActionGotoFrame(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function parse(data:SWFData):void {
			frame = data.readUI16();
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			body.writeUI16(frame);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionGotoFrame = new ActionGotoFrame(code, length, pos);
			action.frame = frame;
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionGotoFrame] Frame: " + frame;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "gotoFrame " + frame;
		}
	}
}
