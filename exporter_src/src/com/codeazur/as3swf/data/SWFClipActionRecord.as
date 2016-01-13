package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.actions.Action;
	import com.codeazur.as3swf.data.actions.ActionExecutionContext;
	import com.codeazur.as3swf.data.actions.IAction;
	import com.codeazur.utils.StringUtils;
	
	public class SWFClipActionRecord
	{
		public var eventFlags:SWFClipEventFlags;
		public var keyCode:uint;
		
		protected var _actions:Vector.<IAction>;
		
		protected var labelCount:uint;
		
		public function SWFClipActionRecord(data:SWFData = null, version:uint = 0) {
			_actions = new Vector.<IAction>();
			if (data != null) {
				parse(data, version);
			}
		}
		
		public function get actions():Vector.<IAction> { return _actions; }
		
		public function parse(data:SWFData, version:uint):void {
			eventFlags = data.readCLIPEVENTFLAGS(version);
			data.readUI32(); // actionRecordSize, not needed here
			if (eventFlags.keyPressEvent) {
				keyCode = data.readUI8();
			}
			var action:IAction;
			while ((action = data.readACTIONRECORD()) != null) {
				_actions.push(action);
			}
			labelCount = Action.resolveOffsets(_actions);
		}
		
		public function publish(data:SWFData, version:uint):void {
			data.writeCLIPEVENTFLAGS(eventFlags, version);
			var actionBlock:SWFData = new SWFData();
			if (eventFlags.keyPressEvent) {
				actionBlock.writeUI8(keyCode);
			}
			for(var i:uint = 0; i < actions.length; i++) {
				actionBlock.writeACTIONRECORD(actions[i])
			}
			actionBlock.writeUI8(0);
			data.writeUI32(actionBlock.length); // actionRecordSize
			data.writeBytes(actionBlock);
		}
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			var str:String = "ClipActionRecord (" + eventFlags.toString() + ")";
			if (keyCode > 0) {
				str += ", KeyCode: " + keyCode;
			}
			if ((flags & SWF.TOSTRING_FLAG_AVM1_BYTECODE) == 0) {
				for (var i:uint = 0; i < _actions.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 2) + "[" + i + "] " + _actions[i].toString(indent + 2);
				}
			} else {
				var context:ActionExecutionContext = new ActionExecutionContext(_actions, [], labelCount);
				for (i = 0; i < _actions.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 4) + _actions[i].toBytecode(indent + 4, context);
				}
				if(context.endLabel != null) {
					str += "\n" + StringUtils.repeat(indent + 4) + context.endLabel + ":";
				}
			}
			return str;
		}
	}
}
