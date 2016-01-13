package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.geom.ColorTransform;
	
	public class SWFColorTransform
	{
		protected var _rMult:int = 256;
		protected var _gMult:int = 256;
		protected var _bMult:int = 256;
		protected var _aMult:int = 256;

		protected var _rAdd:int = 0;
		protected var _gAdd:int = 0;
		protected var _bAdd:int = 0;
		protected var _aAdd:int = 0;
		
		public var hasMultTerms:Boolean;
		public var hasAddTerms:Boolean;
		
		public function SWFColorTransform(data:SWFData = null) {
			if (data != null) {
				parse(data);
			}
		}
		
		public function get rMult():Number { return _rMult / 256; }
		public function get gMult():Number { return _gMult / 256; }
		public function get bMult():Number { return _bMult / 256; }

		public function set rMult(value:Number):void { _rMult = clamp(value * 256); updateHasMultTerms(); }
		public function set gMult(value:Number):void { _gMult = clamp(value * 256); updateHasMultTerms(); }
		public function set bMult(value:Number):void { _bMult = clamp(value * 256); updateHasMultTerms(); }

		public function get rAdd():Number { return _rAdd; }
		public function get gAdd():Number { return _gAdd; }
		public function get bAdd():Number { return _bAdd; }
		
		public function set rAdd(value:Number):void { _rAdd = clamp(value); updateHasAddTerms(); }
		public function set gAdd(value:Number):void { _gAdd = clamp(value); updateHasAddTerms(); }
		public function set bAdd(value:Number):void { _bAdd = clamp(value); updateHasAddTerms(); }

		public function get colorTransform():ColorTransform {
			return new ColorTransform(rMult, gMult, bMult, 1, rAdd, gAdd, bAdd, 0);
		}
		
		public function parse(data:SWFData):void {
			data.resetBitsPending();
			hasAddTerms = (data.readUB(1) == 1);
			hasMultTerms = (data.readUB(1) == 1);
			var bits:uint = data.readUB(4);
			if (hasMultTerms) {
				_rMult = data.readSB(bits);
				_gMult = data.readSB(bits);
				_bMult = data.readSB(bits);
			} else {
				_rMult = 256;
				_gMult = 256;
				_bMult = 256;
			}
			if (hasAddTerms) {
				_rAdd = data.readSB(bits);
				_gAdd = data.readSB(bits);
				_bAdd = data.readSB(bits);
			} else {
				_rAdd = 0;
				_gAdd = 0;
				_bAdd = 0;
			}
		}
		
		public function publish(data:SWFData):void {
			data.resetBitsPending();
			data.writeUB(1, hasAddTerms ? 1 : 0);
			data.writeUB(1, hasMultTerms ? 1 : 0);
			var values:Array = [];
			if (hasMultTerms) { values.push(_rMult, _gMult, _bMult); }
			if (hasAddTerms) { values.push(_rAdd, _gAdd, _bAdd); }
			var bits:uint = data.calculateMaxBits(true, values);
			data.writeUB(4, bits);
			if (hasMultTerms) {
				data.writeSB(bits, _rMult);
				data.writeSB(bits, _gMult);
				data.writeSB(bits, _bMult);
			}
			if (hasAddTerms) {
				data.writeSB(bits, _rAdd);
				data.writeSB(bits, _gAdd);
				data.writeSB(bits, _bAdd);
			}
		}
		
		public function clone():SWFColorTransform {
			var colorTransform:SWFColorTransform = new SWFColorTransform();
			colorTransform.hasAddTerms = hasAddTerms;
			colorTransform.hasMultTerms = hasMultTerms;
			colorTransform.rMult = rMult;
			colorTransform.gMult = gMult;
			colorTransform.bMult = bMult;
			colorTransform.rAdd = rAdd;
			colorTransform.gAdd = gAdd;
			colorTransform.bAdd = bAdd;
			return colorTransform;
		}

		protected function updateHasMultTerms():void {
			hasMultTerms = (_rMult != 256) || (_gMult != 256) || (_bMult != 256);
		}
		
		protected function updateHasAddTerms():void {
			hasAddTerms = (_rAdd != 0) || (_gAdd != 0) || (_bAdd != 0);
		}
		
		protected function clamp(value:Number):int {
			return Math.min(Math.max(value, -32768), 32767);
		}
		
		public function isIdentity():Boolean {
			return !hasMultTerms && !hasAddTerms;
		}
		
		public function toString():String {
			return "(" + rMult + "," + gMult + "," + bMult + "," + rAdd + "," + gAdd + "," + bAdd + ")";
		}
	}
}
