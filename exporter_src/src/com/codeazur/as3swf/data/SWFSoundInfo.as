package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFSoundInfo
	{
		public var syncStop:Boolean;
		public var syncNoMultiple:Boolean;
		public var hasEnvelope:Boolean;
		public var hasLoops:Boolean;
		public var hasOutPoint:Boolean;
		public var hasInPoint:Boolean;
		
		public var outPoint:uint;
		public var inPoint:uint;
		public var loopCount:uint;
		
		protected var _envelopeRecords:Vector.<SWFSoundEnvelope>;
		
		public function SWFSoundInfo(data:SWFData = null) {
			_envelopeRecords = new Vector.<SWFSoundEnvelope>();
			if (data != null) {
				parse(data);
			}
		}
		
		public function get envelopeRecords():Vector.<SWFSoundEnvelope> { return _envelopeRecords; }
		
		public function parse(data:SWFData):void {
			var flags:uint = data.readUI8();
			syncStop = ((flags & 0x20) != 0);
			syncNoMultiple = ((flags & 0x10) != 0);
			hasEnvelope = ((flags & 0x08) != 0);
			hasLoops = ((flags & 0x04) != 0);
			hasOutPoint = ((flags & 0x02) != 0);
			hasInPoint = ((flags & 0x01) != 0);
			if (hasInPoint) {
				inPoint = data.readUI32();
			}
			if (hasOutPoint) {
				outPoint = data.readUI32();
			}
			if (hasLoops) {
				loopCount = data.readUI16();
			}
			if (hasEnvelope) {
				var envPoints:uint = data.readUI8();
				for (var i:uint = 0; i < envPoints; i++) {
					_envelopeRecords.push(data.readSOUNDENVELOPE());
				}
			}
		}
		
		public function publish(data:SWFData):void {
			var flags:uint = 0;
			if(syncStop) { flags |= 0x20; }
			if(syncNoMultiple) { flags |= 0x10; }
			if(hasEnvelope) { flags |= 0x08; }
			if(hasLoops) { flags |= 0x04; }
			if(hasOutPoint) { flags |= 0x02; }
			if(hasInPoint) { flags |= 0x01; }
			data.writeUI8(flags)
			if (hasInPoint) {
				data.writeUI32(inPoint);
			}
			if (hasOutPoint) {
				data.writeUI32(outPoint);
			}
			if (hasLoops) {
				data.writeUI16(loopCount);
			}
			if (hasEnvelope) {
				var envPoints:uint = _envelopeRecords.length;
				data.writeUI8(envPoints);
				for (var i:uint = 0; i < envPoints; i++) {
					data.writeSOUNDENVELOPE(_envelopeRecords[i]);
				}
			}
		}
		
		public function clone():SWFSoundInfo {
			var soundInfo:SWFSoundInfo = new SWFSoundInfo();
			soundInfo.syncStop = syncStop;
			soundInfo.syncNoMultiple = syncNoMultiple;
			soundInfo.hasEnvelope = hasEnvelope;
			soundInfo.hasLoops = hasLoops;
			soundInfo.hasOutPoint = hasOutPoint;
			soundInfo.hasInPoint = hasInPoint;
			soundInfo.outPoint = outPoint;
			soundInfo.inPoint = inPoint;
			soundInfo.loopCount = loopCount;
			for (var i:uint = 0; i < _envelopeRecords.length; i++) {
				soundInfo.envelopeRecords.push(_envelopeRecords[i].clone());
			}
			return soundInfo;
		}
		
		public function toString():String {
			return "[SWFSoundInfo]";
		}
	}
}
