package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFGlyphEntry;
	import com.codeazur.as3swf.data.SWFMatrix;
	import com.codeazur.as3swf.data.SWFRectangle;
	import com.codeazur.as3swf.data.SWFTextRecord;
	import com.codeazur.utils.StringUtils;
	
	public class TagDefineText implements IDefinitionTag
	{
		public static const TYPE:uint = 11;
		
		public var textBounds:SWFRectangle;
		public var textMatrix:SWFMatrix;
		
		protected var _characterId:uint;
		
		protected var _records:Vector.<SWFTextRecord>;
		
		public function TagDefineText() {
			_records = new Vector.<SWFTextRecord>();
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function get records():Vector.<SWFTextRecord> { return _records; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			textBounds = data.readRECT();
			textMatrix = data.readMATRIX();
			var glyphBits:uint = data.readUI8();
			var advanceBits:uint = data.readUI8();
			var record:SWFTextRecord;
			while ((record = data.readTEXTRECORD(glyphBits, advanceBits, record, level)) != null) {
				_records.push(record);
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			var i:uint;
			var j:uint;
			var record:SWFTextRecord;
			body.writeUI16(characterId);
			body.writeRECT(textBounds);
			body.writeMATRIX(textMatrix);
			// Calculate glyphBits and advanceBits values
			var glyphBitsValues:Array = [];
			var advanceBitsValues:Array = [];
			var recordsLen:uint = _records.length 
			for(i = 0; i < recordsLen; i++) {
				record = _records[i];
				var glyphCount:uint = record.glyphEntries.length;
				for (j = 0; j < glyphCount; j++) {
					var glyphEntry:SWFGlyphEntry = record.glyphEntries[j];
					glyphBitsValues.push(glyphEntry.index);
					advanceBitsValues.push(glyphEntry.advance);
				}
			}
			var glyphBits:uint = body.calculateMaxBits(false, glyphBitsValues);
			var advanceBits:uint = body.calculateMaxBits(true, advanceBitsValues);
			body.writeUI8(glyphBits);
			body.writeUI8(advanceBits);
			// Write text records
			record = null;
			for(i = 0; i < recordsLen; i++) {
				body.writeTEXTRECORD(_records[i], glyphBits, advanceBits, record, level);
				record = _records[i];
			}
			body.writeUI8(0);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineText = new TagDefineText();
			tag.characterId = characterId;
			tag.textBounds = textBounds.clone();
			tag.textMatrix = textMatrix.clone();
			for(var i:uint = 0; i < _records.length; i++) {
				tag.records.push(_records[i].clone());
			}
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineText"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }
	
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Bounds: " + textBounds + ", " +
				"Matrix: " + textMatrix;
			if (_records.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "TextRecords:";
				for (var i:uint = 0; i < _records.length; i++) {
					str += "\n" +
						StringUtils.repeat(indent + 4) +
						"[" + i + "] " +
						_records[i].toString(indent + 4);
				}
			}
			return str;
		}
	}
}
