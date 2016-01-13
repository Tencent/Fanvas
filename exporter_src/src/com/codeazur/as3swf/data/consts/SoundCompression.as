package com.codeazur.as3swf.data.consts
{
	public class SoundCompression
	{
		public static const UNCOMPRESSED_NATIVE_ENDIAN:uint = 0;
		public static const ADPCM:uint = 1;
		public static const MP3:uint = 2;
		public static const UNCOMPRESSED_LITTLE_ENDIAN:uint = 3;
		public static const NELLYMOSER_16_KHZ:uint = 4;
		public static const NELLYMOSER_8_KHZ:uint = 5;
		public static const NELLYMOSER:uint = 6;
		public static const SPEEX:uint = 11;
		
		public static function toString(soundCompression:uint):String {
			switch(soundCompression) {
				case UNCOMPRESSED_NATIVE_ENDIAN: return "Uncompressed Native Endian"; break;
				case ADPCM: return "ADPCM"; break;
				case MP3: return "MP3"; break;
				case UNCOMPRESSED_LITTLE_ENDIAN: return "Uncompressed Little Endian"; break;
				case NELLYMOSER_16_KHZ: return "Nellymoser 16kHz"; break;
				case NELLYMOSER_8_KHZ: return "Nellymoser 8kHz"; break;
				case NELLYMOSER: return "Nellymoser"; break;
				case SPEEX: return "Speex"; break;
				default: return "unknown"; break;
			}
		}
	}
}
