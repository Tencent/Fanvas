package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.utils.ByteArray;
	
	public class TagDoABC implements ITag
	{
		public static const TYPE:uint = 82;
		
		public var lazyInitializeFlag:Boolean;
		public var abcName:String = "";
		
		protected var _bytes:ByteArray;
		
		public function TagDoABC() {
			_bytes = new ByteArray();
		}
		
		public static function create(abcData:ByteArray = null, aName:String = "", aLazyInitializeFlag:Boolean = true):TagDoABC {
			var doABC:TagDoABC = new TagDoABC();
			if (abcData != null && abcData.length > 0) {
				doABC.bytes.writeBytes(abcData);
			}
			doABC.abcName = aName;
			doABC.lazyInitializeFlag = aLazyInitializeFlag;
			return doABC;
		}
		
		public function get bytes():ByteArray { return _bytes; }

		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			var pos:uint = data.position;
			var flags:uint = data.readUI32();
			lazyInitializeFlag = ((flags & 0x01) != 0);
			abcName = data.readString();
			data.readBytes(bytes, 0, length - (data.position - pos));
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI32(lazyInitializeFlag ? 1 : 0);
			body.writeString(abcName);
			if (_bytes.length > 0) {
				body.writeBytes(_bytes);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DoABC"; }
		public function get version():uint { return 9; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"Lazy: " + lazyInitializeFlag + ", " +
				((abcName.length > 0) ? "Name: " + abcName + ", " : "") +
				"Length: " + _bytes.length;
		}
	}
}
