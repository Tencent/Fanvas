package com.codeazur.as3swf.data.consts
{
	public class CSMTableHint
	{
		public static const THIN:uint = 0;
		public static const MEDIUM:uint = 1;
		public static const THICK:uint = 2;
		
		public static function toString(csmTableHint:uint):String {
			switch(csmTableHint) {
				case THIN: return "thin"; break;
				case MEDIUM: return "medium"; break;
				case THICK: return "thick"; break;
				default: return "unknown"; break;
			}
		}
	}
}
