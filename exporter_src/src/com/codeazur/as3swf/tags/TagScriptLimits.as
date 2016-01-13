package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	
	public class TagScriptLimits implements ITag
	{
		public static const TYPE:uint = 65;
		
		public var maxRecursionDepth:uint;
		public var scriptTimeoutSeconds:uint;
		
		public function TagScriptLimits() {}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			maxRecursionDepth = data.readUI16();
			scriptTimeoutSeconds = data.readUI16();
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, 4);
			data.writeUI16(maxRecursionDepth);
			data.writeUI16(scriptTimeoutSeconds);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "ScriptLimits"; }
		public function get version():uint { return 7; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"MaxRecursionDepth: " + maxRecursionDepth + ", " +
				"ScriptTimeoutSeconds: " + scriptTimeoutSeconds;
		}
	}
}
