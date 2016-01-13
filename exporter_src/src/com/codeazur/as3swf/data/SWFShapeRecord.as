package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFShapeRecord
	{
		public static const TYPE_UNKNOWN:uint = 0;
		public static const TYPE_END:uint = 1;
		public static const TYPE_STYLECHANGE:uint = 2;
		public static const TYPE_STRAIGHTEDGE:uint = 3;
		public static const TYPE_CURVEDEDGE:uint = 4;
		
		public function SWFShapeRecord(data:SWFData = null, level:uint = 1) {
			if (data != null) {
				parse(data, level);
			}
		}
		
		public function get type():uint { return TYPE_UNKNOWN; }
		
		public function get isEdgeRecord():Boolean {
			return (type == TYPE_STRAIGHTEDGE || type == TYPE_CURVEDEDGE);
		}
		
		public function parse(data:SWFData = null, level:uint = 1):void {}

		public function publish(data:SWFData = null, level:uint = 1):void {}
		
		public function clone():SWFShapeRecord { return null; }
		
		public function toString(indent:uint = 0):String {
			return "[SWFShapeRecord]";
		}
	}
}
