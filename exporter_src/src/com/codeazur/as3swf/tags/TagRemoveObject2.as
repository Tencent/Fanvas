package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagRemoveObject2 extends TagRemoveObject implements IDisplayListTag
	{
		public static const TYPE:uint = 28;
		
		public function TagRemoveObject2() {}
		
		override public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			depth = data.readUI16();
		}
		
		override public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, 2);
			data.writeUI16(depth);
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "RemoveObject2"; }
		override public function get version():uint { return 3; }
		override public function get level():uint { return 2; }

		override public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"Depth: " + depth;
		}
	}
}
