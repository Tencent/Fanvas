package com.codeazur.as3swf.data.consts
{
	public class SoundRate
	{
		public static const KHZ_5:uint = 0;
		public static const KHZ_11:uint = 1;
		public static const KHZ_22:uint = 2;
		public static const KHZ_44:uint = 3;
		
		public static function toString(soundRate:uint):String {
			switch(soundRate) {
				case KHZ_5: return "5.5kHz"; break;
				case KHZ_11: return "11kHz"; break;
				case KHZ_22: return "22kHz"; break;
				case KHZ_44: return "44kHz"; break;
				default: return "unknown"; break;
			}
		}
	}
}
