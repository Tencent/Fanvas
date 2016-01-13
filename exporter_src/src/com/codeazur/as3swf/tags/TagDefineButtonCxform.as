package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFColorTransform;
	
	public class TagDefineButtonCxform implements IDefinitionTag
	{
		public static const TYPE:uint = 23;
		
		public var buttonColorTransform:SWFColorTransform;

		protected var _characterId:uint;

		public function TagDefineButtonCxform() {}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			buttonColorTransform = data.readCXFORM();
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			body.writeCXFORM(buttonColorTransform);
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineButtonCxform = new TagDefineButtonCxform();
			tag.characterId = characterId;
			tag.buttonColorTransform = buttonColorTransform.clone();
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineButtonCxform"; }
		public function get version():uint { return 2; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"ColorTransform: " + buttonColorTransform;
			return str;
		}
	}
}
