package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.utils.StringUtils;
	
	import flash.utils.ByteArray;
	
	public class TagDebugID implements ITag
	{
		public static const TYPE:uint = 63;
		
		protected var _uuid:ByteArray;
		
		public function TagDebugID() {
			_uuid = new ByteArray();
		}
		
		public function get uuid():ByteArray { return _uuid; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			if(length > 0) {
				data.readBytes(_uuid, 0, length);
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, _uuid.length);
			if(_uuid.length > 0) {
				data.writeBytes(_uuid);
			}
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DebugID"; }
		public function get version():uint { return 6; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) + "UUID: ";
			if (_uuid.length == 16) {
				str += StringUtils.printf("%02x%02x%02x%02x-", _uuid[0], _uuid[1], _uuid[2], _uuid[3]);
				str += StringUtils.printf("%02x%02x-", _uuid[4], _uuid[5]);
				str += StringUtils.printf("%02x%02x-", _uuid[6], _uuid[7]);
				str += StringUtils.printf("%02x%02x-", _uuid[8], _uuid[9]);
				str += StringUtils.printf("%02x%02x%02x%02x%02x%02x", _uuid[10], _uuid[11], _uuid[12], _uuid[13], _uuid[14], _uuid[15]);
			} else {
				str += "(invalid length: " + _uuid.length + ")";
			}
			return str;
		}
	}
}
