package com.codeazur.as3swf.data.actions.swf5
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.actions.*;
	import com.codeazur.utils.StringUtils;
	
	public class ActionWith extends Action implements IAction
	{
		public static const CODE:uint = 0x94;
		
		public var withBody:Vector.<IAction>;
		
		protected var labelCount:uint;
		
		public function ActionWith(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
			withBody = new Vector.<IAction>();
			labelCount = 0;
		}
		
		override public function parse(data:SWFData):void {
			var codeSize:uint = data.readUI16();
			var bodyEndPosition:uint = data.position + codeSize;
			while (data.position < bodyEndPosition) {
				withBody.push(data.readACTIONRECORD());
			}
			labelCount = Action.resolveOffsets(withBody);
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			var bodyActions:SWFData = new SWFData();
			for (var i:uint = 0; i < withBody.length; i++) {
				bodyActions.writeACTIONRECORD(withBody[i]);
			}
			body.writeUI16(bodyActions.length);
			body.writeBytes(bodyActions);
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionWith = new ActionWith(code, length, pos);
			for (var i:uint = 0; i < withBody.length; i++) {
				action.withBody.push(withBody[i].clone());
			}
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			var str:String = "[ActionWith]";
			for (var i:uint = 0; i < withBody.length; i++) {
				str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + withBody[i].toString(indent + 4);
			}
			return str;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			var str:String = toBytecodeLabel(indent) + "with {"; 
			var context:ActionExecutionContext = new ActionExecutionContext(withBody, context.cpool.concat(), labelCount);
			for (var i:uint = 0; i < withBody.length; i++) {
				if(withBody[i]) {
					str += "\n" + StringUtils.repeat(indent + 4) + withBody[i].toBytecode(indent + 4, context);
				}
			}
			if(context.endLabel != null) {
				str += "\n" + StringUtils.repeat(indent + 4) + context.endLabel + ":";
			}
			str += "\n" + StringUtils.repeat(indent + 2) + "}";
			return str;
		}
	}
}
