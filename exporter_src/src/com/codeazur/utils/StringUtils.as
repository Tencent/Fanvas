package com.codeazur.utils
{
	import flash.events.*;
	
	public class StringUtils
	{
		public static function trim(input:String):String {
			return StringUtils.ltrim(StringUtils.rtrim(input));
		}

		public static function ltrim(input:String):String {
			if (input != null) {
				var size:Number = input.length;
				for(var i:Number = 0; i < size; i++) {
					if(input.charCodeAt(i) > 32) {
						return input.substring(i);
					}
				}
			}
			return "";
		}

		public static function rtrim(input:String):String {
			if (input != null) {
				var size:Number = input.length;
				for(var i:Number = size; i > 0; i--) {
					if(input.charCodeAt(i - 1) > 32) {
						return input.substring(0, i);
					}
				}
			}
			return "";
		}

		public static function simpleEscape(input:String):String {
			input = input.split("\n").join("\\n");
			input = input.split("\r").join("\\r");
			input = input.split("\t").join("\\t");
			input = input.split("\f").join("\\f");
			input = input.split("\b").join("\\b");
			return input;
		}
		
		public static function strictEscape(input:String, trim:Boolean = true):String {
			if (input != null && input.length > 0) {
				if (trim) {
					input = StringUtils.trim(input);
				}
				input = encodeURIComponent(input);
				var a:Array = input.split("");
				for (var i:uint = 0; i < a.length; i++) {
					switch(a[i]) {
						case "!": a[i] = "%21"; break;
						case "'": a[i] = "%27"; break;
						case "(": a[i] = "%28"; break;
						case ")": a[i] = "%29"; break;
						case "*": a[i] = "%2A"; break;
						case "-": a[i] = "%2D"; break;
						case ".": a[i] = "%2E"; break;
						case "_": a[i] = "%5F"; break;
						case "~": a[i] = "%7E"; break;
					}
				}
				return a.join("");
			}
			return "";
		}
		
		public static function repeat(n:uint, str:String = " "):String {
			return new Array(n + 1).join(str);
		}
		
		
		private static var i:int = 0;
		
		private static const SIGN_UNDEF:int = 0;
		private static const SIGN_POS:int = -1;
		private static const SIGN_NEG:int = 1;
		
		public static function printf(format:String, ...args):String {
			var result:String = "";
			var indexValue:int = 0;
			var isIndexed:int = -1;
			var typeLookup:String = "diufFeEgGxXoscpn";
			for(i = 0; i < format.length; i++) {
				var c:String = format.charAt(i);
				if(c == "%") {
					if(++i < format.length) {
						c = format.charAt(i);
						if(c == "%") {
							result += c;
						} else {
							var flagSign:Boolean = false;
							var flagLeftAlign:Boolean = false;
							var flagAlternate:Boolean = false;
							var flagLeftPad:Boolean = false;
							var flagZeroPad:Boolean = false;
							var width:int = -1;
							var precision:int = -1;
							var type:String = "";
							var value:*;
							var j:int;

							///////////////////////////
							// parse parameter
							///////////////////////////
							var idx:int = getIndex(format);
							if(idx < -1 || idx == 0) {
								trace("ERR parsing index");
								break;
							} else if(idx == -1) {
								if(isIndexed == 1) { trace("ERR: indexed placeholder expected"); break; }
								if(isIndexed == -1) { isIndexed = 0; }
								indexValue++;
							} else {
								if(isIndexed == 0) { trace("ERR: non-indexed placeholder expected"); break; }
								if(isIndexed == -1) { isIndexed = 1; }
								indexValue = idx;
							}
							
							///////////////////////////
							// parse flags
							///////////////////////////
							while((c = format.charAt(i)) == "+" || c == "-" || c == "#" || c == " " || c == "0") {
								switch(c) {
									case "+": flagSign = true; break;
									case "-": flagLeftAlign = true; break;
									case "#": flagAlternate = true; break;
									case " ": flagLeftPad = true; break;
									case "0": flagZeroPad = true; break;
								}
								if(++i == format.length) { break; }
								c = format.charAt(i);
							}
							if(i == format.length) { break; }

							///////////////////////////
							// parse width
							///////////////////////////
							if(c == "*") {
								var widthIndex:int = 0;
								if(++i == format.length) { break; }
								idx = getIndex(format);
								if(idx < -1 || idx == 0) {
									trace("ERR parsing index for width");
									break;
								} else if(idx == -1) {
									if(isIndexed == 1) { trace("ERR: indexed placeholder expected for width"); break; }
									if(isIndexed == -1) { isIndexed = 0; }
									widthIndex = indexValue++;
								} else {
									if(isIndexed == 0) { trace("ERR: non-indexed placeholder expected for width"); break; }
									if(isIndexed == -1) { isIndexed = 1; }
									widthIndex = idx;
								}
								widthIndex--;
								if(args.length > widthIndex && widthIndex >= 0) {
									width = parseInt(args[widthIndex]);
									if(isNaN(width)) {
										width = -1;
										trace("ERR NaN while parsing width");
										break;
									}
								} else {
									trace("ERR index out of bounds while parsing width");
									break;
								}
								c = format.charAt(i);
							} else {
								var hasWidth:Boolean = false;
								while(c >= "0" && c <= "9") {
									if(width == -1) { width = 0; }
									width = (width * 10) + uint(c);
									if(++i == format.length) { break; }
									c = format.charAt(i);
								}
								if(width != -1 && i == format.length) {
									trace("ERR eof while parsing width");
									break;
								}
							}
							
							///////////////////////////
							// parse precision
							///////////////////////////
							if(c == ".") {
								if(++i == format.length) { break; }
								c = format.charAt(i);
								if(c == "*") {
									var precisionIndex:int = 0;
									if(++i == format.length) { break; }
									idx = getIndex(format);
									if(idx < -1 || idx == 0) {
										trace("ERR parsing index for precision");
										break;
									} else if(idx == -1) {
										if(isIndexed == 1) { trace("ERR: indexed placeholder expected for precision"); break; }
										if(isIndexed == -1) { isIndexed = 0; }
										precisionIndex = indexValue++;
									} else {
										if(isIndexed == 0) { trace("ERR: non-indexed placeholder expected for precision"); break; }
										if(isIndexed == -1) { isIndexed = 1; }
										precisionIndex = idx;
									}
									precisionIndex--;
									if(args.length > precisionIndex && precisionIndex >= 0) {
										precision = parseInt(args[precisionIndex]);
										if(isNaN(precision)) {
											precision = -1;
											trace("ERR NaN while parsing precision");
											break;
										}
									} else {
										trace("ERR index out of bounds while parsing precision");
										break;
									}
									c = format.charAt(i);
								} else {
									while(c >= "0" && c <= "9") {
										if(precision == -1) { precision = 0; }
										precision = (precision * 10) + uint(c);
										if(++i == format.length) { break; }
										c = format.charAt(i);
									}
									if(precision != -1 && i == format.length) {
										trace("ERR eof while parsing precision");
										break;
									}
								}
							}
							
							///////////////////////////
							// parse length (ignored)
							///////////////////////////
							switch(c) {
								case "h":
								case "l":
									if(++i == format.length) { trace("ERR eof after length"); break; }
									var c1:String = format.charAt(i);
									if((c == "h" && c1 == "h") || (c == "l" && c1 == "l")) {
										if(++i == format.length) { trace("ERR eof after length"); break; }
										c = format.charAt(i);
									} else {
										c = c1;
									}
									break;
								case "L":
								case "z":
								case "j":
								case "t":
									if(++i == format.length) { trace("ERR eof after length"); break; }
									c = format.charAt(i);
									break;
							}
							
							///////////////////////////
							// parse type
							///////////////////////////
							if(typeLookup.indexOf(c) >= 0) {
								type = c;
							} else {
								trace("ERR unknown type: " + c);
								break;
							}
							
							if(args.length >= indexValue && indexValue > 0) {
								value = args[indexValue - 1];
							} else {
								trace("ERR value index out of bounds (" + indexValue + ")");
								break;
							}

							var valueStr:String;
							var valueFloat:Number;
							var valueInt:int;
							var sign:int = SIGN_UNDEF;
							switch(type) {
								case "s":
									valueStr = value.toString();
									if(precision != -1) { valueStr = valueStr.substr(0, precision); }
									break;
								case "c":
									valueStr = value.toString().getAt(0);
									break;
								case "d":
								case "i":
									valueInt = ((typeof value == "number") ? int(value) : parseInt(value));
									valueStr = Math.abs(valueInt).toString();
									sign = (valueInt < 0) ? SIGN_NEG : SIGN_POS;
									break;
								case "u":
									valueStr = ((typeof value == "number") ? uint(value) : uint(parseInt(value))).toString();
									break;
								case "f":
								case "F":
								case "e":
								case "E":
								case "g":
								case "G":
									if(precision == -1) { precision = 6; }
									var exp10:Number = Math.pow(10, precision);
									valueFloat = (typeof value == "number") ? Number(value) : parseFloat(value);
									valueStr = (Math.round(Math.abs(valueFloat) * exp10) / exp10).toString();
									if(precision > 0) {
										var numZerosToAppend:int;
										var dotPos:int = valueStr.indexOf(".");
										if(dotPos == -1) {
											valueStr += ".";
											numZerosToAppend = precision;
										} else {
											numZerosToAppend = precision - (valueStr.length - dotPos - 1);
										}
										for(j = 0; j < numZerosToAppend; j++) {
											valueStr += "0";
										}
									}
									sign = (valueFloat < 0) ? SIGN_NEG : SIGN_POS;
									break;
								case "x":
								case "X":
								case "p":
									valueStr = ((typeof value == "number") ? uint(value) : parseInt(value)).toString(16);
									if(type == "X") { valueStr = valueStr.toUpperCase(); }
									break;
								case "o":
									valueStr = ((typeof value == "number") ? uint(value) : parseInt(value)).toString(8);
									break;
							}
							
							var hasSign:Boolean = ((sign == SIGN_NEG) || flagSign || flagLeftPad);
							if(width > -1) {
								var numFill:int = width - valueStr.length;
								if(hasSign) { numFill--; }
								if(numFill > 0) {
									var fillChar:String = (flagZeroPad && !flagLeftAlign) ? "0" : " ";
									if(flagLeftAlign) {
										for(j = 0; j < numFill; j++) {
											valueStr += fillChar;
										}
									} else {
										for(j = 0; j < numFill; j++) {
											valueStr = fillChar + valueStr;
										}
									}
								}
							}
							if(hasSign) {
								if(sign == SIGN_POS) {
									valueStr = (flagLeftPad ? " " : "0") + valueStr;
								} else {
									valueStr = "-" + valueStr;
								}
							}
							
							result += valueStr;

							///////////////////////////
							// debug
							///////////////////////////
							/*
							var d:String = "";
							d += "type:" + type + " ";
							d += "width:" + width + " ";
							d += "precision:" + precision + " ";
							d += "flags:";
							var da:Array = [];
							if(flagSign) { da.push("sign"); }
							if(flagLeftAlign) { da.push("leftalign"); }
							if(flagAlternate) { da.push("alternate"); }
							if(flagLeftPad) { da.push("leftpad"); }
							if(flagZeroPad) { da.push("zeropad"); }
							d += ((da.length == 0) ? "-" : da.toString()) + " ";
							d += "index:" + indexValue + " ";
							d += "value:" + value + " ";
							d += "result:" + valueStr;
							trace(d);
							*/
							
						}
					} else {
						result += c;
					}
				} else {
					result += c;
				}
			}
			return result;
		}
		
		private static function getIndex(format:String):int {
			var result:int = 0;
			var isIndexed:Boolean = false;
			var c:String = "";
			var iTmp:int = i;
			while((c = format.charAt(i)) >= "0" && c <= "9") {
				isIndexed = true;
				result = (result * 10) + uint(c);
				if(++i == format.length) { return -2; }
			}
			if(isIndexed) {
				if(c != "$") {
					i = iTmp;
					return -1;
				}
				if(++i == format.length) { return -2; }
				return result;
			} else {
				return -1;
			}
		}
	}
}
