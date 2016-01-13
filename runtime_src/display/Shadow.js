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

// namespace:
this.fanvas = this.fanvas||{};

(function() {
	"use strict";

/**
 * This class encapsulates the properties required to define a shadow to apply to a {{#crossLink "DisplayObject"}}{{/crossLink}}
 * via its <code>shadow</code> property.
 *
 * <h4>Example</h4>
 *
 *      myImage.shadow = new fanvas.Shadow("#000000", 5, 5, 10);
 *
 * @class Shadow
 * @constructor
 * @param {String} color The color of the shadow.
 * @param {Number} offsetX The x offset of the shadow in pixels.
 * @param {Number} offsetY The y offset of the shadow in pixels.
 * @param {Number} blur The size of the blurring effect.
 **/
var Shadow = function(color, offsetX, offsetY, blur) {
  this.initialize(color, offsetX, offsetY, blur);
};
var p = Shadow.prototype;

// public properties:
	/** The color of the shadow.
	 * property color
	 * @type String
	 * @default null
	 */
	p.color = null;

	/** The x offset of the shadow.
	 * property offsetX
	 * @type Number
	 * @default 0
	 */
	p.offsetX = 0;

	/** The y offset of the shadow.
	 * property offsetY
	 * @type Number
	 * @default 0
	 */
	p.offsetY = 0;

	/** The blur of the shadow.
	 * property blur
	 * @type Number
	 * @default 0
	 */
	p.blur = 0;

// constructor:
	/**
	 * Initialization method.
	 * @method initialize
	 * @protected
	 * @param {String} color The color of the shadow.
	 * @param {Number} offsetX The x offset of the shadow.
	 * @param {Number} offsetY The y offset of the shadow.
	 * @param {Number} blur The size of the blurring effect.
	 **/
	p.initialize = function(color, offsetX, offsetY, blur) {
		this.color = color;
		this.offsetX = offsetX || 0;
		this.offsetY = offsetY || 0;
		this.blur = blur;
	};

// static public properties:
	Shadow.identity = new Shadow("transparent", 0, 0, 0);

fanvas.Shadow = Shadow;
}());
