package com.codeazur.as3swf.data.actions
{
	import com.codeazur.as3swf.SWFData;
	
	public interface IAction
	{
		function get code():uint;
		function get length():uint;
		function get lengthWithHeader():uint;
		function get pos():uint;

		function get lbl():String;
		function set lbl(value:String):void;

		function parse(data:SWFData):void;
		function publish(data:SWFData):void;
		function clone():IAction;
		function toString(indent:uint = 0):String;
		function toBytecode(indent:uint, context:ActionExecutionContext):String;
	}
}
