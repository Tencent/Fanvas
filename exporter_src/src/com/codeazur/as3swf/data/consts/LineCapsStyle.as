package com.codeazur.as3swf.data.consts
{
	import flash.display.CapsStyle;

	public class LineCapsStyle
	{
		public static const ROUND:uint = 0;
		public static const NO:uint = 1;
		public static const SQUARE:uint = 2;
		
		public static function toString(lineCapsStyle:uint):String {
			switch(lineCapsStyle) {
				case ROUND: return CapsStyle.ROUND;
				case NO: return CapsStyle.NONE;
				case SQUARE: return CapsStyle.SQUARE;
				default: return "unknown";
			}
		}
	}
}
