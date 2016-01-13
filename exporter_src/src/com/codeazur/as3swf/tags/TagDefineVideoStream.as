package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.VideoCodecID;
	import com.codeazur.as3swf.data.consts.VideoDeblockingType;
	
	public class TagDefineVideoStream implements IDefinitionTag
	{
		public static const TYPE:uint = 60;

		public var numFrames:uint;
		public var width:uint;
		public var height:uint;
		public var deblocking:uint;
		public var smoothing:Boolean;
		public var codecId:uint;
		
		protected var _characterId:uint;
		
		public function TagDefineVideoStream() {}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			numFrames = data.readUI16();
			width = data.readUI16();
			height = data.readUI16();
			data.readUB(4);
			deblocking = data.readUB(3);
			smoothing = (data.readUB(1) == 1);
			codecId = data.readUI8();
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeTagHeader(type, 10);
			data.writeUI16(characterId);
			data.writeUI16(numFrames);
			data.writeUI16(width);
			data.writeUI16(height);
			data.writeUB(4, 0); // Reserved
			data.writeUB(3, deblocking);
			data.writeUB(1, smoothing ? 1 : 0);
			data.writeUI8(codecId);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineVideoStream = new TagDefineVideoStream();
			tag.characterId = characterId;
			tag.numFrames = numFrames;
			tag.width = width;
			tag.height = height;
			tag.deblocking = deblocking;
			tag.smoothing = smoothing;
			tag.codecId = codecId;
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineVideoStream"; }
		public function get version():uint { return 6; }
		public function get level():uint { return 1; }
	
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Frames: " + numFrames + ", " +
				"Width: " + width + ", " +
				"Height: " + height + ", " +
				"Deblocking: " + VideoDeblockingType.toString(deblocking) + ", " +
				"Smoothing: " + smoothing + ", " +
				"Codec: " + VideoCodecID.toString(codecId);
		}
	}
}
