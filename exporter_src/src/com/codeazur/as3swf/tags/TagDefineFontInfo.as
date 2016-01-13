package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.utils.ByteArray;
	
	public class TagDefineFontInfo implements ITag
	{
		public static const TYPE:uint = 13;
		
		public var fontId:uint;
		public var fontName:String;
		public var smallText:Boolean;
		public var shiftJIS:Boolean;
		public var ansi:Boolean;
		public var italic:Boolean;
		public var bold:Boolean;
		public var wideCodes:Boolean;
		public var langCode:uint = 0;
		
		protected var _codeTable:Vector.<uint>;
		
		protected var langCodeLength:uint = 0;
		
		public function TagDefineFontInfo() {
			_codeTable = new Vector.<uint>();
		}
		
		public function get codeTable():Vector.<uint> { return _codeTable; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void
		{
			fontId = data.readUI16();

			var fontNameLen:uint = data.readUI8();
			var fontNameRaw:ByteArray = new ByteArray();
			data.readBytes(fontNameRaw, 0, fontNameLen);
			fontName = fontNameRaw.readUTFBytes(fontNameLen);
			
			var flags:uint = data.readUI8();
			smallText = ((flags & 0x20) != 0);
			shiftJIS = ((flags & 0x10) != 0);
			ansi = ((flags & 0x08) != 0);
			italic = ((flags & 0x04) != 0);
			bold = ((flags & 0x02) != 0);
			wideCodes = ((flags & 0x01) != 0);
			
			parseLangCode(data);
			
			var numGlyphs:uint = length - fontNameLen - langCodeLength - 4;
			for (var i:uint = 0; i < numGlyphs; i++) {
				_codeTable.push(wideCodes ? data.readUI16() : data.readUI8());
			}
		}
		
		public function publish(data:SWFData, version:uint):void
		{
			var body:SWFData = new SWFData();
			body.writeUI16(fontId);
			
			var fontNameRaw:ByteArray = new ByteArray();
			fontNameRaw.writeUTFBytes(fontName);
			body.writeUI8(fontNameRaw.length);
			body.writeBytes(fontNameRaw);
			
			var flags:uint = 0;
			if(smallText) { flags |= 0x20; }
			if(shiftJIS) { flags |= 0x10; }
			if(ansi) { flags |= 0x08; }
			if(italic) { flags |= 0x04; }
			if(bold) { flags |= 0x02; }
			if(wideCodes) { flags |= 0x01; }
			body.writeUI8(flags);
			
			publishLangCode(body);

			var numGlyphs:uint = _codeTable.length;
			for (var i:uint = 0; i < numGlyphs; i++) {
				if(wideCodes) {
					body.writeUI16(_codeTable[i]);
				} else {
					body.writeUI8(_codeTable[i]);
				}
			}
			
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		protected function parseLangCode(data:SWFData):void {
			// Does nothing here.
			// Overridden in TagDefineFontInfo2, where it:
			// - reads langCode
			// - sets langCodeLength to 1
		}
		
		protected function publishLangCode(data:SWFData):void {
			// Does nothing here.
			// Overridden in TagDefineFontInfo2
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineFontInfo"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"FontID: " + fontId + ", " +
				"FontName: " + fontName + ", " +
				"Italic: " + italic + ", " +
				"Bold: " + bold + ", " +
				"Codes: " + _codeTable.length;
		}
	}
}
