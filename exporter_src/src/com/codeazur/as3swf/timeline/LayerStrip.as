package com.codeazur.as3swf.timeline
{
	public class LayerStrip
	{
		public static const TYPE_EMPTY:uint = 0;
		public static const TYPE_SPACER:uint = 1;
		public static const TYPE_STATIC:uint = 2;
		public static const TYPE_MOTIONTWEEN:uint = 3;
		public static const TYPE_SHAPETWEEN:uint = 4;
		
		public var type:uint = TYPE_EMPTY;
		public var startFrameIndex:uint = 0;
		public var endFrameIndex:uint = 0;
		
		public function LayerStrip(type:uint, startFrameIndex:uint, endFrameIndex:uint)
		{
			this.type = type;
			this.startFrameIndex = startFrameIndex;
			this.endFrameIndex = endFrameIndex;
		}
		
		public function toString():String {
			var str:String;
			if(startFrameIndex == endFrameIndex) {
				str = "Frame: " + startFrameIndex;
			} else {
				str = "Frames: " + startFrameIndex + "-" + endFrameIndex;
			}
			str += ", Type: ";
			switch(type) {
				case TYPE_EMPTY: str += "EMPTY"; break;
				case TYPE_SPACER: str += "SPACER"; break;
				case TYPE_STATIC: str += "STATIC"; break;
				case TYPE_MOTIONTWEEN: str += "MOTIONTWEEN"; break;
				case TYPE_SHAPETWEEN: str += "SHAPETWEEN"; break;
				default: str += "unknown"; break;
			}
			return str;
		}
	}
}