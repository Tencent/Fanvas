package com.codeazur.as3swf.data.etc
{
	import flash.geom.Point;
	
	public interface IEdge
	{
		function get from():Point;
		function get to():Point;
		function get lineStyleIdx():uint;
		function get fillStyleIdx():uint;
		
		function reverseWithNewFillStyle(newFillStyleIdx:uint):IEdge;
	}
}
