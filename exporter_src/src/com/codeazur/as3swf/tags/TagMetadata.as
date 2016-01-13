package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagMetadata implements ITag
	{
		public static const TYPE:uint = 77;
		
		public var xmlString:String;
		
		public function TagMetadata() {}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			xmlString = data.readString();
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeString(xmlString);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "Metadata"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }
			
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent)
			var xml:XML;
			try {
				xml = new XML(xmlString);
				str += " " + xml.toXMLString();
			} catch(error:Error) {
				str += " " + xmlString;
			}
			return str;
		}
	}
}
