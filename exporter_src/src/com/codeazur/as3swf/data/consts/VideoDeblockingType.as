package com.codeazur.as3swf.data.consts
{
	public class VideoDeblockingType
	{
		public static const VIDEOPACKET:uint = 0;
		public static const OFF:uint = 1;
		public static const LEVEL1:uint = 2;
		public static const LEVEL2:uint = 3;
		public static const LEVEL3:uint = 4;
		public static const LEVEL4:uint = 5;
		
		public static function toString(deblockingType:uint):String {
			switch(deblockingType) {
				case VIDEOPACKET: return "videopacket"; break;
				case OFF: return "off"; break;
				case LEVEL1: return "level 1"; break;
				case LEVEL2: return "level 2"; break;
				case LEVEL3: return "level 3"; break;
				case LEVEL4: return "level 4"; break;
				default: return "unknown"; break;
			}
		}
	}
}
