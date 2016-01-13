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
 * @class Shape
 * @extends DisplayObject
 * @constructor
 * @param {Array/Graphics} graphicsOrGraphicsData. A graphics instance or The graphics data exported by fanvas swf tool
 * @param config {Object} imagePath, cache Shape or not
 **/
var Shape = function(graphicsOrGraphicsData, config) {
  this.initialize(graphicsOrGraphicsData, config);
};
var p = Shape.prototype = new fanvas.DisplayObject();

// public properties:
	/**
	 * The graphics instance to display.
	 * @property graphics
	 * @type Graphics
	 **/
	p.graphics = null;

// constructor:
	/**
	 * @property DisplayObject_initialize
	 * @private
	 * @type Function
	 **/
	p.DisplayObject_initialize = p.initialize;

	/**
	 * Initialization method.
	 * @method initialize
     * @param {Array/Graphics} graphicsOrGraphicsData. A graphics instance or The graphics data exported by fanvas swf tool
     * @param config {Object} imagePath, cache Shape or not
	 * @protected
	 **/
	p.initialize = function(graphicsOrGraphicsData, config) {
		this.DisplayObject_initialize();
        if(graphicsOrGraphicsData instanceof fanvas.Graphics){
            this.graphics = graphicsOrGraphicsData;
        } else {
            this.graphics = new fanvas.Graphics(config.imagePath||"");
            for(var i = 0; i < graphicsOrGraphicsData.length; i++) {
                //every element is array. The first element is function name, and the remain ones is params array. ex, ["f", "#FFFFFF"]
                this.graphics[graphicsOrGraphicsData[i][0]].apply(this.graphics, graphicsOrGraphicsData[i].slice(1));
            }
        }
	};

	/**
	 * Draws the Shape into the specified context ignoring its visible, alpha, shadow, and transform. Returns true if
	 * the draw was handled (useful for overriding functionality).
	 *
	 * <i>NOTE: This method is mainly for internal use, though it may be useful for advanced uses.</i>
	 * @method draw
	 * @param {CanvasRenderingContext2D} ctx The canvas 2D context object to draw into..
     * @param {Boolean} isCacheCanvas If the ctx is a cacheCanvas. If true, skip the cacheCanvas, because it can't copy from itself, or there is no meaning for cache.
     *                  isCacheCanvas is set true just in DisplayObject.updateCache()
	 * @return {Boolean}
	 **/
	p.draw = function(ctx, isCacheCanvas) {
        // try to copy from cache first:
        if (!isCacheCanvas && this.drawFromCache(ctx)) { return true; }
		this.graphics.draw(ctx);
		return true;
	};

fanvas.Shape = Shape;
}());
