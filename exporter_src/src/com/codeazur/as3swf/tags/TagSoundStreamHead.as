package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.SoundCompression;
	import com.codeazur.as3swf.data.consts.SoundRate;
	import com.codeazur.as3swf.data.consts.SoundSize;
	import com.codeazur.as3swf.data.consts.SoundType;
	
	public class TagSoundStreamHead implements ITag
	{
		public static const TYPE:uint = 18;
		
		public var playbackSoundRate:uint;
		public var playbackSoundSize:uint;
		public var playbackSoundType:uint;
		public var streamSoundCompression:uint;
		public var streamSoundRate:uint;
		public var streamSoundSize:uint;
		public var streamSoundType:uint;
		public var streamSoundSampleCount:uint;
		public var latencySeek:uint;
		
		public function TagSoundStreamHead() {}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			data.readUB(4);
			playbackSoundRate = data.readUB(2);
			playbackSoundSize = data.readUB(1);
			playbackSoundType = data.readUB(1);
			streamSoundCompression = data.readUB(4);
			streamSoundRate = data.readUB(2);
			streamSoundSize = data.readUB(1);
			streamSoundType = data.readUB(1);
			streamSoundSampleCount = data.readUI16();
			if (streamSoundCompression == SoundCompression.MP3) {
				latencySeek = data.readSI16();
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUB(4, 0);
			body.writeUB(2, playbackSoundRate);
			body.writeUB(1, playbackSoundSize);
			body.writeUB(1, playbackSoundType);
			body.writeUB(4, streamSoundCompression);
			body.writeUB(2, streamSoundRate);
			body.writeUB(1, streamSoundSize);
			body.writeUB(1, streamSoundType);
			body.writeUI16(streamSoundSampleCount);
			if (streamSoundCompression == SoundCompression.MP3) {
				body.writeSI16(latencySeek);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "SoundStreamHead"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent);
			if(streamSoundSampleCount > 0) {
				str += "Format: " + SoundCompression.toString(streamSoundCompression) + ", " +
					"Rate: " + SoundRate.toString(streamSoundRate) + ", " +
					"Size: " + SoundSize.toString(streamSoundSize) + ", " +
					"Type: " + SoundType.toString(streamSoundType) + ", ";
			}
			str += "Samples: " + streamSoundSampleCount + ", ";
			str += "LatencySeek: " + latencySeek;
			return str;
		}
	}
}
