package com.codeazur.as3swf.data.actions
{
	public class ActionExecutionContext
	{
		protected var _actions:Vector.<IAction>;
		protected var _cpool:Array;
		
		public var labelCount:uint;
		public var endLabel:String;
		
		public function ActionExecutionContext(actions:Vector.<IAction>, cpool:Array, labelCount:uint)
		{
			_actions = actions;
			_cpool = cpool;
			
			this.labelCount = labelCount;
			this.endLabel = null;
			
			for(var i:uint = 0; i < actions.length; i++) {
				var action:IAction = actions[i];
				if (action is IActionBranch) {
					var actionBranch:IActionBranch = action as IActionBranch;
					if(actionBranch.branchIndex == -1) {
						endLabel = "L" + (labelCount + 1);
						break;
					}
				}
			}
		}

		public function get actions():Vector.<IAction> { return _actions; }
		public function get cpool():Array { return _cpool; }
	}
}