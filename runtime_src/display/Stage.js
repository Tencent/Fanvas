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
 * A stage is the root level {{#crossLink "Container"}}{{/crossLink}} for a display list.
 * A stage stands for a SWF
 *
 * @class Stage
 * @extends Container
 * @constructor
 * @param canvas {HTMLCanvasElement | String | Object} canvas A canvas object, or the string id of a canvas object in the current document.
 * @param swfData {Object} swf info exported by fanvas swf tool.
 * @param config {Object} imagePath, cache Shape or not
 **/
var Stage = function(canvas, swfData, config) {
  this.initialize(canvas, swfData, config);
};
var p = Stage.prototype = new fanvas.Container();


// public properties:

	/**
	 * The canvas the stage will render to.
	 *
	 * @property canvas
	 * @type HTMLCanvasElement
	 **/
	p.canvas = null;

    /**
     * swf info exported by fanvas swf tool.
     * swfData.definitionPool will be used through out the whole animation scope.
     * after cached, more instances will be added to this definitionPool
     * @type {Object}
     */
    p.swfData = null;

    p.config = null;

    /**
     * to clear these rect before redrawing, and just redraw these areas
     * @type {Array}
     */
    p.dirtyRectList = [];

    /**
     * when dirty rect area summed up to  dirtyThresholdArea, dirty draw will be cancel, and turn to all screen redraw
     * @type {number}
     */
    p.dirtyThresholdArea = 0;


// constructor:
	/**
	 * @property DisplayObject_initialize
	 * @type Function
	 * @private
	 **/
	p.Container_initialize = p.initialize;

	/**
	 * Initialization method.
	 * @method initialize
     * @param canvas {HTMLCanvasElement | String | Object} canvas A canvas object, or the string id of a canvas object in the current document.
     * @param swfData {Object} swf info exported by fanvas swf tool.
     * @param config {Object} imagePath, cache Shape or not
	 * @protected
	 **/
	p.initialize = function(canvas, swfData, config) {
        this.config = config;
        this.swfData = swfData;
		this.Container_initialize();
		var canvas = this.canvas = (typeof canvas == "string") ? document.getElementById(canvas) : canvas;
        if(swfData.bgColor)
            this.canvas.setAttribute("style", (this.canvas.getAttribute("style") || "") + ";background-color:" + swfData.bgColor);
        this.root = this;
        this.dirtyThresholdArea = canvas.width * canvas.height * 2 / 3;
        this._prebuildShapes(swfData.definitionPool);

        var mainMC = new fanvas.MovieClip(swfData.definitionPool, 0, config);
        config.scale && (mainMC.scaleX = mainMC.scaleY = config.scale);
        canvas.width = swfData.stageWidth*mainMC.scaleX;
        canvas.height = swfData.stageHeight*mainMC.scaleY;
        mainMC.globalMatrix = mainMC.getMatrix();       //use in dirty rect redrawing
//        alert(canvas.width + " " + canvas.height + " " + mainMC.scaleX + " " + mainMC.scaleY);
        this.addChild(mainMC);
        config.showFPS && (this.stats = new fanvas.Stats(this.canvas.getContext("2d")));
	};

// public methods:

	/**
	 * update method used to be Timer onFrame callback
	 *
	 * @method update
     * @param delta 毫秒
     */
	p.update = function(delta) {
		if (!this.canvas) { return; }

        var mc = this.getChildAt(0);
        var dirtyRectList = this.dirtyRectList = [];
        mc.update();    //push the main MC to go forward, and calculate a new dirtyRect list

        if(dirtyRectList.length){
            var ctx = this.canvas.getContext("2d");
            ctx.setTransform(1, 0, 0, 1, 0, 0);
            ctx.save();
            this._clear(ctx, dirtyRectList, mc.currentFrame == 1 || !!this.config.clearAll);      //显示dirtyRect的时候要全屏刷新
            mc.presetContext(ctx);          //draw在cache中也会用到，但cache的时候不需要presetContext，所以presetContext抽离出来
            mc.draw(ctx, false);
            this.config.showDirtyRect && this._showDirtyRect(ctx, dirtyRectList, '#CC0000');
            ctx.restore();
        }

        this.config.showFPS && this.stats.update(delta);
	};

    p._clear = function (ctx, dirtyRectList, clearAll) {
        var calculateArea = function (rectList) {
            var sum = 0;
            for (var i = 0; i < rectList.length; i++) {
                var rect = rectList[i];
                sum += rect.width*rect.height;
            }
            return sum;
        };

        if(clearAll || dirtyRectList.length > 30 || calculateArea(dirtyRectList) > this.dirtyThresholdArea){
            ctx.clearRect(0, 0, this.canvas.width+1, this.canvas.height+1);
        } else {
            for (var i = 0; i < dirtyRectList.length; i++) {
                var rect = dirtyRectList[i];
                ctx.clearRect(rect.x-1, rect.y-1, rect.width+2, rect.height+2);
            }

            ctx.beginPath();
            for (var i = 0; i < dirtyRectList.length; i++) {
                var rect = dirtyRectList[i];
                ctx.rect(rect.x-1, rect.y-1, rect.width+2, rect.height+2);
            }
            ctx.clip();
        }
    };

    /**
     * prebuild all Shapes to speed up animation
     */
    p._prebuildShapes = function (definitionPool) {
        for (var i = 0; i < definitionPool.length; i++) {
            var element = definitionPool[i];
            //just prebuild Shapes, turn graphics data array into a Real graphics Class instance
            if(element.graphics){
                var shape = new fanvas.Shape(element.graphics, this.config);
                element.graphics = shape.graphics;
            }
        }
    };

    p._showDirtyRect = function (ctx, dirtyRectList, color) {
        ctx.beginPath();
        for (var i = 0; i < dirtyRectList.length; i++) {
            var rect = dirtyRectList[i];
            ctx.rect(rect.x, rect.y, rect.width, rect.height);
        }
        ctx.lineWidth = 1.0;
        ctx.strokeStyle = color;
        ctx.stroke();
    };

    p.replay = function () {
        this.removeAllChildren();
        var mainMC = new fanvas.MovieClip(this.swfData.definitionPool, 0, this.config);
        this.addChild(mainMC);
    };

fanvas.Stage = Stage;
}());
