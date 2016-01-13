package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.utils.ByteArray;
	
	public class TagDefineFont4 implements IDefinitionTag
	{
		public static const TYPE:uint = 91;
		
		public var hasFontData:Boolean;
		public var italic:Boolean;
		public var bold:Boolean;
		public var fontName:String;

		protected var _characterId:uint;
		
		protected var _fontData:ByteArray;
		
		public function TagDefineFont4() {
			_fontData = new ByteArray();
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function get fontData():ByteArray { return _fontData; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			var pos:uint = data.position;
			_characterId = data.readUI16();
			var flags:uint = data.readUI8();
			hasFontData = ((flags & 0x04) != 0);
			italic = ((flags & 0x02) != 0);
			bold = ((flags & 0x01) != 0);
			fontName = data.readString();
			if (hasFontData && length > data.position - pos) {
				data.readBytes(_fontData, 0, length - (data.position - pos));
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			var flags:uint = 0;
			if(hasFontData) { flags |= 0x04; }
			if(italic) { flags |= 0x02; }
			if(bold) { flags |= 0x01; }
			body.writeUI8(flags);
			body.writeString(fontName);
			if (hasFontData && _fontData.length > 0) {
				body.writeBytes(_fontData);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineFont4 = new TagDefineFont4();
			tag.characterId = characterId;
			tag.hasFontData = hasFontData;
			tag.italic = italic;
			tag.bold = bold;
			tag.fontName = fontName;
			if (_fontData.length > 0) {
				tag.fontData.writeBytes(_fontData);
			}
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineFont4"; }
		public function get version():uint { return 10; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"FontName: " + fontName + ", " +
				"HasFontData: " + hasFontData + ", " +
				"Italic: " + italic + ", " +
				"Bold: " + bold;
			return str;
		}
	}
}
