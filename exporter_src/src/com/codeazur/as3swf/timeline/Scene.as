package com.codeazur.as3swf.timeline
{
	import com.codeazur.utils.StringUtils;

	public class Scene
	{
		public var frameNumber:uint = 0;
		public var name:String;
		
		public function Scene(frameNumber:uint, name:String)
		{
			this.frameNumber = frameNumber;
			this.name = name;
		}
		
		public function toString(indent:uint = 0):String {
			return StringUtils.repeat(indent) + 
				"Name: " + name + ", " +
				"Frame: " + frameNumber;
		}
	}
}