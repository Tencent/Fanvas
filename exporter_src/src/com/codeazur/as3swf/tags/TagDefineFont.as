package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFShape;
	import com.codeazur.as3swf.exporters.core.IShapeExporter;
	import com.codeazur.utils.StringUtils;
		
	public class TagDefineFont implements IDefinitionTag
	{
		public static const TYPE:uint = 10;
		
		protected var _characterId:uint;
		
		protected var _glyphShapeTable:Vector.<SWFShape>;
		
		public function TagDefineFont() {
			_glyphShapeTable = new Vector.<SWFShape>();
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function get glyphShapeTable():Vector.<SWFShape> { return _glyphShapeTable; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			// Because the glyph shape table immediately follows the offset table,
			// the number of entries in each table (the number of glyphs in the font) can be inferred by
			// dividing the first entry in the offset table by two.
			var numGlyphs:uint = data.readUI16() >> 1;
			// Skip offsets. We don't need them here.
			data.skipBytes((numGlyphs - 1) << 1);
			// Read glyph shape table
			for (var i:uint = 0; i < numGlyphs; i++) {
				_glyphShapeTable.push(data.readSHAPE(unitDivisor));
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			var i:uint
			var prevPtr:uint = 0;
			var len:uint = glyphShapeTable.length;
			var shapeTable:SWFData = new SWFData();
			body.writeUI16(characterId);
			var offsetTableLength:uint = (len << 1);
			for (i = 0; i < len; i++) {
				// Write out the offset table for the current glyph
				body.writeUI16(shapeTable.position + offsetTableLength);
				// Serialize the glyph's shape to a separate bytearray
				shapeTable.writeSHAPE(glyphShapeTable[i]);
			}
			// Now concatenate the glyph shape table to the end (after
			// the offset table that we were previously writing inside
			// the for loop above).
			body.writeBytes(shapeTable);
			// Now write the tag with the known body length, and the
			// actual contents out to the provided SWFData instance.
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineFont = new TagDefineFont();
			throw(new Error("Not implemented yet."));
			return tag;
		}
		
		public function export(handler:IShapeExporter, glyphIndex:uint):void {
			glyphShapeTable[glyphIndex].export(handler);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineFont"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }
		
		protected function get unitDivisor():Number { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Glyphs: " + _glyphShapeTable.length;
			return str + toStringCommon(indent);
		}
		
		protected function toStringCommon(indent:uint):String {
			var str:String = "";
			for (var i:uint = 0; i < _glyphShapeTable.length; i++) {
				str += "\n" + StringUtils.repeat(indent + 2) + "[" + i + "] GlyphShapes:";
				str += _glyphShapeTable[i].toString(indent + 4);
			}
			return str;
		}
	}
}
