package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.BitmapFormat;
	
	import flash.utils.ByteArray;
	
	public class TagDefineBitsLossless implements IDefinitionTag
	{
		public static const TYPE:uint = 20;
		
		public var bitmapFormat:uint;
		public var bitmapWidth:uint;
		public var bitmapHeight:uint;
		public var bitmapColorTableSize:uint;
		
		protected var _characterId:uint;

		protected var _zlibBitmapData:ByteArray;
		
		public function TagDefineBitsLossless() {
			_zlibBitmapData = new ByteArray();
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }
		
		public function get zlibBitmapData():ByteArray { return _zlibBitmapData; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			bitmapFormat = data.readUI8();
			bitmapWidth = data.readUI16();
			bitmapHeight = data.readUI16();
			if (bitmapFormat == BitmapFormat.BIT_8) {
				bitmapColorTableSize = data.readUI8();
			}
			data.readBytes(zlibBitmapData, 0, length - ((bitmapFormat == BitmapFormat.BIT_8) ? 8 : 7));
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(_characterId);
			body.writeUI8(bitmapFormat);
			body.writeUI16(bitmapWidth);
			body.writeUI16(bitmapHeight);
			if (bitmapFormat == BitmapFormat.BIT_8) {
				body.writeUI8(bitmapColorTableSize);
			}
			if (_zlibBitmapData.length > 0) {
				body.writeBytes(_zlibBitmapData);
			}
			data.writeTagHeader(type, body.length, true);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineBitsLossless = new TagDefineBitsLossless();
			tag.characterId = characterId;
			tag.bitmapFormat = bitmapFormat;
			tag.bitmapWidth = bitmapWidth;
			tag.bitmapHeight = bitmapHeight;
			if (_zlibBitmapData.length > 0) {
				tag.zlibBitmapData.writeBytes(_zlibBitmapData);
			}
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineBitsLossless"; }
		public function get version():uint { return 2; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Format: " + BitmapFormat.toString(bitmapFormat) + ", " +
				"Size: (" + bitmapWidth + "," + bitmapHeight + ")";
		}
	}
}
