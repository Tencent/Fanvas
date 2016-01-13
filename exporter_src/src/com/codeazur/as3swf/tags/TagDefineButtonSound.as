package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFSoundInfo;
	
	public class TagDefineButtonSound implements IDefinitionTag
	{
		public static const TYPE:uint = 17;
		
		public var buttonSoundChar0:uint;
		public var buttonSoundChar1:uint;
		public var buttonSoundChar2:uint;
		public var buttonSoundChar3:uint;
		public var buttonSoundInfo0:SWFSoundInfo;
		public var buttonSoundInfo1:SWFSoundInfo;
		public var buttonSoundInfo2:SWFSoundInfo;
		public var buttonSoundInfo3:SWFSoundInfo;

		protected var _characterId:uint;
		
		public function TagDefineButtonSound() {}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			buttonSoundChar0 = data.readUI16();
			if (buttonSoundChar0 != 0) {
				buttonSoundInfo0 = data.readSOUNDINFO();
			}
			buttonSoundChar1 = data.readUI16();
			if (buttonSoundChar1 != 0) {
				buttonSoundInfo1 = data.readSOUNDINFO();
			}
			buttonSoundChar2 = data.readUI16();
			if (buttonSoundChar2 != 0) {
				buttonSoundInfo2 = data.readSOUNDINFO();
			}
			buttonSoundChar3 = data.readUI16();
			if (buttonSoundChar3 != 0) {
				buttonSoundInfo3 = data.readSOUNDINFO();
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			body.writeUI16(buttonSoundChar0);
			if (buttonSoundChar0 != 0) {
				body.writeSOUNDINFO(buttonSoundInfo0);
			}
			body.writeUI16(buttonSoundChar1);
			if (buttonSoundChar1 != 0) {
				body.writeSOUNDINFO(buttonSoundInfo1);
			}
			body.writeUI16(buttonSoundChar2);
			if (buttonSoundChar2 != 0) {
				body.writeSOUNDINFO(buttonSoundInfo2);
			}
			body.writeUI16(buttonSoundChar3);
			if (buttonSoundChar3 != 0) {
				body.writeSOUNDINFO(buttonSoundInfo3);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineButtonSound = new TagDefineButtonSound();
			tag.characterId = characterId;
			tag.buttonSoundChar0 = buttonSoundChar0;
			tag.buttonSoundChar1 = buttonSoundChar1;
			tag.buttonSoundChar2 = buttonSoundChar2;
			tag.buttonSoundChar3 = buttonSoundChar3;
			tag.buttonSoundInfo0 = buttonSoundInfo0.clone();
			tag.buttonSoundInfo1 = buttonSoundInfo1.clone();
			tag.buttonSoundInfo2 = buttonSoundInfo2.clone();
			tag.buttonSoundInfo3 = buttonSoundInfo3.clone();
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineButtonSound"; }
		public function get version():uint { return 2; }
		public function get level():uint { return 1; }

		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ButtonID: " + characterId + ", " +
				"ButtonSoundChars: " + buttonSoundChar0 + "," + buttonSoundChar1 + "," + buttonSoundChar2 + "," + buttonSoundChar3;;
			return str;
		}
	}
}
