package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFMorphLineStyle2;
	import com.codeazur.as3swf.data.SWFRectangle;
	import com.codeazur.utils.StringUtils;
	
	public class TagDefineMorphShape2 extends TagDefineMorphShape implements ITag
	{
		public static const TYPE:uint = 84;
		
		public var startEdgeBounds:SWFRectangle;
		public var endEdgeBounds:SWFRectangle;
		public var usesNonScalingStrokes:Boolean;
		public var usesScalingStrokes:Boolean;
		
		public function TagDefineMorphShape2() {}
		
		override public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			startBounds = data.readRECT();
			endBounds = data.readRECT();
			startEdgeBounds = data.readRECT();
			endEdgeBounds = data.readRECT();
			var flags:uint = data.readUI8();
			usesNonScalingStrokes = ((flags & 0x02) != 0);
			usesScalingStrokes = ((flags & 0x01) != 0);
			var offset:uint = data.readUI32();
			var i:uint;
			// MorphFillStyleArray
			var fillStyleCount:uint = data.readUI8();
			if (fillStyleCount == 0xff) {
				fillStyleCount = data.readUI16();
			}
			for (i = 0; i < fillStyleCount; i++) {
				_morphFillStyles.push(data.readMORPHFILLSTYLE());
			}
			// MorphLineStyleArray
			var lineStyleCount:uint = data.readUI8();
			if (lineStyleCount == 0xff) {
				lineStyleCount = data.readUI16();
			}
			for (i = 0; i < lineStyleCount; i++) {
				_morphLineStyles.push(data.readMORPHLINESTYLE2());
			}
			startEdges = data.readSHAPE();
			endEdges = data.readSHAPE();
		}
		
		override public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			body.writeRECT(startBounds);
			body.writeRECT(endBounds);
			body.writeRECT(startEdgeBounds);
			body.writeRECT(endEdgeBounds);
			var flags:uint = 0;
			if(usesNonScalingStrokes) { flags |= 0x02; }
			if(usesScalingStrokes) { flags |= 0x01; }
			body.writeUI8(flags);
			var startBytes:SWFData = new SWFData();
			var i:uint;
			// MorphFillStyleArray
			var fillStyleCount:uint = _morphFillStyles.length;
			if (fillStyleCount > 0xfe) {
				startBytes.writeUI8(0xff);
				startBytes.writeUI16(fillStyleCount);
			} else {
				startBytes.writeUI8(fillStyleCount);
			}
			for (i = 0; i < fillStyleCount; i++) {
				startBytes.writeMORPHFILLSTYLE(_morphFillStyles[i])
			}
			// MorphLineStyleArray
			var lineStyleCount:uint = _morphLineStyles.length;
			if (lineStyleCount > 0xfe) {
				startBytes.writeUI8(0xff);
				startBytes.writeUI16(lineStyleCount);
			} else {
				startBytes.writeUI8(lineStyleCount);
			}
			for (i = 0; i < lineStyleCount; i++) {
				startBytes.writeMORPHLINESTYLE2(SWFMorphLineStyle2(_morphLineStyles[i]));
			}
			startBytes.writeSHAPE(startEdges);
			body.writeUI32(startBytes.length);
			body.writeBytes(startBytes);
			body.writeSHAPE(endEdges);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "DefineMorphShape2"; }
		override public function get version():uint { return 8; }
		override public function get level():uint { return 2; }
		
		override public function toString(indent:uint = 0, flags:uint = 0):String {
			var i:uint;
			var indent2:String = StringUtils.repeat(indent + 2);
			var indent4:String = StringUtils.repeat(indent + 4);
			var str:String = Tag.toStringCommon(type, name, indent) + "ID: " + characterId;
			str += "\n" + indent2 + "Bounds:";
			str += "\n" + indent4 + "StartBounds: " + startBounds.toString();
			str += "\n" + indent4 + "EndBounds: " + endBounds.toString();
			str += "\n" + indent4 + "StartEdgeBounds: " + startEdgeBounds.toString();
			str += "\n" + indent4 + "EndEdgeBounds: " + endEdgeBounds.toString();
			if(_morphFillStyles.length > 0) {
				str += "\n" + indent2 + "FillStyles:";
				for(i = 0; i < _morphFillStyles.length; i++) {
					str += "\n" + indent4 + "[" + (i + 1) + "] " + _morphFillStyles[i].toString();
				}
			}
			if(_morphLineStyles.length > 0) {
				str += "\n" + indent2 + "LineStyles:";
				for(i = 0; i < _morphLineStyles.length; i++) {
					str += "\n" + indent4 + "[" + (i + 1) + "] " + _morphLineStyles[i].toString();
				}
			}
			str += startEdges.toString(indent + 2);
			str += endEdges.toString(indent + 2);
			return str;
		}
	}
}
