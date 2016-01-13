package com.codeazur.as3swf.exporters
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.exporters.core.DefaultSVGShapeExporter;
	import com.codeazur.as3swf.utils.ColorUtils;
	import com.codeazur.utils.StringUtils;
	
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	public class SVGShapeExporter extends DefaultSVGShapeExporter
	{
		protected static const s:Namespace = new Namespace("s", "http://www.w3.org/2000/svg");
		protected static const xlink:Namespace = new Namespace("xlink", "http://www.w3.org/1999/xlink");
				
		protected var _svg:XML;
		protected var path:XML;
		protected var gradients:Vector.<String>;
		
		public function SVGShapeExporter(swf:SWF) {
			super(swf);
		}
		
		public function get svg():XML { return _svg; }
		
		override public function beginShape():void {
			_svg = <svg xmlns={s.uri} xmlns:xlink={xlink.uri}><defs /><g /></svg>;
			gradients = new Vector.<String>();
		}
		
		override public function beginFill(color:uint, alpha:Number = 1.0):void {
			finalizePath();
			path.@stroke = "none";
			path.@fill = ColorUtils.rgbToString(color);
			if(alpha != 1) { path.@["fill-opacity"] = alpha; }
		}
		
		override public function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = SpreadMethod.PAD, interpolationMethod:String = InterpolationMethod.RGB, focalPointRatio:Number = 0):void {
			finalizePath();
			var gradient:XML = (type == GradientType.LINEAR) ? <linearGradient /> : <radialGradient />;
			populateGradientElement(gradient, type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
			var id:int = gradients.indexOf(gradient.toXMLString());
			if(id < 0) {
				id = gradients.length;
				gradients.push(gradient.toXMLString());
			}
			gradient.@id = "gradient" + id;
			path.@stroke = "none";
			path.@fill = "url(#gradient" + id + ")";
			svg.s::defs.appendChild(gradient);
		}

		override public function beginBitmapFill(bitmapId:uint, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void {
			throw(new Error("Bitmap fills are not yet supported for shape export."));
		}
		
		override public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0, pixelHinting:Boolean = false, scaleMode:String = LineScaleMode.NORMAL, startCaps:String = null, endCaps:String = null, joints:String = null, miterLimit:Number = 3):void {
			finalizePath();
			path.@fill = "none";
			path.@stroke = ColorUtils.rgbToString(color);
			path.@["stroke-width"] = isNaN(thickness) ? 1 : thickness;
			if(alpha != 1) { path.@["stroke-opacity"] = alpha; }
			switch(startCaps) {
				case CapsStyle.NONE: path.@["stroke-linecap"] = "butt"; break;
				case CapsStyle.SQUARE: path.@["stroke-linecap"] = "square"; break;
				default: path.@["stroke-linecap"] = "round"; break;
			}
			switch(joints) {
				case JointStyle.BEVEL: path.@["stroke-linejoin"] = "bevel"; break;
				case JointStyle.ROUND: path.@["stroke-linejoin"] = "round"; break;
				default:
					path.@["stroke-linejoin"] = "miter";
					if(miterLimit >= 1 && miterLimit != 4) {
						path.@["stroke-miterlimit"] = miterLimit;
					}
					break;
			}
		}

		override public function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = SpreadMethod.PAD, interpolationMethod:String = InterpolationMethod.RGB, focalPointRatio:Number = 0):void {
			delete path.@["stroke-opacity"]
			var gradient:XML = (type == GradientType.LINEAR) ? <linearGradient /> : <radialGradient />;
			populateGradientElement(gradient, type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
			var id:int = gradients.indexOf(gradient.toXMLString());
			if(id < 0) {
				id = gradients.length;
				gradients.push(gradient.toXMLString());
			}
			gradient.@id = "gradient" + id;
			path.@stroke = "url(#gradient" + id + ")";
			path.@fill = "none";
			svg.s::defs.appendChild(gradient);
		}

		
		override protected function finalizePath():void {
			if(path && pathData != "") {
				path.@d = StringUtils.trim(pathData);
				svg.s::g.appendChild(path);
			}
			path = <path />;
			super.finalizePath();
		}
		
		
		protected function populateGradientElement(gradient:XML, type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix, spreadMethod:String, interpolationMethod:String, focalPointRatio:Number):void {
			gradient.@gradientUnits = "userSpaceOnUse";
			if(type == GradientType.LINEAR) {
				gradient.@x1 = -819.2;
				gradient.@x2 = 819.2;
			} else {
				gradient.@r = 819.2;
				gradient.@cx = 0;
				gradient.@cy = 0;
				if(focalPointRatio != 0) {
					gradient.@fx = 819.2 * focalPointRatio;
					gradient.@fy = 0;
				}
			}
			if(spreadMethod != SpreadMethod.PAD) { gradient.@spreadMethod = spreadMethod; }
			switch(spreadMethod) {
				case SpreadMethod.PAD: gradient.@spreadMethod = "pad"; break;
				case SpreadMethod.REFLECT: gradient.@spreadMethod = "reflect"; break;
				case SpreadMethod.REPEAT: gradient.@spreadMethod = "repeat"; break;
			}
			if(interpolationMethod == InterpolationMethod.LINEAR_RGB) { gradient.@["color-interpolation"] = "linearRGB"; }
			if(matrix) {
				var gradientValues:Array = [matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty];
				gradient.@gradientTransform = "matrix(" + gradientValues.join(" ") + ")";
			}
			for(var i:uint = 0; i < colors.length; i++) {
				var gradientEntry:XML = <stop offset={ratios[i] / 255} />
				if(colors[i] != 0) { gradientEntry.@["stop-color"] = ColorUtils.rgbToString(colors[i]); }
				if(alphas[i] != 1) { gradientEntry.@["stop-opacity"] = alphas[i]; }
				gradient.appendChild(gradientEntry);
			}
		}
	}
}
