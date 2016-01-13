package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.utils.ByteArray;
	
	public class TagJPEGTables implements ITag
	{
		public static const TYPE:uint = 8;
		
		protected var _jpegTables:ByteArray;
		
		public function TagJPEGTables() {
			_jpegTables = new ByteArray();
		}
		
		public function get jpegTables():ByteArray { return _jpegTables; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			if(length > 0) {
				data.readBytes(_jpegTables, 0, length);
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, _jpegTables.length);
			if (jpegTables.length > 0) {
				data.writeBytes(jpegTables);
			}
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "JPEGTables"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }
	
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) + "Length: " + _jpegTables.length;
		}
	}
}
