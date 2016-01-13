package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFFillStyle;
	import com.codeazur.as3swf.data.SWFLineStyle;
	import com.codeazur.as3swf.data.SWFMorphFillStyle;
	import com.codeazur.as3swf.data.SWFMorphLineStyle;
	import com.codeazur.as3swf.data.SWFRectangle;
	import com.codeazur.as3swf.data.SWFShape;
	import com.codeazur.as3swf.data.SWFShapeRecord;
	import com.codeazur.as3swf.data.SWFShapeRecordCurvedEdge;
	import com.codeazur.as3swf.data.SWFShapeRecordStraightEdge;
	import com.codeazur.as3swf.data.SWFShapeRecordStyleChange;
	import com.codeazur.as3swf.exporters.core.IShapeExporter;
	import com.codeazur.utils.StringUtils;
	
	public class TagDefineMorphShape implements IDefinitionTag
	{
		public static const TYPE:uint = 46;
		
		public var startBounds:SWFRectangle;
		public var endBounds:SWFRectangle;
		public var startEdges:SWFShape;
		public var endEdges:SWFShape;
		
		protected var _characterId:uint;
		
		protected var _morphFillStyles:Vector.<SWFMorphFillStyle>;
		protected var _morphLineStyles:Vector.<SWFMorphLineStyle>;
		
		public function TagDefineMorphShape() {
			_morphFillStyles = new Vector.<SWFMorphFillStyle>();
			_morphLineStyles = new Vector.<SWFMorphLineStyle>();
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function get morphFillStyles():Vector.<SWFMorphFillStyle> { return _morphFillStyles; }
		public function get morphLineStyles():Vector.<SWFMorphLineStyle> { return _morphLineStyles; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			startBounds = data.readRECT();
			endBounds = data.readRECT();
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
				_morphLineStyles.push(data.readMORPHLINESTYLE());
			}
			startEdges = data.readSHAPE();
			endEdges = data.readSHAPE();
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			body.writeRECT(startBounds);
			body.writeRECT(endBounds);
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
				startBytes.writeMORPHLINESTYLE(_morphLineStyles[i])
			}
			startBytes.writeSHAPE(startEdges);
			body.writeUI32(startBytes.length);
			body.writeBytes(startBytes);
			body.writeSHAPE(endEdges);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineMorphShape = new TagDefineMorphShape();
			throw(new Error("Not implemented yet."));
			return tag;
		}
		
		public function export(handler:IShapeExporter = null, ratio:Number = 0):void {
			var i:uint;
			var j:uint = 0;
			var exportShape:SWFShape = new SWFShape();
			var numEdges:uint = startEdges.records.length;
			for(i = 0; i < numEdges; i++) {
				var startRecord:SWFShapeRecord = startEdges.records[i];
				// Ignore start records that are style change records and don't have moveTo
				// The end record index is not incremented, because end records do not have
				// style change records without moveTo's.
				if(startRecord.type == SWFShapeRecord.TYPE_STYLECHANGE && !SWFShapeRecordStyleChange(startRecord).stateMoveTo) {
					exportShape.records.push(startRecord.clone());
					continue;
				}
				var endRecord:SWFShapeRecord = endEdges.records[j++];
				var exportRecord:SWFShapeRecord;
				// It is possible for an edge to change type over the course of a morph sequence. 
				// A straight edge can become a curved edge and vice versa
				// Convert straight edge to curved edge, if needed:
				if(startRecord.type == SWFShapeRecord.TYPE_CURVEDEDGE && endRecord.type == SWFShapeRecord.TYPE_STRAIGHTEDGE) {
					endRecord = convertToCurvedEdge(endRecord as SWFShapeRecordStraightEdge);
				} else if(startRecord.type == SWFShapeRecord.TYPE_STRAIGHTEDGE && endRecord.type == SWFShapeRecord.TYPE_CURVEDEDGE) {
					startRecord = convertToCurvedEdge(startRecord as SWFShapeRecordStraightEdge);
				}
				switch(startRecord.type) {
					case SWFShapeRecord.TYPE_STYLECHANGE:
						var startStyleChange:SWFShapeRecordStyleChange = startRecord.clone() as SWFShapeRecordStyleChange;
						var endStyleChange:SWFShapeRecordStyleChange = endRecord as SWFShapeRecordStyleChange;
						startStyleChange.moveDeltaX += (endStyleChange.moveDeltaX - startStyleChange.moveDeltaX) * ratio;
						startStyleChange.moveDeltaY += (endStyleChange.moveDeltaY - startStyleChange.moveDeltaY) * ratio;
						exportRecord = startStyleChange;
						break;
					case SWFShapeRecord.TYPE_STRAIGHTEDGE:
						var startStraightEdge:SWFShapeRecordStraightEdge = startRecord.clone() as SWFShapeRecordStraightEdge;
						var endStraightEdge:SWFShapeRecordStraightEdge = endRecord as SWFShapeRecordStraightEdge;
						startStraightEdge.deltaX += (endStraightEdge.deltaX - startStraightEdge.deltaX) * ratio;
						startStraightEdge.deltaY += (endStraightEdge.deltaY - startStraightEdge.deltaY) * ratio;
						if(startStraightEdge.deltaX != 0 && startStraightEdge.deltaY != 0) {
							startStraightEdge.generalLineFlag = true;
							startStraightEdge.vertLineFlag = false;
						} else {
							startStraightEdge.generalLineFlag = false;
							startStraightEdge.vertLineFlag = (startStraightEdge.deltaX == 0);
						}
						exportRecord = startStraightEdge;
						break;
					case SWFShapeRecord.TYPE_CURVEDEDGE:
						var startCurvedEdge:SWFShapeRecordCurvedEdge = startRecord.clone() as SWFShapeRecordCurvedEdge;
						var endCurvedEdge:SWFShapeRecordCurvedEdge = endRecord as SWFShapeRecordCurvedEdge;
						startCurvedEdge.controlDeltaX += (endCurvedEdge.controlDeltaX - startCurvedEdge.controlDeltaX) * ratio;
						startCurvedEdge.controlDeltaY += (endCurvedEdge.controlDeltaY - startCurvedEdge.controlDeltaY) * ratio;
						startCurvedEdge.anchorDeltaX += (endCurvedEdge.anchorDeltaX - startCurvedEdge.anchorDeltaX) * ratio;
						startCurvedEdge.anchorDeltaY += (endCurvedEdge.anchorDeltaY - startCurvedEdge.anchorDeltaY) * ratio;
						exportRecord = startCurvedEdge;
						break;
					case SWFShapeRecord.TYPE_END:
						exportRecord = startRecord.clone();
						break;
				}
				exportShape.records.push(exportRecord);
			}
			for(i = 0; i < morphFillStyles.length; i++) {
				exportShape.fillStyles.push(morphFillStyles[i].getMorphedFillStyle(ratio));
			}
			for(i = 0; i < morphLineStyles.length; i++) {
				exportShape.lineStyles.push(morphLineStyles[i].getMorphedLineStyle(ratio));
			}
			exportShape.export(handler);
		}
		
		protected function convertToCurvedEdge(straightEdge:SWFShapeRecordStraightEdge):SWFShapeRecordCurvedEdge {
			var curvedEdge:SWFShapeRecordCurvedEdge = new SWFShapeRecordCurvedEdge();
			curvedEdge.controlDeltaX = straightEdge.deltaX / 2;
			curvedEdge.controlDeltaY = straightEdge.deltaY / 2;
			curvedEdge.anchorDeltaX = straightEdge.deltaX;
			curvedEdge.anchorDeltaY = straightEdge.deltaY;
			return curvedEdge;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineMorphShape"; }
		public function get version():uint { return 3; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var i:uint;
			var indent2:String = StringUtils.repeat(indent + 2);
			var indent4:String = StringUtils.repeat(indent + 4);
			var str:String = Tag.toStringCommon(type, name, indent) + "ID: " + characterId;
			str += "\n" + indent2 + "Bounds:";
			str += "\n" + indent4 + "StartBounds: " + startBounds.toString();
			str += "\n" + indent4 + "EndBounds: " + endBounds.toString();
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
