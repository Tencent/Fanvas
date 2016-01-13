package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFZoneRecord
	{
		public var maskX:Boolean;
		public var maskY:Boolean;

		protected var _zoneData:Vector.<SWFZoneData>;
		
		public function SWFZoneRecord(data:SWFData = null) {
			_zoneData = new Vector.<SWFZoneData>();
			if (data != null) {
				parse(data);
			}
		}
		
		public function get zoneData():Vector.<SWFZoneData> { return _zoneData; }
		
		public function parse(data:SWFData):void {
			var numZoneData:uint = data.readUI8();
			for (var i:uint = 0; i < numZoneData; i++) {
				_zoneData.push(data.readZONEDATA());
			}
			var mask:uint = data.readUI8();
			maskX = ((mask & 0x01) != 0);
			maskY = ((mask & 0x02) != 0);
		}
		
		public function publish(data:SWFData):void {
			var numZoneData:uint = _zoneData.length;
			data.writeUI8(numZoneData);
			for (var i:uint = 0; i < numZoneData; i++) {
				data.writeZONEDATA(_zoneData[i]);
			}
			var mask:uint = 0;
			if(maskX) { mask |= 0x01; }
			if(maskY) { mask |= 0x02; }
			data.writeUI8(mask);
		}
		
		public function toString(indent:uint = 0):String {
			var str:String = "MaskY: " + maskY + ", MaskX: " + maskX;
			for (var i:uint = 0; i < _zoneData.length; i++) {
				str += ", " + i + ": " + _zoneData[i].toString();
			}
			return str;
		}
	}
}
