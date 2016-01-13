package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.BitmapType;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	public class TagDefineBits implements IDefinitionTag
	{
		public static const TYPE:uint = 6;
		
		public var bitmapType:uint = BitmapType.JPEG;
		
		protected var _characterId:uint;

		protected var _bitmapData:ByteArray;
		
		public function TagDefineBits() {
			_bitmapData = new ByteArray();
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }

		public function get bitmapData():ByteArray { return _bitmapData; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			if (length > 2) {
				data.readBytes(_bitmapData, 0, length - 2);
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, _bitmapData.length + 2, true);
			data.writeUI16(_characterId);
			if (_bitmapData.length > 0) {
				data.writeBytes(_bitmapData);
			}
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineBits = new TagDefineBits();
			tag.characterId = characterId;
			tag.bitmapType = bitmapType;
			if (_bitmapData.length > 0) {
				tag.bitmapData.writeBytes(_bitmapData);
			}
			return tag;
		}
		
		protected var loader:Loader;
		protected var onCompleteCallback:Function;
		
		public function exportBitmapData(onComplete:Function):void {
			onCompleteCallback = onComplete;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, exportCompleteHandler);
			loader.loadBytes(_bitmapData);
		}
		
		protected function exportCompleteHandler(event:Event):void {
			var loader:Loader = event.target.loader as Loader;
			var bitmapData:BitmapData = new BitmapData(loader.content.width, loader.content.height);
			bitmapData.draw(loader);
			onCompleteCallback(bitmapData);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineBits"; }
		public function get version():uint { return 1; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"BitmapLength: " + _bitmapData.length;
		}
	}
}
