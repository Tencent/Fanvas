package com.codeazur.as3swf.utils
{
	import com.codeazur.as3swf.data.SWFMatrix;

	public class MatrixUtils
	{
		public static function interpolate(matrix1:SWFMatrix, matrix2:SWFMatrix, ratio:Number):SWFMatrix {
			// TODO: not sure about this at all
			var matrix:SWFMatrix = new SWFMatrix();
			matrix.scaleX = matrix1.scaleX + (matrix2.scaleX - matrix1.scaleX) * ratio;
			matrix.scaleY = matrix1.scaleY + (matrix2.scaleY - matrix1.scaleY) * ratio;
			matrix.rotateSkew0 = matrix1.rotateSkew0 + (matrix2.rotateSkew0 - matrix1.rotateSkew0) * ratio;
			matrix.rotateSkew1 = matrix1.rotateSkew1 + (matrix2.rotateSkew1 - matrix1.rotateSkew1) * ratio;
			matrix.translateX = matrix1.translateX + (matrix2.translateX - matrix1.translateX) * ratio;
			matrix.translateY = matrix1.translateY + (matrix2.translateY - matrix1.translateY) * ratio;
			return matrix;
		}
	}
}