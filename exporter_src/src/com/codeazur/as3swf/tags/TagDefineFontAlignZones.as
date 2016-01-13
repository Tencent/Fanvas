package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFZoneRecord;
	import com.codeazur.as3swf.data.consts.CSMTableHint;
	import com.codeazur.utils.StringUtils;
	
	public class TagDefineFontAlignZones implements ITag
	{
		public static const TYPE:uint = 73;
		
		public var fontId:uint;
		public var csmTableHint:uint;
		
		protected var _zoneTable:Vector.<SWFZoneRecord>;
		
		public function TagDefineFontAlignZones() {
			_zoneTable = new Vector.<SWFZoneRecord>();
		}
		
		public function get zoneTable():Vector.<SWFZoneRecord> { return _zoneTable; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			fontId = data.readUI16();
			csmTableHint = (data.readUI8() >> 6);
			var recordsEndPos:uint = data.position + length - 3;
			while (data.position < recordsEndPos) {
				_zoneTable.push(data.readZONERECORD());
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(fontId);
			body.writeUI8(csmTableHint << 6);
			for(var i:uint = 0; i < _zoneTable.length; i++) {
				body.writeZONERECORD(_zoneTable[i]);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineFontAlignZones"; }
		public function get version():uint { return 8; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"FontID: " + fontId + ", " +
				"CSMTableHint: " + CSMTableHint.toString(csmTableHint) + ", " +
				"Records: " + _zoneTable.length;
			for (var i:uint = 0; i < _zoneTable.length; i++) {
				str += "\n" + StringUtils.repeat(indent + 2) + "[" + i + "] " + _zoneTable[i].toString(indent + 2);
			}
			return str;
		}
	}
}
