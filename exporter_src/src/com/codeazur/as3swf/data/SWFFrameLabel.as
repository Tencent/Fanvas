package com.codeazur.as3swf.data
{
	public class SWFFrameLabel
	{
		public var frameNumber:uint;
		public var name:String;
		
		// TODO: parse() method?
		public function SWFFrameLabel(frameNumber:uint, name:String)
		{
			this.frameNumber = frameNumber;
			this.name = name;
		}
		
		public function toString():String {
			return "Frame: " + frameNumber + ", Name: " + name;
		}
	}
}
