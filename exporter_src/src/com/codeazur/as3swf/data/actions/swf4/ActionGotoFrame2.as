package com.codeazur.as3swf.data.actions.swf4
{
	import com.codeazur.as3swf.data.actions.*;
	import com.codeazur.as3swf.SWFData;
	
	public class ActionGotoFrame2 extends Action implements IAction
	{
		public static const CODE:uint = 0x9f;
		
		public var sceneBiasFlag:Boolean;
		public var playFlag:Boolean;
		public var sceneBias:uint;
		
		public function ActionGotoFrame2(code:uint, length:uint, pos:uint) {
			super(code, length, pos);
		}
		
		override public function parse(data:SWFData):void {
			var flags:uint = data.readUI8();
			sceneBiasFlag = ((flags & 0x02) != 0);
			playFlag = ((flags & 0x01) != 0);
			if (sceneBiasFlag) {
				sceneBias = data.readUI16();
			}
		}
		
		override public function publish(data:SWFData):void {
			var body:SWFData = new SWFData();
			var flags:uint = 0;
			if (sceneBiasFlag) { flags |= 0x02; }
			if (playFlag) { flags |= 0x01; }
			body.writeUI8(flags);
			if (sceneBiasFlag) { 
				body.writeUI16(sceneBias);
			}
			write(data, body);
		}
		
		override public function clone():IAction {
			var action:ActionGotoFrame2 = new ActionGotoFrame2(code, length, pos);
			action.sceneBiasFlag = sceneBiasFlag;
			action.playFlag = playFlag;
			action.sceneBias = sceneBias;
			return action;
		}
		
		override public function toString(indent:uint = 0):String {
			var str:String = "[ActionGotoFrame2] " +
				"PlayFlag: " + playFlag + ", ";
				"SceneBiasFlag: " + sceneBiasFlag;
			if (sceneBiasFlag) {
				str += ", " + sceneBias;
			}
			return str;
		}
		
		override public function toBytecode(indent:uint, context:ActionExecutionContext):String {
			return toBytecodeLabel(indent) + "gotoFrame2 (" +
				(playFlag == 0 ? "gotoAndStop" : "gotoAndPlay") +
				(sceneBiasFlag == 1 ? ", sceneBias: " + sceneBias : "") +
				")";
		}
	}
}
