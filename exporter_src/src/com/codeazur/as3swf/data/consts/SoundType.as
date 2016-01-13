package com.codeazur.as3swf.data.consts
{
	public class SoundType
	{
		public static const MONO:uint = 0;
		public static const STEREO:uint = 1;
		
		public static function toString(soundType:uint):String {
			switch(soundType) {
				case MONO: return "mono"; break;
				case STEREO: return "stereo"; break;
				default: return "unknown"; break;
			}
		}
	}
}
