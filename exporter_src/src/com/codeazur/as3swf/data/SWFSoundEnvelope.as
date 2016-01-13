package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	public class SWFSoundEnvelope
	{
		public var pos44:uint;
		public var leftLevel:uint;
		public var rightLevel:uint;
		
		public function SWFSoundEnvelope(data:SWFData = null) {
			if (data != null) {
				parse(data);
			}
		}
		
		public function parse(data:SWFData):void {
			pos44 = data.readUI32();
			leftLevel = data.readUI16();
			rightLevel = data.readUI16();
		}
		
		public function publish(data:SWFData):void {
			data.writeUI32(pos44);
			data.writeUI16(leftLevel);
			data.writeUI16(rightLevel);
		}
		
		public function clone():SWFSoundEnvelope {
			var soundEnvelope:SWFSoundEnvelope = new SWFSoundEnvelope();
			soundEnvelope.pos44 = pos44;
			soundEnvelope.leftLevel = leftLevel;
			soundEnvelope.rightLevel = rightLevel;
			return soundEnvelope;
		}
		
		public function toString():String {
			return "[SWFSoundEnvelope]";
		}
	}
}
