package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagUnknown implements ITag
	{
		protected var _type:uint;
		
		public function TagUnknown(type:uint = 0) {
			_type = type;
		}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			data.skipBytes(length);
		}
		
		public function publish(data:SWFData, version:uint):void {
			throw(new Error("No raw tag data available."));
		}
		
		public function get type():uint { return _type; }
		public function get name():String { return "????"; }
		public function get version():uint { return 0; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent);
		}
	}
}
