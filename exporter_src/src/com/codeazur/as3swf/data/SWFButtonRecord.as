package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.BlendMode;
	import com.codeazur.as3swf.data.filters.IFilter;
	import com.codeazur.utils.StringUtils;
	
	public class SWFButtonRecord
	{
		public var hasBlendMode:Boolean = false;
		public var hasFilterList:Boolean = false;
		public var stateHitTest:Boolean;
		public var stateDown:Boolean;
		public var stateOver:Boolean;
		public var stateUp:Boolean;
		
		public var characterId:uint;
		public var placeDepth:uint;
		public var placeMatrix:SWFMatrix;
		public var colorTransform:SWFColorTransformWithAlpha;
		public var blendMode:uint;

		protected var _filterList:Vector.<IFilter>;
		
		public function SWFButtonRecord(data:SWFData = null, level:uint = 1) {
			_filterList = new Vector.<IFilter>();
			if (data != null) {
				parse(data, level);
			}
		}
		
		public function get filterList():Vector.<IFilter> { return _filterList; }

		public function parse(data:SWFData, level:uint = 1):void {
			var flags:uint = data.readUI8();
			stateHitTest = ((flags & 0x08) != 0);
			stateDown = ((flags & 0x04) != 0);
			stateOver = ((flags & 0x02) != 0);
			stateUp = ((flags & 0x01) != 0);
			characterId = data.readUI16();
			placeDepth = data.readUI16();
			placeMatrix = data.readMATRIX();
			if (level >= 2) {
				colorTransform = data.readCXFORMWITHALPHA();
				hasFilterList = ((flags & 0x10) != 0);
				if (hasFilterList) {
					var numberOfFilters:uint = data.readUI8();
					for (var i:uint = 0; i < numberOfFilters; i++) {
						_filterList.push(data.readFILTER());
					}
				}
				hasBlendMode = ((flags & 0x20) != 0);
				if (hasBlendMode) {
					blendMode = data.readUI8();
				}
			}
		}
		
		public function publish(data:SWFData, level:uint = 1):void {
			var flags:uint = 0;
			if(level >= 2 && hasBlendMode) { flags |= 0x20; }
			if(level >= 2 && hasFilterList) { flags |= 0x10; }
			if(stateHitTest) { flags |= 0x08; }
			if(stateDown) { flags |= 0x04; }
			if(stateOver) { flags |= 0x02; }
			if(stateUp) { flags |= 0x01; }
			data.writeUI8(flags);
			data.writeUI16(characterId);
			data.writeUI16(placeDepth);
			data.writeMATRIX(placeMatrix);
			if (level >= 2) {
				data.writeCXFORMWITHALPHA(colorTransform);
				if (hasFilterList) {
					var numberOfFilters:uint = filterList.length;
					data.writeUI8(numberOfFilters);
					for (var i:uint = 0; i < numberOfFilters; i++) {
						data.writeFILTER(filterList[i]);
					}
				}
				if (hasBlendMode) {
					data.writeUI8(blendMode);
				}
			}
		}
		
		public function clone():SWFButtonRecord {
			var data:SWFButtonRecord = new SWFButtonRecord();
			data.hasBlendMode = hasBlendMode;
			data.hasFilterList = hasFilterList;
			data.stateHitTest = stateHitTest;
			data.stateDown = stateDown;
			data.stateOver = stateOver;
			data.stateUp = stateUp;
			data.characterId = characterId;
			data.placeDepth = placeDepth;
			data.placeMatrix = placeMatrix.clone();
			if(colorTransform) {
				data.colorTransform = colorTransform.clone() as SWFColorTransformWithAlpha;
			}
			for(var i:uint = 0; i < filterList.length; i++) {
				data.filterList.push(filterList[i].clone());
			}
			data.blendMode = blendMode;
			return data;
		}
		
		public function toString(indent:uint = 0):String {
			var str:String = "Depth: " + placeDepth + ", CharacterID: " + characterId + ", States: ";
			var states:Array = [];
			if (stateUp) { states.push("up"); }
			if (stateOver) { states.push("over"); }
			if (stateDown) { states.push("down"); }
			if (stateHitTest) { states.push("hit"); }
			str += states.join(",");
			if (hasBlendMode) { str += ", BlendMode: " + BlendMode.toString(blendMode); }
			if (placeMatrix && !placeMatrix.isIdentity()) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Matrix: " + placeMatrix;
			}
			if (colorTransform && !colorTransform.isIdentity()) {
				str += "\n" + StringUtils.repeat(indent + 2) + "ColorTransform: " + colorTransform;
			}
			if (hasFilterList) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Filters:"
				for(var i:uint = 0; i < filterList.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + filterList[i].toString(indent + 4);
				}
			}
			return str;
		}
	}
}
