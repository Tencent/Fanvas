package com.codeazur.as3swf.data.consts
{
	import flash.display.InterpolationMethod;
	
	public class GradientInterpolationMode
	{
		public static const NORMAL:uint = 0;
		public static const LINEAR:uint = 1;
		
		public static function toString(interpolationMode:uint):String {
			switch(interpolationMode) {
				case NORMAL: return InterpolationMethod.RGB; break;
				case LINEAR: return InterpolationMethod.LINEAR_RGB; break;
				default: return InterpolationMethod.RGB; break;
			}
		}
	}
}
