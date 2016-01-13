package com.codeazur.as3swf.utils
{
	public class ObjCUtils
	{
		public static function num2str(n:Number, twips:Boolean = false):String {
			if(twips) { n = Math.round(n * 100) / 100; }
			var s:String = n.toString();
			if (s.indexOf(".") == -1) {
				s += ".0";
			}
			return s + "f";
		}
	}
}
