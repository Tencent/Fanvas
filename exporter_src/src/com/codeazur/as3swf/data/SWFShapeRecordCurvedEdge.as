package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFShapeRecordCurvedEdge extends SWFShapeRecord
	{
		public var controlDeltaX:int;
		public var controlDeltaY:int;
		public var anchorDeltaX:int;
		public var anchorDeltaY:int;
		
		protected var numBits:uint;

		public function SWFShapeRecordCurvedEdge(data:SWFData = null, numBits:uint = 0, level:uint = 1) {
			this.numBits = numBits;
			super(data, level);
		}
		
		override public function parse(data:SWFData = null, level:uint = 1):void {
			controlDeltaX = data.readSB(numBits);
			controlDeltaY = data.readSB(numBits);
			anchorDeltaX = data.readSB(numBits);
			anchorDeltaY = data.readSB(numBits);
		}
		
		override public function publish(data:SWFData = null, level:uint = 1):void {
			numBits = data.calculateMaxBits(true, [controlDeltaX, controlDeltaY, anchorDeltaX, anchorDeltaY]);
			if(numBits < 2) { numBits = 2; }
			data.writeUB(4, numBits - 2);
			data.writeSB(numBits, controlDeltaX);
			data.writeSB(numBits, controlDeltaY);
			data.writeSB(numBits, anchorDeltaX);
			data.writeSB(numBits, anchorDeltaY);
		}
		
		override public function clone():SWFShapeRecord {
			var record:SWFShapeRecordCurvedEdge = new SWFShapeRecordCurvedEdge();
			record.anchorDeltaX = anchorDeltaX;
			record.anchorDeltaY = anchorDeltaY;
			record.controlDeltaX = controlDeltaX;
			record.controlDeltaY = controlDeltaY;
			record.numBits = numBits;
			return record;
		}
		
		override public function get type():uint { return SWFShapeRecord.TYPE_CURVEDEDGE; }
		
		override public function toString(indent:uint = 0):String {
			return "[SWFShapeRecordCurvedEdge] " +
				"ControlDelta: " + controlDeltaX + "," + controlDeltaY + ", " +
				"AnchorDelta: " + anchorDeltaX + "," + anchorDeltaY;
		}
	}
}
