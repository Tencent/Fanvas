package com.codeazur.as3swf.data.actions.swf5
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.actions.*;
	import com.codeazur.utils.StringUtils;
	
	public class ActionConstantPool extends Action implements IAction
	{
		public static const CODE:uint = 0x88;
		
		public var constants:Vector.<String>;
		
		public function ActionConstantPool(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
			constants = new Vector.<String>();
		}
		
		override public function parse(data:SWFData):void {
			var count:uint = data.readUI16();
			for (var i:uint = 0; i < count; i++) {
				constants.push(data.readString());
			}
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			body.writeUI16(constants.length);
			for (var i:uint = 0; i < constants.length; i++) {
				body.writeString(constants[i]);
			}
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionConstantPool = new ActionConstantPool(code, length, pos);
			for (var i:uint = 0; i < constants.length; i++) {
				action.constants.push(constants[i]);
			}
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			var str:String = "[ActionConstantPool] Values: " + constants.length;
			for (var i:uint = 0; i < constants.length; i++) {
				str += "\n" + StringUtils.repeat(indent + 4) + i + ": " + StringUtils.simpleEscape(constants[i]);
			}
			return str;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			var str:String = toBytecodeLabel(indent) + "constantPool";
			context.cpool.length = 0;
			for (var i:uint = 0; i < constants.length; i++) {
				str += "\n" + StringUtils.repeat(indent + 4) + i + ": " + StringUtils.simpleEscape(constants[i]);
				context.cpool.push(constants[i]);
			}
			return str;
		}
	}
}
