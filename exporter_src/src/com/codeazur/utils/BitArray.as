package com.codeazur.utils
{
	import flash.utils.ByteArray;
	
	public class BitArray extends ByteArray
	{
		protected var bitsPending:uint = 0;
		
		public function readBits(bits:uint, bitBuffer:uint = 0):uint {
			if (bits == 0) { return bitBuffer; }
			var partial:uint;
			var bitsConsumed:uint;
			if (bitsPending > 0) {
				var byte:uint = this[position - 1] & (0xff >> (8 - bitsPending));
				bitsConsumed = Math.min(bitsPending, bits);
				bitsPending -= bitsConsumed;
				partial = byte >> bitsPending;
			} else {
				bitsConsumed = Math.min(8, bits);
				bitsPending = 8 - bitsConsumed;
				partial = readUnsignedByte() >> bitsPending;
			}
			bits -= bitsConsumed;
			bitBuffer = (bitBuffer << bitsConsumed) | partial;
			return (bits > 0) ? readBits(bits, bitBuffer) : bitBuffer;
		}
		
		public function writeBits(bits:uint, value:uint):void {
			if (bits == 0) { return; }
			value &= (0xffffffff >>> (32 - bits));
			var bitsConsumed:uint;
			if (bitsPending > 0) {
				if (bitsPending > bits) {
					this[position - 1] |= value << (bitsPending - bits);
					bitsConsumed = bits;
					bitsPending -= bits;
				} else if (bitsPending == bits) {
					this[position - 1] |= value;
					bitsConsumed = bits;
					bitsPending = 0;
				} else {
					this[position - 1] |= value >> (bits - bitsPending);
					bitsConsumed = bitsPending;
					bitsPending = 0;
				}
			} else {
				bitsConsumed = Math.min(8, bits);
				bitsPending = 8 - bitsConsumed;
				writeByte((value >> (bits - bitsConsumed)) << bitsPending);
			}
			bits -= bitsConsumed;
			if (bits > 0) {
				writeBits(bits, value);
			}
		}
		
		public function resetBitsPending():void {
			bitsPending = 0;
		}
		
		public function calculateMaxBits(signed:Boolean, values:Array):uint {
			var b:uint = 0;
			var vmax:int = int.MIN_VALUE;
			if(!signed) {
				for each(var usvalue:uint in values) {
					b |= usvalue;
				}
			} else {
				for each(var svalue:int in values) {
					if(svalue >= 0) {
						b |= svalue;
					} else {
						b |= ~svalue << 1;
					}
					if(vmax < svalue) {
						vmax = svalue;
					}
				}
			}
			var bits:uint = 0;
			if(b > 0) {
				bits = b.toString(2).length;
				if(signed && vmax > 0 && vmax.toString(2).length >= bits) {
					bits++;
				}
			}
			return bits;
		}
	}
}
