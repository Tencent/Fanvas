package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagImportAssets2 extends TagImportAssets implements ITag
	{
		public static const TYPE:uint = 71;

		public function TagImportAssets2() {}
		
		override public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			url = data.readString();
			data.readUI8(); // reserved, always 1
			data.readUI8(); // reserved, always 0
			var numSymbols:uint = data.readUI16();
			for (var i:uint = 0; i < numSymbols; i++) {
				_symbols.push(data.readSYMBOL());
			}
		}

		override public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeString(url);
			body.writeUI8(1);
			body.writeUI8(0);
			var numSymbols:uint = _symbols.length;
			body.writeUI16(numSymbols);
			for (var i:uint = 0; i < numSymbols; i++) {
				body.writeSYMBOL(_symbols[i]);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "ImportAssets2"; }
		override public function get version():uint { return 8; }
		override public function get level():uint { return 2; }
	}
}
