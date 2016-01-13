package com.codeazur.as3swf.utils
{
	import com.codeazur.utils.StringUtils;

	public class ColorUtils
	{
		public static function alpha(color:uint):Number {
			return Number(color >>> 24) / 255;
		}

		public static function rgb(color:uint):uint {
			return (color & 0xffffff);
		}
		
		public static function r(color:uint):Number {
			return Number((rgb(color) >> 16) & 0xff) / 255;
		}
		
		public static function g(color:uint):Number {
			return Number((rgb(color) >> 8) & 0xff) / 255;
		}
		
		public static function b(color:uint):Number {
			return Number(rgb(color) & 0xff) / 255;
		}
		
		public static function interpolate(color1:uint, color2:uint, ratio:Number):uint {
			var r1:Number = r(color1);
			var g1:Number = g(color1);
			var b1:Number = b(color1);
			var alpha1:Number = alpha(color1);
			var ri:uint = uint((r1 + (r(color2) - r1) * ratio) * 255);
			var gi:uint = uint((g1 + (g(color2) - g1) * ratio) * 255);
			var bi:uint = uint((b1 + (b(color2) - b1) * ratio) * 255);
			var alphai:uint = uint((alpha1 + (alpha(color2) - alpha1) * ratio) * 255);
			return bi | (gi << 8) | (ri << 16) | (alphai << 24);
		}
		
		public static function rgbToString(color:uint):String
		{
			return StringUtils.printf("#%06x", (color & 0xffffff));
		}
		
		public static function rgbaToString(color:uint):String
		{
			return StringUtils.printf("#%06x(%02x)", (color & 0xffffff), (color >>> 24));
		}
		
		public static function argbToString(color:uint):String
		{
			return StringUtils.printf("#(%02x)%06x", (color >>> 24), (color & 0xffffff));
		}
	}
}
