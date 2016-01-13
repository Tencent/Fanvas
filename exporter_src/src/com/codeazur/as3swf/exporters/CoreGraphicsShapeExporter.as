package com.codeazur.as3swf.exporters
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.utils.ColorUtils;
	import com.codeazur.as3swf.utils.ObjCUtils;
	
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import com.codeazur.as3swf.exporters.core.DefaultShapeExporter;

	public class CoreGraphicsShapeExporter extends DefaultShapeExporter
	{
		protected static const DEFAULT_CLASSNAME:String = "DefaultClassName";
		
		protected static const NOT_ACTIVE:String = "notActive";
		protected static const FILL_ACTIVE:String = "fillActive";
		protected static const STROKE_ACTIVE:String = "strokeActive";
		
		protected var _m:String = "";
		protected var _h:String = "";
		
		protected var _className:String;
		protected var _projectName:String;
		protected var _author:String;
		protected var _copyright:String;

		protected var fills:Vector.<String>;
		protected var strokes:Vector.<String>;
		protected var geometry:String = "";
		protected var prefix:String = "";
		protected var suffix:String = "";
		
		protected var active:String = NOT_ACTIVE;
		
		public function CoreGraphicsShapeExporter(swf:SWF, aClassName:String, aProjectName:String = "###ProjectName###", aAuthor:String = "###AuthorName###", aCopyright:String = "###Copyright###")
		{
			_className = (aClassName != null && aClassName.length > 0) ? aClassName : DEFAULT_CLASSNAME;
			_projectName = aProjectName;
			_author = aAuthor;
			_copyright = aCopyright;
			super(swf);
		}
		
		public function get m():String { return _m; }
		
		public function get h():String { return _h; }
		
		public function get className():String { return _className; }
		public function set className(value:String):void {
			_className = (value != null && value.length > 0) ? value : DEFAULT_CLASSNAME;
		}
		
		public function get projectName():String { return _projectName; }
		public function set projectName(value:String):void { _projectName = value; }
		
		public function get author():String { return _author; }
		public function set author(value:String):void { _author = value; }
		
		public function get copyright():String { return _copyright; }
		public function set copyright(value:String):void { _copyright = value; }


		override public function beginShape():void {
			_m = "//\r" +
				"//  " + className + ".m\r" +
				"//  " + projectName + "\r" +
				"//\r" +
				"//  Created by " + _author + " on " + new Date().toDateString() + ".\r" +
				"//  Copyright " + new Date().fullYear + " " + _copyright + ". All rights reserved.\r" +
				"//\r" +
				"\r" +
				"#import \"" + className + ".h\"\r" +
				"\r" +
				"@implementation " + className + "\r" +
				"\r" +
				"- (id)initWithFrame:(CGRect)frame {\r" + 
				"\tif (self = [super initWithFrame:frame]) {\r" + 
				"\t\t// Initialization code\r" + 
				"\t}\r" + 
				"\treturn self;\r" + 
				"}\r" + 
				"\r" +
				"- (void)drawRect:(CGRect)rect {\r" +
				"\tCGContextRef ctx = UIGraphicsGetCurrentContext();\r";
			_h = "//\r" +
				"//  " + className + ".h\r" +
				"//  " + projectName + "\r" +
				"//\r" +
				"//  Created by " + _author + " on " + new Date().toDateString() + ".\r" +
				"//  Copyright " + new Date().fullYear + " " + _copyright + ". All rights reserved.\r" +
				"//\r" +
				"\r" +
				"#import <UIKit/UIKit.h>\r" +
				"\r" +
				"@interface " + className + " : UIView {\r" +
				"}\r";
		}
		
		
		override public function beginFills():void {
			fills = new Vector.<String>();
		}

		override public function endFills():void {
			for (var i:uint = 0; i < fills.length; i++) {
				_m += "\t[self drawFill" + i + ":ctx];\r";
			}
		}

		
		override public function beginLines():void {
			strokes = new Vector.<String>();
		}
		
		override public function endLines():void {
			processPreviousStroke();
			for (var i:uint = 0; i < strokes.length; i++) {
				_m += "\t[self drawStroke" + i + ":ctx];\r";
			}
		}
		
		
		override public function endShape():void {
			var i:uint;
			_m += "}\r";
			if (fills != null) {
				for (i = 0; i < fills.length; i++) {
					_m += "\r- (void)drawFill" + i + ":(CGContextRef)ctx {\r" + fills[i] + "}\r";
					_h += "\r- (void)drawFill" + i + ":(CGContextRef)ctx;";
				}
			}
			if (strokes != null) {
				for (i = 0; i < strokes.length; i++) {
					_m += "\r- (void)drawStroke" + i + ":(CGContextRef)ctx {\r" + strokes[i] + "}\r";
					_h += "\r- (void)drawStroke" + i + ":(CGContextRef)ctx;";
				}
			}
			_m += "\r- (void)dealloc {\r\t[super dealloc];\r}\r\r@end\r";
			_h += "\r\r@end\r";
			fills = null;
			strokes = null;
		}
		
		
		override public function beginFill(color:uint, alpha:Number = 1.0):void {
			processPreviousFill();
			active = FILL_ACTIVE;
			prefix = "\tCGContextSaveGState(ctx);\r\r";
			geometry = "\tCGContextBeginPath(ctx);\r";
			suffix = "\tCGFloat c[4] = { " + 
				ObjCUtils.num2str(ColorUtils.r(color)) + ", " +
				ObjCUtils.num2str(ColorUtils.g(color)) + ", " +
				ObjCUtils.num2str(ColorUtils.b(color)) + ", " +
				ObjCUtils.num2str(alpha) +
				" };\r" +
				"\tCGContextSetFillColor(ctx, c);\r" +
				"\tCGContextFillPath(ctx);\r\r" + 
				"\tCGContextRestoreGState(ctx);\r";
		}
		
		override public function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = SpreadMethod.PAD, interpolationMethod:String = InterpolationMethod.RGB, focalPointRatio:Number = 0):void {
			processPreviousFill();
			active = FILL_ACTIVE;
			prefix = "\tCGContextSaveGState(ctx);\r\r";
			geometry = "\tCGContextBeginPath(ctx);\r";
			var i:uint;
			var len:uint = uint(Math.min(Math.min(colors.length, alphas.length), ratios.length));
			if (type == GradientType.LINEAR) {
				suffix = "\tCGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();\r"
				suffix += "\tCGFloat colors[" + (len * 4) + "] = {\r";
				for (i = 0; i < len; i++) {
					var color:uint = colors[i];
					suffix += "\t\t" +
						ObjCUtils.num2str(ColorUtils.r(color)) + ", " +
						ObjCUtils.num2str(ColorUtils.g(color)) + ", " +
						ObjCUtils.num2str(ColorUtils.b(color)) + ", " +
						ObjCUtils.num2str(alphas[i]);
					if (i < colors.length - 1) {
						suffix += ",";
					}
					suffix += "\r";
				}
				suffix += "\t};\r";
				suffix += "\tCGFloat ratios[" + len + "] = { ";
				for (i = 0; i < len; i++) {
					suffix += ObjCUtils.num2str(Number(ratios[i]) / 255);
					if (i < ratios.length - 1) {
						suffix += ", ";
					}
				}
				suffix += " };\r";
				suffix += "\tCGGradientRef g = CGGradientCreateWithColorComponents(cs, colors, ratios, " + len + ");\r"
				suffix += "\tCGContextEOClip(ctx);\r"
				var from:Point = new Point(-819.2 * matrix.a + matrix.tx, -819.2 * matrix.b + matrix.ty);
				var to:Point = new Point(819.2 * matrix.a + matrix.tx, 819.2 * matrix.b + matrix.ty);
				suffix += "\tCGPoint from = CGPointMake(" + ObjCUtils.num2str(from.x) + ", " + ObjCUtils.num2str(from.y) + ");\r";
				suffix += "\tCGPoint to = CGPointMake(" + ObjCUtils.num2str(to.x) + ", " + ObjCUtils.num2str(to.y) + ");\r";
				suffix += "\tCGContextDrawLinearGradient(ctx, g, from, to, 0);\r";
				suffix += "\tCGGradientRelease(g);\r";
				suffix += "\tCGColorSpaceRelease(cs);\r\r"
			} else if (type == GradientType.RADIAL) {
				// TODO
				suffix = "";
			}
			suffix += "\tCGContextRestoreGState(ctx);\r"
		}

		override public function beginBitmapFill(bitmapId:uint, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void {
			processPreviousFill();
			active = NOT_ACTIVE;
			// TODO
		}
		
		override public function endFill():void {
			processPreviousFill();
			active = NOT_ACTIVE;
		}
		
		override public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0, pixelHinting:Boolean = false, scaleMode:String = LineScaleMode.NORMAL, startCaps:String = null, endCaps:String = null, joints:String = null, miterLimit:Number = 3):void {
			processPreviousStroke();
			active = STROKE_ACTIVE;
			prefix = "\tCGContextSaveGState(ctx);\r\r" +
				"\tCGFloat c[4] = { " +
				ObjCUtils.num2str(ColorUtils.r(color)) + ", " +
				ObjCUtils.num2str(ColorUtils.g(color)) + ", " +
				ObjCUtils.num2str(ColorUtils.b(color)) + ", " +
				ObjCUtils.num2str(alpha) +
				" };\r" +
				"\tCGContextSetStrokeColor(ctx, c);\r" +
				"\tCGContextSetLineWidth(ctx, " + ObjCUtils.num2str(thickness) + ");\r";
			if (startCaps == null || startCaps == CapsStyle.ROUND) {
				prefix += "\tCGContextSetLineCap(ctx, kCGLineCapRound);\r";
			} else if (startCaps == CapsStyle.SQUARE) {
				prefix += "\tCGContextSetLineCap(ctx, kCGLineCapSquare);\r";
			}
			if (joints == null || joints == JointStyle.ROUND) {
				prefix += "\tCGContextSetLineJoin(ctx, kCGLineJoinRound);\r";
			} else if (joints == JointStyle.BEVEL) {
				prefix += "\tCGContextSetLineJoin(ctx, kCGLineJoinMiter);\r";
				prefix += "\tCGContextSetMiterLimit(ctx, " + ObjCUtils.num2str(miterLimit) + ");\r";
			} else {
				prefix += "\tCGContextSetMiterLimit(ctx, " + ObjCUtils.num2str(miterLimit) + ");\r";
			}
			prefix += "\r";
			geometry = "\tCGContextBeginPath(ctx);\r";
			suffix = "\tCGContextStrokePath(ctx);\r\r\tCGContextRestoreGState(ctx);\r";
		}
		
		override public function moveTo(x:Number, y:Number):void {
			if (active != NOT_ACTIVE) {
				geometry += "\tCGContextMoveToPoint(ctx, " + 
					ObjCUtils.num2str(x, true) + ", " + 
					ObjCUtils.num2str(y, true) + ");\r";
			}
		}
		
		override public function lineTo(x:Number, y:Number):void {
			if (active != NOT_ACTIVE) {
				geometry += "\tCGContextAddLineToPoint(ctx, " + 
					ObjCUtils.num2str(x, true) + ", " + 
					ObjCUtils.num2str(y, true) + ");\r";
			}
		}
		
		override public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void {
			if (active != NOT_ACTIVE) {
				geometry += "\tCGContextAddQuadCurveToPoint(ctx, " + 
					ObjCUtils.num2str(controlX, true) + ", " + 
					ObjCUtils.num2str(controlY, true) + ", " +
					ObjCUtils.num2str(anchorX, true) + ", " + 
					ObjCUtils.num2str(anchorY, true) + ");\r";
			}
		}

		
		protected function processPreviousFill():void {
			if (active == FILL_ACTIVE) {
				active = NOT_ACTIVE;
				fills.push(prefix + geometry + "\tCGContextClosePath(ctx);\r\r" + suffix);
				geometry = "";
				prefix = "";
				suffix = "";
			}
		}
		
		protected function processPreviousStroke():void {
			if (active == STROKE_ACTIVE) {
				active = NOT_ACTIVE;
				strokes.push(prefix + geometry + "\tCGContextClosePath(ctx);\r\r" + suffix);
				geometry = "";
				prefix = "";
				suffix = "";
			}
		}
	}
}
