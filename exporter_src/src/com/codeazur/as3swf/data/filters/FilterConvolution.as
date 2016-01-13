package com.codeazur.as3swf.data.filters
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.utils.ColorUtils;
	import com.codeazur.utils.StringUtils;

	import flash.filters.BitmapFilter;
	import flash.filters.ConvolutionFilter;
	
	public class FilterConvolution extends Filter implements IFilter
	{
		public var matrixX:uint;
		public var matrixY:uint;
		public var divisor:Number;
		public var bias:Number;
		public var defaultColor:uint;
		public var clamp:Boolean;
		public var preserveAlpha:Boolean;
		
		protected var _matrix:Vector.<Number>;
		
		public function FilterConvolution(id:uint) {
			super(id);
			_matrix = new Vector.<Number>();
		}
		
		public function get matrix():Vector.<Number> { return _matrix; }

		override public function get filter():BitmapFilter {
			var convolutionMatrix:Array = [];
			for (var i:int = 0; i < _matrix.length; i++) {
				convolutionMatrix.push(_matrix[i]);
			}
			return new ConvolutionFilter(
				matrixX,
				matrixY,
				convolutionMatrix,
				divisor,
				bias,
				preserveAlpha,
				clamp,
				ColorUtils.rgb(defaultColor),
				ColorUtils.alpha(defaultColor)
			);
		}
		
		override public function parse(data:SWFData):void {
			matrixX = data.readUI8();
			matrixY = data.readUI8();
			divisor = data.readFLOAT();
			bias = data.readFLOAT();
			var len:uint = matrixX * matrixY;
			for (var i:uint = 0; i < len; i++) {
				matrix.push(data.readFLOAT());
			}
			defaultColor = data.readRGBA();
			var flags:uint = data.readUI8();
			clamp = ((flags & 0x02) != 0);
			preserveAlpha = ((flags & 0x01) != 0);
		}
		
		override public function publish(data:SWFData):void {
			data.writeUI8(matrixX);
			data.writeUI8(matrixY);
			data.writeFLOAT(divisor);
			data.writeFLOAT(bias);
			var len:uint = matrixX * matrixY;
			for (var i:uint = 0; i < len; i++) {
				data.writeFLOAT(matrix[i]);
			}
			data.writeRGBA(defaultColor);
			var flags:uint = 0;
			if(clamp) { flags |= 0x02; }
			if(preserveAlpha) { flags |= 0x01; }
			data.writeUI8(flags);
		}
		
		override public function clone():IFilter {
			var filter:FilterConvolution = new FilterConvolution(id);
			filter.matrixX = matrixX;
			filter.matrixY = matrixY;
			filter.divisor = divisor;
			filter.bias = bias;
			var len:uint = matrixX * matrixY;
			for (var i:uint = 0; i < len; i++) {
				filter.matrix.push(matrix[i]);
			}
			filter.defaultColor = defaultColor;
			filter.clamp = clamp;
			filter.preserveAlpha = preserveAlpha;
			return filter;
		}
		
		override public function toString(indent:uint = 0):String {
			var str:String = "[ConvolutionFilter] " +
				"DefaultColor: " + ColorUtils.rgbToString(defaultColor) + ", " +
				"Divisor: " + divisor + ", " +
				"Bias: " + bias;
			var flags:Array = [];
			if(clamp) { flags.push("Clamp"); }
			if(preserveAlpha) { flags.push("PreserveAlpha"); }
			if(flags.length > 0) {
				str += ", Flags: " + flags.join(", ");
			}
			if(matrix.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Matrix:";
				for(var y:uint = 0; y < matrixY; y++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + y + "]";
					for(var x:uint = 0; x < matrixX; x++) {
						str += ((x > 0) ? ", " : " ") + matrix[matrixX * y + x];
					}
				}
			}
			return str;
		}
	}
}
