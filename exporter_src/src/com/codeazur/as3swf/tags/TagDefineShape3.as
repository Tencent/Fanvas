package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagDefineShape3 extends TagDefineShape2 implements IDefinitionTag
	{
		public static const TYPE:uint = 32;
		
		public function TagDefineShape3() {}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "DefineShape3"; }
		override public function get version():uint { return 3; }
		override public function get level():uint { return 3; }
		
		override public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Bounds: " + shapeBounds;
			str += shapes.toString(indent + 2);
			return str;
		}
	}
}
