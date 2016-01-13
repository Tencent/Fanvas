package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.BitmapType;
	
	import flash.utils.ByteArray;
	
	public class TagDefineBitsJPEG3 extends TagDefineBitsJPEG2 implements IDefinitionTag
	{
		public static const TYPE:uint = 35;
		
		protected var _bitmapAlphaData:ByteArray;
		
		public function TagDefineBitsJPEG3() {
			_bitmapAlphaData = new ByteArray();
		}
		
		public function get bitmapAlphaData():ByteArray { return _bitmapAlphaData; }
		
		override public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			var alphaDataOffset:uint = data.readUI32();
			data.readBytes(_bitmapData, 0, alphaDataOffset);
			if (bitmapData[0] == 0xff && (bitmapData[1] == 0xd8 || bitmapData[1] == 0xd9)) {
				bitmapType = BitmapType.JPEG;
			} else if (bitmapData[0] == 0x89 && bitmapData[1] == 0x50 && bitmapData[2] == 0x4e && bitmapData[3] == 0x47 && bitmapData[4] == 0x0d && bitmapData[5] == 0x0a && bitmapData[6] == 0x1a && bitmapData[7] == 0x0a) {
				bitmapType = BitmapType.PNG;
			} else if (bitmapData[0] == 0x47 && bitmapData[1] == 0x49 && bitmapData[2] == 0x46 && bitmapData[3] == 0x38 && bitmapData[4] == 0x39 && bitmapData[5] == 0x61) {
				bitmapType = BitmapType.GIF89A;
			}
			var alphaDataSize:uint = length - alphaDataOffset - 6;
			if (alphaDataSize > 0) {
				data.readBytes(_bitmapAlphaData, 0, alphaDataSize);
			}
		}
		
		override public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, _bitmapData.length + _bitmapAlphaData.length + 6, true);
			data.writeUI16(characterId);
			data.writeUI32(_bitmapData.length);
			if (_bitmapData.length > 0) {
				data.writeBytes(_bitmapData);
			}
			if (_bitmapAlphaData.length > 0) {
				data.writeBytes(_bitmapAlphaData);
			}
		}
		
		override public function clone():IDefinitionTag {
			var tag:TagDefineBitsJPEG3 = new TagDefineBitsJPEG3();
			tag.characterId = characterId;
			tag.bitmapType = bitmapType;
			if (_bitmapData.length > 0) {
				tag.bitmapData.writeBytes(_bitmapData);
			}
			if (_bitmapAlphaData.length > 0) {
				tag.bitmapAlphaData.writeBytes(_bitmapAlphaData);
			}
			return tag;
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "DefineBitsJPEG3"; }
		override public function get version():uint { return (bitmapType == BitmapType.JPEG) ? 3 : 8; }
		override public function get level():uint { return 3; }

		override public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Type: " + BitmapType.toString(bitmapType) + ", " +
				"HasAlphaData: " + (_bitmapAlphaData.length > 0) + ", " +
				((_bitmapAlphaData.length > 0) ? "BitmapAlphaLength: " + _bitmapAlphaData.length + ", " : "") +
				"BitmapLength: " + bitmapData.length;
			return str;
		}
	}
}
