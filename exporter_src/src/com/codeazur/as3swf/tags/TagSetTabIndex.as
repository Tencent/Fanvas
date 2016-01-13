package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagSetTabIndex implements ITag
	{
		public static const TYPE:uint = 66;
		
		public var depth:uint;
		public var tabIndex:uint;
		
		public function TagSetTabIndex() {}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			depth = data.readUI16();
			tabIndex = data.readUI16();
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, 4);
			data.writeUI16(depth);
			data.writeUI16(tabIndex);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "SetTabIndex"; }
		public function get version():uint { return 7; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"Depth: " + depth + ", " +
				"TabIndex: " + tabIndex;
		}
	}
}
