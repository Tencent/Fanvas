package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	
	import flash.geom.ColorTransform;
	
	public class SWFColorTransformWithAlpha extends SWFColorTransform
	{
		public function SWFColorTransformWithAlpha(data:SWFData = null) {
			super(data);
		}

		public function get aMult():Number { return _aMult / 256; }
		public function set aMult(value:Number):void { _aMult = clamp(value * 256); updateHasMultTerms(); }

		public function get aAdd():Number { return _aAdd; }
		public function set aAdd(value:Number):void { _aAdd = clamp(value); updateHasAddTerms(); }

		override public function get colorTransform():ColorTransform {
			return new ColorTransform(rMult, gMult, bMult, aMult, rAdd, gAdd, bAdd, aAdd);
		}
		
		override public function parse(data:SWFData):void {
			data.resetBitsPending();
			hasAddTerms = (data.readUB(1) == 1);
			hasMultTerms = (data.readUB(1) == 1);
			var bits:uint = data.readUB(4);
			if (hasMultTerms) {
				_rMult = data.readSB(bits);
				_gMult = data.readSB(bits);
				_bMult = data.readSB(bits);
				_aMult = data.readSB(bits);
			} else {
				_rMult = 256;
				_gMult = 256;
				_bMult = 256;
				_aMult = 256;
			}
			if (hasAddTerms) {
				_rAdd = data.readSB(bits);
				_gAdd = data.readSB(bits);
				_bAdd = data.readSB(bits);
				_aAdd = data.readSB(bits);
			} else {
				_rAdd = 0;
				_gAdd = 0;
				_bAdd = 0;
				_aAdd = 0;
			}
		}
		
		override public function publish(data:SWFData):void {
			data.resetBitsPending();
			data.writeUB(1, hasAddTerms ? 1 : 0);
			data.writeUB(1, hasMultTerms ? 1 : 0);
			var values:Array = [];
			if (hasMultTerms) { values.push(_rMult, _gMult, _bMult, _aMult); }
			if (hasAddTerms) { values.push(_rAdd, _gAdd, _bAdd, _aAdd); }
			var bits:uint = (hasMultTerms || hasAddTerms) ? data.calculateMaxBits(true, values) : 1;
			data.writeUB(4, bits);
			if (hasMultTerms) {
				data.writeSB(bits, _rMult);
				data.writeSB(bits, _gMult);
				data.writeSB(bits, _bMult);
				data.writeSB(bits, _aMult);
			}
			if (hasAddTerms) {
				data.writeSB(bits, _rAdd);
				data.writeSB(bits, _gAdd);
				data.writeSB(bits, _bAdd);
				data.writeSB(bits, _aAdd);
			}
		}
		
		override public function clone():SWFColorTransform {
			var colorTransform:SWFColorTransformWithAlpha = new SWFColorTransformWithAlpha();
			colorTransform.hasAddTerms = hasAddTerms;
			colorTransform.hasMultTerms = hasMultTerms;
			colorTransform.rMult = rMult;
			colorTransform.gMult = gMult;
			colorTransform.bMult = bMult;
			colorTransform.aMult = aMult;
			colorTransform.rAdd = rAdd;
			colorTransform.gAdd = gAdd;
			colorTransform.bAdd = bAdd;
			colorTransform.aAdd = aAdd;
			return colorTransform;
		}

		override protected function updateHasMultTerms():void {
			hasMultTerms = (_rMult != 256) || (_gMult != 256) || (_bMult != 256) || (_aMult != 256);
		}
		
		override protected function updateHasAddTerms():void {
			hasAddTerms = (_rAdd != 0) || (_gAdd != 0) || (_bAdd != 0) || (_aAdd != 0);
		}

		override public function toString():String {
			return "(" + rMult + "," + gMult + "," + bMult + "," + aMult + "," + rAdd + "," + gAdd + "," + bAdd + "," + aAdd + ")";
		}
	}
}
