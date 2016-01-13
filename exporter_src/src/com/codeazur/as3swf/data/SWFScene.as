package com.codeazur.as3swf.data
{
	public class SWFScene
	{
		public var offset:uint;
		public var name:String;
		
		// TODO: parse() method?
		public function SWFScene(offset:uint, name:String)
		{
			this.offset = offset;
			this.name = name;
		}
		
		public function toString():String {
			return "Frame: " + offset + ", Name: " + name;
		}
	}
}
