package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagShowFrame implements IDisplayListTag
	{
		public static const TYPE:uint = 1;
		
		public function TagShowFrame() {}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			// Do nothing. The End tag has no body.
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, 0);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "ShowFrame"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent);
		}
	}
}
