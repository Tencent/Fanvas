package com.codeazur.as3swf.data.etc
{
	import flash.geom.Point;
	
	public class CurvedEdge extends StraightEdge implements IEdge
	{
		protected var _control:Point;
		
		public function CurvedEdge(aFrom:Point, aControl:Point, aTo:Point, aLineStyleIdx:uint = 0, aFillStyleIdx:uint = 0)
		{
			super(aFrom, aTo, aLineStyleIdx, aFillStyleIdx);
			_control = aControl;
		}
		
		public function get control():Point { return _control; }
		
		override public function reverseWithNewFillStyle(newFillStyleIdx:uint):IEdge {
			return new CurvedEdge(to, control, from, lineStyleIdx, newFillStyleIdx);
		}
		
		override public function toString():String {
			return "stroke:" + lineStyleIdx + ", fill:" + fillStyleIdx + ", start:" + from.toString() + ", control:" + control.toString() + ", end:" + to.toString();
		}
	}
}
