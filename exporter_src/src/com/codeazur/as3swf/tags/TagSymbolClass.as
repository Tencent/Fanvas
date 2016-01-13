package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.utils.StringUtils;
	
	public class TagSymbolClass implements ITag
	{
		public static const TYPE:uint = 76;
		
		protected var _symbols:Vector.<SWFSymbol>;
		
		public function TagSymbolClass() {
			_symbols = new Vector.<SWFSymbol>();
		}
		
		public function get symbols():Vector.<SWFSymbol> { return _symbols; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			var numSymbols:uint = data.readUI16();
			for (var i:uint = 0; i < numSymbols; i++) {
				_symbols.push(data.readSYMBOL());
			}
		}

		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			var numSymbols:uint = _symbols.length;
			body.writeUI16(numSymbols);
			for (var i:uint = 0; i < numSymbols; i++) {
				body.writeSYMBOL(_symbols[i]);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "SymbolClass"; }
		public function get version():uint { return 9; } // educated guess (not specified in SWF10 spec)
		public function get level():uint { return 1; }
	
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent);
			if (_symbols.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Symbols:";
				for (var i:uint = 0; i < _symbols.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + _symbols[i].toString();
				}
			}
			return str;
		}
	}
}
