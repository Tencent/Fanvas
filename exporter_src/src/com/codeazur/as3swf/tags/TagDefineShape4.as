package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFRectangle;
	import com.codeazur.utils.StringUtils;
	
	public class TagDefineShape4 extends TagDefineShape3 implements IDefinitionTag
	{
		public static const TYPE:uint = 83;
		
		public var edgeBounds:SWFRectangle;
		public var usesFillWindingRule:Boolean;
		public var usesNonScalingStrokes:Boolean;
		public var usesScalingStrokes:Boolean;

		public function TagDefineShape4() {}
		
		override public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			shapeBounds = data.readRECT();
			edgeBounds = data.readRECT();
			var flags:uint = data.readUI8();
			usesFillWindingRule = ((flags & 0x04) != 0);
			usesNonScalingStrokes = ((flags & 0x02) != 0);
			usesScalingStrokes = ((flags & 0x01) != 0);
			shapes = data.readSHAPEWITHSTYLE(level);
		}
		
		override public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			body.writeRECT(shapeBounds);
			body.writeRECT(edgeBounds);
			var flags:uint = 0;
			if(usesFillWindingRule) { flags |= 0x04; }
			if(usesNonScalingStrokes) { flags |= 0x02; }
			if(usesScalingStrokes) { flags |= 0x01; }
			body.writeUI8(flags);
			body.writeSHAPEWITHSTYLE(shapes, level);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "DefineShape4"; }
		override public function get version():uint { return 8; }
		override public function get level():uint { return 4; }
		
		override public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) + "ID: " + characterId + ", ";
			if(usesFillWindingRule) { str += "UsesFillWindingRule, "; }
			if(usesNonScalingStrokes) { str += "UsesNonScalingStrokes, "; }
			if(usesScalingStrokes) { str += "UsesScalingStrokes, "; }
			str += "ShapeBounds: " + shapeBounds + ", EdgeBounds: " + edgeBounds;
			str += shapes.toString(indent + 2);
			return str;
		}
	}
}
