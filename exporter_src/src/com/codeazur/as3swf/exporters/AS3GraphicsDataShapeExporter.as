package com.codeazur.as3swf.exporters
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.exporters.core.DefaultShapeExporter;
	
	import flash.display.CapsStyle;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsGradientFill;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.InterpolationMethod;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	public class AS3GraphicsDataShapeExporter extends DefaultShapeExporter
	{
		protected var _graphicsData:Vector.<IGraphicsData>;
		
		protected var tmpGraphicsPath:GraphicsPath;
		protected var tmpStroke:GraphicsStroke;
		
		public function AS3GraphicsDataShapeExporter(swf:SWF) {
			super(swf);
		}
		
		public function get graphicsData():Vector.<IGraphicsData> { return _graphicsData; }
		
		override public function beginShape():void {
			_graphicsData = new Vector.<IGraphicsData>();
		}
		
		override public function beginFills():void {
			_graphicsData.push(new GraphicsStroke());
		}

		override public function beginFill(color:uint, alpha:Number = 1.0):void {
			cleanUpGraphicsPath();
			_graphicsData.push(new GraphicsSolidFill(color, alpha));
		}
		
		override public function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = SpreadMethod.PAD, interpolationMethod:String = InterpolationMethod.RGB, focalPointRatio:Number = 0):void {
			cleanUpGraphicsPath();
			_graphicsData.push(new GraphicsGradientFill(
				type,
				colors,
				alphas,
				ratios,
				matrix,
				spreadMethod,
				interpolationMethod,
				focalPointRatio
			));
		}

		override public function beginBitmapFill(bitmapId:uint, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void {
			cleanUpGraphicsPath();
			// TODO
		}
		
		override public function endFill():void {
			cleanUpGraphicsPath();
			_graphicsData.push(new GraphicsEndFill());
		}

		override public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0, pixelHinting:Boolean = false, scaleMode:String = LineScaleMode.NORMAL, startCaps:String = CapsStyle.ROUND, endCaps:String = CapsStyle.ROUND, joints:String = JointStyle.ROUND, miterLimit:Number = 3):void {
			cleanUpGraphicsPath();
			tmpStroke = new GraphicsStroke(
				thickness,
				pixelHinting,
				scaleMode,
				startCaps,
				joints,
				miterLimit,
				new GraphicsSolidFill(color, alpha)
			);
			_graphicsData.push(tmpStroke);
		}
		
		override public function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix=null, spreadMethod:String=SpreadMethod.PAD, interpolationMethod:String=InterpolationMethod.RGB, focalPointRatio:Number=0):void {
			if(tmpStroke) {
				tmpStroke.fill = new GraphicsGradientFill(
					type,
					colors,
					alphas,
					ratios,
					matrix,
					spreadMethod,
					interpolationMethod,
					focalPointRatio
				);
			}
		}
		
		override public function moveTo(x:Number, y:Number):void {
			tmpGraphicsPath.moveTo(x, y);
		}
		
		override public function lineTo(x:Number, y:Number):void {
			tmpGraphicsPath.lineTo(x, y);
		}
		
		override public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void {
			tmpGraphicsPath.curveTo(controlX, controlY, anchorX, anchorY);
		}
		
		override public function endLines():void {
			cleanUpGraphicsPath();
		}
		
		protected function cleanUpGraphicsPath():void {
			if(tmpGraphicsPath && tmpGraphicsPath.commands && tmpGraphicsPath.commands.length > 0) {
				_graphicsData.push(tmpGraphicsPath);
			}
			tmpGraphicsPath = new GraphicsPath();
			tmpStroke = null;
		}
	}
}
