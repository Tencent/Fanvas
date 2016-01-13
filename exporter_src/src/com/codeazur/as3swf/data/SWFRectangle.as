package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.utils.NumberUtils;
	
	import flash.geom.Rectangle;
	
	public class SWFRectangle
	{
		public var xmin:int = 0;
		public var xmax:int = 11000;
		public var ymin:int = 0;
		public var ymax:int = 8000;
		
		protected var _rectangle:Rectangle;
		
		public function SWFRectangle(data:SWFData = null) {
			_rectangle = new Rectangle();
			if (data != null) {
				parse(data);
			}
		}

		public function parse(data:SWFData):void {
			data.resetBitsPending();
			var bits:uint = data.readUB(5);
			xmin = data.readSB(bits);
			xmax = data.readSB(bits);
			ymin = data.readSB(bits);
			ymax = data.readSB(bits);
		}
		
		public function publish(data:SWFData):void {
			var numBits:uint = data.calculateMaxBits(true, [xmin, xmax, ymin, ymax]);
			data.resetBitsPending();
			data.writeUB(5, numBits);
			data.writeSB(numBits, xmin);
			data.writeSB(numBits, xmax);
			data.writeSB(numBits, ymin);
			data.writeSB(numBits, ymax);
		}
		
		public function clone():SWFRectangle {
			var rect:SWFRectangle = new SWFRectangle();
			rect.xmin = xmin;
			rect.xmax = xmax;
			rect.ymin = ymin;
			rect.ymax = ymax;
			return rect;
		}
		
		public function get rect():Rectangle {
			_rectangle.left = NumberUtils.roundPixels20(xmin / 20);
			_rectangle.right = NumberUtils.roundPixels20(xmax / 20);
			_rectangle.top = NumberUtils.roundPixels20(ymin / 20);
			_rectangle.bottom = NumberUtils.roundPixels20(ymax / 20);
			return _rectangle;
		}
		
		public function toString():String {
			return "(" + xmin + "," + xmax + "," + ymin + "," + ymax + ")";
		}
		
		public function toStringSize():String {
			return "(" + (Number(xmax) / 20 - Number(xmin) / 20) + "," + (Number(ymax) / 20 - Number(ymin) / 20) + ")";
		}
	}
}
