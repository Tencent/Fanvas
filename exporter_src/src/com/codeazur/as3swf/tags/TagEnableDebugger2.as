package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.utils.ByteArray;
	
	public class TagEnableDebugger2 extends TagEnableDebugger implements ITag
	{
		public static const TYPE:uint = 64;
		
		// Reserved, SWF File Format v10 says this is always zero.
		// Observed other values from generated SWFs, e.g. 0x1975.
		protected var _reserved:uint = 0;
		
		public function TagEnableDebugger2() {
			super();
		}
		
		public function get reserved():uint { return _reserved; }
		
		override public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_reserved = data.readUI16(); 
			if (length > 2) {
				data.readBytes(_password, 0, length - 2);
			}
		}
		
		override public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, _password.length + 2);
			data.writeUI16(_reserved);
			if (_password.length > 0) {
				data.writeBytes(_password);
			}
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "EnableDebugger2"; }
		override public function get version():uint { return 6; }
		override public function get level():uint { return 2; }
	
		override public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"Password: " + (_password.length ? 'null' : _password.readUTF()) + ", " +
				"Reserved: 0x" + _reserved.toString(16);
		}
	}
}
