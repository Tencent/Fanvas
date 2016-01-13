package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.utils.ByteArray;
	
	public class TagNameCharacter implements ITag
	{
		public static const TYPE:uint = 40;
		
		protected var _characterId:uint;

		protected var _binaryData:ByteArray;
		
		public function TagNameCharacter() {
			_binaryData = new ByteArray();
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function get binaryData():ByteArray { return _binaryData; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			if (length > 2) {
				data.readBytes(_binaryData, 0, length - 2);
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(_characterId);
			if (_binaryData.length > 0) {
				body.writeBytes(_binaryData);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():ITag {
			var tag:TagNameCharacter = new TagNameCharacter();
			tag.characterId = characterId;
			if (_binaryData.length > 0) {
				tag.binaryData.writeBytes(_binaryData);
			}
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "NameCharacter"; }
		public function get version():uint { return 3; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId;
			if (binaryData.length > 0) {
				binaryData.position = 0;
				str += ", Name: " + binaryData.readUTFBytes(binaryData.length - 1);
				binaryData.position = 0;
			}
			return str;
		}
	}
}
