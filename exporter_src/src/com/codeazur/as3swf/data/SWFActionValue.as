package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.ActionValueType;
	import com.codeazur.utils.StringUtils;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SWFActionValue
	{
		public var type:uint;
		public var string:String;
		public var number:Number;
		public var register:uint;
		public var boolean:Boolean;
		public var integer:uint;
		public var constant:uint;

		private static var ba:ByteArray = initTmpBuffer();

		private static function initTmpBuffer():ByteArray {
			var baTmp:ByteArray = new ByteArray();
			baTmp.endian = Endian.LITTLE_ENDIAN;
			baTmp.length = 8;
			return baTmp;
		}

		public function SWFActionValue(data:SWFData = null) {
			if (data != null) {
				parse(data);
			}
		}
		
		public function parse(data:SWFData):void {
			type = data.readUI8();
			switch (type) {
				case ActionValueType.STRING: string = data.readString(); break;
				case ActionValueType.FLOAT: number = data.readFLOAT(); break;
				case ActionValueType.NULL: break;
				case ActionValueType.UNDEFINED: break;
				case ActionValueType.REGISTER: register = data.readUI8(); break;
				case ActionValueType.BOOLEAN: boolean = (data.readUI8() != 0); break;
				case ActionValueType.DOUBLE:
					ba.position = 0;
					ba[4] = data.readUI8();
					ba[5] = data.readUI8();
					ba[6] = data.readUI8();
					ba[7] = data.readUI8();
					ba[0] = data.readUI8();
					ba[1] = data.readUI8();
					ba[2] = data.readUI8();
					ba[3] = data.readUI8();
					number = ba.readDouble();
					break;
				case ActionValueType.INTEGER: integer = data.readUI32(); break;
				case ActionValueType.CONSTANT_8: constant = data.readUI8(); break;
				case ActionValueType.CONSTANT_16: constant = data.readUI16(); break;
				default:
					throw(new Error("Unknown ActionValueType: " + type));
			}
		}
		
		public function publish(data:SWFData):void {
			data.writeUI8(type);
			switch (type) {
				case ActionValueType.STRING: data.writeString(string); break;
				case ActionValueType.FLOAT: data.writeFLOAT(number); break;
				case ActionValueType.NULL: break;
				case ActionValueType.UNDEFINED: break;
				case ActionValueType.REGISTER: data.writeUI8(register); break;
				case ActionValueType.BOOLEAN: data.writeUI8(boolean ? 1 : 0); break;
				case ActionValueType.DOUBLE:
					ba.position = 0;
					ba.writeDouble(number);
					data.writeUI8(ba[4]);
					data.writeUI8(ba[5]);
					data.writeUI8(ba[6]);
					data.writeUI8(ba[7]);
					data.writeUI8(ba[0]);
					data.writeUI8(ba[1]);
					data.writeUI8(ba[2]);
					data.writeUI8(ba[3]);
					break;
				case ActionValueType.INTEGER: data.writeUI32(integer); break;
				case ActionValueType.CONSTANT_8: data.writeUI8(constant); break;
				case ActionValueType.CONSTANT_16: data.writeUI16(constant); break;
				default:
					throw(new Error("Unknown ActionValueType: " + type));
			}
		}
		
		public function clone():SWFActionValue {
			var value:SWFActionValue = new SWFActionValue();
			switch (type) {
				case ActionValueType.FLOAT:
				case ActionValueType.DOUBLE:
					value.number = number;
					break;
				case ActionValueType.CONSTANT_8:
				case ActionValueType.CONSTANT_16:
					value.constant = constant;
					break;
				case ActionValueType.NULL: break;
				case ActionValueType.UNDEFINED: break;
				case ActionValueType.STRING: value.string = string; break;
				case ActionValueType.REGISTER: value.register = register; break;
				case ActionValueType.BOOLEAN: value.boolean = boolean; break;
				case ActionValueType.INTEGER: value.integer = integer; break;
				default:
					throw(new Error("Unknown ActionValueType: " + type));
			}
			return value;
		}
		
		public function toString():String {
			var str:String = "";
			switch (type) {
				case ActionValueType.STRING: str = StringUtils.simpleEscape(string) + " (string)"; break;
				case ActionValueType.FLOAT: str = number + " (float)"; break;
				case ActionValueType.NULL: str = "null";  break;
				case ActionValueType.UNDEFINED: str = "undefined";  break;
				case ActionValueType.REGISTER: str = register + " (register)"; break;
				case ActionValueType.BOOLEAN: str = boolean + " (boolean)"; break;
				case ActionValueType.DOUBLE: str = number + " (double)"; break;
				case ActionValueType.INTEGER: str = integer + " (integer)"; break;
				case ActionValueType.CONSTANT_8: str = constant + " (constant8)"; break;
				case ActionValueType.CONSTANT_16: str = constant + " (constant16)"; break;
				default:
					str = "unknown";
					break;
			}
			return str;
		}
		
		public function toBytecodeString(cpool:Array):String {
			var str:String = "";
			switch (type) {
				case ActionValueType.STRING: str = "\"" + StringUtils.simpleEscape(string) + "\""; break;
				case ActionValueType.FLOAT:
				case ActionValueType.DOUBLE:
					str = number.toString();
					if (str.indexOf(".") == -1) {
						str += ".0";
					}
					break;
				case ActionValueType.NULL: str = "null";  break;
				case ActionValueType.UNDEFINED: str = "undefined";  break;
				case ActionValueType.REGISTER: str = "$" + register; break;
				case ActionValueType.BOOLEAN: str = boolean.toString(); break;
				case ActionValueType.INTEGER: str = integer.toString(); break;
				case ActionValueType.CONSTANT_8:
				case ActionValueType.CONSTANT_16:
					str = "\"" + StringUtils.simpleEscape(cpool[constant]) + "\"";
					break;
				default:
					str = "UNKNOWN";
					break;
			}
			return str;
		}
	}
}
