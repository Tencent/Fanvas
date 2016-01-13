package com.codeazur.as3swf.data.actions.swf4
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.SWFActionValue;
	import com.codeazur.as3swf.data.actions.*;
	import com.codeazur.utils.StringUtils;
	
	public class ActionPush extends Action implements IAction
	{
		public static const CODE:uint = 0x96;
		
		public var values:Vector.<SWFActionValue>;
		
		public function ActionPush(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
			values = new Vector.<SWFActionValue>();
		}
		
		override public function parse(data:SWFData):void {
			var endPosition:uint = data.position + length;
			while (data.position != endPosition) {
				values.push(data.readACTIONVALUE());
			}
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			for (var i:uint = 0; i < values.length; i++) {
				body.writeACTIONVALUE(values[i]);
			}
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionPush = new ActionPush(code, length, pos);
			for (var i:uint = 0; i < values.length; i++) {
				action.values.push(values[i].clone());
			}
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			return "[ActionPush] " + values.join(", ");
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			var str:String = toBytecodeLabel(indent);
			for (var i:uint = 0; i < values.length; i++) {
				if (i > 0) {
					str += "\n" + StringUtils.repeat(indent + 2);
				}
				str += "push " + values[i].toBytecodeString(context.cpool);
			}
			return str;
		}
	}
}
