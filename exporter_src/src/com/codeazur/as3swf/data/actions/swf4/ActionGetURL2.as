package com.codeazur.as3swf.data.actions.swf4
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.actions.*;
	
	public class ActionGetURL2 extends Action implements IAction
	{
		public static const CODE:uint = 0x9a;
		
		public var sendVarsMethod:uint;
		public var reserved:uint;
		public var loadTargetFlag:Boolean;
		public var loadVariablesFlag:Boolean;
		
		public function ActionGetURL2(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function parse(data:SWFData):void {
			sendVarsMethod = data.readUB(2);
			reserved = data.readUB(4); // reserved, always 0
			loadTargetFlag = (data.readUB(1) == 1);
			loadVariablesFlag = (data.readUB(1) == 1);
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			body.writeUB(2, sendVarsMethod);
			body.writeUB(4, reserved); // reserved, always 0
			body.writeUB(1, loadTargetFlag ? 1 : 0);
			body.writeUB(1, loadVariablesFlag ? 1 : 0);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionGetURL2 = new ActionGetURL2(code, length, pos);
			action.sendVarsMethod = sendVarsMethod;
			action.reserved = reserved;
			action.loadTargetFlag = loadTargetFlag;
			action.loadVariablesFlag = loadVariablesFlag;
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionGetURL2] " +
				"SendVarsMethod: " + sendVarsMethod + " (" + sendVarsMethodToString() + "), " +
				"Reserved: " + reserved + ", " +
				"LoadTargetFlag: " + loadTargetFlag + ", " +
				"LoadVariablesFlag: " + loadVariablesFlag;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + 
				"getUrl2 (method: " + sendVarsMethodToString() + ", target: " +
				(loadTargetFlag == 0 ? "window" : "sprite") + ", variables: " +
				(loadVariablesFlag == 0 ? "no" : "yes") + ")";
		}
		
		public function sendVarsMethodToString():String {
			if (!sendVarsMethod) {
				return "None";
			}
			else if (sendVarsMethod == 1) {
				return "GET";
			}
			else if (sendVarsMethod == 2) {
				return "POST";
			}
			else {
				throw new Error("sendVarsMethod is only defined for values of 0, 1, and 2.");
			}
		}
	}
}
