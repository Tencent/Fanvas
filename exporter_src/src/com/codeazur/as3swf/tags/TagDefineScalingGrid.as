package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFRectangle;
	
	public class TagDefineScalingGrid implements IDefinitionTag
	{
		public static const TYPE:uint = 78;
		
		public var splitter:SWFRectangle;

		protected var _characterId:uint;
		
		public function TagDefineScalingGrid() {}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			splitter = data.readRECT();
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			body.writeRECT(splitter);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineScalingGrid = new TagDefineScalingGrid();
			tag.characterId = characterId;
			tag.splitter = splitter.clone();
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineScalingGrid"; }
		public function get version():uint { return 8; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"CharacterID: " + characterId + ", " +
				"Splitter: " + splitter;
		}
	}
}
