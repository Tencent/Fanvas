package com.codeazur.as3swf.tags
{
	import com.codeazur.utils.StringUtils;
	
	public class TagDefineText2 extends TagDefineText implements IDefinitionTag
	{
		public static const TYPE:uint = 33;
		
		public function TagDefineText2() {}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "DefineText2"; }
		override public function get version():uint { return 3; }
		override public function get level():uint { return 2; }
		
		override public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Bounds: " + textBounds + ", " +
				"Matrix: " + textMatrix;
			if (_records.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "TextRecords:";
				for (var i:uint = 0; i < _records.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + _records[i].toString();
				}
			}
			return str;
		}
	}
}
