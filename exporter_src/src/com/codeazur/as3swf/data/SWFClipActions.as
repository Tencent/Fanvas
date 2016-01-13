package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.utils.StringUtils;
	
	public class SWFClipActions
	{
		public var eventFlags:SWFClipEventFlags;
		
		protected var _records:Vector.<SWFClipActionRecord>;
		
		public function SWFClipActions(data:SWFData = null, version:uint = 0) {
			_records = new Vector.<SWFClipActionRecord>();
			if (data != null) {
				parse(data, version);
			}
		}
		
		public function get records():Vector.<SWFClipActionRecord> { return _records; }
		
		public function parse(data:SWFData, version:uint):void {
			data.readUI16(); // reserved, always 0
			eventFlags = data.readCLIPEVENTFLAGS(version);
			var record:SWFClipActionRecord;
			while ((record = data.readCLIPACTIONRECORD(version)) != null) {
				_records.push(record);
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeUI16(0); // reserved, always 0
			data.writeCLIPEVENTFLAGS(eventFlags, version);
			for(var i:uint = 0; i < records.length; i++) {
				data.writeCLIPACTIONRECORD(records[i], version);
			}
			if(version >= 6) {
				data.writeUI32(0);
			} else {
				data.writeUI16(0);
			}
		}
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = "ClipActions (" + eventFlags.toString() + "):";
			for (var i:uint = 0; i < _records.length; i++) {
				str += "\n" + StringUtils.repeat(indent + 2) + "[" + i + "] " + _records[i].toString(indent + 2, flags);
			}
			return str;
		}
	}
}
