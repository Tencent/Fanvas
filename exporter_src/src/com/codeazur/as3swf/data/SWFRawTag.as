package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;

	public class SWFRawTag
	{
		public var header:SWFRecordHeader;
		public var bytes:SWFData;
		
		public function SWFRawTag(data:SWFData = null)
		{
			if (data != null) {
				parse(data);
			}
		}
		
		public function parse(data:SWFData):void {
			var pos:uint = data.position;
			header = data.readTagHeader();
			bytes = new SWFData();
			var posContent:uint = data.position;
			data.position = pos;
			data.readBytes(bytes, 0, header.tagLength);
			data.position = posContent;
		}
		
		public function publish(data:SWFData):void {
			// Header is part of the byte array
			data.writeBytes(bytes);
		}
	}
}