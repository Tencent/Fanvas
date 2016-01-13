package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.utils.ColorUtils;
	import com.codeazur.utils.StringUtils;
	
	public class SWFFillStyle
	{
		public var type:uint;

		public var rgb:uint;
		public var gradient:SWFGradient;
		public var gradientMatrix:SWFMatrix;
		public var bitmapId:uint;
		public var bitmapMatrix:SWFMatrix;

		protected var _level:uint;
		
		public function SWFFillStyle(data:SWFData = null, level:uint = 1) {
			if (data != null) {
				parse(data, level);
			}
		}
		
		public function parse(data:SWFData, level:uint = 1):void {
			_level = level;
			type = data.readUI8();
			switch(type) {
				case 0x00:
					rgb = (level <= 2) ? data.readRGB() : data.readRGBA();
					break;
				case 0x10:
				case 0x12:
				case 0x13:
					gradientMatrix = data.readMATRIX();
					gradient = (type == 0x13) ? data.readFOCALGRADIENT(level) : data.readGRADIENT(level);
					break;
				case 0x40:
				case 0x41:
				case 0x42:
				case 0x43:
					bitmapId = data.readUI16();
					bitmapMatrix = data.readMATRIX();
					break;
				default:
					throw(new Error("Unknown fill style type: 0x" + type.toString(16)));
			}
		}
		
		public function publish(data:SWFData, level:uint = 1):void {
			data.writeUI8(type);
			switch(type) {
				case 0x00:
					if(level <= 2) {
						data.writeRGB(rgb);
					} else {
						data.writeRGBA(rgb);
					}
					break;
				case 0x10:
				case 0x12:
					data.writeMATRIX(gradientMatrix);
					data.writeGRADIENT(gradient, level);
					break;
				case 0x13:
					data.writeMATRIX(gradientMatrix);
					data.writeFOCALGRADIENT(SWFFocalGradient(gradient), level);
					break;
				case 0x40:
				case 0x41:
				case 0x42:
				case 0x43:
					data.writeUI16(bitmapId);
					data.writeMATRIX(bitmapMatrix);
					break;
				default:
					throw(new Error("Unknown fill style type: 0x" + type.toString(16)));
			}
		}
		
		public function clone():SWFFillStyle {
			var fillStyle:SWFFillStyle = new SWFFillStyle();
			fillStyle.type = type;
			fillStyle.rgb = rgb;
			fillStyle.gradient = gradient.clone();
			fillStyle.gradientMatrix = gradientMatrix.clone();
			fillStyle.bitmapId = bitmapId;
			fillStyle.bitmapMatrix = bitmapMatrix.clone();
			return fillStyle;
		}
		
		public function toString():String {
			var str:String = "[SWFFillStyle] Type: " + StringUtils.printf("%02x", type);
			switch(type) {
				case 0x00: str += " (solid), Color: " + ((_level <= 2) ? ColorUtils.rgbToString(rgb) : ColorUtils.rgbaToString(rgb)); break;
				case 0x10: str += " (linear gradient), Gradient: " + gradient + ", Matrix: " + gradientMatrix; break;
				case 0x12: str += " (radial gradient), Gradient: " + gradient + ", Matrix: " + gradientMatrix; break;
				case 0x13: str += " (focal radial gradient), Gradient: " + gradient + ", Matrix: " + gradientMatrix + ", FocalPoint: " + gradient.focalPoint; break;
				case 0x40: str += " (repeating bitmap), BitmapID: " + bitmapId; break;
				case 0x41: str += " (clipped bitmap), BitmapID: " + bitmapId; break;
				case 0x42: str += " (non-smoothed repeating bitmap), BitmapID: " + bitmapId; break;
				case 0x43: str += " (non-smoothed clipped bitmap), BitmapID: " + bitmapId; break;
			}
			return str;
		}
	}
}
