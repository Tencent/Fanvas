package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagDefineFontName implements ITag
	{
		public static const TYPE:uint = 88;
		
		public var fontId:uint;
		public var fontName:String;
		public var fontCopyright:String;
		
		public function TagDefineFontName() {}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			fontId = data.readUI16();
			fontName = data.readString();
			fontCopyright = data.readString();
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(fontId);
			body.writeString(fontName);
			body.writeString(fontCopyright);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineFontName"; }
		public function get version():uint { return 9; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"FontID: " + fontId + ", " +
				"Name: " + fontName + ", " +
				"Copyright: " + fontCopyright;
		}
	}
}
