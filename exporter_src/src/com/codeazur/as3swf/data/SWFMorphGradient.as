package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFMorphGradient
	{
		public var spreadMode:uint;
		public var interpolationMode:uint;
		
		// Forward declarations of properties in SWFMorphFocalGradient
		public var startFocalPoint:Number = 0.0;
		public var endFocalPoint:Number = 0.0;

		protected var _records:Vector.<SWFMorphGradientRecord>;
		
		public function SWFMorphGradient(data:SWFData = null, level:uint = 1) {
			_records = new Vector.<SWFMorphGradientRecord>();
			if (data != null) {
				parse(data, level);
			}
		}
		
		public function get records():Vector.<SWFMorphGradientRecord> { return _records; }
		
		public function parse(data:SWFData, level:uint):void {
			data.resetBitsPending();
			spreadMode = data.readUB(2);
			interpolationMode = data.readUB(2);
			var numGradients:uint = data.readUB(4);
			for (var i:uint = 0; i < numGradients; i++) {
				_records.push(data.readMORPHGRADIENTRECORD());
			}
		}
		
		public function publish(data:SWFData, level:uint):void {
			var numGradients:uint = records.length;
			data.resetBitsPending();
			data.writeUB(2, spreadMode);
			data.writeUB(2, interpolationMode);
			data.writeUB(4, numGradients);
			for (var i:uint = 0; i < numGradients; i++) {
				data.writeMORPHGRADIENTRECORD(_records[i]);
			}
		}
		
		public function getMorphedGradient(ratio:Number = 0):SWFGradient {
			var gradient:SWFGradient = new SWFGradient();
			for(var i:uint = 0; i < records.length; i++) {
				gradient.records.push(records[i].getMorphedGradientRecord(ratio)); 
			}
			return gradient;
		}
		
		public function toString():String {
			return "(" + _records.join(",") + "), spread:" + spreadMode + ", interpolation:" + interpolationMode;
		}
	}
}
