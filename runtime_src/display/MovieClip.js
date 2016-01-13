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

    /**
     * @class MovieClip
     * @constructor
     * @param lib {Array} definition list
     * @param definitionID
     * @param config {Object} imagePath, cache Shape or not
     * @constructor
     */
    var MovieClip = function(lib, definitionID, config) {
        this.initialize(lib, definitionID, config);
    };
    var p = MovieClip.prototype = new fanvas.Container();

    p.currentFrame = 0;
    p.totalFrames = 0;
    p.actionList = null;
    p.library = null;
    p.config = null;
    p._tweenList = null;
    p._remainList = null;

    p.Container_initialize = p.initialize;

    p.initialize = function(lib, definitionID, config) {
        this.Container_initialize();
        this.library = lib;
        this.config = config;
        this.currentFrame = 0;
        var defObj = this.library[definitionID];
        this.totalFrames = defObj.totalFrames;
        this.actionList = defObj.frameActionList;
        this._tweenList = [];
        this._remainList = [];
    };

// public methods:

    p.Container_draw = p.draw;

    p.Container_update = p.update;

    /**
     * @method draw
     * @param {CanvasRenderingContext2D} ctx The canvas 2D context object to draw into..
     * @param {Boolean} isCacheCanvas If the ctx is a cacheCanvas. If true, skip the cacheCanvas, because it can't copy from itself, or there is no meaning for cache.
     *                  isCacheCanvas is set true just in DisplayObject.updateCache()
     * @return {Boolean}
     **/
    p.draw = function(ctx, isCacheCanvas) {
        // try to copy from cache first:
        if (!isCacheCanvas && this.drawFromCache(ctx)) { return true; }
        this.Container_draw(ctx, isCacheCanvas);
        return true;
    };

    /**
     * update
     */
    p.update = function(){
        this._updateTween();
        this._updateTimeline();
        this.Container_update();
    };

