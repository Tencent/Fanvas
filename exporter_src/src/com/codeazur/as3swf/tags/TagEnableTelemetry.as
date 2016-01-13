package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.utils.ByteArray;
	
	public class TagEnableTelemetry implements ITag
	{
		public static const TYPE:uint = 93;
		
		protected var _password:ByteArray;
		
		public function TagEnableTelemetry() {
			_password = new ByteArray();
		}
		
		public function get password():ByteArray { return _password; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			if (length > 2) {
				data.readByte();
				data.readByte();
				data.readBytes(_password, 0, length - 2);
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, _password.length + 2);
			data.writeByte(0);
			data.writeByte(0);
			if (_password.length > 0) {
				data.writeBytes(_password);
			}
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "EnableTelemetry"; }
		public function get version():uint { return 19; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent);
		}
		
	}

}