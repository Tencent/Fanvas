package com.codeazur.as3swf.data.actions.swf4
{
	import com.codeazur.as3swf.data.actions.*;
	import com.codeazur.as3swf.SWFData;
	
	public class ActionJump extends Action implements IActionBranch
	{
		public static const CODE:uint = 0x99;
		
		protected var _branchOffset:int;

		// branchIndex is resolved in TagDoAction::parse()
		protected var _branchIndex:int = -2;
		
		public function ActionJump(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		public function get branchOffset():int { return _branchOffset; }
		public function set branchOffset(value:int):void { _branchOffset = value; }
		
		public function get branchIndex():int { return _branchIndex; }
		public function set branchIndex(value:int):void { _branchIndex = value; }
		
		override public function parse(data:SWFData):void {
			_branchOffset = data.readSI16();
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			body.writeSI16(_branchOffset);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionJump = new ActionJump(code, length, pos);
			action.branchOffset = _branchOffset;
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			var bi:String = " [";
			if (_branchIndex >= 0) {
				bi += _branchIndex.toString();
			} else if (_branchIndex == -1) {
				bi += "EOB";
			} else {
				bi += "???";
			}
			bi += "]";
			return "[ActionJump] BranchOffset: " + branchOffset + bi;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			var ls:String = "";
			if (_branchIndex >= 0) {
				ls += context.actions[_branchIndex].lbl;
			} else if (_branchIndex == -1) {
				ls += "L" + (context.labelCount + 1);
			} else {
				ls += "ILLEGAL BRANCH";
			}
			return toBytecodeLabel(indent) + "jump " + ls;
		}
	}
}
