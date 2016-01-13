package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.data.consts.BitmapFormat;

	public class TagDefineBitsLossless2 extends TagDefineBitsLossless implements IDefinitionTag
	{
		public static const TYPE:uint = 36;
		
		public function TagDefineBitsLossless2() {}
		
		override public function clone():IDefinitionTag {
			var tag:TagDefineBitsLossless2 = new TagDefineBitsLossless2();
			tag.characterId = characterId;
			tag.bitmapFormat = bitmapFormat;
			tag.bitmapWidth = bitmapWidth;
			tag.bitmapHeight = bitmapHeight;
			if (_zlibBitmapData.length > 0) {
				tag.zlibBitmapData.writeBytes(_zlibBitmapData);
			}
			return tag;
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "DefineBitsLossless2"; }
		override public function get version():uint { return 3; }
		override public function get level():uint { return 2; }

		override public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Format: " + BitmapFormat.toString(bitmapFormat) + ", " +
				"Size: (" + bitmapWidth + "," + bitmapHeight + ")";
		}
	}
}
