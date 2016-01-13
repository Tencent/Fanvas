package com.codeazur.as3swf.data.actions.swf7
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.actions.*;
	import com.codeazur.utils.StringUtils;
	
	public class ActionTry extends Action implements IAction
	{
		public static const CODE:uint = 0x8f;
		
		public var catchInRegisterFlag:Boolean;
		public var finallyBlockFlag:Boolean;
		public var catchBlockFlag:Boolean;
		public var catchName:String;
		public var catchRegister:uint;
		public var tryBody:Vector.<IAction>;
		public var catchBody:Vector.<IAction>;
		public var finallyBody:Vector.<IAction>;

		protected var labelCountTry:uint;
		protected var labelCountCatch:uint;
		protected var labelCountFinally:uint;

		public function ActionTry(code:uint, length:uint, pos:uint)
		{
			super(code, length, pos);
			tryBody = new Vector.<IAction>();
			catchBody = new Vector.<IAction>();
			finallyBody = new Vector.<IAction>();
			labelCountTry = 0;
			labelCountCatch = 0;
			labelCountFinally = 0;
		}
		
		override public function parse(data:SWFData):void {
			var flags:uint = data.readUI8();
			catchInRegisterFlag = ((flags & 0x04) != 0);
			finallyBlockFlag = ((flags & 0x02) != 0);
			catchBlockFlag = ((flags & 0x01) != 0);
			var trySize:uint = data.readUI16();
			var catchSize:uint = data.readUI16();
			var finallySize:uint = data.readUI16();
			if (catchInRegisterFlag) {
				catchRegister = data.readUI8();
			} else {
				catchName = data.readString();
			}
			var tryEndPosition:uint = data.position + trySize;
			while (data.position < tryEndPosition) {
				tryBody.push(data.readACTIONRECORD());
			}
			var catchEndPosition:uint = data.position + catchSize;
			while (data.position < catchEndPosition) {
				catchBody.push(data.readACTIONRECORD());
			}
			var finallyEndPosition:uint = data.position + finallySize;
			while (data.position < finallyEndPosition) {
				finallyBody.push(data.readACTIONRECORD());
			}
			labelCountTry = Action.resolveOffsets(tryBody);
			labelCountCatch = Action.resolveOffsets(catchBody);
			labelCountFinally = Action.resolveOffsets(finallyBody);
		}
		
		override public function publish(data:SWFData):void {
			var i:uint;
			var body:SWFData = new SWFData();
			var flags:uint = 0;
			if (catchInRegisterFlag) { flags |= 0x04; }
			if (finallyBlockFlag) { flags |= 0x02; }
			if (catchBlockFlag) { flags |= 0x01; }
			body.writeUI8(flags);
			var bodyTryActions:SWFData = new SWFData();
			for (i = 0; i < tryBody.length; i++) {
				bodyTryActions.writeACTIONRECORD(tryBody[i]);
			}
			var bodyCatchActions:SWFData = new SWFData();
			for (i = 0; i < catchBody.length; i++) {
				bodyCatchActions.writeACTIONRECORD(catchBody[i]);
			}
			var bodyFinallyActions:SWFData = new SWFData();
			for (i = 0; i < finallyBody.length; i++) {
				bodyFinallyActions.writeACTIONRECORD(finallyBody[i]);
			}
			body.writeUI16(bodyTryActions.length);
			body.writeUI16(bodyCatchActions.length);
			body.writeUI16(bodyFinallyActions.length);
			if (catchInRegisterFlag) {
				body.writeUI8(catchRegister);
			} else {
				body.writeString(catchName);
			}
			body.writeBytes(bodyTryActions);
			body.writeBytes(bodyCatchActions);
			body.writeBytes(bodyFinallyActions);
			write(data, body);
		}
		
		override public function clone():IAction {
			var i:uint;
			var action:ActionTry = new ActionTry(code, length, pos);
			action.catchInRegisterFlag = catchInRegisterFlag;
			action.finallyBlockFlag = finallyBlockFlag;
			action.catchBlockFlag = catchBlockFlag;
			action.catchName = catchName;
			action.catchRegister = catchRegister;
			for (i = 0; i < tryBody.length; i++) {
				action.tryBody.push(tryBody[i].clone());
			}
			for (i = 0; i < catchBody.length; i++) {
				action.catchBody.push(catchBody[i].clone());
			}
			for (i = 0; i < finallyBody.length; i++) {
				action.finallyBody.push(finallyBody[i].clone());
			}
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			var str:String = "[ActionTry] ";
			str += (catchInRegisterFlag) ? "Register: " + catchRegister : "Name: " + catchName;
			var i:uint;
			if (tryBody.length) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Try:";
				for (i = 0; i < tryBody.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + tryBody[i].toString(indent + 4);
				}
			}
			if (catchBody.length) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Catch:";
				for (i = 0; i < catchBody.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + catchBody[i].toString(indent + 4);
				}
			}
			if (finallyBody.length) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Finally:";
				for (i = 0; i < finallyBody.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + finallyBody[i].toString(indent + 4);
				}
			}
			return str;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			var str:String = lbl ? lbl + ":\n" : "";
			var lf:String = "";
			var i:uint;
			if (tryBody.length) {
				str += lf + StringUtils.repeat(indent + 2) + "try {";
				var contextTry:ActionExecutionContext = new ActionExecutionContext(tryBody, context.cpool.concat(), labelCountTry);
				for (i = 0; i < tryBody.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + tryBody[i].toBytecode(indent + 4, contextTry);
				}
				if(contextTry.endLabel != null) {
					str += "\n" + StringUtils.repeat(indent + 4) + contextTry.endLabel + ":";
				}
				str += "\n" + StringUtils.repeat(indent + 2) + "}";
				lf = "\n";
			}
			if (catchBody.length) {
				str += lf + StringUtils.repeat(indent + 2) + "catch(" + ((catchInRegisterFlag) ? "$" + catchRegister : catchName) + ") {";
				var contextCatch:ActionExecutionContext = new ActionExecutionContext(catchBody, context.cpool.concat(), labelCountCatch);
				for (i = 0; i < catchBody.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + catchBody[i].toBytecode(indent + 4, contextCatch);
				}
				if(contextCatch.endLabel != null) {
					str += "\n" + StringUtils.repeat(indent + 4) + contextCatch.endLabel + ":";
				}
				str += "\n" + StringUtils.repeat(indent + 2) + "}";
				lf = "\n";
			}
			if (finallyBody.length) {
				str += lf + StringUtils.repeat(indent + 2) + "finally {";
				var contextFinally:ActionExecutionContext = new ActionExecutionContext(finallyBody, context.cpool.concat(), labelCountFinally);
				for (i = 0; i < finallyBody.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + finallyBody[i].toBytecode(indent + 4, contextFinally);
				}
				if(contextFinally.endLabel != null) {
					str += "\n" + StringUtils.repeat(indent + 4) + contextFinally.endLabel + ":";
				}
				str += "\n" + StringUtils.repeat(indent + 2) + "}";
			}
			return str;
		}
	}
}
