package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFRectangle;
	
	public class TagDefineEditText implements IDefinitionTag
	{
		public static const TYPE:uint = 37;
		
		public var bounds:SWFRectangle;
		public var variableName:String;
		
		public var hasText:Boolean;
		public var wordWrap:Boolean;
		public var multiline:Boolean;
		public var password:Boolean;
		public var readOnly:Boolean;
		public var hasTextColor:Boolean;
		public var hasMaxLength:Boolean;
		public var hasFont:Boolean;
		public var hasFontClass:Boolean;
		public var autoSize:Boolean;
		public var hasLayout:Boolean;
		public var noSelect:Boolean;
		public var border:Boolean;
		public var wasStatic:Boolean;
		public var html:Boolean;
		public var useOutlines:Boolean;
		
		public var fontId:uint;
		public var fontClass:String;
		public var fontHeight:uint;
		public var textColor:uint;
		public var maxLength:uint;
		public var align:uint;
		public var leftMargin:uint;
		public var rightMargin:uint;
		public var indent:uint;
		public var leading:int;
		public var initialText:String;

		protected var _characterId:uint;
		
		public function TagDefineEditText() {}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void {
			_characterId = data.readUI16();
			bounds = data.readRECT();
			var flags1:uint = data.readUI8();
			hasText = ((flags1 & 0x80) != 0);
			wordWrap = ((flags1 & 0x40) != 0);
			multiline = ((flags1 & 0x20) != 0);
			password = ((flags1 & 0x10) != 0);
			readOnly = ((flags1 & 0x08) != 0);
			hasTextColor = ((flags1 & 0x04) != 0);
			hasMaxLength = ((flags1 & 0x02) != 0);
			hasFont = ((flags1 & 0x01) != 0);
			var flags2:uint = data.readUI8();
			hasFontClass = ((flags2 & 0x80) != 0);
			autoSize = ((flags2 & 0x40) != 0);
			hasLayout = ((flags2 & 0x20) != 0);
			noSelect = ((flags2 & 0x10) != 0);
			border = ((flags2 & 0x08) != 0);
			wasStatic = ((flags2 & 0x04) != 0);
			html = ((flags2 & 0x02) != 0);
			useOutlines = ((flags2 & 0x01) != 0);
			if (hasFont) {
				fontId = data.readUI16();
			}
			if (hasFontClass) {
				fontClass = data.readString();
			}
			if (hasFont) {
				fontHeight = data.readUI16();
			}
			if (hasTextColor) {
				textColor = data.readRGBA();
			}
			if (hasMaxLength) {
				maxLength = data.readUI16();
			}
			if (hasLayout) {
				align = data.readUI8();
				leftMargin = data.readUI16();
				rightMargin = data.readUI16();
				indent = data.readUI16();
				leading = data.readSI16();
			}
			variableName = data.readString();
			if (hasText) {
				initialText = data.readString();
			}
		}
		
		public function publish(data:SWFData, version:uint):void {
			var body:SWFData = new SWFData();
			body.writeUI16(characterId);
			body.writeRECT(bounds);
			var flags1:uint = 0;
			if(hasText) { flags1 |= 0x80; }
			if(wordWrap) { flags1 |= 0x40; }
			if(multiline) { flags1 |= 0x20; }
			if(password) { flags1 |= 0x10; }
			if(readOnly) { flags1 |= 0x08; }
			if(hasTextColor) { flags1 |= 0x04; }
			if(hasMaxLength) { flags1 |= 0x02; }
			if(hasFont) { flags1 |= 0x01; }
			body.writeUI8(flags1);
			var flags2:uint = 0;
			if(hasFontClass) { flags2 |= 0x80; }
			if(autoSize) { flags2 |= 0x40; }
			if(hasLayout) { flags2 |= 0x20; }
			if(noSelect) { flags2 |= 0x10; }
			if(border) { flags2 |= 0x08; }
			if(wasStatic) { flags2 |= 0x04; }
			if(html) { flags2 |= 0x02; }
			if(useOutlines) { flags2 |= 0x01; }
			body.writeUI8(flags2);
			if (hasFont) {
				body.writeUI16(fontId);
			}
			if (hasFontClass) {
				body.writeString(fontClass);
			}
			if (hasFont) {
				body.writeUI16(fontHeight);
			}
			if (hasTextColor) {
				body.writeRGBA(textColor);
			}
			if (hasMaxLength) {
				body.writeUI16(maxLength);
			}
			if (hasLayout) {
				body.writeUI8(align);
				body.writeUI16(leftMargin);
				body.writeUI16(rightMargin);
				body.writeUI16(indent);
				body.writeSI16(leading);
			}
			body.writeString(variableName);
			if (hasText) {
				body.writeString(initialText);
			}
			data.writeTagHeader(type, body.length);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineEditText = new TagDefineEditText();
			tag.characterId = characterId;
			tag.bounds = bounds.clone();
			tag.variableName = variableName;
			tag.hasText = hasText;
			tag.wordWrap = wordWrap;
			tag.multiline = multiline;
			tag.password = password;
			tag.readOnly = readOnly;
			tag.hasTextColor = hasTextColor;
			tag.hasMaxLength = hasMaxLength;
			tag.hasFont = hasFont;
			tag.hasFontClass = hasFontClass;
			tag.autoSize = autoSize;
			tag.hasLayout = hasLayout;
			tag.noSelect = noSelect;
			tag.border = border;
			tag.wasStatic = wasStatic;
			tag.html = html;
			tag.useOutlines = useOutlines;
			tag.fontId = fontId;
			tag.fontClass = fontClass;
			tag.fontHeight = fontHeight;
			tag.textColor = textColor;
			tag.maxLength = maxLength;
			tag.align = align;
			tag.leftMargin = leftMargin;
			tag.rightMargin = rightMargin;
			tag.indent = indent;
			tag.leading = leading;
			tag.initialText = initialText;
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineEditText"; }
		public function get version():uint { return 4; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				((hasText && initialText.length > 0) ? "Text: " + initialText + ", " : "") +
				((variableName.length > 0) ? "VariableName: " + variableName + ", " : "") +
				"Bounds: " + bounds;
			return str;
		}
	}
}
