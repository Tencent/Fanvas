package com.codeazur.as3swf.data.etc
{
	import flash.geom.Point;
	
	public class StraightEdge implements IEdge
	{
		protected var _from:Point;
		protected var _to:Point;
		protected var _lineStyleIdx:uint = 0;
		protected var _fillStyleIdx:uint = 0;
		
		public function StraightEdge(aFrom:Point, aTo:Point, aLineStyleIdx:uint = 0, aFillStyleIdx:uint = 0)
		{
			_from = aFrom;
			_to = aTo;
			_lineStyleIdx = aLineStyleIdx;
			_fillStyleIdx = aFillStyleIdx;
		}
		
		public function get from():Point { return _from; }
		public function get to():Point { return _to; }
		public function get lineStyleIdx():uint { return _lineStyleIdx; }
		public function get fillStyleIdx():uint { return _fillStyleIdx; }
		
		public function reverseWithNewFillStyle(newFillStyleIdx:uint):IEdge {
			return new StraightEdge(to, from, lineStyleIdx, newFillStyleIdx);
		}
		
		public function toString():String {
			return "stroke:" + lineStyleIdx + ", fill:" + fillStyleIdx + ", start:" + from.toString() + ", end:" + to.toString();
		}
	}
}
