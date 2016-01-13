package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.utils.StringUtils;

	/**
	 * PlaceObject4 is essentially identical to PlaceObject3 except it has a different
	 * swf tag value of course (94 instead of 70) and at the end of the tag, if there are
	 * additional bytes, those bytes will be interpreted as AMF binary data that will be
	 * used as the metadata attached to the instance.
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/DisplayObject.html#metaData
	 */
	public class TagPlaceObject4 extends TagPlaceObject3 implements IDisplayListTag
	{
		public static const TYPE:uint = 94;
		
		public function TagPlaceObject4() {}
		
		override public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			super.parse(data, length, version, async);
			if (data.bytesAvailable > 0) {
				metaData = data.readObject();
			}
		}
		
		override public function publish(data:SWFData, version:uint):void {
			var body:SWFData = prepareBody();
			
			if (metaData != null) {
				body.writeObject(metaData);
			}
			
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "PlaceObject4"; }
		override public function get version():uint { return 19; }
		override public function get level():uint { return 4; }
		
		override public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = super.toString(indent);
			if (metaData != null) {
				str += "\n" + StringUtils.repeat(indent + 2) + "MetaData: yes";
			}
			return str;
		}
	}
}