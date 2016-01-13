package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFSoundInfo;
	
	public class TagStartSound2 implements ITag
	{
		public static const TYPE:uint = 89;
		
		public var soundClassName:String;
		public var soundInfo:SWFSoundInfo;
		
		public function TagStartSound2() {}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			soundClassName = data.readString();
			soundInfo = data.readSOUNDINFO();
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeString(soundClassName);
			body.writeSOUNDINFO(soundInfo);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "StartSound2"; }
		public function get version():uint { return 9; }
		public function get level():uint { return 2; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"SoundClassName: " + soundClassName + ", " +
				"SoundInfo: " + soundInfo;
			return str;
		}
	}
}
