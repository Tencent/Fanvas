package com.codeazur.as3swf.data.actions.swf3
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.actions.*;
	
	public class ActionGetURL extends Action implements IAction
	{
		public static const CODE:uint = 0x83;
		
		public var urlString:String;
		public var targetString:String;
		
		public function ActionGetURL(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function parse(data:SWFData):void {
			urlString = data.readString();
			targetString = data.readString();
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			body.writeString(urlString);
			body.writeString(targetString);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionGetURL = new ActionGetURL(code, length, pos);
			action.urlString = urlString;
			action.targetString = targetString;
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionGetURL] URL: " + urlString + ", Target: " + targetString;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "getURL \"" + urlString + "\", \"" + targetString + "\"";
		}
	}
}
