package com.codeazur.as3swf.timeline
{
	import flash.utils.ByteArray;

	public class SoundStream
	{
		public var startFrame:uint;
		public var numFrames:uint;
		public var numSamples:uint;

		public var compression:uint;
		public var rate:uint;
		public var size:uint;
		public var type:uint;
		
		protected var _data:ByteArray;
		
		public function SoundStream()
		{
			_data = new ByteArray();
		}
		
		public function get data():ByteArray { return _data; }
		
		public function toString():String {
			return "[SoundStream] " +
				"StartFrame: " + startFrame + ", " +
				"Frames: " + numFrames + ", " +
				"Samples: " + numSamples + ", " +
				"Bytes: " + data.length;
		}
	}
}