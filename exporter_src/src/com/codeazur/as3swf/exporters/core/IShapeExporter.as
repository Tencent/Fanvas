package com.codeazur.as3swf.exporters.core
{
	import flash.display.BitmapData;
	import flash.display.InterpolationMethod;
	import flash.display.LineScaleMode;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	public interface IShapeExporter
	{
		function beginShape():void;
		function endShape():void;
		
		function beginFills():void;
		function endFills():void;
		
		function beginLines():void;
		function endLines():void;
		
		function beginFill(color:uint, alpha:Number = 1.0):void;
		function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void;
		function beginBitmapFill(bitmapId:uint, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void;
		function endFill():void;

		function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0, pixelHinting:Boolean = false, scaleMode:String = "normal", startCaps:String = null, endCaps:String = null, joints:String = null, miterLimit:Number = 3):void;
		function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void;

		function moveTo(x:Number, y:Number):void;
		function lineTo(x:Number, y:Number):void;
		function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void;
	}
}
