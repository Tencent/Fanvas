package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagRemoveObject implements IDisplayListTag
	{
		public static const TYPE:uint = 5;
		
		public var characterId:uint = 0;
		public var depth:uint;
		
		public function TagRemoveObject() {}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			characterId = data.readUI16();
			depth = data.readUI16();
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, 4);
			data.writeUI16(characterId);
			data.writeUI16(depth);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "RemoveObject"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"CharacterID: " + characterId + ", " +
				"Depth: " + depth;
		}
	}
}
