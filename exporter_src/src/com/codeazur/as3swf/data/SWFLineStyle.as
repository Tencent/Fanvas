package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.LineCapsStyle;
	import com.codeazur.as3swf.data.consts.LineJointStyle;
	import com.codeazur.as3swf.utils.ColorUtils;
	
	public class SWFLineStyle
	{
		public var width:uint;
		public var color:uint;

		public var _level:uint;
		
		// Forward declaration of SWFLineStyle2 properties
		public var startCapsStyle:uint = LineCapsStyle.ROUND;
		public var endCapsStyle:uint = LineCapsStyle.ROUND;
		public var jointStyle:uint = LineJointStyle.ROUND;
		public var hasFillFlag:Boolean = false;
		public var noHScaleFlag:Boolean = false;
		public var noVScaleFlag:Boolean = false;
		public var pixelHintingFlag:Boolean = false;
		public var noClose:Boolean = false;
		public var miterLimitFactor:Number = 3;
		public var fillType:SWFFillStyle;

		public function SWFLineStyle(data:SWFData = null, level:uint = 1) {
			if (data != null) {
				parse(data, level);
			}
		}
		
		public function parse(data:SWFData, level:uint = 1):void {
			_level = level;
			width = data.readUI16();
			color = (level <= 2) ? data.readRGB() : data.readRGBA();
		}
		
		public function publish(data:SWFData, level:uint = 1):void {
			data.writeUI16(width);
			if(level <= 2) {
				data.writeRGB(color);
			} else {
				data.writeRGBA(color);
			}
		}
		
		public function clone():SWFLineStyle {
			var lineStyle:SWFLineStyle = new SWFLineStyle();
			lineStyle.width = width;
			lineStyle.color = color;
			lineStyle.startCapsStyle = startCapsStyle;
			lineStyle.endCapsStyle = endCapsStyle;
			lineStyle.jointStyle = jointStyle;
			lineStyle.hasFillFlag = hasFillFlag;
			lineStyle.noHScaleFlag = noHScaleFlag;
			lineStyle.noVScaleFlag = noVScaleFlag;
			lineStyle.pixelHintingFlag = pixelHintingFlag;
			lineStyle.noClose = noClose;
			lineStyle.miterLimitFactor = miterLimitFactor;
			lineStyle.fillType = fillType.clone();
			return lineStyle;
		}
		
		public function toString():String {
			return "[SWFLineStyle] Width: " + width + " Color: " + ((_level <= 2) ? ColorUtils.rgbToString(color) : ColorUtils.rgbaToString(color));
		}
	}
}
