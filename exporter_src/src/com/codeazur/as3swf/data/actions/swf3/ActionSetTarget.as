package com.codeazur.as3swf.data.actions.swf3
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.actions.*;
	
	public class ActionSetTarget extends Action implements IAction
	{
		public static const CODE:uint = 0x8b;
		
		public var targetName:String;
		
		public function ActionSetTarget(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function parse(data:SWFData):void {
			targetName = data.readString();
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			body.writeString(targetName);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionSetTarget = new ActionSetTarget(code, length, pos);
			action.targetName = targetName;
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionSetTarget] TargetName: " + targetName;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "setTarget \"" + targetName + "\"";
		}
	}
}
