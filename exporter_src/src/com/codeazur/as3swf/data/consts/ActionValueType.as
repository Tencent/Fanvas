package com.codeazur.as3swf.data.consts
{
	public class ActionValueType
	{
		public static const STRING:uint = 0;
		public static const FLOAT:uint = 1;
		public static const NULL:uint = 2;
		public static const UNDEFINED:uint = 3;
		public static const REGISTER:uint = 4;
		public static const BOOLEAN:uint = 5;
		public static const DOUBLE:uint = 6;
		public static const INTEGER:uint = 7;
		public static const CONSTANT_8:uint = 8;
		public static const CONSTANT_16:uint = 9;
		
		public static function toString(bitmapFormat:uint):String {
			switch(bitmapFormat) {
				case STRING: return "string"; break;
				case FLOAT: return "float"; break;
				case NULL: return "null"; break;
				case UNDEFINED: return "undefined"; break;
				case REGISTER: return "register"; break;
				case BOOLEAN: return "boolean"; break;
				case DOUBLE: return "double"; break;
				case INTEGER: return "integer"; break;
				case CONSTANT_8: return "constant8"; break;
				case CONSTANT_16: return "constant16"; break;
				default: return "unknown"; break;
			}
		}
	}
}
