package com.codeazur.as3swf.factories
{
	import com.codeazur.as3swf.data.filters.*;
	
	public class SWFFilterFactory
	{
		public static function create(id:uint):IFilter
		{
			switch(id)
			{
				case 0: return new FilterDropShadow(id);
				case 1: return new FilterBlur(id);
				case 2: return new FilterGlow(id);
				case 3: return new FilterBevel(id);
				case 4: return new FilterGradientGlow(id);
				case 5: return new FilterConvolution(id);
				case 6: return new FilterColorMatrix(id);
				case 7: return new FilterGradientBevel(id);
				default: throw(new Error("Unknown filter ID: " + id));
			}
		}
	}
}
