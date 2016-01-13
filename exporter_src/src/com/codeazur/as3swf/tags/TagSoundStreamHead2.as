package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.data.consts.SoundRate;
	import com.codeazur.as3swf.data.consts.SoundSize;
	import com.codeazur.as3swf.data.consts.SoundType;
	import com.codeazur.as3swf.data.consts.SoundCompression;
	
	public class TagSoundStreamHead2 extends TagSoundStreamHead implements ITag
	{
		public static const TYPE:uint = 45;
		
		public function TagSoundStreamHead2() {}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "SoundStreamHead2"; }
		override public function get version():uint { return 3; }
		override public function get level():uint { return 2; }

		override public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent);
			if(streamSoundSampleCount > 0) {
				str += "Format: " + SoundCompression.toString(streamSoundCompression) + ", " +
					"Rate: " + SoundRate.toString(streamSoundRate) + ", " +
					"Size: " + SoundSize.toString(streamSoundSize) + ", " +
					"Type: " + SoundType.toString(streamSoundType) + ", ";
			}
			str += "Samples: " + streamSoundSampleCount;
			return str;
		}
	}
}
