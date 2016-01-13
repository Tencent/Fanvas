package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class SWFMatrix
	{
		public var scaleX:Number = 1.0;
		public var scaleY:Number = 1.0;
		public var rotateSkew0:Number = 0.0;
		public var rotateSkew1:Number = 0.0;
		public var translateX:int = 0;
		public var translateY:int = 0;
		
		public var xscale:Number;
		public var yscale:Number;
		public var rotation:Number;
		
		public function SWFMatrix(data:SWFData = null) {
			if (data != null) {
				parse(data);
			}
		}
		
		public function get matrix():Matrix {
			return new Matrix(scaleX, rotateSkew0, rotateSkew1, scaleY, translateX, translateY);
		}
		
		public function parse(data:SWFData):void {
			data.resetBitsPending();
			scaleX = 1.0;
			scaleY = 1.0;
			if (data.readUB(1) == 1) {
				var scaleBits:uint = data.readUB(5);
				scaleX = data.readFB(scaleBits);
				scaleY = data.readFB(scaleBits);
			}
			rotateSkew0 = 0.0;
			rotateSkew1 = 0.0;
			if (data.readUB(1) == 1) {
				var rotateBits:uint = data.readUB(5);
				rotateSkew0 = data.readFB(rotateBits);
				rotateSkew1 = data.readFB(rotateBits);
			}
			var translateBits:uint = data.readUB(5);
			translateX = data.readSB(translateBits);
			translateY = data.readSB(translateBits);
			// conversion to rotation, xscale, yscale
			var px:Point = matrix.deltaTransformPoint(new Point(0, 1));
			rotation = ((180 / Math.PI) * Math.atan2(px.y, px.x) - 90);
			if(rotation < 0) { rotation = 360 + rotation; }
			xscale = Math.sqrt(scaleX * scaleX + rotateSkew0 * rotateSkew0);
			yscale = Math.sqrt(rotateSkew1 * rotateSkew1 + scaleY * scaleY);
		}
		
		public function clone():SWFMatrix {
			var matrix:SWFMatrix = new SWFMatrix();
			matrix.scaleX = scaleX;
			matrix.scaleY = scaleY;
			matrix.rotateSkew0 = rotateSkew0;
			matrix.rotateSkew1 = rotateSkew1;
			matrix.translateX = translateX;
			matrix.translateY = translateY;
			return matrix;
		}
		
		public function isIdentity():Boolean {
			return (scaleX == 1 && scaleY == 1 && rotateSkew0 == 0 && rotateSkew1 == 0 && translateX == 0 && translateY == 0);
		}
		
		public function toString():String {
			return "(" + scaleX + "," + rotateSkew0 + "," + rotateSkew1 + "," + scaleY + "," + translateX + "," + translateY + ")";
		}
	}
}
