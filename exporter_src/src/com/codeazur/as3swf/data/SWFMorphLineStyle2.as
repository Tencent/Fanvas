package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.LineCapsStyle;
	import com.codeazur.as3swf.data.consts.LineJointStyle;
	import com.codeazur.as3swf.utils.ColorUtils;
	
	public class SWFMorphLineStyle2 extends SWFMorphLineStyle
	{
		public function SWFMorphLineStyle2(data:SWFData = null, level:uint = 1) {
			super(data, level);
		}
		
		override public function parse(data:SWFData, level:uint = 1):void {
			startWidth = data.readUI16();
			endWidth = data.readUI16();
			startCapsStyle = data.readUB(2);
			jointStyle = data.readUB(2);
			hasFillFlag = (data.readUB(1) == 1);
			noHScaleFlag = (data.readUB(1) == 1);
			noVScaleFlag = (data.readUB(1) == 1);
			pixelHintingFlag = (data.readUB(1) == 1);
			var reserved:uint = data.readUB(5);
			noClose = (data.readUB(1) == 1);
			endCapsStyle = data.readUB(2);
			if (jointStyle == LineJointStyle.MITER) {
				miterLimitFactor = data.readFIXED8();
			}
			if (hasFillFlag) {
				fillType = data.readMORPHFILLSTYLE(level);
			} else {
				startColor = data.readRGBA();
				endColor = data.readRGBA();
			}
		}
		
		override public function publish(data:SWFData, level:uint = 1):void {
			data.writeUI16(startWidth);
			data.writeUI16(endWidth);
			data.writeUB(2, startCapsStyle); 
			data.writeUB(2, jointStyle); 
			data.writeUB(1, hasFillFlag ? 1 : 0); 
			data.writeUB(1, noHScaleFlag ? 1 : 0); 
			data.writeUB(1, noVScaleFlag ? 1 : 0); 
			data.writeUB(1, pixelHintingFlag ? 1 : 0); 
			data.writeUB(5, 0); // Reserved
			data.writeUB(1, noClose ? 1 : 0); 
			data.writeUB(2, endCapsStyle); 
			if (jointStyle == LineJointStyle.MITER) {
				data.writeFIXED8(miterLimitFactor); 
			}
			if (hasFillFlag) {
				data.writeMORPHFILLSTYLE(fillType, level);
			} else {
				data.writeRGBA(startColor);
				data.writeRGBA(endColor);
			}
		}
		
		override public function toString():String {
			var str:String = "[SWFMorphLineStyle2] " +
				"StartWidth: " + startWidth + ", " +
				"EndWidth: " + endWidth + ", " +
				"StartCaps: " + LineCapsStyle.toString(startCapsStyle) + ", " +
				"EndCaps: " + LineCapsStyle.toString(endCapsStyle) + ", " +
				"Joint: " + LineJointStyle.toString(jointStyle);
			if (hasFillFlag) {
				str += ", Fill: " + fillType.toString();
			} else {
				str += ", StartColor: " + ColorUtils.rgbaToString(startColor);
				str += ", EndColor: " + ColorUtils.rgbaToString(endColor);
			}
			return str;
		}
	}
}
