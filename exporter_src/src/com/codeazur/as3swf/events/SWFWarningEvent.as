package com.codeazur.as3swf.events
{
	import flash.events.Event;
	
	public class SWFWarningEvent extends Event
	{
		public static const OVERFLOW:String = "overflow";
		public static const UNDERFLOW:String = "underflow";
		
		public var index:uint;
		public var data:Object;
		
		public function SWFWarningEvent(type:String, index:uint, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.index = index;
			this.data = data;
		}
		
		override public function clone():Event {
			return new SWFWarningEvent(type, index, data, bubbles, cancelable);
		}
		
		override public function toString():String {
			return "[SWFWarningEvent] index: " + index;
		}
	}
}