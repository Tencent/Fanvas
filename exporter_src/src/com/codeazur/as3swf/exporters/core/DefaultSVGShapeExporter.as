package com.codeazur.as3swf.exporters.core
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.utils.NumberUtils;
	
	import flash.display.InterpolationMethod;
	import flash.display.LineScaleMode;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	public class DefaultSVGShapeExporter extends DefaultShapeExporter
	{
		protected static const DRAW_COMMAND_L:String = "L";
		protected static const DRAW_COMMAND_Q:String = "Q";

		protected var currentDrawCommand:String = "";
		protected var pathData:String;
		
		public function DefaultSVGShapeExporter(swf:SWF) {
			super(swf);
		}
		
		override public function beginFill(color:uint, alpha:Number = 1.0):void {
			finalizePath();
		}
		
		override public function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = SpreadMethod.PAD, interpolationMethod:String = InterpolationMethod.RGB, focalPointRatio:Number = 0):void {
			finalizePath();
		}

		override public function beginBitmapFill(bitmapId:uint, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void {
			finalizePath();
		}
		
		override public function endFill():void {
			finalizePath();
		}

		override public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0, pixelHinting:Boolean = false, scaleMode:String = LineScaleMode.NORMAL, startCaps:String = null, endCaps:String = null, joints:String = null, miterLimit:Number = 3):void {
			finalizePath();
		}
		
		override public function moveTo(x:Number, y:Number):void {
			currentDrawCommand = "";
			pathData += "M" +
				NumberUtils.roundPixels20(x) + " " + 
				NumberUtils.roundPixels20(y) + " ";
		}
		
		override public function lineTo(x:Number, y:Number):void {
			if(currentDrawCommand != DRAW_COMMAND_L) {
				currentDrawCommand = DRAW_COMMAND_L;
				pathData += "L";
			}
			pathData += 
				NumberUtils.roundPixels20(x) + " " + 
				NumberUtils.roundPixels20(y) + " ";
		}
		
		override public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void {
			if(currentDrawCommand != DRAW_COMMAND_Q) {
				currentDrawCommand = DRAW_COMMAND_Q;
				pathData += "Q";
			}
			pathData += 
				NumberUtils.roundPixels20(controlX) + " " + 
				NumberUtils.roundPixels20(controlY) + " " + 
				NumberUtils.roundPixels20(anchorX) + " " + 
				NumberUtils.roundPixels20(anchorY) + " ";
		}
		
		override public function endLines():void {
			finalizePath();
		}

		
		protected function finalizePath():void {
			pathData = "";
			currentDrawCommand = "";
		}
	}
}
