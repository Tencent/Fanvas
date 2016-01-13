package com.codeazur.as3swf.timeline
{
	import com.codeazur.utils.StringUtils;

	public class Layer
	{
		public var depth:uint = 0;
		public var frameCount:uint = 0;
		
		public var frameStripMap:Array;
		public var strips:Array;
		
		public function Layer(depth:uint, frameCount:uint)
		{
			this.depth = depth;
			this.frameCount = frameCount;
			frameStripMap = [];
			strips = [];
		}
		
		public function appendStrip(type:uint, start:uint, end:uint):void {
			if(type != LayerStrip.TYPE_EMPTY) {
				var i:uint;
				var stripIndex:uint = strips.length;
				if(stripIndex == 0 && start > 0) {
					for(i = 0; i < start; i++) {
						frameStripMap[i] = stripIndex;
					}
					strips[stripIndex++] = new LayerStrip(LayerStrip.TYPE_SPACER, 0, start - 1);
				} else if(stripIndex > 0) {
					var prevStrip:LayerStrip = strips[stripIndex - 1] as LayerStrip;
					if(prevStrip.endFrameIndex + 1 < start) {
						for(i = prevStrip.endFrameIndex + 1; i < start; i++) {
							frameStripMap[i] = stripIndex;
						}
						strips[stripIndex++] = new LayerStrip(LayerStrip.TYPE_SPACER, prevStrip.endFrameIndex + 1, start - 1);
					}
				}
				for(i = start; i <= end; i++) {
					frameStripMap[i] = stripIndex;
				}
				strips[stripIndex] = new LayerStrip(type, start, end);
			}
		}
		
		public function getStripsForFrameRegion(start:uint, end:uint):Array {
			if(start >= frameStripMap.length || end < start) {
				return [];
			}
			var startStripIndex:uint = frameStripMap[start];
			var endStripIndex:uint = (end >= frameStripMap.length) ? strips.length - 1 : frameStripMap[end];
			return strips.slice(startStripIndex, endStripIndex + 1);
		}
		
		public function toString(indent:uint = 0):String {
			var str:String = "Depth: " + depth + ", Frames: " + frameCount;
			if(strips.length > 0) {
				str += "\n" + StringUtils.repeat(indent + 2) + "Strips:";
				for(var i:uint = 0; i < strips.length; i++) {
					var strip:LayerStrip = strips[i] as LayerStrip;
					str += "\n" + StringUtils.repeat(indent + 4) + "[" + i + "] " + strip.toString();
				}
			}
			return str;
		}
	}
}