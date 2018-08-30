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

// constructor:
    /**
     * preload images
     * @class Preloader
     * @param {Array} list
     * @constructor
     **/
    var Preloader = function() {
        this.initialize();
    };
    var p = Preloader.prototype;


    p._taskCount = 0;
    p._finishCount = 0;
    p._callback = null;

// constructor:
    p.initialize = function() {
    };

// public

    /**
     *
     * @param list {array} url list
     * @param imageList {array} used to store all image elements
     * @param callback
     */
    p.load = function(list, imageList, callback) {
        if(list.length == 0)
            callback();
        this._taskCount = list.length;
        this._finishCount = 0;
        var that = this;
        for (var i = 0; i < list.length; i++) {
            var image = document.createElement("img");
            image.onload = function(){
                that._finishCount++;
                if(that._finishCount == that._taskCount)
                    callback();
            };
            image.src = list[i];
            imageList[list[i]] = image;
        }
    };

    fanvas.Preloader = Preloader;
}());
