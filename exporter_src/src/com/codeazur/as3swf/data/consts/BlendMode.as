package com.codeazur.as3swf.data.consts
{
	public class BlendMode
	{
		public static const NORMAL_0:uint = 0;
		public static const NORMAL_1:uint = 1;
		public static const LAYER:uint = 2;
		public static const MULTIPLY:uint = 3;
		public static const SCREEN:uint = 4;
		public static const LIGHTEN:uint = 5;
		public static const DARKEN:uint = 6;
		public static const DIFFERENCE:uint = 7;
		public static const ADD:uint = 8;
		public static const SUBTRACT:uint = 9;
		public static const INVERT:uint = 10;
		public static const ALPHA:uint = 11;
		public static const ERASE:uint = 12;
		public static const OVERLAY:uint = 13;
		public static const HARDLIGHT:uint = 14;
		
		public static function toString(blendMode:uint):String {
			switch(blendMode) {
				case NORMAL_0:
				case NORMAL_1: 
					return "normal";
					break;
				case LAYER: return "layer"; break;
				case MULTIPLY: return "multiply"; break;
				case SCREEN: return "screen"; break;
				case LIGHTEN: return "lighten"; break;
				case DARKEN: return "darken"; break;
				case DIFFERENCE: return "difference"; break;
				case ADD: return "add"; break;
				case SUBTRACT: return "subtract"; break;
				case INVERT: return "invert"; break;
				case ALPHA: return "alpha"; break;
				case ERASE: return "erase"; break;
				case OVERLAY: return "overlay"; break;
				case HARDLIGHT: return "hardlight"; break;
				default: return "unknown"; break;
			}
		}
	}
}
