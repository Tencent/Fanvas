package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFKerningRecord;
	import com.codeazur.as3swf.data.SWFRectangle;
	import com.codeazur.utils.StringUtils;
	
	import flash.utils.ByteArray;
	
	public class TagDefineFont2 extends TagDefineFont implements IDefinitionTag
	{
		public static const TYPE:uint = 48;
		
		public var hasLayout:Boolean;
		public var shiftJIS:Boolean;
		public var smallText:Boolean;
		public var ansi:Boolean;
		public var wideOffsets:Boolean;
		public var wideCodes:Boolean;
		public var italic:Boolean;
		public var bold:Boolean;
		public var languageCode:uint;
		public var fontName:String;
		public var ascent:uint;
		public var descent:uint;
		public var leading:int;

		protected var _codeTable:Vector.<uint>;
		protected var _fontAdvanceTable:Vector.<int>;
		protected var _fontBoundsTable:Vector.<SWFRectangle>;
		protected var _fontKerningTable:Vector.<SWFKerningRecord>;
		
		public function TagDefineFont2() {
			_codeTable = new Vector.<uint>();
			_fontAdvanceTable = new Vector.<int>();
			_fontBoundsTable = new Vector.<SWFRectangle>();
			_fontKerningTable = new Vector.<SWFKerningRecord>();
		}
		
		public function get codeTable():Vector.<uint> { return _codeTable; }
		public function get fontAdvanceTable():Vector.<int> { return _fontAdvanceTable; }
		public function get fontBoundsTable():Vector.<SWFRectangle> { return _fontBoundsTable; }
		public function get fontKerningTable():Vector.<SWFKerningRecord> { return _fontKerningTable; }
		
		override public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			var flags:uint = data.readUI8();
			hasLayout = ((flags & 0x80) != 0);
			shiftJIS = ((flags & 0x40) != 0);
			smallText = ((flags & 0x20) != 0);
			ansi = ((flags & 0x10) != 0);
			wideOffsets = ((flags & 0x08) != 0);
			wideCodes = ((flags & 0x04) != 0);
			italic = ((flags & 0x02) != 0);
			bold = ((flags & 0x01) != 0);
			languageCode = data.readLANGCODE();
			var fontNameLen:uint = data.readUI8();
			var fontNameRaw:ByteArray = new ByteArray();
			data.readBytes(fontNameRaw, 0, fontNameLen);
			fontName = fontNameRaw.readUTFBytes(fontNameLen);
			var i:uint;
			var numGlyphs:uint = data.readUI16();
			if(numGlyphs > 0) {
				// Skip offsets. We don't need them.
				data.skipBytes(numGlyphs << (wideOffsets ? 2 : 1));
				// Not used
				var codeTableOffset:uint = (wideOffsets ? data.readUI32() : data.readUI16());
				for (i = 0; i < numGlyphs; i++) {
					_glyphShapeTable.push(data.readSHAPE());
				}
				for (i = 0; i < numGlyphs; i++) {
					_codeTable.push(wideCodes ? data.readUI16() : data.readUI8());
				}
			}
			if (hasLayout) {
				ascent = data.readUI16();
				descent = data.readUI16();
				leading = data.readSI16();
				for (i = 0; i < numGlyphs; i++) {
					_fontAdvanceTable.push(data.readSI16());
				}
				for (i = 0; i < numGlyphs; i++) {
					_fontBoundsTable.push(data.readRECT());
				}
				var kerningCount:uint = data.readUI16();
				for (i = 0; i < kerningCount; i++) {
					_fontKerningTable.push(data.readKERNINGRECORD(wideCodes));
				}
			}
		}
		
		override public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			var numGlyphs:uint = glyphShapeTable.length;
			var i:uint
			body.writeUI16(characterId);
			var flags:uint = 0;
			if(hasLayout) { flags |= 0x80; }
			if(shiftJIS) { flags |= 0x40; }
			if(smallText) { flags |= 0x20; }
			if(ansi) { flags |= 0x10; }
			if(wideOffsets) { flags |= 0x08; }
			if(wideCodes) { flags |= 0x04; }
			if(italic) { flags |= 0x02; }
			if(bold) { flags |= 0x01; }
			body.writeUI8(flags);
			body.writeLANGCODE(languageCode);
			var fontNameRaw:ByteArray = new ByteArray();
			fontNameRaw.writeUTFBytes(fontName);
			body.writeUI8(fontNameRaw.length);
			body.writeBytes(fontNameRaw);
			body.writeUI16(numGlyphs);
			if(numGlyphs > 0) {
				var offsetTableLength:uint = (numGlyphs << (wideOffsets ? 2 : 1));
				var codeTableOffsetLength:uint = (wideOffsets ? 4 : 2);
				var codeTableLength:uint = (wideOffsets ? (numGlyphs << 1) : numGlyphs);
				var offset:uint = offsetTableLength + codeTableOffsetLength;
				var shapeTable:SWFData = new SWFData();
				for (i = 0; i < numGlyphs; i++) {
					// Write out the offset table for the current glyph
					if(wideOffsets) {
						body.writeUI32(offset + shapeTable.position);
					} else {
						body.writeUI16(offset + shapeTable.position);
					}
					// Serialize the glyph's shape to a separate bytearray
					shapeTable.writeSHAPE(glyphShapeTable[i]);
				}
				// Code table offset
				if(wideOffsets) {
					body.writeUI32(offset + shapeTable.length);
				} else {
					body.writeUI16(offset + shapeTable.length);
				}
				// Now concatenate the glyph shape table to the end (after
				// the offset table that we were previously writing inside
				// the for loop above).
				body.writeBytes(shapeTable);
				// Write the code table
				for (i = 0; i < numGlyphs; i++) {
					if(wideCodes) {
						body.writeUI16(codeTable[i]);
					} else {
						body.writeUI8(codeTable[i]);
					}
				}
			}
			if (hasLayout) {
				body.writeUI16(ascent);
				body.writeUI16(descent);
				body.writeSI16(leading);
				for (i = 0; i < numGlyphs; i++) {
					body.writeSI16(fontAdvanceTable[i]);
				}
				for (i = 0; i < numGlyphs; i++) {
					body.writeRECT(fontBoundsTable[i]);
				}
				var kerningCount:uint = fontKerningTable.length;
				body.writeUI16(kerningCount);
				for (i = 0; i < kerningCount; i++) {
					body.writeKERNINGRECORD(fontKerningTable[i], wideCodes);
				}
			}
			// Now write the tag with the known body length, and the
			// actual contents out to the provided SWFData instance.
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "DefineFont2"; }
		override public function get version():uint { return 3; }
		override public function get level():uint { return 2; }

		override public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"FontName: " + fontName + ", " +
				"Italic: " + italic + ", " +
				"Bold: " + bold + ", " +
				"Glyphs: " + _glyphShapeTable.length;
			return str + toStringCommon(indent);
		}
		
		override protected function toStringCommon(indent:uint):String {
			var i:uint;
			var str:String = super.toStringCommon(indent);
			if (hasLayout) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Ascent: " + ascent;
				str += "\n" + StringUtils.repeat(indent + 2) + "Descent: " + descent;
				str += "\n" + StringUtils.repeat(indent + 2) + "Leading: " + leading;
			}
			if (_codeTable.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "CodeTable:";
				for (i = 0; i < _codeTable.length; i++) {
					if ((i & 0x0f) == 0) {
						str += "\n" + StringUtils.repeat(indent + 4) + _codeTable[i].toString();
					} else {
						str += ", " + _codeTable[i].toString();
					}
				}
			}
			if (_fontAdvanceTable.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "FontAdvanceTable:";
				for (i = 0; i < _fontAdvanceTable.length; i++) {
					if ((i & 0x07) == 0) {
						str += "\n" + StringUtils.repeat(indent + 4) + _fontAdvanceTable[i].toString();
					} else {
						str += ", " + _fontAdvanceTable[i].toString();
					}
				}
			}
			if (_fontBoundsTable.length > 0) {
				var hasNonNullBounds:Boolean = false;
				for (i = 0; i < _fontBoundsTable.length; i++) {
					var rect:SWFRectangle = _fontBoundsTable[i];
					if (rect.xmin != 0 || rect.xmax != 0 || rect.ymin != 0 || rect.ymax != 0) {
						hasNonNullBounds = true;
						break;
					}
				}
				if (hasNonNullBounds) {
					str += "\n" + StringUtils.repeat(indent + 2) + "FontBoundsTable:";
					for (i = 0; i < _fontBoundsTable.length; i++) {
						str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + _fontBoundsTable[i].toString();
					}
				}
			}
			if (_fontKerningTable.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "KerningTable:";
				for (i = 0; i < _fontKerningTable.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + _fontKerningTable[i].toString();
				}
			}
			return str;
		}
	}
}
