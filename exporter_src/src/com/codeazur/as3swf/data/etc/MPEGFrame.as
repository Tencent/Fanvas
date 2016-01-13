package com.codeazur.as3swf.data.etc
{
	import flash.utils.ByteArray;
	
	public class MPEGFrame 
	{
		public static const MPEG_VERSION_1_0:uint = 0;
		public static const MPEG_VERSION_2_0:uint = 1;
		public static const MPEG_VERSION_2_5:uint = 2;
		
		public static const MPEG_LAYER_I:uint = 0;
		public static const MPEG_LAYER_II:uint = 1;
		public static const MPEG_LAYER_III:uint = 2;
		
		public static const CHANNEL_MODE_STEREO:uint = 0;
		public static const CHANNEL_MODE_JOINT_STEREO:uint = 1;
		public static const CHANNEL_MODE_DUAL:uint = 2;
		public static const CHANNEL_MODE_MONO:uint = 3;
		
		protected static var mpegBitrates:Array = [
			[ [0, 32, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, -1],
			  [0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, -1],
			  [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, -1] ],
			[ [0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256, -1],
			  [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, -1],
			  [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, -1] ]
		];
		protected static var mpegSamplingRates:Array = [
			[44100, 48000, 32000],
			[22050, 24000, 16000],
			[11025, 12000, 8000]
		];
		
		protected var _version:uint;
		protected var _layer:uint;
		protected var _bitrate:uint;
		protected var _samplingRate:uint;
		protected var _padding:Boolean;
		protected var _channelMode:uint;
		protected var _channelModeExt:uint;
		protected var _copyright:Boolean;
		protected var _original:Boolean;
		protected var _emphasis:uint;
		
		protected var _header:ByteArray;
		protected var _data:ByteArray;
		protected var _crc:ByteArray;
		
		protected var _hasCRC:Boolean;

		protected var _samples:uint = 1152;
		
		public function MPEGFrame() {
			init();
		}
		
		public function get version():uint { return _version; }
		public function get layer():uint { return _layer; }
		public function get bitrate():uint { return _bitrate; }
		public function get samplingrate():uint { return _samplingRate; }
		public function get padding():Boolean { return _padding; }
		public function get channelMode():uint { return _channelMode; }
		public function get channelModeExt():uint { return _channelModeExt; }
		public function get copyright():Boolean { return _copyright; }
		public function get original():Boolean { return _original; }
		public function get emphasis():uint { return _emphasis; }

		public function get hasCRC():Boolean { return _hasCRC; }
		public function get crc():uint { _crc.position = 0; return _crc.readUnsignedShort(); _crc.position = 0; }

		public function get samples():uint { return _samples; }

		public function get data():ByteArray { return _data; }
		public function set data(value:ByteArray):void { _data = value; }

		public function get size():uint {
			var ret:uint = 0;
			if (layer == MPEG_LAYER_I) {
				ret = Math.floor((12000.0 * bitrate) / samplingrate);
				if (padding) {
					ret++;
				}
				// one slot is 4 bytes long
				ret <<= 2;
			} else {
				ret = Math.floor(((version == MPEG_VERSION_1_0) ? 144000.0 : 72000.0) * bitrate / samplingrate);
				if (padding) {
					ret++;
				}
			}
			// subtract header size and (if present) crc size
			return ret - 4 - (hasCRC ? 2 : 0);
		}

		public function setHeaderByteAt(index:uint, value:uint):void {
			switch(index) {
				case 0:
					if (value != 0xff) {
						throw(new Error("Not a MPEG header."));
					}
					break;
				case 1:
					if ((value & 0xe0) != 0xe0) {
						throw(new Error("Not a MPEG header."));
					}
					// get the mpeg version (we only support mpeg 1.0 and 2.0)
					var mpegVersionBits:uint = (value & 0x18) >> 3;
					switch(mpegVersionBits) {
						case 3: _version = MPEG_VERSION_1_0; break;
						case 2: _version = MPEG_VERSION_2_0; break;
						default: throw(new Error("Unsupported MPEG version."));
					}
					// get the mpeg layer version (we only support layer III)
					var mpegLayerBits:uint = (value & 0x06) >> 1;
					switch(mpegLayerBits) {
						case 1: _layer = MPEG_LAYER_III; break;
						default: throw(new Error("Unsupported MPEG layer."));
					}
					// is the frame secured by crc?
					_hasCRC = !((value & 0x01) != 0);
					break;
				case 2:
					var bitrateIndex:uint = ((value & 0xf0) >> 4);
					// get the frame's bitrate
					if (bitrateIndex == 0 || bitrateIndex == 0x0f) {
						throw(new Error("Unsupported bitrate index."));
					}
					_bitrate = mpegBitrates[_version][_layer][bitrateIndex];
					// get the frame's samplingrate
					var samplingrateIndex:uint = ((value & 0x0c) >> 2);
					if (samplingrateIndex == 3) {
						throw(new Error("Unsupported samplingrate index."));
					}
					_samplingRate = mpegSamplingRates[_version][samplingrateIndex];
					// is the frame padded?
					_padding = ((value & 0x02) == 0x02);
					break;
				case 3:
					// get the frame's channel mode:
					// 0: stereo
					// 1: joint stereo
					// 2: dual channel
					// 3: mono
					_channelMode = ((value & 0xc0) >> 6);
					// get the frame's extended channel mode (only for joint stereo):
					_channelModeExt = ((value & 0x30) >> 4);
					// get the copyright flag
					_copyright = ((value & 0x08) == 0x08);
					// get the original flag
					_original = ((value & 0x04) == 0x04);
					// get the emphasis:
					// 0: none
					// 1: 50/15 ms
					// 2: reserved
					// 3: ccit j.17
					_emphasis = (value & 0x02);
					break;
				default:
					throw(new Error("Index out of bounds."));
			}
			// store the raw header byte for easy access
			_header[index] = value;
		}
		
		public function setCRCByteAt(index:uint, value:uint):void {
			if (index > 1) {
				throw(new Error("Index out of bounds."));
			}
			_crc[index] = value;
		}
		
		protected function init():void {
			_header = new ByteArray();
			_header.writeByte(0);
			_header.writeByte(0);
			_header.writeByte(0);
			_header.writeByte(0);
			_crc = new ByteArray();
			_crc.writeByte(0);
			_crc.writeByte(0);
		}
		
		public function getFrame():ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.writeBytes(_header, 0, 4);
			if(hasCRC) {
				ba.writeBytes(_crc, 0, 2);
			}
			ba.writeBytes(_data);
			return ba;
		}
		
		public function toString():String {
			var encoding:String = "MPEG ";
			switch(version) {
				case MPEGFrame.MPEG_VERSION_1_0: encoding += "1.0 "; break;
				case MPEGFrame.MPEG_VERSION_2_0: encoding += "2.0 "; break;
				case MPEGFrame.MPEG_VERSION_2_5: encoding += "2.5 "; break;
				default: encoding += "?.? "; break;
			}
			switch(layer) {
				case MPEGFrame.MPEG_LAYER_I: encoding += "Layer I"; break;
				case MPEGFrame.MPEG_LAYER_II: encoding += "Layer II"; break;
				case MPEGFrame.MPEG_LAYER_III: encoding += "Layer III"; break;
				default: encoding += "Layer ?"; break;
			}
			var channel:String = "unknown";
			switch(channelMode) {
				case 0: channel = "Stereo"; break;
				case 1: channel = "Joint stereo"; break;
				case 2: channel = "Dual channel"; break;
				case 3: channel = "Mono"; break;
			}
			return encoding + ", " + bitrate + " kbit/s, " + samplingrate + " Hz, " + channel + ", " + size + " bytes";
		}
	}
}
