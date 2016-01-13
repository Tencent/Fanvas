package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFClipActions;
	import com.codeazur.as3swf.data.SWFColorTransform;
	import com.codeazur.as3swf.data.SWFMatrix;
	import com.codeazur.as3swf.data.filters.IFilter;
	
	public class TagPlaceObject implements IDisplayListTag
	{
		public static const TYPE:uint = 4;
		
		public var hasClipActions:Boolean;
		public var hasClipDepth:Boolean;
		public var hasName:Boolean;
		public var hasRatio:Boolean;
		public var hasColorTransform:Boolean;
		public var hasMatrix:Boolean;
		public var hasCharacter:Boolean;
		public var hasMove:Boolean;
		public var hasOpaqueBackground:Boolean;
		public var hasVisible:Boolean;
		public var hasImage:Boolean;
		public var hasClassName:Boolean;
		public var hasCacheAsBitmap:Boolean;
		public var hasBlendMode:Boolean;
		public var hasFilterList:Boolean;
		
		public var characterId:uint;
		public var depth:uint;
		public var matrix:SWFMatrix;
		public var colorTransform:SWFColorTransform;
		
		// Forward declarations for TagPlaceObject2
		public var ratio:uint;
		public var instanceName:String;
		public var clipDepth:uint;
		public var clipActions:SWFClipActions;

		// Forward declarations for TagPlaceObject3
		public var className:String;
		public var blendMode:uint;
		public var bitmapCache:uint;
		public var bitmapBackgroundColor:uint;
		public var visible:uint;

		// Forward declarations for TagPlaceObject4
		public var metaData:Object;
		
		protected var _surfaceFilterList:Vector.<IFilter>;
		
		public function TagPlaceObject() {
			_surfaceFilterList = new Vector.<IFilter>();
		}
		
		public function get surfaceFilterList():Vector.<IFilter> { return _surfaceFilterList; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			var pos:uint = data.position;
			characterId = data.readUI16();
			depth = data.readUI16();
			matrix = data.readMATRIX();
			hasCharacter = true;
			hasMatrix = true;
			if (data.position - pos < length) {
				colorTransform = data.readCXFORM();
				hasColorTransform = true;
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			body.writeUI16(depth);
			body.writeMATRIX(matrix);
			if (hasColorTransform) {
				body.writeCXFORM(colorTransform);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "PlaceObject"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"Depth: " + depth;
			if (hasCharacter) { str += ", CharacterID: " + characterId; }
			if (hasMatrix) { str += ", Matrix: " + matrix; }
			if (hasColorTransform) { str += ", ColorTransform: " + colorTransform; }
			return str;
		}
	}
}
