package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFButtonCondAction;
	import com.codeazur.as3swf.data.SWFButtonRecord;
	import com.codeazur.utils.StringUtils;
	
	import flash.utils.Dictionary;
	
	public class TagDefineButton2 implements IDefinitionTag
	{
		public static const TYPE:uint = 34;
		
		public var trackAsMenu:Boolean;
		
		protected var _characterId:uint;

		protected var _characters:Vector.<SWFButtonRecord>;
		protected var _condActions:Vector.<SWFButtonCondAction>;
		
		protected var frames:Dictionary;
		
		public function TagDefineButton2() {
			_characters = new Vector.<SWFButtonRecord>();
			_condActions = new Vector.<SWFButtonCondAction>();
			frames = new Dictionary();
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function get characters():Vector.<SWFButtonRecord> { return _characters; }
		public function get condActions():Vector.<SWFButtonCondAction> { return _condActions; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			trackAsMenu = ((data.readUI8() & 0x01) != 0);
			var actionOffset:uint = data.readUI16();
			var record:SWFButtonRecord;
			while ((record = data.readBUTTONRECORD(2)) != null) {
				characters.push(record);
			}
			if (actionOffset != 0) {
				var condActionSize:uint;
				do {
					condActionSize = data.readUI16();
					condActions.push(data.readBUTTONCONDACTION());
				} while(condActionSize != 0);
			}
			processRecords();
		}
		
		public function publish(data:SWFData, version:uint):void {
			var i:uint;
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			body.writeUI8(trackAsMenu ? 0x01 : 0);
			var hasCondActions:Boolean = (condActions.length > 0); 
			var buttonRecordsBytes:SWFData = new SWFData();
			for(i = 0; i < characters.length; i++) {
				buttonRecordsBytes.writeBUTTONRECORD(characters[i], 2);
			}
			buttonRecordsBytes.writeUI8(0);
			body.writeUI16(hasCondActions ? buttonRecordsBytes.length + 2 : 0);
			body.writeBytes(buttonRecordsBytes);
			if(hasCondActions) {
				for(i = 0; i < condActions.length; i++) {
					var condActionBytes:SWFData = new SWFData();
					condActionBytes.writeBUTTONCONDACTION(condActions[i]);
					body.writeUI16((i < condActions.length - 1) ? condActionBytes.length + 2 : 0);
					body.writeBytes(condActionBytes);
				}
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var i:uint;
			var tag:TagDefineButton2 = new TagDefineButton2();
			tag.characterId = characterId;
			tag.trackAsMenu = trackAsMenu;
			for(i = 0; i < characters.length; i++) {
				tag.characters.push(characters[i].clone());
			}
			for(i = 0; i < condActions.length; i++) {
				tag.condActions.push(condActions[i].clone());
			}
			return tag;
		}
		
		public function getRecordsByState(state:String):Vector.<SWFButtonRecord> {
			return frames[state] as Vector.<SWFButtonRecord>;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineButton2"; }
		public function get version():uint { return 3; }
		public function get level():uint { return 2; }

		protected function processRecords():void {
			var upState:Vector.<SWFButtonRecord> = new Vector.<SWFButtonRecord>();
			var overState:Vector.<SWFButtonRecord> = new Vector.<SWFButtonRecord>();
			var downState:Vector.<SWFButtonRecord> = new Vector.<SWFButtonRecord>();
			var hitState:Vector.<SWFButtonRecord> = new Vector.<SWFButtonRecord>();
			for(var i:uint = 0; i < characters.length; i++) {
				var record:SWFButtonRecord = characters[i];
				if(record.stateUp) { upState.push(record); }
				if(record.stateOver) { overState.push(record); }
				if(record.stateDown) { downState.push(record); }
				if(record.stateHitTest) { hitState.push(record); }
			}
			frames[TagDefineButton.STATE_UP] = upState.sort(sortByDepthCompareFunction);
			frames[TagDefineButton.STATE_OVER] = overState.sort(sortByDepthCompareFunction);
			frames[TagDefineButton.STATE_DOWN] = downState.sort(sortByDepthCompareFunction);
			frames[TagDefineButton.STATE_HIT] = hitState.sort(sortByDepthCompareFunction);
		}
		
		protected function sortByDepthCompareFunction(a:SWFButtonRecord, b:SWFButtonRecord):Number {
			if(a.placeDepth < b.placeDepth) {
				return -1;
			} else if(a.placeDepth > b.placeDepth) {
				return 1;
			} else {
				return 0;
			}
		}
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", TrackAsMenu: " + trackAsMenu;
			var i:uint;
			if (_characters.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Characters:";
				for (i = 0; i < _characters.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + _characters[i].toString(indent + 4);
				}
			}
			if (_condActions.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "CondActions:";
				for (i = 0; i < _condActions.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + _condActions[i].toString(indent + 4, flags);
				}
			}
			return str;
		}
	}
}