// private methods:
    p._updateTween = function() {
        var tweenList = this._tweenList;
        var tweenObj;
        var target;
        var duration;
        var r = this.root;
        for (var i = 0; i < tweenList.length; i++) {
            tweenObj = tweenList[i];
            target = tweenObj.target;
            duration = tweenObj.duration;
            r.dirtyRectList.push(target.dirtyRect);
            for (var prop in tweenObj.tweenData) {
                target[prop] += (tweenObj.tweenData[prop] -  target[prop]) / duration;
            }
            r.dirtyRectList.push(target.calculateDirtyRect());
            tweenObj.duration--;
            if (tweenObj.duration == 0) {
                tweenList.splice(i, 1);
                i--;
            }
        }
    };

    p._updateTimeline = function() {
        var currentFrame = this.currentFrame;
        if(currentFrame == 0 && this.totalFrames > 1){
            var child;
            this._remainList.length > 0 && this._remainList.splice(0);
            while(this.getNumChildren() > 0){
                child = this.getChildAt(0);
                if (child.initFrame == 0) {
                    this._remainList.push(child);
                }
                this.removeChildAt(0);
            }
            this._tweenList.splice(0);
        }
        var actions = this._getCurrentAction();
        if (actions != null && actions instanceof Array) {
            for (var i = 0; i < actions.length; i++) {
                this._exec(actions[i]);
            }
        }
        currentFrame++;
        this.currentFrame = (currentFrame == this.totalFrames)?0:currentFrame;
    };

    p._getCurrentAction = function() {
        for (var i = 0; i < this.actionList.length; i++) {
            if (this.actionList[i][0] == this.currentFrame) {
                return this.actionList[i].slice(1);
            }
        }
       return null;
    };

    p._exec = function(array) {
        this["_" + array[0]].apply(this, array.slice(1));
    };

    p._placeElement = function (instanceData) {
        var child = this.getChildByName(instanceData.n);
        if (!child) {
            if (instanceData.id == undefined || instanceData.id == -1 || instanceData.id >= this.library.length)
                return;
            var definition = this.library[instanceData.id];
            if(definition == null) return;

            if (this.currentFrame == 0) {
                child = this._getFromList(instanceData.n);
            }
            if (!child) {
                var rect = definition.rect;
                if (instanceData.t == "MC") {
                    child = new fanvas.MovieClip(this.library, instanceData.id, this.config);
                } else {
                    child = new fanvas.Shape(definition.graphics, this.config);
                    var cacheScale = this.config.cache;
                    if (cacheScale) {
                        var canvas = this.root.canvas;
                        if(rect.width > canvas.width || rect.height > canvas.height)
                            cacheScale = 1;       //prevent drawing too big
                        child.cache(rect.x, rect.y, rect.width, rect.height, cacheScale);
                    }
                    definition.instance = child;    //just cache Shape
                }
                child.rect = rect;
                child.name = instanceData.n;
                child.initFrame = this.currentFrame;
            }
            child.clipDepth = instanceData.cd || 0;
            child.maskDepth = instanceData.md || 0;

            if(child.clipDepth) {
                //遮罩
                this._updateMaskRelation(child);
            } else if(child.maskDepth){
                //被遮罩
                child.mask = this._getMask(child);        //mask is added earlier
            } else {
                //什么都不是
                child.mask = null;
            }
            this.addChildAt(child, instanceData.d);
        } else {
            this.root.dirtyRectList.push(child.dirtyRect);
        }
        child.setTransform(instanceData.x, instanceData.y, instanceData.sX, instanceData.sY, 0, instanceData.skX, instanceData.skY);
        child.alpha = instanceData.a != undefined?instanceData.a:1;
        if (instanceData.shadow) {
            child.shadow = new fanvas.Shadow(instanceData.shadow.color, instanceData.shadow.offsetX, instanceData.shadow.offsetY, instanceData.shadow.blur);
        } else if (child.shadow != null) {
            child.shadow = null;
        }
        if (instanceData.filters && instanceData.filters.length > 0) {
            var filterInfo;
            var filter;
            var filters = [];
            for (var i = 0; i < instanceData.filters.length; i++) {
                filterInfo = instanceData.filters[i];
                if (filterInfo.type == "CF") {
                    filter = new fanvas.ColorFilter(filterInfo.data[0],filterInfo.data[1],filterInfo.data[2],
                        filterInfo.data[3],filterInfo.data[4],filterInfo.data[5],filterInfo.data[6],filterInfo.data[7]);
                    filters.push(filter);
                } else if (filterInfo.type == "CMF") {
                    filter = new fanvas.ColorMatrixFilter(filterInfo.matrix);
                    filters.push(filter);
                } else if (filterInfo.type == "BF") {
                    filter = new fanvas.BlurFilter(filterInfo.blurX, filterInfo.blurY, filterInfo.quality);
                    filters.push(filter);
                }
            }
            child.filters = filters;
            //instanceID会是空，所以把rect写进child的属性
            var rectData = child.rect;
            child.cache(rectData.x,rectData.y,rectData.width,rectData.height);
        } else if (child.filters && child.filters.length > 0) {
            child.uncache();
        }
        this.root.dirtyRectList.push(child.calculateDirtyRect());
    };

    p._removeElement = function (name) {
        var child = this.getChildByName(name);
        this.removeChild(child);
        this.root.dirtyRectList.push(child.dirtyRect);
    };

    p._tweenElement = function (name, duration, tweenData) {
        var child = this.getChildByName(name);
        if (!child)
            return;
        var tweenObj = {};
        tweenObj.target = child;
        tweenObj.duration = duration;
        tweenObj.tweenData = tweenData;
        this._tweenList.push(tweenObj);
    };

    /**
     * 原来只需要一对一的设置mask。但考虑到mask在时间轴过程中可能发生变化，此时被遮罩的Shape对此无感知，所以这里刷新一遍这些元件的mask
     * @private
     */
    p._updateMaskRelation = function (mask) {
        for (var i = 0; i < this.children.length; i++) {
            var child = this.children[i];
            if(mask.clipDepth > child.maskDepth && mask.maskDepth < child.maskDepth){
                child.mask = mask;
                this.root.dirtyRectList.push(child.dirtyRect);
                var rect = child.calculateDirtyRect();
                this.root.dirtyRectList.push(rect);
            }
        }
    };

    /**
     * 查找被遮罩元件的mask
     * @param child
     * @returns {*}
     * @private
     */
    p._getMask = function (child) {
        for (var i = 0; i < this.children.length; i++) {
            var mask = this.children[i];
            if(mask.clipDepth > child.maskDepth && mask.maskDepth < child.maskDepth) {
                return mask;
            }
        }
        return null;
    };

    p._pE = p._placeElement;
    p._tE = p._tweenElement;
    p._rE = p._removeElement;

    p._getFromList = function (name) {
        for (var i = 0; i < this._remainList.length; i++) {
            if (this._remainList[i].name == name) {
                return this._remainList.splice(i, 1)[0];
            }
        }
        return null;
    };

    fanvas.MovieClip = MovieClip;
}());
