/*
* Tencent is pleased to support the open source community by making Fanvas available.
* Copyright (C) 2015 THL A29 Limited, a Tencent company. All rights reserved.
*
* Licensed under the MIT License (the "License"); you may not use this file except in compliance with the 
* License. You may obtain a copy of the License at
* http://opensource.org/licenses/MIT
*
* Unless required by applicable law or agreed to in writing, software distributed under the License is 
* distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
* implied. See the License for the specific language governing permissions and limitations under the 
* License.
*/
package exporters.JSExporter
{
	import com.adobe.encoders.JPGEncoder;
	import com.adobe.encoders.PNGEncoder;
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.exporters.core.IShapeExporter;
	import com.codeazur.as3swf.tags.IDefinitionTag;
	import com.codeazur.as3swf.tags.TagDefineBits;
	import com.codeazur.as3swf.tags.TagDefineBitsJPEG3;
	import com.codeazur.as3swf.tags.TagDefineBitsLossless;
	import com.codeazur.as3swf.tags.TagDefineBitsLossless2;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.LineScaleMode;
	import flash.display.Loader;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import model.ShapeData;

	/**
	 * 
	 * @author tencent
	 * @date Nov 13, 2014
	 */
	public class ShapeDataExporter implements IShapeExporter
	{
		public var commandArray:Array;
		private var _imageList:Array;
		private var _swf:SWF;
		private var _pathString:String;	
		private var _fillActive:Boolean;
		private var _strokeActive:Boolean;
		private var _lastX:Number;
		private var _lastY:Number;
		
		private var _finish:Function;		//为了解决jpg异步加载的问题
		private var _imageToLoadCount:int;
		private var _imageLoadedCount:int;
		private var _endShape:Boolean;
		
		public function ShapeDataExporter(swf:SWF, imageList:Array, finish:Function)
		{
			_swf = swf;
			_finish = finish;
			_imageList = imageList;
			_imageToLoadCount = _imageLoadedCount = 0;
		}
		
		/**
		 * 使用入口
		 * @param shapeData
		 * @param imageList
		 * @param finish 
		 */
		public static function export(shapeData:ShapeData, swf:SWF, imageList:Array, finish:Function):void
		{
			var exporter:ShapeDataExporter = new ShapeDataExporter(swf, imageList, function():void
			{
				finish({graphics:exporter.commandArray});
			});
			shapeData.data.export(exporter);
		}		
		
		public function beginShape():void 
		{
			commandArray = new Array();
			_pathString = "";
			_lastX = _lastY = 0;
		}
		public function endShape():void 
		{
			endPath();
			_endShape = true;
			if(_imageLoadedCount == _imageToLoadCount)
				_finish();
		}
		
		public function beginFills():void {}
		public function endFills():void {}
		
		public function beginLines():void {}
		public function endLines():void {}
		
		public function beginFill(color:uint, alpha:Number = 1.0):void 
		{
			processPreviousFill();
			_fillActive = true;
			commandArray.push(["f", JSUtil.getJSColor(color, alpha)]);
		}
		
		public function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = SpreadMethod.PAD, interpolationMethod:String = InterpolationMethod.RGB, focalPointRatio:Number = 0):void 
		{
			processPreviousFill();
			_fillActive = true;
			commandArray.push(exportGradientFillStyle(false, type, matrix, colors, alphas, ratios, focalPointRatio));
		}
		
		public function beginBitmapFill(bitmapId:uint, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void 
		{
			processPreviousFill();
			_fillActive = true;
			var tag:IDefinitionTag = _swf.getCharacter(bitmapId);
			
			var transparent:Boolean = false;
			if((tag is TagDefineBitsJPEG3 && (tag as TagDefineBitsJPEG3).bitmapAlphaData.length > 0) || tag is TagDefineBitsLossless2)
			{
				transparent = true;
			}
			var imageName:String = "img" + bitmapId + (transparent?".png":".jpg");
			commandArray.push(["bf", imageName, [JSUtil.toPrecision(matrix.a/20,2), JSUtil.toPrecision(matrix.b/20,2), 
				JSUtil.toPrecision(matrix.c/20,2), JSUtil.toPrecision(matrix.d/20,2), 
				JSUtil.toPrecision(matrix.tx/20,1), JSUtil.toPrecision(matrix.ty/20,1)]]);
			
			//检查是否已经导出过该图片
			for (var ii:int = 0; ii < _imageList.length; ii++) 
			{
				if(bitmapId == _imageList[ii].id)
					return;
			}
			
			var file:ByteArray;
			var bitmapData:BitmapData;
			var pixel:uint;
			var r:int;
			var g:int;
			var b:int;
			var a:int;
			var aa:Number;
			//有损
			if(tag is TagDefineBits)
			{
				file = (tag as TagDefineBits).bitmapData;
				if(transparent)
				{
					var alphaData:ByteArray = (tag as TagDefineBitsJPEG3).bitmapAlphaData;
					alphaData.uncompress();
					_imageToLoadCount++;
					var loader:Loader = new Loader();
					loader.loadBytes((tag as TagDefineBits).bitmapData);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
					{
						bitmapData = new BitmapData(loader.content.width, loader.content.height);
						for (var j:int = 0; j < loader.content.height; j++) 
						{
							for (var i:int = 0; i < loader.content.width; i++) 
							{
								pixel = (loader.content as Bitmap).bitmapData.getPixel(i, j);
								r = (pixel&0xff0000)>>16;
								g = (pixel&0x00ff00)>>8;
								b = pixel&0x0000ff;
								a = alphaData.readUnsignedByte();
								if(a != 255 && a != 0)
								{
									aa = a/255;
									r = Math.min(255, r/aa);	//傻逼adobe莫名其妙的先把rgb乘了a，所以这里要先除掉a
									g = Math.min(255, g/aa);
									b = Math.min(255, b/aa);
								}
								bitmapData.setPixel32(i, j, (a<<24)|(r<<16)|(g<<8)|b);
							}
						}
						file = PNGEncoder.encode(bitmapData);
						for (var ii:int = 0; ii < _imageList.length; ii++) 
						{
							if(bitmapId == _imageList[ii].id)
								_imageList[ii].file = file;
						}
						_imageLoadedCount++;
						if(_imageLoadedCount == _imageToLoadCount && _endShape)
							_finish();
					});
				}
				else
				{
					file.position = 0;
					var head:uint = file.readUnsignedInt();
					if(head == 0xffd9ffd8)
					{
						head = file.readUnsignedShort();
						if(head == 0xffd8)
						{
							//swf8以前的旧玩意，多了一个uint头。
							var copyFile:ByteArray = new ByteArray();
							file.position = 4;
							file.readBytes(copyFile);
							file = copyFile;
						}
					}
					file.position = 0;
				}
			}
			//无损
			else if(tag is TagDefineBitsLossless)
			{
				var pngTag:TagDefineBitsLossless = tag as TagDefineBitsLossless;
				if(pngTag.bitmapFormat != 5)
				{
					Fanvas.warningMessage += "swf包含的图片含有低版本图片（无法导出该图片），请检查。";
					return; 	
				}
				try
				{
					pngTag.zlibBitmapData.uncompress();
				} 
				catch(error:Error) 
				{
				}
				bitmapData = new BitmapData(pngTag.bitmapWidth, pngTag.bitmapHeight, transparent);
				for (var k:int = 0; k < pngTag.bitmapHeight; k++) 
				{
					for (var l:int = 0; l < pngTag.bitmapWidth; l++) 
					{
						pixel = pngTag.zlibBitmapData.readUnsignedInt();
						if(transparent)
						{
							r = (pixel&0xff0000)>>16;
							g = (pixel&0x00ff00)>>8;
							b = pixel&0x0000ff;
							a = (pixel/2)>>23;
							if(a != 255 && a != 0)
							{
								aa = a/255;
								r = Math.min(255, r/aa);	//傻逼adobe莫名其妙的先把rgb乘了a，所以这里要先除掉a
								g = Math.min(255, g/aa);
								b = Math.min(255, b/aa);
							}
							bitmapData.setPixel32(l, k, (a<<24)|(r<<16)|(g<<8)|b);
						}
						else
						{
							bitmapData.setPixel(l, k, pixel);
						}
					}
				}
				if(transparent)
					file = PNGEncoder.encode(bitmapData);
				else
					file = new JPGEncoder(100).encode(bitmapData);
			}
			
			_imageList.push({id:bitmapId, name:imageName, "file":file});
		}
		
		public function endFill():void 
		{
			processPreviousFill();
			_fillActive = false;
		}
		
		public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0, pixelHinting:Boolean = false, scaleMode:String = LineScaleMode.NORMAL, startCaps:String = null, endCaps:String = null, joints:String = null, miterLimit:Number = 10):void 
		{
			endPath();
			if(thickness > 0 && alpha > 0)
			{
				_strokeActive = true;
				commandArray.push(["ss", thickness<1?1:thickness, startCaps=="none"?"round":startCaps, joints, miterLimit]);
				commandArray.push(["s", JSUtil.getJSColor(color, alpha)]);
			}
		}
		
		public function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = SpreadMethod.PAD, interpolationMethod:String = InterpolationMethod.RGB, focalPointRatio:Number = 0):void 
		{
			commandArray.push(exportGradientFillStyle(true, type, matrix, colors, alphas, ratios, focalPointRatio));
		}
		
		public function moveTo(x:Number, y:Number):void 
		{
			_pathString += encodeInstruction(0, x, y);
			_lastX = x;
			_lastY = y;
		}
		
		public function lineTo(x:Number, y:Number):void 
		{
			_pathString += encodeInstruction(1, x-_lastX, y-_lastY);
			_lastX = x;
			_lastY = y;
		}
		
		public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void 
		{
			_pathString += encodeInstruction(2, controlX-_lastX, controlY-_lastY, anchorX-controlX, anchorY-controlY);
			_lastX = anchorX;
			_lastY = anchorY;
		}
		
		private function processPreviousFill():void
		{
			endPath();
		}
		
		private function endPath():void
		{
			if(_pathString != "")
			{
				commandArray.push(["p", _pathString]);
				_pathString = "";
			}
			if(_strokeActive)
			{
				_strokeActive = false;
				commandArray.push(["es"]);
			}
			if(_fillActive)
			{
				commandArray.push(["ef"]);
				_fillActive = false;
			}
		}
		
		/**
		 * 导出fill或stroke的fill指令
		 */
		private function exportGradientFillStyle(isStroke:Boolean, type:String, matrix:Matrix, colors:Array, alphas:Array, ratios:Array, focalPointRatio:Number = 0):Array
		{
			var command:String = isStroke?"s":"f";
			var middlePoint:Point;
			var focalPoint:Point;
			var radius:Number;
			var result:Array;
			var startPoint:Point = matrix.transformPoint(new Point(-819.2, 0));	//Flash的线性渐变默认是这个线段（推算得出）
			var endPoint:Point = matrix.transformPoint(new Point(819.2, 0));
			if(type == GradientType.LINEAR)
			{
				result = ["l"+command, getGradientColors(colors, alphas), 
					getGradientRatios(ratios), JSUtil.toPrecision(startPoint.x, 1), JSUtil.toPrecision(startPoint.y, 1),
					JSUtil.toPrecision(endPoint.x, 1), JSUtil.toPrecision(endPoint.y, 1)];
			}
			else if(type == GradientType.RADIAL)
			{
				middlePoint = new Point(startPoint.x/2+endPoint.x/2, startPoint.y/2+endPoint.y/2);
				focalPoint = new Point(middlePoint.x*(1-focalPointRatio)+endPoint.x*focalPointRatio, middlePoint.y*(1-focalPointRatio)+endPoint.y*focalPointRatio);
				radius = Math.sqrt(Math.pow(middlePoint.x-endPoint.x, 2) + Math.pow(middlePoint.y-endPoint.y, 2));
				
				result = ["r"+command, getGradientColors(colors, alphas), 
					getGradientRatios(ratios), JSUtil.toPrecision(focalPoint.x, 1), JSUtil.toPrecision(focalPoint.y, 1), 0,
					JSUtil.toPrecision(middlePoint.x, 1), JSUtil.toPrecision(middlePoint.y, 1), JSUtil.toPrecision(radius, 1)
				];
			}
			return result;
		}
		
		/**
		 * 压缩path绘图指令（指令+数值参数）
		 * @param instruction (0-moveTo, 1-lineTo, 2-quadraticCurveTo, 3-bezierCurveTo, 4-closePath, 5-7 unused)
		 * @param numbers
		 * @return 
		 */
		private function encodeInstruction(instruction:int, ...numbers):String
		{
			//base64 encoding table: 0-63 A-/
			var base64:Array = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
				"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
				"0","1","2","3","4","5","6","7","8","9","+","/"];
			
			var numberStr:String = "";
			var charCount:int = 2;
			for (var i:int = 0; i < numbers.length; i++) 
			{
				//坐标都乘以10；base64字母表等于64进制，6bit表示。
				if(Math.abs(Math.round(numbers[i]*10)) >= (1<<11))
				{
					charCount = 3;
				}
			}
			numberStr += base64[(instruction<<3) + ((charCount==3?1:0)<<2)];	//前3bit表示指令，第4bit表示后续参数是2char还是3char，5、6bit未使用
			
			for (var k:int = 0; k < numbers.length; k++) 
			{
				var minus:Boolean = numbers[k] < 0;
				var num:int = Math.abs(Math.round(numbers[k]*10));
				if(charCount == 2)
					numberStr += base64[((num>>6)&31) + ((minus?1:0)<<5)] + base64[num&63];
				else
					numberStr += base64[((num>>12)&31) + ((minus?1:0)<<5)] + base64[(num>>6)&63] + base64[num&63];
			}
			return numberStr;
		}
		
		/**
		 * 把渐变颜色转化为js表示法
		 * @param colors
		 * @param alphas
		 * @return 
		 */
		private function getGradientColors(colors:Array, alphas:Array):Array
		{
			var jsColors:Array = new Array();
			for (var j:int = 0; j < colors.length; j++) 
			{
				jsColors.push(JSUtil.getJSColor(colors[j], alphas[j]));
			}
			return jsColors;
		}
		
		/**
		 * 把渐变ratios调整为精度2
		 * @param ratios
		 * @return 
		 */
		private function getGradientRatios(ratios:Array):Array
		{
			var jsRatios:Array = new Array();
			for (var j:int = 0; j < ratios.length; j++) 
			{
				jsRatios.push(Number((Number(ratios[j])/255).toPrecision(2)));
			}
			return jsRatios;
		}
	}
}