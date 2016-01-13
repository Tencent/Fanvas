package com.codeazur.as3swf.data.consts
{
	import flash.display.SpreadMethod;
	
	public class GradientSpreadMode
	{
		public static const PAD:uint = 0;
		public static const REFLECT:uint = 1;
		public static const REPEAT:uint = 2;
		
		public static function toString(spreadMode:uint):String {
			switch(spreadMode) {
				case PAD: return SpreadMethod.PAD; break;
				case REFLECT: return SpreadMethod.REFLECT; break;
				case REPEAT: return SpreadMethod.REPEAT; break;
				default: return "unknown"; break;
			}
		}
	}
}
