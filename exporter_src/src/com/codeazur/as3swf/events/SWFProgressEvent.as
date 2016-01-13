package com.codeazur.as3swf.events
{
	import flash.events.Event;
	
	public class SWFProgressEvent extends Event
	{
		public static const PROGRESS:String = "progress";
		public static const COMPLETE:String = "complete";
		
		protected var processed:uint;
		protected var total:uint;
		
		public function SWFProgressEvent(type:String, processed:uint, total:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.processed = processed;
			this.total = total;
		}
		
		public function get progress():Number {
			return processed / total;
		}
		
		public function get progressPercent():Number {
			return Math.round(progress * 100);
		}
		
		override public function clone():Event {
			return new SWFProgressEvent(type, processed, total, bubbles, cancelable);
		}
		
		override public function toString():String {
			return "[SWFProgressEvent] processed: " + processed + ", total: " + total + " (" + progressPercent + "%)";
		}
	}
}