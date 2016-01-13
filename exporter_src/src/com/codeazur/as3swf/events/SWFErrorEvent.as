package com.codeazur.as3swf.events
{
	import flash.events.Event;
	
	public class SWFErrorEvent extends Event
	{
		public static const ERROR:String = "error";

		public static const REASON_EOF:String = "eof";
		
		public var reason:String;
		
		public function SWFErrorEvent(type:String, reason:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.reason = reason;
		}
		
		override public function clone():Event {
			return new SWFErrorEvent(type, reason, bubbles, cancelable);
		}
		
		override public function toString():String {
			return "[SWFErrorEvent] reason: " + reason;
		}
	}
}