package com.codeazur.as3swf.data.actions.swf3
{
	import com.codeazur.as3swf.data.actions.*;
	import com.codeazur.as3swf.SWFData;
	
	public class ActionGotoLabel extends Action implements IAction
	{
		public static const CODE:uint = 0x8c;
		
		public var label:String;
		
		public function ActionGotoLabel(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function parse(data:SWFData):void {
			label = data.readString();
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			body.writeString(label);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionGotoLabel = new ActionGotoLabel(code, length, pos);
			action.label = label;
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionGotoLabel] Label: " + label;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "gotoLabel \"" + label + "\"";
		}
	}
}
