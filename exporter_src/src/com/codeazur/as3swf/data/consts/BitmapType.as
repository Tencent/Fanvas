package com.codeazur.as3swf.data.consts
{
	public class BitmapType
	{
		public static const JPEG:uint = 1;
		public static const GIF89A:uint = 2;
		public static const PNG:uint = 3;
		
		public static function toString(bitmapFormat:uint):String {
			switch(bitmapFormat) {
				case JPEG: return "JPEG"; break;
				case GIF89A: return "GIF89a"; break;
				case PNG: return "PNG"; break;
				default: return "unknown"; break;
			}
		}
	}
}
