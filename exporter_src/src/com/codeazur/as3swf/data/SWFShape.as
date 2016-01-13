package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.GradientInterpolationMode;
	import com.codeazur.as3swf.data.consts.GradientSpreadMode;
	import com.codeazur.as3swf.data.consts.LineCapsStyle;
	import com.codeazur.as3swf.data.consts.LineJointStyle;
	import com.codeazur.as3swf.data.etc.CurvedEdge;
	import com.codeazur.as3swf.data.etc.IEdge;
	import com.codeazur.as3swf.data.etc.StraightEdge;
	import com.codeazur.as3swf.exporters.core.DefaultShapeExporter;
	import com.codeazur.as3swf.exporters.core.IShapeExporter;
	import com.codeazur.as3swf.utils.ColorUtils;
	import com.codeazur.as3swf.utils.NumberUtils;
	import com.codeazur.utils.StringUtils;
	
	import flash.display.GradientType;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class SWFShape
	{
		protected var _records:Vector.<SWFShapeRecord>;

		protected var _fillStyles:Vector.<SWFFillStyle>;
		protected var _lineStyles:Vector.<SWFLineStyle>;
		protected var _referencePoint:Point;
		
		protected var fillEdgeMaps:Vector.<Dictionary>;
		protected var lineEdgeMaps:Vector.<Dictionary>;
		protected var currentFillEdgeMap:Dictionary;
		protected var currentLineEdgeMap:Dictionary;
		protected var numGroups:uint;
		protected var coordMap:Dictionary;
		
		protected var unitDivisor:Number;
		
		protected var edgeMapsCreated:Boolean = false;
		
		public function SWFShape(data:SWFData = null, level:uint = 1, unitDivisor:Number = 20) {
			_records = new Vector.<SWFShapeRecord>();
			_fillStyles = new Vector.<SWFFillStyle>();
			_lineStyles = new Vector.<SWFLineStyle>();
			_referencePoint = new Point(0, 0);
			this.unitDivisor = unitDivisor;
			if (data != null) {
				parse(data, level);
			}
		}
		
		public function get records():Vector.<SWFShapeRecord> { return _records; }

		public function get fillStyles():Vector.<SWFFillStyle> { return _fillStyles; }
		public function get lineStyles():Vector.<SWFLineStyle> { return _lineStyles; }

		// The reference point is used with font glyphs
		public function get referencePoint():Point { return _referencePoint; }

		public function getMaxFillStyleIndex():uint {
			var ret:uint = 0;
			for(var i:uint = 0; i < records.length; i++) {
				var shapeRecord:SWFShapeRecord = records[i];
				if(shapeRecord.type == SWFShapeRecord.TYPE_STYLECHANGE) {
					var shapeRecordStyleChange:SWFShapeRecordStyleChange = shapeRecord as SWFShapeRecordStyleChange;
					if(shapeRecordStyleChange.fillStyle0 > ret) {
						ret = shapeRecordStyleChange.fillStyle0;
					}
					if(shapeRecordStyleChange.fillStyle1 > ret) {
						ret = shapeRecordStyleChange.fillStyle1;
					}
					if(shapeRecordStyleChange.stateNewStyles) {
						break;
					}
				} 
			}
			return ret;
		}
		
		public function getMaxLineStyleIndex():uint {
			var ret:uint = 0;
			for(var i:uint = 0; i < records.length; i++) {
				var shapeRecord:SWFShapeRecord = records[i];
				if(shapeRecord.type == SWFShapeRecord.TYPE_STYLECHANGE) {
					var shapeRecordStyleChange:SWFShapeRecordStyleChange = shapeRecord as SWFShapeRecordStyleChange;
					if(shapeRecordStyleChange.lineStyle > ret) {
						ret = shapeRecordStyleChange.lineStyle;
					}
					if(shapeRecordStyleChange.stateNewStyles) {
						break;
					}
				} 
			}
			return ret;
		}
		
		public function parse(data:SWFData, level:uint = 1):void {
			data.resetBitsPending();
			var numFillBits:uint = data.readUB(4);
			var numLineBits:uint = data.readUB(4);
			readShapeRecords(data, numFillBits, numLineBits, level);
			determineReferencePoint();
		}
		
		public function publish(data:SWFData, level:uint = 1):void {
			var numFillBits:uint = data.calculateMaxBits(false, [getMaxFillStyleIndex()]);
			var numLineBits:uint = data.calculateMaxBits(false, [getMaxLineStyleIndex()]);
			data.resetBitsPending();
			data.writeUB(4, numFillBits);
			data.writeUB(4, numLineBits);
			writeShapeRecords(data, numFillBits, numLineBits, level);
		}
		
		protected function readShapeRecords(data:SWFData, fillBits:uint, lineBits:uint, level:uint = 1):void {
			var shapeRecord:SWFShapeRecord;
			while (!(shapeRecord is SWFShapeRecordEnd)) {
				// The SWF10 spec says that shape records are byte aligned.
				// In reality they seem not to be?
				// bitsPending = 0;
				var edgeRecord:Boolean = (data.readUB(1) == 1);
				if (edgeRecord) {
					var straightFlag:Boolean = (data.readUB(1) == 1);
					var numBits:uint = data.readUB(4) + 2;
					if (straightFlag) {
						shapeRecord = data.readSTRAIGHTEDGERECORD(numBits);
					} else {
						shapeRecord = data.readCURVEDEDGERECORD(numBits);
					}
				} else {
					var states:uint = data.readUB(5);
					if (states == 0) {
						shapeRecord = new SWFShapeRecordEnd();
					} else {
						var styleChangeRecord:SWFShapeRecordStyleChange = data.readSTYLECHANGERECORD(states, fillBits, lineBits, level);
						if (styleChangeRecord.stateNewStyles) {
							fillBits = styleChangeRecord.numFillBits;
							lineBits = styleChangeRecord.numLineBits;
						}
						shapeRecord = styleChangeRecord;
					}
				}
				_records.push(shapeRecord);
			}
		}

		protected function writeShapeRecords(data:SWFData, fillBits:uint, lineBits:uint, level:uint = 1):void {
			if(records.length == 0 || !(records[records.length - 1] is SWFShapeRecordEnd)) {
				records.push(new SWFShapeRecordEnd());
			}
			for(var i:uint = 0; i < records.length; i++) {
				var shapeRecord:SWFShapeRecord = records[i];
				if(shapeRecord.isEdgeRecord) {
					// EdgeRecordFlag (set)
					data.writeUB(1, 1);
					if(shapeRecord.type == SWFShapeRecord.TYPE_STRAIGHTEDGE) {
						// StraightFlag (set)
						data.writeUB(1, 1);
						data.writeSTRAIGHTEDGERECORD(SWFShapeRecordStraightEdge(shapeRecord));
					} else {
						// StraightFlag (not set)
						data.writeUB(1, 0);
						data.writeCURVEDEDGERECORD(SWFShapeRecordCurvedEdge(shapeRecord));
					}
				} else {
					// EdgeRecordFlag (not set)
					data.writeUB(1, 0);
					if(shapeRecord.type == SWFShapeRecord.TYPE_END) {
						data.writeUB(5, 0);
					} else {
						var states:uint = 0;
						var styleChangeRecord:SWFShapeRecordStyleChange = shapeRecord as SWFShapeRecordStyleChange;
						if(styleChangeRecord.stateNewStyles) { states |= 0x10; }
						if(styleChangeRecord.stateLineStyle) { states |= 0x08; }
						if(styleChangeRecord.stateFillStyle1) { states |= 0x04; }
						if(styleChangeRecord.stateFillStyle0) { states |= 0x02; }
						if(styleChangeRecord.stateMoveTo) { states |= 0x01; }
						data.writeUB(5, states);
						data.writeSTYLECHANGERECORD(styleChangeRecord, fillBits, lineBits, level);
						if (styleChangeRecord.stateNewStyles) {
							fillBits = styleChangeRecord.numFillBits;
							lineBits = styleChangeRecord.numLineBits;
						}
					}
				}
			}
		}
		
		protected function determineReferencePoint():void {
			var styleChangeRecord:SWFShapeRecordStyleChange = _records[0] as SWFShapeRecordStyleChange;
			if(styleChangeRecord && styleChangeRecord.stateMoveTo) {
				referencePoint.x = NumberUtils.roundPixels400(styleChangeRecord.moveDeltaX / unitDivisor);
				referencePoint.y = NumberUtils.roundPixels400(styleChangeRecord.moveDeltaY / unitDivisor);
			}
		}
		
		public function export(handler:IShapeExporter = null):void {
			// Reset the flag so that shapes can be exported multiple times
			// TODO: This is a temporary bug fix. edgeMaps shouldn't need to be recreated for subsequent exports
			edgeMapsCreated = false;
			// Create edge maps
			createEdgeMaps();
			// If no handler is passed, default to DefaultShapeExporter (does nothing)
			if (handler == null) { handler = new DefaultShapeExporter(null); }
			// Let the doc handler know that a shape export starts
			handler.beginShape();
			// Export fills and strokes for each group separately
			for (var i:int = 0; i < numGroups; i++) {
				// Export fills first
				exportFillPath(handler, i);
				// Export strokes last
				exportLinePath(handler, i);
			}
			// Let the doc handler know that we're done exporting a shape
			handler.endShape();
		}
		
		protected function createEdgeMaps():void {
			if(!edgeMapsCreated) {
				var xPos:Number = 0;
				var yPos:Number = 0;
				var from:Point;
				var to:Point;
				var control:Point;
				var fillStyleIdxOffset:int = 0;
				var lineStyleIdxOffset:int = 0;
				var currentFillStyleIdx0:uint = 0;
				var currentFillStyleIdx1:uint = 0;
				var currentLineStyleIdx:uint = 0;
				var subPath:Vector.<IEdge> = new Vector.<IEdge>();
				numGroups = 0;
				fillEdgeMaps = new Vector.<Dictionary>();
				lineEdgeMaps = new Vector.<Dictionary>();
				currentFillEdgeMap = new Dictionary();
				currentLineEdgeMap = new Dictionary();
				for (var i:uint = 0; i < _records.length; i++) {
					var shapeRecord:SWFShapeRecord = _records[i];
					switch(shapeRecord.type) {
						case SWFShapeRecord.TYPE_STYLECHANGE:
							var styleChangeRecord:SWFShapeRecordStyleChange = shapeRecord as SWFShapeRecordStyleChange;
							if (styleChangeRecord.stateLineStyle || styleChangeRecord.stateFillStyle0 || styleChangeRecord.stateFillStyle1) {
								processSubPath(subPath, currentLineStyleIdx, currentFillStyleIdx0, currentFillStyleIdx1);
								subPath = new Vector.<IEdge>();
							}
							if (styleChangeRecord.stateNewStyles) {
								fillStyleIdxOffset = _fillStyles.length;
								lineStyleIdxOffset = _lineStyles.length;
								appendFillStyles(_fillStyles, styleChangeRecord.fillStyles);
								appendLineStyles(_lineStyles, styleChangeRecord.lineStyles);
							}
							// Check if all styles are reset to 0.
							// This (probably) means that a new group starts with the next record
							if (styleChangeRecord.stateLineStyle && styleChangeRecord.lineStyle == 0 &&
								styleChangeRecord.stateFillStyle0 && styleChangeRecord.fillStyle0 == 0 &&
								styleChangeRecord.stateFillStyle1 && styleChangeRecord.fillStyle1 == 0) {
									cleanEdgeMap(currentFillEdgeMap);
									cleanEdgeMap(currentLineEdgeMap);
									fillEdgeMaps.push(currentFillEdgeMap);
									lineEdgeMaps.push(currentLineEdgeMap);
									currentFillEdgeMap = new Dictionary();
									currentLineEdgeMap = new Dictionary();
									currentLineStyleIdx = 0;
									currentFillStyleIdx0 = 0;
									currentFillStyleIdx1 = 0;
									numGroups++;
							} else {
								if (styleChangeRecord.stateLineStyle) {
									currentLineStyleIdx = styleChangeRecord.lineStyle;
									if (currentLineStyleIdx > 0) {
										currentLineStyleIdx += lineStyleIdxOffset;
									}
								}
								if (styleChangeRecord.stateFillStyle0) {
									currentFillStyleIdx0 = styleChangeRecord.fillStyle0;
									if (currentFillStyleIdx0 > 0) {
										currentFillStyleIdx0 += fillStyleIdxOffset;
									}
								}
								if (styleChangeRecord.stateFillStyle1) {
									currentFillStyleIdx1 = styleChangeRecord.fillStyle1;
									if (currentFillStyleIdx1 > 0) {
										currentFillStyleIdx1 += fillStyleIdxOffset;
									}
								}
							}
							if (styleChangeRecord.stateMoveTo) {
								xPos = styleChangeRecord.moveDeltaX / unitDivisor;
								yPos = styleChangeRecord.moveDeltaY / unitDivisor;
							}
							break;
						case SWFShapeRecord.TYPE_STRAIGHTEDGE:
							var straightEdgeRecord:SWFShapeRecordStraightEdge = shapeRecord as SWFShapeRecordStraightEdge;
							from = new Point(NumberUtils.roundPixels400(xPos), NumberUtils.roundPixels400(yPos));
							if (straightEdgeRecord.generalLineFlag) {
								xPos += straightEdgeRecord.deltaX / unitDivisor;
								yPos += straightEdgeRecord.deltaY / unitDivisor;
							} else {
								if (straightEdgeRecord.vertLineFlag) {
									yPos += straightEdgeRecord.deltaY / unitDivisor;
								} else {
									xPos += straightEdgeRecord.deltaX / unitDivisor;
								}
							}
							to = new Point(NumberUtils.roundPixels400(xPos), NumberUtils.roundPixels400(yPos));
							subPath.push(new StraightEdge(from, to, currentLineStyleIdx, currentFillStyleIdx1));
							break;
						case SWFShapeRecord.TYPE_CURVEDEDGE:
							var curvedEdgeRecord:SWFShapeRecordCurvedEdge = shapeRecord as SWFShapeRecordCurvedEdge;
							from = new Point(NumberUtils.roundPixels400(xPos), NumberUtils.roundPixels400(yPos));
							var xPosControl:Number = xPos + curvedEdgeRecord.controlDeltaX / unitDivisor;
							var yPosControl:Number = yPos + curvedEdgeRecord.controlDeltaY / unitDivisor;
							xPos = xPosControl + curvedEdgeRecord.anchorDeltaX / unitDivisor;
							yPos = yPosControl + curvedEdgeRecord.anchorDeltaY / unitDivisor;
							control = new Point(xPosControl, yPosControl);
							to = new Point(NumberUtils.roundPixels400(xPos), NumberUtils.roundPixels400(yPos));
							subPath.push(new CurvedEdge(from, control, to, currentLineStyleIdx, currentFillStyleIdx1));
							break; 
						case SWFShapeRecord.TYPE_END:
							// We're done. Process the last subpath, if any
							processSubPath(subPath, currentLineStyleIdx, currentFillStyleIdx0, currentFillStyleIdx1);
							cleanEdgeMap(currentFillEdgeMap);
							cleanEdgeMap(currentLineEdgeMap);
							fillEdgeMaps.push(currentFillEdgeMap);
							lineEdgeMaps.push(currentLineEdgeMap);
							numGroups++;
							break;
					}
				}
				edgeMapsCreated = true;
			}
		}
		
		protected function processSubPath(subPath:Vector.<IEdge>, lineStyleIdx:uint, fillStyleIdx0:uint, fillStyleIdx1:uint):void {
			var path:Vector.<IEdge>;
			if (fillStyleIdx0 != 0) {
				path = currentFillEdgeMap[fillStyleIdx0] as Vector.<IEdge>;
				if(path == null) { path = currentFillEdgeMap[fillStyleIdx0] = new Vector.<IEdge>(); }
				for (var j:int = subPath.length - 1; j >= 0; j--) {
					path.push(subPath[j].reverseWithNewFillStyle(fillStyleIdx0));
				}
			}
			if (fillStyleIdx1 != 0) {
				path = currentFillEdgeMap[fillStyleIdx1] as Vector.<IEdge>;
				if(path == null) { path = currentFillEdgeMap[fillStyleIdx1] = new Vector.<IEdge>(); }
				appendEdges(path, subPath);
			}
			if (lineStyleIdx != 0) {
				path = currentLineEdgeMap[lineStyleIdx] as Vector.<IEdge>;
				if(path == null) { path = currentLineEdgeMap[lineStyleIdx] = new Vector.<IEdge>(); }
				appendEdges(path, subPath);
			}
		}
		
		protected function exportFillPath(handler:IShapeExporter, groupIndex:uint):void {
			var path:Vector.<IEdge> = createPathFromEdgeMap(fillEdgeMaps[groupIndex]);
			var pos:Point = new Point(Number.MAX_VALUE, Number.MAX_VALUE);
			var fillStyleIdx:uint = uint.MAX_VALUE;
			if(path.length > 0) {
				handler.beginFills();
				for (var i:uint = 0; i < path.length; i++) {
					var e:IEdge = path[i];
					if (fillStyleIdx != e.fillStyleIdx) {
						if(fillStyleIdx != uint.MAX_VALUE) {
							handler.endFill();
						}
						fillStyleIdx = e.fillStyleIdx;
						pos = new Point(Number.MAX_VALUE, Number.MAX_VALUE);
						try {
							var matrix:Matrix;
							var fillStyle:SWFFillStyle = _fillStyles[fillStyleIdx - 1];
							switch(fillStyle.type) {
								case 0x00:
									// Solid fill
									handler.beginFill(ColorUtils.rgb(fillStyle.rgb), ColorUtils.alpha(fillStyle.rgb));
									break;
								case 0x10:
								case 0x12:
								case 0x13:
									// Gradient fill
									var colors:Array = [];
									var alphas:Array = [];
									var ratios:Array = [];
									var gradientRecord:SWFGradientRecord;
									matrix = fillStyle.gradientMatrix.matrix.clone();
									matrix.tx /= 20;
									matrix.ty /= 20;
									for (var gri:uint = 0; gri < fillStyle.gradient.records.length; gri++) {
										gradientRecord = fillStyle.gradient.records[gri];
										colors.push(ColorUtils.rgb(gradientRecord.color));
										alphas.push(ColorUtils.alpha(gradientRecord.color));
										ratios.push(gradientRecord.ratio);
									}
									handler.beginGradientFill(
										(fillStyle.type == 0x10) ? GradientType.LINEAR : GradientType.RADIAL,
										colors, alphas, ratios, matrix,
										GradientSpreadMode.toString(fillStyle.gradient.spreadMode),
										GradientInterpolationMode.toString(fillStyle.gradient.interpolationMode),
										fillStyle.gradient.focalPoint
									);
									break;
								case 0x40:
								case 0x41:
								case 0x42:
								case 0x43:
									// Bitmap fill
									handler.beginBitmapFill(
										fillStyle.bitmapId,
										fillStyle.bitmapMatrix.matrix,
										(fillStyle.type == 0x40 || fillStyle.type == 0x42),
										(fillStyle.type == 0x40 || fillStyle.type == 0x41)
									);
									break;
							}
						} catch (e:Error) {
							// Font shapes define no fillstyles per se, but do reference fillstyle index 1,
							// which represents the font color. We just report solid black in this case.
							trace("exportFillPath error:" + e);
							handler.beginFill(0);
						}
					}
					if (!pos.equals(e.from)) {
						handler.moveTo(e.from.x, e.from.y);
					}
					if (e is CurvedEdge) {
						var c:CurvedEdge = CurvedEdge(e);
						handler.curveTo(c.control.x, c.control.y, c.to.x, c.to.y);
					} else {
						handler.lineTo(e.to.x, e.to.y);
					}
					pos = e.to;
				}
				if(fillStyleIdx != uint.MAX_VALUE) {
					handler.endFill();
				}
				handler.endFills();
			}
		}
		
		protected function exportLinePath(handler:IShapeExporter, groupIndex:uint):void {
			var path:Vector.<IEdge> = createPathFromEdgeMap(lineEdgeMaps[groupIndex]);
			var pos:Point = new Point(Number.MAX_VALUE, Number.MAX_VALUE);
			var lineStyleIdx:uint = uint.MAX_VALUE;
			var lineStyle:SWFLineStyle;
			if(path.length > 0) {
				handler.beginLines();
				for (var i:uint = 0; i < path.length; i++) {
					var e:IEdge = path[i];
					if (lineStyleIdx != e.lineStyleIdx) {
						lineStyleIdx = e.lineStyleIdx;
						pos = new Point(Number.MAX_VALUE, Number.MAX_VALUE);
						try {
							lineStyle = _lineStyles[lineStyleIdx - 1];
						} catch (e:Error) {
							lineStyle = null;
						}
						if (lineStyle != null) {
							var scaleMode:String = LineScaleMode.NORMAL;
							if (lineStyle.noHScaleFlag && lineStyle.noVScaleFlag) {
								scaleMode = LineScaleMode.NONE;
							} else if (lineStyle.noHScaleFlag) {
								scaleMode = LineScaleMode.HORIZONTAL;
							} else if (lineStyle.noVScaleFlag) {
								scaleMode = LineScaleMode.VERTICAL;
							}
							handler.lineStyle(
								lineStyle.width / 20, 
								ColorUtils.rgb(lineStyle.color), 
								ColorUtils.alpha(lineStyle.color), 
								lineStyle.pixelHintingFlag,
								scaleMode,
								LineCapsStyle.toString(lineStyle.startCapsStyle),
								LineCapsStyle.toString(lineStyle.endCapsStyle),
								LineJointStyle.toString(lineStyle.jointStyle),
								lineStyle.miterLimitFactor);
							
							if(lineStyle.hasFillFlag) {
								var fillStyle:SWFFillStyle = lineStyle.fillType;
								switch(fillStyle.type) {
									case 0x10:
									case 0x12:
									case 0x13:
										// Gradient fill
										var colors:Array = [];
										var alphas:Array = [];
										var ratios:Array = [];
										var gradientRecord:SWFGradientRecord;
										var matrix:Matrix = fillStyle.gradientMatrix.matrix.clone();
										matrix.tx /= 20;
										matrix.ty /= 20;
										for (var gri:uint = 0; gri < fillStyle.gradient.records.length; gri++) {
											gradientRecord = fillStyle.gradient.records[gri];
											colors.push(ColorUtils.rgb(gradientRecord.color));
											alphas.push(ColorUtils.alpha(gradientRecord.color));
											ratios.push(gradientRecord.ratio);
										}
										handler.lineGradientStyle(
											(fillStyle.type == 0x10) ? GradientType.LINEAR : GradientType.RADIAL,
											colors, alphas, ratios, matrix,
											GradientSpreadMode.toString(fillStyle.gradient.spreadMode),
											GradientInterpolationMode.toString(fillStyle.gradient.interpolationMode),
											fillStyle.gradient.focalPoint
										);
										break;
								}
							}
						} else {
							// We should never get here
							handler.lineStyle(0);
						}
					}
					if (!e.from.equals(pos)) {
						handler.moveTo(e.from.x, e.from.y);
					}
					if (e is CurvedEdge) {
						var c:CurvedEdge = CurvedEdge(e);
						handler.curveTo(c.control.x, c.control.y, c.to.x, c.to.y);
					} else {
						handler.lineTo(e.to.x, e.to.y);
					}
					pos = e.to;
				}
				handler.endLines();
			}
		}
		
		protected function createPathFromEdgeMap(edgeMap:Dictionary):Vector.<IEdge> {
			var newPath:Vector.<IEdge> = new Vector.<IEdge>();
			var styleIdxArray:Array = [];
			for(var styleIdx:String in edgeMap) {
				styleIdxArray.push(parseInt(styleIdx));
			}
			styleIdxArray.sort(Array.NUMERIC);
			for(var i:uint = 0; i < styleIdxArray.length; i++) {
				appendEdges(newPath, edgeMap[styleIdxArray[i]] as Vector.<IEdge>);
			}
			return newPath;
		}
		
		protected function cleanEdgeMap(edgeMap:Dictionary):void {
			for(var styleIdx:String in edgeMap) {
				var subPath:Vector.<IEdge> = edgeMap[styleIdx] as Vector.<IEdge>;
				if(subPath && subPath.length > 0) {
					var idx:uint;
					var prevEdge:IEdge;
					var tmpPath:Vector.<IEdge> = new Vector.<IEdge>();
					createCoordMap(subPath);
					while(subPath.length > 0) {
						idx = 0;
						while(idx < subPath.length) {
							if(prevEdge == null || prevEdge.to.equals(subPath[idx].from)) {
								var edge:IEdge = subPath.splice(idx, 1)[0];
								tmpPath.push(edge);
								removeEdgeFromCoordMap(edge);
								prevEdge = edge;
							} else {
								edge = findNextEdgeInCoordMap(prevEdge);
								if(edge) {
									idx = subPath.indexOf(edge);
								} else {
									idx = 0;
									prevEdge = null;
								}
							}
						}
					}
					edgeMap[styleIdx] = tmpPath;
				}
			}
		}
		
		protected function createCoordMap(path:Vector.<IEdge>):void {
			coordMap = new Dictionary();
			for(var i:uint = 0; i < path.length; i++) {
				var from:Point = path[i].from;
				var key:String = from.x + "_" + from.y;
				var coordMapArray:Array = coordMap[key] as Array;
				if(coordMapArray == null) {
					coordMap[key] = [path[i]];
				} else {
					coordMapArray.push(path[i]);
				}
			}
		}
		
		protected function removeEdgeFromCoordMap(edge:IEdge):void {
			var key:String = edge.from.x + "_" + edge.from.y;
			var coordMapArray:Array = coordMap[key] as Array;
			if(coordMapArray) {
				if(coordMapArray.length == 1) {
					delete coordMap[key];
				} else {
					var i:int = coordMapArray.indexOf(edge);
					if(i > -1) {
						coordMapArray.splice(i, 1);
					}
				}
			}
		}
		
		protected function findNextEdgeInCoordMap(edge:IEdge):IEdge {
			var key:String = edge.to.x + "_" + edge.to.y;
			var coordMapArray:Array = coordMap[key] as Array;
			if(coordMapArray && coordMapArray.length > 0) {
				return coordMapArray[0] as IEdge;
			}
			return null;
		}
		
		protected function appendFillStyles(v1:Vector.<SWFFillStyle>, v2:Vector.<SWFFillStyle>):void {
			for (var i:uint = 0; i < v2.length; i++) {
				v1.push(v2[i]);
			}
		}
		
		protected function appendLineStyles(v1:Vector.<SWFLineStyle>, v2:Vector.<SWFLineStyle>):void {
			for (var i:uint = 0; i < v2.length; i++) {
				v1.push(v2[i]);
			}
		}

		protected function appendEdges(v1:Vector.<IEdge>, v2:Vector.<IEdge>):void {
			for (var i:uint = 0; i < v2.length; i++) {
				v1.push(v2[i]);
			}
		}
		
		public function toString(indent:uint = 0):String {
			var str:String = "\n" + StringUtils.repeat(indent) + "ShapeRecords:";
			for (var i:uint = 0; i < _records.length; i++) {
				str += "\n" + StringUtils.repeat(indent + 2) + "[" + i + "] " + _records[i].toString(indent + 2);
			}
			return str;
		}
	}
}
