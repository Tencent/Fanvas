package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFSoundInfo;
	
	public class TagStartSound implements ITag
	{
		public static const TYPE:uint = 15;
		
		public var soundId:uint;
		public var soundInfo:SWFSoundInfo;
		
		public function TagStartSound() {}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			soundId = data.readUI16();
			soundInfo = data.readSOUNDINFO();
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(soundId);
			body.writeSOUNDINFO(soundInfo);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "StartSound"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"SoundID: " + soundId + ", " +
				"SoundInfo: " + soundInfo;
			return str;
		}
	}
}
