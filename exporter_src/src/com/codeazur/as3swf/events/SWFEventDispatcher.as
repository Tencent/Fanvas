package com.codeazur.as3swf.events
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class SWFEventDispatcher implements IEventDispatcher
	{
		protected var dispatcher:EventDispatcher;
		
		public function SWFEventDispatcher() {
			dispatcher = new EventDispatcher(this);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		public function dispatchEvent(event:Event):Boolean {
			return dispatcher.dispatchEvent(event);
		}
		public function hasEventListener(type:String):Boolean {
			return dispatcher.hasEventListener(type);
		}
		public function willTrigger(type:String):Boolean {
			return dispatcher.willTrigger(type);
		}
	}
}