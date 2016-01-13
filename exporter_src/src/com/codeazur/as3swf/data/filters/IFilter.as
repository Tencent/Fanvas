package com.codeazur.as3swf.data.filters
{
	import com.codeazur.as3swf.SWFData;

	import flash.filters.BitmapFilter;
	
	public interface IFilter
	{
		function get id():uint;
		function get filter():BitmapFilter;
		
		function parse(data:SWFData):void;
		function publish(data:SWFData):void;
		function clone():IFilter;
		function toString(indent:uint = 0):String;
	}
}
