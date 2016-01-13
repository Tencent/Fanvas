package com.codeazur.as3swf.data.actions
{
	import com.codeazur.as3swf.SWFData;
	
	public interface IActionBranch extends IAction
	{
		function get branchOffset():int;
		function set branchOffset(value:int):void;

		function get branchIndex():int;
		function set branchIndex(value:int):void;
	}
}
