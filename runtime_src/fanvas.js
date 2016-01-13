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
     * store all canvas.
     * {canvas:xxx, timer:xx, stage:xx}
     * @type {Array}
     */
    var canvasList = [];
	
    /**
     * store all images.
     * @type {Object} key-{image path} value-{ImageElement}
     */
	fanvas.imageList = {};

    /**
     * Finds the first occurrence of a specified value searchElement in the passed in array, and returns the index of
     * that value.  Returns -1 if value is not found.
     *
     *      var i = fanvas.indexOf(myArray, myElementToFind);
     *
     * @method indexOf
     * @param {Array} array Array to search for searchElement
     * @param searchElement Element to find in array.
     * @return {Number} The first index of searchElement in array.
     */
    fanvas.indexOf = function (array, searchElement){
        for (var i = 0,l=array.length; i < l; i++) {
            if (searchElement === array[i]) {
                return i;
            }
        }
        return -1;
    };

    fanvas.indexOfCanvas = function (array, canvas){
        for (var i = 0,l=array.length; i < l; i++) {
            if (array[i].canvas && canvas === array[i].canvas) {
                return i;
            }
        }
        return -1;
    };

    /**
     *
     * @param canvas {HTMLCanvasElement | String | Object} canvas A canvas object, or the string id of a canvas object in the current document.
     * @param swfData {Object}
     * @param config {Object} {imagePath: images path, cache: cache Shape or not}
     */
    fanvas.play = function(canvas, swfData, config) {
        if(fanvas.indexOfCanvas(canvasList, canvas) >= 0 || !swfData)
            return;

        var start = function(){
            var o = {"canvas":canvas, "config":config, "frame":0};
            canvasList.push(o);
            o.stage = new fanvas.Stage(canvas, swfData, config);
            var onTick = function(delta) {
                o.stage.update(delta);
                o.frame++;
                if(config.onFrame){
                    config.onFrame(o.frame);
                }
                if(config.autoPlay == false){
                    o.timer.pause();
                    config.autoPlay = true;
                }
            };
            o.timer = new fanvas.Timer(swfData.frameRate, onTick);
            o.timer.start();
            onTick(0);
        };

        config = config || {};
        var imagePath = config.imagePath || "";
        if(swfData.images){
            var list = [];
            for (var i = 0; i < swfData.images.length; i++) {
                list.push(imagePath + swfData.images[i]);
            }
            new fanvas.Preloader().load(list, fanvas.imageList, start);
        }else{
            start();
        }
    };

    fanvas.replay = function (canvas) {
        var index = fanvas.indexOfCanvas(canvasList, canvas);
        if (index >= 0) {
            canvasList[index].frame = 0;
            canvasList[index].stage.replay();
            canvasList[index].timer.resume();
        }
    };

    fanvas.pause = function(canvas) {
        var index = fanvas.indexOfCanvas(canvasList, canvas);
        if (index >= 0) {
            canvasList[index].timer.pause();
        }
    };

    fanvas.resume = function(canvas) {
        var index = fanvas.indexOfCanvas(canvasList, canvas);
        if (index >= 0) {
            canvasList[index].timer.resume();
        }
    };

    var gotoFrame = function (canvas, index, stop) {
        var i = fanvas.indexOfCanvas(canvasList, canvas);
        if (i >= 0) {
            canvasList[i].timer.pause();
            if(index < canvasList[i].frame){
                canvasList[i].stage.replay();
                canvasList[i].frame = 0;
            }
            var steps = index-canvasList[i].frame-1;
            for (var j = 0; j < steps; j++) {
                canvasList[i].stage.update(0, true);
            }
            if(steps >= 0){
                canvasList[i].stage.update(0, false);
            }
            canvasList[i].frame = index;
            if(!stop){
                canvasList[i].timer.resume();
            }
        }
    };

    fanvas.gotoAndPlay = function (canvas, index) {
        gotoFrame(canvas, index);
    };

    fanvas.gotoAndStop = function (canvas, index) {
        gotoFrame(canvas, index, true);
    };

}());
