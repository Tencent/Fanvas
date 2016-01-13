package com.codeazur.as3swf.data
{
	public class SWFRecordHeader
	{
		public var type:uint;
		public var contentLength:uint;
		public var headerLength:uint;
		
		public function SWFRecordHeader(type:uint, contentLength:uint, headerLength:uint)
		{
			this.type = type;
			this.contentLength = contentLength;
			this.headerLength = headerLength;
		}
		
		public function get tagLength():uint {
			return headerLength + contentLength;
		}
		
		public function toString():String {
			return "[SWFRecordHeader] type: " + type + ", headerLength: " + headerLength + ", contentlength: " + contentLength;
		}
	}
}
