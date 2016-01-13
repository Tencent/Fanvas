package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.utils.ByteArray;
	
	public class TagDefineBinaryData implements IDefinitionTag
	{
		public static const TYPE:uint = 87;
		
		protected var _characterId:uint;

		protected var _binaryData:ByteArray;
		
		public function TagDefineBinaryData() {
			_binaryData = new ByteArray();
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function get binaryData():ByteArray { return _binaryData; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			data.readUI32(); // reserved, always 0
			if (length > 6) {
				data.readBytes(_binaryData, 0, length - 6);
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(_characterId);
			body.writeUI32(0); // reserved, always 0
			if (_binaryData.length > 0) {
				body.writeBytes(_binaryData);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineBinaryData = new TagDefineBinaryData();
			tag.characterId = characterId;
			if (_binaryData.length > 0) {
				tag.binaryData.writeBytes(_binaryData);
			}
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineBinaryData"; }
		public function get version():uint { return 9; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Length: " + _binaryData.length;
		}
	}
}
