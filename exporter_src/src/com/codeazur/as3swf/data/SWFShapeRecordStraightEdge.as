package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFShapeRecordStraightEdge extends SWFShapeRecord
	{
		public var generalLineFlag:Boolean;
		public var vertLineFlag:Boolean;
		public var deltaY:int;
		public var deltaX:int;
		
		protected var numBits:uint;

		public function SWFShapeRecordStraightEdge(data:SWFData = null, numBits:uint = 0, level:uint = 1) {
			this.numBits = numBits;
			super(data, level);
		}
		
		override public function parse(data:SWFData = null, level:uint = 1):void {
			generalLineFlag = (data.readUB(1) == 1);
			vertLineFlag = !generalLineFlag ? (data.readUB(1) == 1) : false;
			deltaX = (generalLineFlag || !vertLineFlag) ? data.readSB(numBits) : 0;
			deltaY = (generalLineFlag || vertLineFlag) ? data.readSB(numBits) : 0;
		}
		
		override public function publish(data:SWFData = null, level:uint = 1):void {
			var deltas:Array = [];
			if(generalLineFlag || !vertLineFlag) { deltas.push(deltaX); }
			if(generalLineFlag || vertLineFlag) { deltas.push(deltaY); }
			numBits = data.calculateMaxBits(true, deltas);
			if(numBits < 2) { numBits = 2; }
			data.writeUB(4, numBits - 2);
			data.writeUB(1, generalLineFlag ? 1 : 0);
			if(!generalLineFlag) {
				data.writeUB(1, vertLineFlag ? 1 : 0);
			}
			for(var i:uint = 0; i < deltas.length; i++) {
				data.writeSB(numBits, int(deltas[i]));
			}
		}
		
		override public function clone():SWFShapeRecord {
			var record:SWFShapeRecordStraightEdge = new SWFShapeRecordStraightEdge();
			record.deltaX = deltaX;
			record.deltaY = deltaY;
			record.generalLineFlag = generalLineFlag;
			record.vertLineFlag = vertLineFlag;
			record.numBits = numBits;
			return record;
		}
		
		override public function get type():uint { return SWFShapeRecord.TYPE_STRAIGHTEDGE; }
		
		override public function toString(indent:uint = 0):String {
			var str:String = "[SWFShapeRecordStraightEdge] ";
			if (generalLineFlag) {
				str += "General: " + deltaX + "," + deltaY;
			} else {
				if (vertLineFlag) {
					str += "Vertical: " + deltaY;
				} else {
					str += "Horizontal: " + deltaX;
				}
			}
			return str;
		}
	}
}
