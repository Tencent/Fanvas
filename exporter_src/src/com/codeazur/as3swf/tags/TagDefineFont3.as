package com.codeazur.as3swf.tags
{
	public class TagDefineFont3 extends TagDefineFont2 implements IDefinitionTag
	{
		public static const TYPE:uint = 75;
		
		public function TagDefineFont3() {}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "DefineFont3"; }
		override public function get version():uint { return 8; }
		override public function get level():uint { return 2; }
		
		override protected function get unitDivisor():Number { return 20; }
		
		override public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"FontName: " + fontName + ", " +
				"Italic: " + italic + ", " +
				"Bold: " + bold + ", " +
				"Glyphs: " + _glyphShapeTable.length;
			return str + toStringCommon(indent);
		}
	}
}
