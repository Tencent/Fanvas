package com.codeazur.as3swf.tags
{
	import com.codeazur.utils.StringUtils;
	
	public class Tag
	{
		public static function toStringCommon(type:uint, name:String, indent:uint = 0):String {
			return StringUtils.repeat(indent) + "[" + StringUtils.printf("%02d", type) + ":" + name + "] ";
		}
	}
}
