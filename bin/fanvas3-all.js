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
     * @param config {Object} {imagePath: images path, cache: cache Shape or not, onPreloadProgress, onPreloadError}
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
            new fanvas.Preloader().load(list, fanvas.imageList, start, config.onPreloadProgress, config.onPreloadError);
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

// namespace:
this.fanvas = this.fanvas||{};

(function() {
    "use strict";

// constructor:
    /**
     *
     * @class Timer
     * @param {int} fps
     * @param {Function} onFrame callback every frame
     * @constructor
     **/
    var Timer = function(fps, onFrame) {
        this.initialize(fps, onFrame);
    };
    var p = Timer.prototype;


// public
    p.interval = 16;
    p.onFrame = null;
    p.paused = false;   //let timer pause in the next tick
    p._stop = false;    //mark timer has been stopped

// constructor:
    p.initialize = function(fps, onFrame) {
        if(fps <= 0 || !onFrame)
            throw "err";
        this.interval = Math.floor(1000/fps);
        this.onFrame = onFrame;
    };

// public

    window.requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;

    p.start = function() {
        var then=Date.now(), realThen=Date.now(), timer=this;
        //使用闭包实现类似this的效果
        var loop = function() {
            if(timer.paused){
                timer._stop = true;
                return;
            }
            var now = Date.now();
            var delta = now - then;
            var realDelta = now - realThen;     //只用于统计两帧之间的真正间隔时间

            if(window.requestAnimationFrame){
                requestAnimationFrame(loop);
                if (delta > timer.interval) {
                    // 这里不能简单then=now，否则还会出现简单做法的细微时间差问题。例如fps=10，每帧100ms，而现在每16ms（60fps）执行一次draw。16*7=112>100，需要7次才实际绘制一次。
                    // 这个情况下，实际10帧需要112*10=1120ms>1000ms才绘制完成。
                    then = now - (delta % timer.interval);
                    realThen = now;
                    timer.onFrame(realDelta);
                }
            }
            else {
                setTimeout(loop, timer.interval);
                then = now;
                timer.onFrame(delta);
            }
        };
        loop();
    };

    p.pause = function(){
        this.paused = true;
    };

    p.resume = function(){
        if(this.paused){
            this.paused = false;
            if(this._stop){
                this._stop = false;
                this.start();
            }
        }
    };

    fanvas.Timer = Timer;
}());
/**
 * Created by tencent on 2015/4/10.
 */

// namespace:
this.fanvas = this.fanvas||{};

(function() {
    "use strict";

// constructor:
    /**
     *
     * @class Stats
     * @param {ctx} ctx
     * @constructor
     **/
    var Stats = function(ctx) {
        this.initialize(ctx);
    };
    var p = Stats.prototype;


// public
    p.ctx = null;
    p.maxFPS = 0;
    p.minFPS = 99;
    p.frameCount = 0;
    p.totalDelta = 0;
    p.fps = 0;

// constructor:
    p.initialize = function(ctx) {
        this.ctx = ctx;
    };

// public

    p.update = function (delta) {
        this.totalDelta += delta;
        this.frameCount++;
        if(this.totalDelta > 1000){
            var fps = this.fps = this.frameCount;
            this.frameCount = this.totalDelta = 0;
            if(fps > this.maxFPS)
                this.maxFPS = fps;
            if(fps < this.minFPS)
                this.minFPS = fps;
        }

        var ctx = this.ctx;
        ctx.beginPath();
        ctx.rect(0, 0, 48, 48);
        ctx.fillStyle = '#000';
        ctx.fill();
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText('FPS: ' + this.fps, 5, 13);
        ctx.fillText('Max: ' + this.maxFPS, 5, 27);
        ctx.fillText('Min: ' + this.minFPS, 5, 41);
    };

    fanvas.Stats = Stats;
}());

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
     * @param finish
     * @param onProgress
     * @param onError
     */
    p.load = function(list, imageList, finish, onProgress, onError) {
        if(list.length == 0)
            finish();
        this._taskCount = list.length;
        this._finishCount = 0;
        var that = this;
        var errorReturned = false;
        for (var i = 0; i < list.length; i++) {
            var image = document.createElement("img");
            image.onload = function(){
                that._finishCount++;
                onProgress && onProgress(that._finishCount/that._taskCount);
                if(that._finishCount == that._taskCount)
                    finish();
            };
            image.onerror = function () {
                if(!errorReturned && onError){
                    onError();
                }
            };
            image.src = list[i] + '?max_age=604800';
            imageList[list[i]] = image;
        }
    };

    fanvas.Preloader = Preloader;
}());

// namespace:
this.fanvas = this.fanvas||{};

(function() {
	"use strict";

/**
 * Represents an affine transformation matrix, and provides tools for constructing and concatenating matrixes.
 * @class Matrix2D
 * @param {Number} [a=1] Specifies the a property for the new matrix.
 * @param {Number} [b=0] Specifies the b property for the new matrix.
 * @param {Number} [c=0] Specifies the c property for the new matrix.
 * @param {Number} [d=1] Specifies the d property for the new matrix.
 * @param {Number} [tx=0] Specifies the tx property for the new matrix.
 * @param {Number} [ty=0] Specifies the ty property for the new matrix.
 * @constructor
 **/
var Matrix2D = function(a, b, c, d, tx, ty) {
  this.initialize(a, b, c, d, tx, ty);
};
var p = Matrix2D.prototype;

// static public properties:

	/**
	 * An identity matrix, representing a null transformation.
	 * @property identity
	 * @static
	 * @type Matrix2D
	 * @readonly
	 **/
	Matrix2D.identity = null; // set at bottom of class definition.

	/**
	 * Multiplier for converting degrees to radians. Used internally by Matrix2D.
	 * @property DEG_TO_RAD
	 * @static
	 * @final
	 * @type Number
	 * @readonly
	 **/
	Matrix2D.DEG_TO_RAD = Math.PI/180;


// public properties:
	/**
	 * Position (0, 0) in a 3x3 affine transformation matrix.
	 * @property a
	 * @type Number
	 **/
	p.a = 1;

	/**
	 * Position (0, 1) in a 3x3 affine transformation matrix.
	 * @property b
	 * @type Number
	 **/
	p.b = 0;

	/**
	 * Position (1, 0) in a 3x3 affine transformation matrix.
	 * @property c
	 * @type Number
	 **/
	p.c = 0;

	/**
	 * Position (1, 1) in a 3x3 affine transformation matrix.
	 * @property d
	 * @type Number
	 **/
	p.d = 1;

	/**
	 * Position (2, 0) in a 3x3 affine transformation matrix.
	 * @property tx
	 * @type Number
	 **/
	p.tx = 0;

	/**
	 * Position (2, 1) in a 3x3 affine transformation matrix.
	 * @property ty
	 * @type Number
	 **/
	p.ty = 0;

	/**
	 * Property representing the alpha that will be applied to a display object. This is not part of matrix
	 * operations, but is used for operations like getConcatenatedMatrix to provide concatenated alpha values.
	 * @property alpha
	 * @type Number
	 **/
	p.alpha = 1;

	/**
	 * Property representing the shadow that will be applied to a display object. This is not part of matrix
	 * operations, but is used for operations like getConcatenatedMatrix to provide concatenated shadow values.
	 * @property shadow
	 * @type Shadow
	 **/
	p.shadow  = null;

	/**
	 * Property representing the compositeOperation that will be applied to a display object. This is not part of
	 * matrix operations, but is used for operations like getConcatenatedMatrix to provide concatenated
	 * compositeOperation values. You can find a list of valid composite operations at:
	 * <a href="https://developer.mozilla.org/en/Canvas_tutorial/Compositing">https://developer.mozilla.org/en/Canvas_tutorial/Compositing</a>
	 * @property compositeOperation
	 * @type String
	 **/
	p.compositeOperation = null;
	
	/**
	 * Property representing the value for visible that will be applied to a display object. This is not part of matrix
	 * operations, but is used for operations like getConcatenatedMatrix to provide concatenated visible values.
	 * @property visible
	 * @type Boolean
	 **/
	p.visible = true;

// constructor:
	/**
	 * Initialization method. Can also be used to reinitialize the instance.
	 * @method initialize
	 * @param {Number} [a=1] Specifies the a property for the new matrix.
	 * @param {Number} [b=0] Specifies the b property for the new matrix.
	 * @param {Number} [c=0] Specifies the c property for the new matrix.
	 * @param {Number} [d=1] Specifies the d property for the new matrix.
	 * @param {Number} [tx=0] Specifies the tx property for the new matrix.
	 * @param {Number} [ty=0] Specifies the ty property for the new matrix.
	 * @return {Matrix2D} This instance. Useful for chaining method calls.
	*/
	p.initialize = function(a, b, c, d, tx, ty) {
		this.a = (a == null) ? 1 : a;
		this.b = b || 0;
		this.c = c || 0;
		this.d = (d == null) ? 1 : d;
		this.tx = tx || 0;
		this.ty = ty || 0;
		return this;
	};

// public methods:
	/**
	 * Concatenates the specified matrix properties with this matrix. All parameters are required.
	 * @method prepend
	 * @param {Number} a
	 * @param {Number} b
	 * @param {Number} c
	 * @param {Number} d
	 * @param {Number} tx
	 * @param {Number} ty
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.prepend = function(a, b, c, d, tx, ty) {
		var tx1 = this.tx;
		if (a != 1 || b != 0 || c != 0 || d != 1) {
			var a1 = this.a;
			var c1 = this.c;
			this.a  = a1*a+this.b*c;
			this.b  = a1*b+this.b*d;
			this.c  = c1*a+this.d*c;
			this.d  = c1*b+this.d*d;
		}
		this.tx = tx1*a+this.ty*c+tx;
		this.ty = tx1*b+this.ty*d+ty;
		return this;
	};

	/**
	 * Appends the specified matrix properties with this matrix. All parameters are required.
	 * @method append
	 * @param {Number} a
	 * @param {Number} b
	 * @param {Number} c
	 * @param {Number} d
	 * @param {Number} tx
	 * @param {Number} ty
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.append = function(a, b, c, d, tx, ty) {
		var a1 = this.a;
		var b1 = this.b;
		var c1 = this.c;
		var d1 = this.d;

		this.a  = a*a1+b*c1;
		this.b  = a*b1+b*d1;
		this.c  = c*a1+d*c1;
		this.d  = c*b1+d*d1;
		this.tx = tx*a1+ty*c1+this.tx;
		this.ty = tx*b1+ty*d1+this.ty;
		return this;
	};

	/**
	 * Prepends the specified matrix with this matrix.
	 * @method prependMatrix
	 * @param {Matrix2D} matrix
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.prependMatrix = function(matrix) {
		this.prepend(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
		this.prependProperties(matrix.alpha, matrix.shadow,  matrix.compositeOperation, matrix.visible);
		return this;
	};

	/**
	 * Appends the specified matrix with this matrix.
	 * @method appendMatrix
	 * @param {Matrix2D} matrix
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.appendMatrix = function(matrix) {
		this.append(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
		this.appendProperties(matrix.alpha, matrix.shadow,  matrix.compositeOperation, matrix.visible);
		return this;
	};

	/**
	 * Generates matrix properties from the specified display object transform properties, and prepends them with this matrix.
	 * For example, you can use this to generate a matrix from a display object: var mtx = new Matrix2D();
	 * mtx.prependTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation);
	 * @method prependTransform
	 * @param {Number} x
	 * @param {Number} y
	 * @param {Number} scaleX
	 * @param {Number} scaleY
	 * @param {Number} rotation
	 * @param {Number} skewX
	 * @param {Number} skewY
	 * @param {Number} regX Optional.
	 * @param {Number} regY Optional.
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.prependTransform = function(x, y, scaleX, scaleY, rotation, skewX, skewY, regX, regY) {
		if (rotation%360) {
			var r = rotation*Matrix2D.DEG_TO_RAD;
			var cos = Math.cos(r);
			var sin = Math.sin(r);
		} else {
			cos = 1;
			sin = 0;
		}

		if (regX || regY) {
			// append the registration offset:
			this.tx -= regX; this.ty -= regY;
		}
		if (skewX || skewY) {
			// TODO: can this be combined into a single prepend operation?
			skewX *= Matrix2D.DEG_TO_RAD;
			skewY *= Matrix2D.DEG_TO_RAD;
			this.prepend(cos*scaleX, sin*scaleX, -sin*scaleY, cos*scaleY, 0, 0);
			this.prepend(Math.cos(skewY), Math.sin(skewY), -Math.sin(skewX), Math.cos(skewX), x, y);
		} else {
			this.prepend(cos*scaleX, sin*scaleX, -sin*scaleY, cos*scaleY, x, y);
		}
		return this;
	};

	/**
	 * Generates matrix properties from the specified display object transform properties, and appends them with this matrix.
	 * For example, you can use this to generate a matrix from a display object: var mtx = new Matrix2D();
	 * mtx.appendTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation);
	 * @method appendTransform
	 * @param {Number} x
	 * @param {Number} y
	 * @param {Number} scaleX
	 * @param {Number} scaleY
	 * @param {Number} rotation
	 * @param {Number} skewX
	 * @param {Number} skewY
	 * @param {Number} regX Optional.
	 * @param {Number} regY Optional.
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.appendTransform = function(x, y, scaleX, scaleY, rotation, skewX, skewY, regX, regY) {
		if (rotation%360) {
			var r = rotation*Matrix2D.DEG_TO_RAD;
			var cos = Math.cos(r);
			var sin = Math.sin(r);
		} else {
			cos = 1;
			sin = 0;
		}

		if (skewX || skewY) {
			// TODO: can this be combined into a single append?
			skewX *= Matrix2D.DEG_TO_RAD;
			skewY *= Matrix2D.DEG_TO_RAD;
			this.append(Math.cos(skewY), Math.sin(skewY), -Math.sin(skewX), Math.cos(skewX), x, y);
			this.append(cos*scaleX, sin*scaleX, -sin*scaleY, cos*scaleY, 0, 0);
		} else {
			this.append(cos*scaleX, sin*scaleX, -sin*scaleY, cos*scaleY, x, y);
		}

		if (regX || regY) {
			// prepend the registration offset:
			this.tx -= regX*this.a+regY*this.c; 
			this.ty -= regX*this.b+regY*this.d;
		}
		return this;
	};

	/**
	 * Applies a rotation transformation to the matrix.
	 * @method rotate
	 * @param {Number} angle The angle in radians. To use degrees, multiply by <code>Math.PI/180</code>.
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.rotate = function(angle) {
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);

		var a1 = this.a;
		var c1 = this.c;
		var tx1 = this.tx;

		this.a = a1*cos-this.b*sin;
		this.b = a1*sin+this.b*cos;
		this.c = c1*cos-this.d*sin;
		this.d = c1*sin+this.d*cos;
		this.tx = tx1*cos-this.ty*sin;
		this.ty = tx1*sin+this.ty*cos;
		return this;
	};

	/**
	 * Applies a skew transformation to the matrix.
	 * @method skew
	 * @param {Number} skewX The amount to skew horizontally in degrees.
	 * @param {Number} skewY The amount to skew vertically in degrees.
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	*/
	p.skew = function(skewX, skewY) {
		skewX = skewX*Matrix2D.DEG_TO_RAD;
		skewY = skewY*Matrix2D.DEG_TO_RAD;
		this.append(Math.cos(skewY), Math.sin(skewY), -Math.sin(skewX), Math.cos(skewX), 0, 0);
		return this;
	};

	/**
	 * Applies a scale transformation to the matrix.
	 * @method scale
	 * @param {Number} x The amount to scale horizontally
	 * @param {Number} y The amount to scale vertically
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.scale = function(x, y) {
		this.a *= x;
		this.d *= y;
		this.c *= x;
		this.b *= y;
		this.tx *= x;
		this.ty *= y;
		return this;
	};

	/**
	 * Translates the matrix on the x and y axes.
	 * @method translate
	 * @param {Number} x
	 * @param {Number} y
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.translate = function(x, y) {
		this.tx += x;
		this.ty += y;
		return this;
	};

	/**
	 * Sets the properties of the matrix to those of an identity matrix (one that applies a null transformation).
	 * @method identity
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.identity = function() {
		this.alpha = this.a = this.d = 1;
		this.b = this.c = this.tx = this.ty = 0;
		this.shadow = this.compositeOperation = null;
		this.visible = true;
		return this;
	};

	/**
	 * Inverts the matrix, causing it to perform the opposite transformation.
	 * @method invert
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	 **/
	p.invert = function() {
		var a1 = this.a;
		var b1 = this.b;
		var c1 = this.c;
		var d1 = this.d;
		var tx1 = this.tx;
		var n = a1*d1-b1*c1;

		this.a = d1/n;
		this.b = -b1/n;
		this.c = -c1/n;
		this.d = a1/n;
		this.tx = (c1*this.ty-d1*tx1)/n;
		this.ty = -(a1*this.ty-b1*tx1)/n;
		return this;
	};

	/**
	 * Appends the specified visual properties to the current matrix.
	 * @method appendProperties
	 * @param {Number} alpha desired alpha value
	 * @param {Shadow} shadow desired shadow value
	 * @param {String} compositeOperation desired composite operation value
	 * @param {Boolean} visible desired visible value
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	*/
	p.appendProperties = function(alpha, shadow, compositeOperation, visible) {
		this.alpha *= alpha;
		this.shadow = shadow || this.shadow;
		this.compositeOperation = compositeOperation || this.compositeOperation;
		this.visible = this.visible && visible;
		return this;
	};

	/**
	 * Prepends the specified visual properties to the current matrix.
	 * @method prependProperties
	 * @param {Number} alpha desired alpha value
	 * @param {Shadow} shadow desired shadow value
	 * @param {String} compositeOperation desired composite operation value
	 * @param {Boolean} visible desired visible value
	 * @return {Matrix2D} This matrix. Useful for chaining method calls.
	*/
	p.prependProperties = function(alpha, shadow, compositeOperation, visible) {
		this.alpha *= alpha;
		this.shadow = this.shadow || shadow;
		this.compositeOperation = this.compositeOperation || compositeOperation;
		this.visible = this.visible && visible;
		return this;
	};

	// this has to be populated after the class is defined:
	Matrix2D.identity = new Matrix2D();

fanvas.Matrix2D = Matrix2D;
}());

// namespace:
this.fanvas = this.fanvas||{};

(function() {
	"use strict";

/**
 * Represents a rectangle as defined by the points (x, y) and (x+width, y+height).
 *
 * <h4>Example</h4>
 *
 *      var rect = new fanvas.Rectangle(0, 0, 100, 100);
 *
 * @class Rectangle
 * @param {Number} [x=0] X position.
 * @param {Number} [y=0] Y position.
 * @param {Number} [width=0] The width of the Rectangle.
 * @param {Number} [height=0] The height of the Rectangle.
 * @constructor
 **/
var Rectangle = function(x, y, width, height) {
  this.initialize(x, y, width, height);
};
var p = Rectangle.prototype;

// public properties:
	/**
	 * X position.
	 * @property x
	 * @type Number
	 **/
	p.x = 0;

	/**
	 * Y position.
	 * @property y
	 * @type Number
	 **/
	p.y = 0;

	/**
	 * Width.
	 * @property width
	 * @type Number
	 **/
	p.width = 0;

	/**
	 * Height.
	 * @property height
	 * @type Number
	 **/
	p.height = 0;

// constructor:
	/** 
	 * Initialization method. Can also be used to reinitialize the instance.
	 * @method initialize
	 * @param {Number} [x=0] X position.
	 * @param {Number} [y=0] Y position.
	 * @param {Number} [width=0] The width of the Rectangle.
	 * @param {Number} [height=0] The height of the Rectangle.
	 * @return {Rectangle} This instance. Useful for chaining method calls.
	*/
	p.initialize = function(x, y, width, height) {
		this.x = x||0;
		this.y = y||0;
		this.width = width||0;
		this.height = height||0;
		return this;
	};


fanvas.Rectangle = Rectangle;
}());

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

// namespace:
this.fanvas = this.fanvas||{};

(function() {
/**
 * DisplayObject is an abstract class that should not be constructed directly. Instead construct subclasses such as
 * {{#crossLink "Container"}}{{/crossLink}}, and {{#crossLink "Shape"}}{{/crossLink}}.
 * DisplayObject is the base class for all display classes in the fanvas library. It defines the core properties and
 * methods that are shared between all display objects, such as transformation properties (x, y, scaleX, scaleY, etc),
 * caching.
 * @class DisplayObject
 * @constructor
 **/
var DisplayObject = function() {
  this.initialize();
};
var p = DisplayObject.prototype;
	
	
// public properties:
	/**
	 * The alpha (transparency) for this display object. 0 is fully transparent, 1 is fully opaque.
	 * @property alpha
	 * @type {Number}
	 * @default 1
	 **/
	p.alpha = 1;

	/**
	 * If a cache is active, this returns the canvas that holds the cached version of this display object. See {{#crossLink "cache"}}{{/crossLink}}
	 * for more information.
	 * @property cacheCanvas
	 * @type {HTMLCanvasElement | Object}
	 * @default null
	 * @readonly
	 **/
	p.cacheCanvas = null;

	/**
	 * An optional name for this display object.
	 * @property name
	 * @type {String}
	 * @default null
	 **/
	p.name = null;

	/**
	 * A reference to the {{#crossLink "Container"}}{{/crossLink}} or {{#crossLink "Stage"}}{{/crossLink}} object that
	 * contains this display object, or null if it has not been added
	 * to one.
	 * @property parent
	 * @final
	 * @type {Container}
	 * @default null
	 * @readonly
	 **/
	p.parent = null;

    p.root = null;

	/**
	 * The left offset for this display object's registration point. For example, to make a 100x100px Bitmap rotate
	 * around its center, you would set regX and {{#crossLink "DisplayObject/regY:property"}}{{/crossLink}} to 50.
	 * @property regX
	 * @type {Number}
	 * @default 0
	 **/
	p.regX = 0;

	/**
	 * The y offset for this display object's registration point. For example, to make a 100x100px Bitmap rotate around
	 * its center, you would set {{#crossLink "DisplayObject/regX:property"}}{{/crossLink}} and regY to 50.
	 * @property regY
	 * @type {Number}
	 * @default 0
	 **/
	p.regY = 0;

	/**
	 * The rotation in degrees for this display object.
	 * @property rotation
	 * @type {Number}
	 * @default 0
	 **/
	p.rotation = 0;

	/**
	 * The factor to stretch this display object horizontally. For example, setting scaleX to 2 will stretch the display
	 * object to twice its nominal width. To horizontally flip an object, set the scale to a negative number.
	 * @property scaleX
	 * @type {Number}
	 * @default 1
	 **/
	p.scaleX = 1;

	/**
	 * The factor to stretch this display object vertically. For example, setting scaleY to 0.5 will stretch the display
	 * object to half its nominal height. To vertically flip an object, set the scale to a negative number.
	 * @property scaleY
	 * @type {Number}
	 * @default 1
	 **/
	p.scaleY = 1;

	/**
	 * The factor to skew this display object horizontally.
	 * @property skewX
	 * @type {Number}
	 * @default 0
	 **/
	p.skewX = 0;

	/**
	 * The factor to skew this display object vertically.
	 * @property skewY
	 * @type {Number}
	 * @default 0
	 **/
	p.skewY = 0;

	/**
	 * A shadow object that defines the shadow to render on this display object. Set to `null` to remove a shadow. If
	 * null, this property is inherited from the parent container.
	 * @property shadow
	 * @type {Shadow}
	 * @default null
	 **/
	p.shadow = null;

	/**
	 * Indicates whether this display object should be rendered to the canvas and included when running the Stage
	 * {{#crossLink "Stage/getObjectsUnderPoint"}}{{/crossLink}} method.
	 * @property visible
	 * @type {Boolean}
	 * @default true
	 **/
	p.visible = true;

	/**
	 * The x (horizontal) position of the display object, relative to its parent.
	 * @property x
	 * @type {Number}
	 * @default 0
	 **/
	p.x = 0;

	/** The y (vertical) position of the display object, relative to its parent.
	 * @property y
	 * @type {Number}
	 * @default 0
	 **/
	p.y = 0;

    /**
     * 记录rect信息，因为改变属性action无defID，无法从库中查找rect信息，因此在child中携带rect信息
     * @type {Rectangle}
     */
    p.rect = null;
    //记录初始化帧，如果是0，重播时child将重复使用
    p.initFrame = -1;

	/**
	 * The composite operation indicates how the pixels of this display object will be composited with the elements
	 * behind it. If `null`, this property is inherited from the parent container. For more information, read the
	 * <a href="http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#compositing">
	 * whatwg spec on compositing</a>.
	 * @property compositeOperation
	 * @type {String}
	 * @default null
	 **/
	p.compositeOperation = null;

	/**
	 * An array of Filter objects to apply to this display object. Filters are only applied / updated when {{#crossLink "cache"}}{{/crossLink}}
	 * or {{#crossLink "updateCache"}}{{/crossLink}} is called on the display object, and only apply to the area that is
	 * cached.
	 * @property filters
	 * @type {Array}
	 * @default null
	 **/
	p.filters = null;

    /**
     * A Shape instance that defines a vector mask (clipping path) for this display object.  The shape's transformation
     * will be applied relative to the display object's parent coordinates (as if it were a child of the parent).
     * @property mask
     * @type {Shape}
     * @default null
     */
    p.mask = null;

    /**
     * clipDepth, used in clipping. A mask DisplayObject's clipDepth > 0, others' clipDepth is 0
     * @type {int}
     */
    p.clipDepth = 0;

    /**
     * when displayObject is clipped, it has maskDepth > 0 and clipDepth == 0. MaskDepth of Mask < MaskDepth of Clipped < clipDepth of Mask
     * @type {int}
     */
    p.maskDepth = 0;
	

// private properties:

	/**
	 * @property _cacheOffsetX
	 * @protected
	 * @type {Number}
	 * @default 0
	 **/
	p._cacheOffsetX = 0;

	/**
	 * @property _cacheOffsetY
	 * @protected
	 * @type {Number}
	 * @default 0
	 **/
	p._cacheOffsetY = 0;
	
	/**
	 * @property _cacheScale
	 * @protected
	 * @type {Number}
	 * @default 1
	 **/
	p._cacheScale = 1;

	/**
	 * @property _matrix
	 * @protected
	 * @type {Matrix2D}
	 * @default null
	 **/
	p._matrix = null;

    /**
     * save the global matrix info to speed up dirty rect calculation
     * @type {Matrix2D}
     */
    p.globalMatrix = null;

    /**
     * cache the dirty rect of the last frame
     * @type {Rectangle}
     */
    p.dirtyRect = null;


// constructor:
	// separated so it can be easily addressed in subclasses:

	/**
	 * Initialization method.
	 * @method initialize
	 * @protected
	*/
	p.initialize = function() {
		this._matrix = new fanvas.Matrix2D();
        this.globalMatrix = new fanvas.Matrix2D();
	};

// public methods:
	/**
	 * Returns true or false indicating whether the display object would be visible if drawn to a canvas.
	 * This does not account for whether it would be visible within the boundaries of the stage.
	 *
	 * NOTE: This method is mainly for internal use, though it may be useful for advanced uses.
	 * @method isVisible
	 * @return {Boolean} Boolean indicating whether the display object would be visible if drawn to a canvas
	 **/
	p.isVisible = function() {
		return !!(this.visible && this.alpha > 0 && this.scaleX != 0 && this.scaleY != 0 && !this.clipDepth);
	};

	/**
	 * Draws the display object into the specified context ignoring its visible, alpha, shadow, and transform.
	 * Returns <code>true</code> if the draw was handled (useful for overriding functionality).
     * Draw method of DisplayObject is used to handle cache.
	 *
	 * NOTE: This method is mainly for internal use, though it may be useful for advanced uses.
	 * @method drawFromCache
     * @param {CanvasRenderingContext2D} ctx The canvas 2D context object to draw into.
	 * @return {Boolean}
	 **/
	p.drawFromCache = function(ctx) {
		var cacheCanvas = this.cacheCanvas;
		if (!cacheCanvas) { return false; }
		var scale = this._cacheScale, offX = this._cacheOffsetX, offY = this._cacheOffsetY, fBounds;
		if (fBounds = this._applyFilterBounds(offX, offY, 0, 0)) {
			offX = fBounds.x;
			offY = fBounds.y;
		}
		ctx.drawImage(cacheCanvas, offX, offY, cacheCanvas.width/scale, cacheCanvas.height/scale);
		return true;
	};

    p.update = function () {
    };

    /**
     * update dirty rect
     */
    p.calculateDirtyRect = function () {
        var o = this;
        if(o.parent){
            o.globalMatrix = new fanvas.Matrix2D();
            o.globalMatrix.appendTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation, o.skewX, o.skewY, o.regX, o.regY).prependMatrix(o.parent.globalMatrix);
        }
        var rect = o.rect;
        var filterRect = o._applyFilterBounds(rect.x, rect.y, rect.width, rect.height);
        this.dirtyRect = o._transformBounds(filterRect || rect, o.globalMatrix);
        return this.dirtyRect;
    };

	/**
	 * Applies this display object's transformation, alpha, globalCompositeOperation, clipping path (mask), and shadow
	 * to the specified context. This is typically called prior to {{#crossLink "DisplayObject/draw"}}{{/crossLink}}.
	 * @method presetContext
	 * @param {CanvasRenderingContext2D} ctx The canvas 2D to update.
	 **/
	p.presetContext = function(ctx) {
		var mtx, mask=this.mask, o=this;
		
		if (mask && mask.graphics && !mask.graphics.isEmpty()) {
			mtx = mask.getMatrix(mask._matrix);
			ctx.transform(mtx.a,  mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
			
			mask.graphics.drawAsPath(ctx);
			ctx.clip();
			
			mtx.invert();
			ctx.transform(mtx.a, mtx.b, mtx.c, mtx.d, mtx.tx, mtx.ty);
		}

		mtx = o._matrix.identity().appendTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation, o.skewX, o.skewY, o.regX, o.regY);
		var tx = Math.round(mtx.tx), ty = Math.round(mtx.ty);
//        tx = tx + (tx < 0 ? -0.5 : 0.5) | 0;    //|0 is the same as int(Number);
//        ty = ty + (ty < 0 ? -0.5 : 0.5) | 0;
		ctx.transform(mtx.a, mtx.b, mtx.c, mtx.d, tx, ty);
		ctx.globalAlpha *= o.alpha;
		if (o.compositeOperation) { ctx.globalCompositeOperation = o.compositeOperation; }
		if (o.shadow) { this._applyShadow(ctx, o.shadow); }
	};

	/**
	 * Draws the display object into a new canvas, which is then used for subsequent draws. For complex content
	 * that does not change frequently (ex. a Container with many children that do not move, or a complex vector Shape),
	 * this can provide for much faster rendering because the content does not need to be re-rendered each tick. The
	 * cached display object can be moved, rotated, faded, etc freely, however if its content changes, you must
	 * manually update the cache by calling <code>updateCache()</code> or <code>cache()</code> again. You must specify
	 * the cache area via the x, y, w, and h parameters. This defines the rectangle that will be rendered and cached
	 * using this display object's coordinates.
	 *
	 * Note that filters need to be defined <em>before</em> the cache is applied. Check out the {{#crossLink "Filter"}}{{/crossLink}}
	 * class for more information. Some filters (ex. BlurFilter) will not work as expected in conjunction with the scale param.
	 * 
	 * Usually, the resulting cacheCanvas will have the dimensions width*scale by height*scale, however some filters (ex. BlurFilter)
	 * will add padding to the canvas dimensions.
	 *
	 * @method cache
	 * @param {Number} x The x coordinate origin for the cache region.
	 * @param {Number} y The y coordinate origin for the cache region.
	 * @param {Number} width The width of the cache region.
	 * @param {Number} height The height of the cache region.
	 * @param {Number} [scale=1] The scale at which the cache will be created. For example, if you cache a vector shape using
	 * 	myShape.cache(0,0,100,100,2) then the resulting cacheCanvas will be 200x200 px. This lets you scale and rotate
	 * 	cached elements with greater fidelity. Default is 1.
	 **/
	p.cache = function(x, y, width, height, scale) {
		// draw to canvas.
		scale = scale||1;
		if (!this.cacheCanvas) { this.cacheCanvas = document.createElement("canvas");}
		this._cacheWidth = width;
		this._cacheHeight = height;
		this._cacheOffsetX = x;
		this._cacheOffsetY = y;
		this._cacheScale = scale;
		this.updateCache();
	};

	/**
	 * Redraws the display object to its cache. Calling updateCache without an active cache will throw an error.
	 * If compositeOperation is null the current cache will be cleared prior to drawing. Otherwise the display object
	 * will be drawn over the existing cache using the specified compositeOperation.
	 *
	 * @method updateCache
	 * @param {String} compositeOperation The compositeOperation to use, or null to clear the cache and redraw it.
	 * <a href="http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#compositing">
	 * whatwg spec on compositing</a>.
	 **/
	p.updateCache = function(compositeOperation) {
		var cacheCanvas = this.cacheCanvas, scale = this._cacheScale, offX = this._cacheOffsetX*scale, offY = this._cacheOffsetY*scale;
		var w = this._cacheWidth, h = this._cacheHeight, fBounds;
		if (!cacheCanvas) return;
		var ctx = cacheCanvas.getContext("2d");
		
		// update bounds based on filters:
		if (fBounds = this._applyFilterBounds(offX, offY, w, h)) {
			offX = fBounds.x;
			offY = fBounds.y;
			w = fBounds.width;
			h = fBounds.height;
		}

		w = Math.ceil(w*scale);
		h = Math.ceil(h*scale);
		if (w != cacheCanvas.width || h != cacheCanvas.height) {
			// TODO: it would be nice to preserve the content if there is a compositeOperation.
			cacheCanvas.width = w;
			cacheCanvas.height = h;
		} else if (!compositeOperation) {
			ctx.clearRect(0, 0, w+1, h+1);
		}
		
		ctx.save();
		ctx.globalCompositeOperation = compositeOperation;
		ctx.setTransform(scale, 0, 0, scale, -offX, -offY);
		this.draw(ctx, true);
		// TODO: filters and cache scale don't play well together at present.
		this._applyFilters();
		ctx.restore();
	};

    /**
     * Clears the current cache. When a displayObject loses all filters, call this method to clear cache.
     * See {{#crossLink "DisplayObject/cache"}}{{/crossLink}} for more information.
     * @method uncache
     **/
    p.uncache = function() {
        this.cacheCanvas = null;
        this._cacheOffsetX = this._cacheOffsetY = 0;
        this._cacheScale = 1;
    };

	/**
	 * Shortcut method to quickly set the transform properties on the display object. All parameters are optional.
	 * Omitted parameters will have the default value set.
	 *
	 * <h4>Example</h4>
	 *
	 *      displayObject.setTransform(100, 100, 2, 2);
	 *
	 * @method setTransform
	 * @param {Number} [x=0] The horizontal translation (x position) in pixels
	 * @param {Number} [y=0] The vertical translation (y position) in pixels
	 * @param {Number} [scaleX=1] The horizontal scale, as a percentage of 1
	 * @param {Number} [scaleY=1] the vertical scale, as a percentage of 1
	 * @param {Number} [rotation=0] The rotation, in degrees
	 * @param {Number} [skewX=0] The horizontal skew factor
	 * @param {Number} [skewY=0] The vertical skew factor
	 * @param {Number} [regX=0] The horizontal registration point in pixels
	 * @param {Number} [regY=0] The vertical registration point in pixels
	*/
	p.setTransform = function(x, y, scaleX, scaleY, rotation, skewX, skewY, regX, regY) {
		this.x = x || 0;
		this.y = y || 0;
        this.scaleX = (scaleX != 0 && !scaleX) ? 1 : scaleX;
		this.scaleY = (scaleY != 0 && !scaleY) ? 1 : scaleY;
		this.rotation = rotation || 0;
		this.skewX = skewX || 0;
		this.skewY = skewY || 0;
		this.regX = regX || 0;
		this.regY = regY || 0;
	};
	
	/**
	 * Returns a matrix based on this object's transform.
	 * @method getMatrix
	 * @param {Matrix2D} matrix Optional. A Matrix2D object to populate with the calculated values. If null, a new
	 * Matrix object is returned.
	 * @return {Matrix2D} A matrix representing this display object's transform.
	 **/
	p.getMatrix = function(matrix) {
		var o = this;
		return (matrix ? matrix.identity() : new fanvas.Matrix2D()).appendTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation, o.skewX, o.skewY, o.regX, o.regY).appendProperties(o.alpha, o.shadow, o.compositeOperation);
	};
	
	/**
	 * @method _applyShadow
	 * @protected
	 * @param {CanvasRenderingContext2D} ctx
	 * @param {Shadow} shadow
	 **/
	p._applyShadow = function(ctx, shadow) {
		shadow = shadow || Shadow.identity;
		ctx.shadowColor = shadow.color;
		ctx.shadowOffsetX = shadow.offsetX;
		ctx.shadowOffsetY = shadow.offsetY;
		ctx.shadowBlur = shadow.blur;
	};

	/**
	 * @method _applyFilters
	 * @protected
	 **/
	p._applyFilters = function() {
		if (!this.filters || this.filters.length == 0 || !this.cacheCanvas) { return; }
		var l = this.filters.length;
		var ctx = this.cacheCanvas.getContext("2d");
		var w = this.cacheCanvas.width;
		var h = this.cacheCanvas.height;
		for (var i=0; i<l; i++) {
			this.filters[i].applyFilter(ctx, 0, 0, w, h);
		}
	};
	
	/**
     * calculate the total width and height with all filter effects. ex, blurfilter will make the DisplayObject to be wider and higher.
	 * @method _applyFilterBounds
	 * @param {Number} x
	 * @param {Number} y
	 * @param {Number} width
	 * @param {Number} height
	 * @return {Rectangle}
	 * @protected
	 **/
	p._applyFilterBounds = function(x, y, width, height) {
		var bounds, l, filters = this.filters;
		if (!filters || !(l=filters.length)) { return null; }
		
		for (var i=0; i<l; i++) {
			var f = this.filters[i];
			var fBounds = f.getBounds&&f.getBounds();
			if (!fBounds) { continue; }
			if (!bounds) { bounds = new fanvas.Rectangle(x,y,width,height); }
			bounds.x += fBounds.x;
			bounds.y += fBounds.y;
			bounds.width += fBounds.width;
			bounds.height += fBounds.height;
		}
		return bounds;
	};


    /**
     * find out the new bounds after some matrix transformation
     * @param bounds
     * @param {Rectangle} bounds
     * @param {Matrix2D} matrix
     * @returns {fanvas.Rectangle}
     * @private
     */
    p._transformBounds = function(bounds, matrix) {
        var x = bounds.x, y = bounds.y, width = bounds.width, height = bounds.height;
        var mtx = new fanvas.Matrix2D();
        mtx.appendMatrix(matrix);
        if (x || y) { mtx.append(1,0,0,1,x,y); }

        var x_a = width*mtx.a, x_b = width*mtx.b;
        var y_c = height*mtx.c, y_d = height*mtx.d;
        var tx = mtx.tx, ty = mtx.ty;

        var minX = tx, maxX = tx, minY = ty, maxY = ty;

        if ((x = x_a + tx) < minX) { minX = x; } else if (x > maxX) { maxX = x; }
        if ((x = x_a + y_c + tx) < minX) { minX = x; } else if (x > maxX) { maxX = x; }
        if ((x = y_c + tx) < minX) { minX = x; } else if (x > maxX) { maxX = x; }

        if ((y = x_b + ty) < minY) { minY = y; } else if (y > maxY) { maxY = y; }
        if ((y = x_b + y_d + ty) < minY) { minY = y; } else if (y > maxY) { maxY = y; }
        if ((y = y_d + ty) < minY) { minY = y; } else if (y > maxY) { maxY = y; }

        return new fanvas.Rectangle(Math.round(minX), Math.round(minY), Math.round(maxX-minX), Math.round(maxY-minY));
    };
	

fanvas.DisplayObject = DisplayObject;
}());

// namespace:
this.fanvas = this.fanvas||{};

(function() {
	"use strict";

/**
* Inner class used by the {{#crossLink "Graphics"}}{{/crossLink}} class. Used to create the instruction lists used in Graphics:
* @class Command
* @protected
* @constructor
**/
function Command(f, params, isPath) {
	this.f = f;
	this.params = params;
    this.isPath = Boolean(isPath);
}

/**
* @method exec
* @protected
* @param {Object} scope
**/
Command.prototype.exec = function(scope) { this.f.apply(scope, this.params); };



var Graphics = function(imagePath) {
	this.initialize(imagePath);
};
var p = Graphics.prototype;


// static properties:

	/**
	 * Map of Base64 characters to values.
	 * @property BASE_64
	 * @static
	 * @final
	 * @readonly
	 * @type {Object}
	 **/
	Graphics.BASE_64 = {"A":0,"B":1,"C":2,"D":3,"E":4,"F":5,"G":6,"H":7,"I":8,"J":9,"K":10,"L":11,"M":12,"N":13,"O":14,"P":15,"Q":16,"R":17,"S":18,"T":19,"U":20,"V":21,"W":22,"X":23,"Y":24,"Z":25,"a":26,"b":27,"c":28,"d":29,"e":30,"f":31,"g":32,"h":33,"i":34,"j":35,"k":36,"l":37,"m":38,"n":39,"o":40,"p":41,"q":42,"r":43,"s":44,"t":45,"u":46,"v":47,"w":48,"x":49,"y":50,"z":51,"0":52,"1":53,"2":54,"3":55,"4":56,"5":57,"6":58,"7":59,"8":60,"9":61,"+":62,"/":63};

	var canvas = document.createElement("canvas");
	if (canvas.getContext) {
		var ctx = Graphics._ctx = canvas.getContext("2d");
		Graphics.beginCmd = new Command(ctx.beginPath, []);
		Graphics.fillCmd = new Command(ctx.fill, ["evenodd"]);  //chrome after 2013 support this param. ref: http://blogs.adobe.com/webplatform/2013/01/30/winding-rules-in-canvas/
        Graphics.strokeCmd = new Command(ctx.stroke, []);
		canvas.width = canvas.height = 1;
	}
	
// public properties

// private properties

    p._imagePath = null;

	/**
     * instruction about stroke
	 * @property _strokeInstructions
	 * @protected
	 * @type {Array}
	 **/
	p._strokeInstructions = null;

	/**
     * instruction about stroke style
	 * @property _strokeStyleInstructions
	 * @protected
	 * @type {Array}
	 **/
	p._strokeStyleInstructions = null;

	/**
     * instruction about fill
	 * @property _fillInstructions
	 * @protected
	 * @type {Array}
	 **/
	p._fillInstructions = null;

    /**
     * @property _strokeMatrix
     * @protected
     * @type {Array}
     **/
    p._fillMatrix = null;

	/**
     * before the real draw, this array appends all types of instructions and make them in the right order
	 * @property _instructions
	 * @protected
	 * @type {Array}
	 **/
	p._instructions = null;

	/**
     * store the instructions about path
	 * @property _activeInstructions
	 * @protected
	 * @type {Array}
	 **/
	p._activeInstructions = null;

	/**
     * active=true means now graphics is decoding path
	 * @property _active
	 * @protected
	 * @type {Boolean}
	 * @default false
	 **/
	p._active = false;

	/**
	 * @property _dirty
	 * @protected
	 * @type {Boolean}
	 * @default false
	 **/
	p._dirty = false;

	/**
	 * Initialization method.
	 * @method initialize
	 * @protected
	 **/
	p.initialize = function(imagePath) {
		this.clear();
		this._ctx = Graphics._ctx;
        this._imagePath = imagePath;
	};

	/**
	 * Returns true if this Graphics instance has no drawing commands. Used for <code>DisplayObject.mask</code>
	 * @method isEmpty
	 * @return {Boolean} Returns true if this Graphics instance has no drawing commands.
	 **/
	p.isEmpty = function() {
		return !(this._instructions.length || this._activeInstructions.length);
	};

	/**
	 * Draws the display object into the specified context ignoring its visible, alpha, shadow, and transform.
	 * Returns true if the draw was handled (useful for overriding functionality).
	 *
	 * @method draw
	 * @param {CanvasRenderingContext2D} ctx The canvas 2D context object to draw into.
	 **/
	p.draw = function(ctx) {
		if (this._dirty) { this._updateInstructions(); }
		var instr = this._instructions;
		for (var i=0, l=instr.length; i<l; i++) {
			instr[i].exec(ctx);
		}
	};

	/**
	 * Draws only the path described for this Graphics instance, skipping any non-path instructions, including fill and
	 * stroke descriptions. Used for <code>DisplayObject.mask</code> to draw the clipping path, for example.
	 * @method drawAsPath
	 * @param {CanvasRenderingContext2D} ctx The canvas 2D context object to draw into.
	 **/
	p.drawAsPath = function(ctx) {
		if (this._dirty) { this._updateInstructions(); }
		var instr, instrs = this._instructions;
		for (var i=0, l=instrs.length; i<l; i++) {
			// the first command is always a beginPath command.
			if ((instr = instrs[i]).isPath || i==0) { instr.exec(ctx); }
		}
	};

// public methods that map directly to context 2D calls:
	/**
	 * Moves the drawing point to the specified position. A tiny API method "mt" also exists.
	 * @method moveTo
	 * @param {Number} x The x coordinate the drawing point should move to.
	 * @param {Number} y The y coordinate the drawing point should move to.
	 **/
	p.moveTo = function(x, y) {
		this._activeInstructions.push(new Command(this._ctx.moveTo, [x, y], true));
	};

	/**
	 * Draws a line from the current drawing point to the specified position, which become the new current drawing
	 * point. A tiny API method "lt" also exists.
	 * @method lineTo
	 * @param {Number} x The x coordinate the drawing point should draw to.
	 * @param {Number} y The y coordinate the drawing point should draw to.
	 **/
	p.lineTo = function(x, y) {
		this._dirty = this._active = true;
		this._activeInstructions.push(new Command(this._ctx.lineTo, [x, y], true));
	};

	/**
	 * Draws a quadratic curve from the current drawing point to (x, y) using the control point (cpx, cpy).
     * curveTo = quadraticCurveTo
	 * @method curveTo = quadraticCurveTo
	 * @param {Number} cpx
	 * @param {Number} cpy
	 * @param {Number} x
	 * @param {Number} y
	 **/
	p.quadraticCurveTo = function(cpx, cpy, x, y) {
		this._dirty = this._active = true;
		this._activeInstructions.push(new Command(this._ctx.quadraticCurveTo, [cpx, cpy, x, y], true));
	};

	/**
	 * Draws a bezier curve from the current drawing point to (x, y) using the control points (cp1x, cp1y) and (cp2x,
	 * cp2y). For detailed information, read the
	 * @method bezierCurveTo
	 * @param {Number} cp1x
	 * @param {Number} cp1y
	 * @param {Number} cp2x
	 * @param {Number} cp2y
	 * @param {Number} x
	 * @param {Number} y
	 **/
	p.bezierCurveTo = function(cp1x, cp1y, cp2x, cp2y, x, y) {
		this._dirty = this._active = true;
		this._activeInstructions.push(new Command(this._ctx.bezierCurveTo, [cp1x, cp1y, cp2x, cp2y, x, y], true));
	};

	/**
	 * Closes the current path, effectively drawing a line from the current drawing point to the first drawing point specified
	 * since the fill or stroke was last set. A tiny API method "cp" also exists.
	 * @method closePath
	 **/
	p.closePath = function() {
		if (this._active) {
			this._dirty = true;
			this._activeInstructions.push(new Command(this._ctx.closePath, [], true));
		}
	};


// public methods that roughly map to Flash graphics APIs:
	/**
	 * Clears all drawing instructions, effectively resetting this Graphics instance. Any line and fill styles will need
	 * to be redefined to draw shapes following a clear call. A tiny API method "c" also exists.
	 * @method clear
	 **/
	p.clear = function() {
		this._instructions = [];
		this._activeInstructions = [];
		this._strokeStyleInstructions = this._strokeInstructions = this._fillInstructions = this._fillMatrix = null;
		this._active = this._dirty = false;
	};

	/**
	 * Begins a fill with the specified color. This ends the current sub-path. A tiny API method "f" also exists.
	 * @method beginFill
	 * @param {String} color A CSS compatible color value (ex. "red", "#FF0000", or "rgba(255,0,0,0.5)"). Setting to
	 * null will result in no fill.
	 **/
	p.beginFill = function(color) {
		if (this._active) { this._newPath(); }
		this._fillInstructions = color ? [new Command(this._setProp, ["fillStyle", color])] : null;
        this._fillMatrix = null;
	};

	/**
	 * Begins a linear gradient fill defined by the line (x0, y0) to (x1, y1). This ends the current sub-path. For
	 * example, the following code defines a black to white vertical gradient ranging from 20px to 120px, and draws a
	 * square to display it:
	 *
	 *      myGraphics.beginLinearGradientFill(["#000","#FFF"], [0, 1], 0, 20, 0, 120);
     *      myGraphics.drawRect(20, 20, 120, 120);
	 *
	 * A tiny API method "lf" also exists.
	 * @method beginLinearGradientFill
	 * @param {Array} colors An array of CSS compatible color values. For example, ["#F00","#00F"] would define a gradient
	 * drawing from red to blue.
	 * @param {Array} ratios An array of gradient positions which correspond to the colors. For example, [0.1, 0.9] would draw
	 * the first color to 10% then interpolating to the second color at 90%.
	 * @param {Number} x0 The position of the first point defining the line that defines the gradient direction and size.
	 * @param {Number} y0 The position of the first point defining the line that defines the gradient direction and size.
	 * @param {Number} x1 The position of the second point defining the line that defines the gradient direction and size.
	 * @param {Number} y1 The position of the second point defining the line that defines the gradient direction and size.
	 **/
	p.beginLinearGradientFill = function(colors, ratios, x0, y0, x1, y1) {
		if (this._active) { this._newPath(); }
		var o = this._ctx.createLinearGradient(x0, y0, x1, y1);
		for (var i=0, l=colors.length; i<l; i++) {
			o.addColorStop(ratios[i], colors[i]);
		}
		this._fillInstructions = [new Command(this._setProp, ["fillStyle", o])];
        this._fillMatrix = null;
	};

	/**
	 * Begins a radial gradient fill. This ends the current sub-path. For example, the following code defines a red to
	 * blue radial gradient centered at (100, 100), with a radius of 50, and draws a circle to display it:
	 *
	 *      myGraphics.beginRadialGradientFill(["#F00","#00F"], [0, 1], 100, 100, 0, 100, 100, 50);
     *      myGraphics.drawCircle(100, 100, 50);
	 *
	 * A tiny API method "rf" also exists.
	 * @method beginRadialGradientFill
	 * @param {Array} colors An array of CSS compatible color values. For example, ["#F00","#00F"] would define
	 * a gradient drawing from red to blue.
	 * @param {Array} ratios An array of gradient positions which correspond to the colors. For example, [0.1,
	 * 0.9] would draw the first color to 10% then interpolating to the second color at 90%.
	 * @param {Number} x0 Center position of the inner circle that defines the gradient.
	 * @param {Number} y0 Center position of the inner circle that defines the gradient.
	 * @param {Number} r0 Radius of the inner circle that defines the gradient.
	 * @param {Number} x1 Center position of the outer circle that defines the gradient.
	 * @param {Number} y1 Center position of the outer circle that defines the gradient.
	 * @param {Number} r1 Radius of the outer circle that defines the gradient.
	 **/
	p.beginRadialGradientFill = function(colors, ratios, x0, y0, r0, x1, y1, r1) {
		if (this._active) { this._newPath(); }
		var o = this._ctx.createRadialGradient(x0, y0, r0, x1, y1, r1);
		for (var i=0, l=colors.length; i<l; i++) {
			o.addColorStop(ratios[i], colors[i]);
		}
		this._fillInstructions = [new Command(this._setProp, ["fillStyle", o])];
        this._fillMatrix = null;
	};

    /**
     * Begins a pattern fill using the specified image. This ends the current sub-path. A tiny API method "bf" also
     * exists.
     * @method beginBitmapFill
     * @param {String} imageName file name
     * @param {Matrix2D} matrix . Specifies a transformation matrix for the bitmap fill. This transformation
     * will be applied relative to the parent transform.
     **/
    p.beginBitmapFill = function(imageName, matrix) {
        if (this._active) { this._newPath(); }
        var image = fanvas.imageList[this._imagePath + imageName];
        var o = this._ctx.createPattern(image, "");
        this._fillInstructions = [new Command(this._setProp, ["fillStyle", o], false)];
        this._fillMatrix = matrix;
    };

	/**
	 * Ends the current sub-path, and begins a new one with no fill. Functionally identical to <code>beginFill(null)</code>.
	 * A tiny API method "ef" also exists.
	 * @method endFill
	 **/
	p.endFill = function() {
		this.beginFill();
	};

	/**
	 * Sets the stroke style for the current sub-path. Like all drawing methods, this can be chained, so you can define
	 * the stroke style and color in a single line of code like so:
	 *
	 *      myGraphics.setStrokeStyle(8,"round");
     *      myGraphics.beginStroke("#F00");
	 *
	 * A tiny API method "ss" also exists.
	 * @method setStrokeStyle
	 * @param {Number} thickness The width of the stroke.
	 * @param {String} caps Defaults to "butt". Also accepts the values (butt), (round), and (square) for use with
	 * the tiny API.
	 * @param {String} joints Specifies the type of joints that should be used where two lines meet.
	 * One of bevel, round, or miter. Defaults to "miter". Also accepts the values (miter), (round), and (bevel)
	 * for use with the tiny API.
	 * @param {Number} [miterLimit=10] If joints is set to "miter", then you can specify a miter limit ratio which
	 * controls at what point a mitered joint will be clipped.
	 **/
	p.setStrokeStyle = function(thickness, caps, joints, miterLimit) {
		if (this._active) { this._newPath(); }
		this._strokeStyleInstructions = [
			new Command(this._setProp, ["lineWidth", (thickness == null ? "1" : thickness)]),
			new Command(this._setProp, ["lineCap", (caps == null ? "butt" : caps)]),
			new Command(this._setProp, ["lineJoin", (joints == null ? "miter" : joints)]),
			new Command(this._setProp, ["miterLimit", (miterLimit == null ? "10" : miterLimit)])
			];
		return this;
	};

	/**
	 * Begins a stroke with the specified color. This ends the current sub-path. A tiny API method "s" also exists.
	 * @method beginStroke
	 * @param {String} color A CSS compatible color value (ex. "#FF0000", "red", or "rgba(255,0,0,0.5)"). Setting to
	 * null will result in no stroke.
	 **/
	p.beginStroke = function(color) {
		if (this._active) { this._newPath(); }
		this._strokeInstructions = color ? [new Command(this._setProp, ["strokeStyle", color])] : null;
	};

	/**
	 * Begins a linear gradient stroke defined by the line (x0, y0) to (x1, y1). This ends the current sub-path. For
	 * example, the following code defines a black to white vertical gradient ranging from 20px to 120px, and draws a
	 * square to display it:
	 *
	 *      myGraphics.setStrokeStyle(10);
	 *      myGraphics.beginLinearGradientStroke(["#000","#FFF"], [0, 1], 0, 20, 0, 120);
     *      myGraphics.drawRect(20, 20, 120, 120);
	 *
	 * A tiny API method "ls" also exists.
	 * @method beginLinearGradientStroke
	 * @param {Array} colors An array of CSS compatible color values. For example, ["#F00","#00F"] would define
	 * a gradient drawing from red to blue.
	 * @param {Array} ratios An array of gradient positions which correspond to the colors. For example, [0.1,
	 * 0.9] would draw the first color to 10% then interpolating to the second color at 90%.
	 * @param {Number} x0 The position of the first point defining the line that defines the gradient direction and size.
	 * @param {Number} y0 The position of the first point defining the line that defines the gradient direction and size.
	 * @param {Number} x1 The position of the second point defining the line that defines the gradient direction and size.
	 * @param {Number} y1 The position of the second point defining the line that defines the gradient direction and size.
	 **/
	p.beginLinearGradientStroke = function(colors, ratios, x0, y0, x1, y1) {
		if (this._active) { this._newPath(); }
		var o = this._ctx.createLinearGradient(x0, y0, x1, y1);
		for (var i=0, l=colors.length; i<l; i++) {
			o.addColorStop(ratios[i], colors[i]);
		}
		this._strokeInstructions = [new Command(this._setProp, ["strokeStyle", o])];
	};


	/**
	 * Begins a radial gradient stroke. This ends the current sub-path. For example, the following code defines a red to
	 * blue radial gradient centered at (100, 100), with a radius of 50, and draws a rectangle to display it:
	 *
	 *      myGraphics.setStrokeStyle(10);
	 *      myGraphics.beginRadialGradientStroke(["#F00","#00F"], [0, 1], 100, 100, 0, 100, 100, 50);
	 *      myGraphics.drawRect(50, 90, 150, 110);
	 *
	 * A tiny API method "rs" also exists.
	 * @method beginRadialGradientStroke
	 * @param {Array} colors An array of CSS compatible color values. For example, ["#F00","#00F"] would define
	 * a gradient drawing from red to blue.
	 * @param {Array} ratios An array of gradient positions which correspond to the colors. For example, [0.1,
	 * 0.9] would draw the first color to 10% then interpolating to the second color at 90%, then draw the second color
	 * to 100%.
	 * @param {Number} x0 Center position of the inner circle that defines the gradient.
	 * @param {Number} y0 Center position of the inner circle that defines the gradient.
	 * @param {Number} r0 Radius of the inner circle that defines the gradient.
	 * @param {Number} x1 Center position of the outer circle that defines the gradient.
	 * @param {Number} y1 Center position of the outer circle that defines the gradient.
	 * @param {Number} r1 Radius of the outer circle that defines the gradient.
	 **/
	p.beginRadialGradientStroke = function(colors, ratios, x0, y0, r0, x1, y1, r1) {
		if (this._active) { this._newPath(); }
		var o = this._ctx.createRadialGradient(x0, y0, r0, x1, y1, r1);
		for (var i=0, l=colors.length; i<l; i++) {
			o.addColorStop(ratios[i], colors[i]);
		}
		this._strokeInstructions = [new Command(this._setProp, ["strokeStyle", o])];
	};

	/**
	 * Ends the current sub-path, and begins a new one with no stroke. Functionally identical to <code>beginStroke(null)</code>.
	 * A tiny API method "es" also exists.
	 * @method endStroke
	 **/
	p.endStroke = function() {
		this.beginStroke();
	};

	/**
	 * Decodes a compact encoded path string into a series of draw instructions.
	 * This format is not intended to be human readable, and is meant for use by authoring tools.
	 * The format uses a base64 character set, with each character representing 6 bits, to define a series of draw
	 * commands.
	 *
	 * Each command is comprised of a single "header" character followed by a variable number of alternating x and y
	 * position values. Reading the header bits from left to right (most to least significant): bits 1 to 3 specify the
	 * type of operation (0-moveTo, 1-lineTo, 2-quadraticCurveTo, 3-bezierCurveTo, 4-closePath, 5-7 unused). Bit 4
	 * indicates whether position values use 12 bits (2 characters) or 18 bits (3 characters), with a one indicating the
	 * latter. Bits 5 and 6 are currently unused.
	 *
	 * Following the header is a series of 0 (closePath), 2 (moveTo, lineTo), 4 (quadraticCurveTo), or 6 (bezierCurveTo)
	 * parameters. These parameters are alternating x/y positions represented by 2 or 3 characters (as indicated by the
	 * 4th bit in the command char). These characters consist of a 1 bit sign (1 is negative, 0 is positive), followed
	 * by an 11 (2 char) or 17 (3 char) bit integer value. All position values are in tenths of a pixel. Except in the
	 * case of move operations which are absolute, this value is a delta from the previous x or y position (as
	 * appropriate).
	 *
	 * For example, the string "An0AAIAu4AAA" represents a line starting at -150,0 and ending at 150,0.
	 * <br />A - bits 000000. First 3 bits (000) indicate a moveTo operation. 4th bit (0) indicates 2 chars per
	 * parameter.
	 * <br />n0 - 110111011100. Absolute x position of -150.0px. First bit indicates a negative value, remaining bits
	 * indicate 1500 tenths of a pixel.
	 * <br />AA - 000000000000. Absolute y position of 0.
	 * <br />I - 001100. First 3 bits (001) indicate a lineTo operation. 4th bit (1) indicates 3 chars per parameter.
	 * <br />Au4 - 000000101110111000. An x delta of 300.0px, which is added to the previous x value of -150.0px to
	 * provide an absolute position of +150.0px.
	 * <br />AAA - 000000000000000000. A y delta value of 0.
	 *
	 * A tiny API method "p" also exists.
	 * @method decodePath
	 * @param {String} str The path string to decode.
	 **/
	p.decodePath = function(str) {
		var instructions = [this.moveTo, this.lineTo, this.quadraticCurveTo, this.bezierCurveTo, this.closePath];
		var paramCount = [2, 2, 4, 6, 0];
		var i=0, l=str.length;
		var params = [];
		var x=0, y=0;
		var base64 = Graphics.BASE_64;

		while (i<l) {
			var c = str.charAt(i);
			var n = base64[c];
			var fi = n>>3; // highest order bits 1-3 code for operation.
			var f = instructions[fi];
			// check that we have a valid instruction & that the unused bits are empty:
			if (!f || (n&3)) { throw("bad path data (@"+i+"): "+c); }
			var pl = paramCount[fi];
			if (!fi) { x=y=0; } // move operations reset the position.
			params.length = 0;
			i++;
			var charCount = (n>>2&1)+2;  // 4th header bit indicates number size for this operation.
			for (var p=0; p<pl; p++) {
				var num = base64[str.charAt(i)];
				var sign = (num>>5) ? -1 : 1;
				num = ((num&31)<<6)|(base64[str.charAt(i+1)]);
				if (charCount == 3) { num = (num<<6)|(base64[str.charAt(i+2)]); }
				num = sign*num/10;
				if (p%2) { x = (num += x); }
				else { y = (num += y); }
				params[p] = num;
				i += charCount;
			}
			f.apply(this,params);
		}
	};

// tiny API:

	/** Shortcut to clear.
	 * @method c
	 * @protected
	 * @type {Function}
	 **/
	p.c = p.clear;

	/** Shortcut to beginFill.
	 * @method f
	 * @protected
	 * @type {Function}
	 **/
	p.f = p.beginFill;

	/** Shortcut to beginLinearGradientFill.
	 * @method lf
	 * @protected
	 * @type {Function}
	 **/
	p.lf = p.beginLinearGradientFill;

	/** Shortcut to beginRadialGradientFill.
	 * @method rf
	 * @protected
	 * @type {Function}
	 **/
	p.rf = p.beginRadialGradientFill;

    /** Shortcut to beginBitmapFill.
     * @method bf
     * @protected
     * @type {Function}
     **/
    p.bf = p.beginBitmapFill;

	/** Shortcut to endFill.
	 * @method ef
	 * @protected
	 * @type {Function}
	 **/
	p.ef = p.endFill;

	/** Shortcut to setStrokeStyle.
	 * @method ss
	 * @protected
	 * @type {Function}
	 **/
	p.ss = p.setStrokeStyle;

	/** Shortcut to beginStroke.
	 * @method s
	 * @protected
	 * @type {Function}
	 **/
	p.s = p.beginStroke;

	/** Shortcut to beginLinearGradientStroke.
	 * @method ls
	 * @protected
	 * @type {Function}
	 **/
	p.ls = p.beginLinearGradientStroke;

	/** Shortcut to beginRadialGradientStroke.
	 * @method rs
	 * @protected
	 * @type {Function}
	 **/
	p.rs = p.beginRadialGradientStroke;

	/** Shortcut to endStroke.
	 * @method es
	 * @protected
	 * @type {Function}
	 **/
	p.es = p.endStroke;

	/** Shortcut to decodePath.
	 * @method p
	 * @protected
	 * @type Function
	 **/
	p.p = p.decodePath;


// private methods:
	/**
     * every time create a new path or end path, this function will be called to deal with the last path instructions
	 * @method _updateInstructions
	 * @protected
	 **/
	p._updateInstructions = function() {
		this._instructions.push(Graphics.beginCmd);

		this._appendInstructions(this._fillInstructions);
        if(this._strokeInstructions) {
            this._appendInstructions(this._strokeInstructions);
            this._appendInstructions(this._strokeStyleInstructions);
        }

		this._appendInstructions(this._activeInstructions);

        if (this._fillInstructions) {
            this._appendDraw(Graphics.fillCmd, this._fillMatrix);
		}
		if (this._strokeInstructions) {
            this._instructions.push(Graphics.strokeCmd);
		}
	};

	/**
	 * @method _appendInstructions
	 * @protected
	 **/
	p._appendInstructions = function(instructions) {
		if (instructions) { this._instructions.push.apply(this._instructions, instructions); }
	};

    /**
     * @method _appendDraw
     * @protected
     **/
    p._appendDraw = function(command, matrixArr) {
        if (!matrixArr) { this._instructions.push(command); }
        else {
            this._instructions.push(
                new Command(this._ctx.save, [], false),
                new Command(this._ctx.transform, matrixArr, false),
                command,
                new Command(this._ctx.restore, [], false)
            );
        }
    };

	/**
     * every time create a path or end path, this function will be called
	 * @method _newPath
	 * @protected
	 **/
	p._newPath = function() {
		if (this._dirty) { this._updateInstructions(); }
		this._activeInstructions = [];
		this._active = this._dirty = false;
	};

	/**
	 * Used to create Commands that set properties
	 * @method _setProp
	 * @param {String} name
	 * @param {String} value
	 * @protected
	 **/
	p._setProp = function(name, value) {
		this[name] = value;
	};

fanvas.Graphics = Graphics;
}());

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

// namespace:
this.fanvas = this.fanvas||{};

(function() {

/**
 * A Container is a nestable display list that allows you to work with compound display elements. For  example you could
 * group arm, leg, torso and head {{#crossLink "Bitmap"}}{{/crossLink}} instances together into a Person Container, and
 * transform them as a group, while still being able to move the individual parts relative to each other. Children of
 * containers have their <code>transform</code> and <code>alpha</code> properties concatenated with their parent
 * Container.
 *
 *
 * @class Container
 * @extends DisplayObject
 * @constructor
 **/
var Container = function() {
  this.initialize();
};
var p = Container.prototype = new fanvas.DisplayObject();

// public properties:
	/**
	 * The array of children in the display list. You should usually use the child management methods such as
	 * {{#crossLink "Container/addChild"}}{{/crossLink}}, {{#crossLink "Container/removeChild"}}{{/crossLink}},
	 * {{#crossLink "Container/swapChildren"}}{{/crossLink}}, etc, rather than accessing this directly, but it is
	 * included for advanced uses.
	 * @property children
	 * @type Array
	 * @default null
	 **/
	p.children = null;
	

// constructor:

	/**
	 * @property DisplayObject_initialize
	 * @type Function
	 * @private
	 **/
	p.DisplayObject_initialize = p.initialize;

	/**
	 * Initialization method.
	 * @method initialize
	 * @protected
	*/
	p.initialize = function() {
		this.DisplayObject_initialize();
		this.children = [];
	};


// public methods:

	/**
	 * @property DisplayObject_draw
	 * @type Function
	 * @private
	 **/
    p.DisplayObject_draw = p.draw;
    p.DisplayObject_update = p.update;

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
		
		// this ensures we don't have issues with display list changes that occur during a draw:
		var list = this.children.slice(0);
		for (var i=0,l=list.length; i<l; i++) {
			var child = list[i];
			if (!child.isVisible()) { continue; }
			
			// draw the child:
			ctx.save();
            child.presetContext(ctx);
			child.draw(ctx, isCacheCanvas);
			ctx.restore();
		}
		return true;
	};

    p.update = function(){
        this.DisplayObject_update();
        var list = this.children.slice(0);
        for (var i=0,l=list.length; i<l; i++) {
            list[i].update();
        }
    };
	
	/**
	 * Adds a child to the top of the display list.
	 *
	 * <h4>Example</h4>
	 *
	 *      container.addChild(bitmapInstance);
	 *
	 * @method addChild
	 * @param {DisplayObject} child The display object to add.
	 **/
	p.addChild = function(child) {
		this.addChildAt(child, this.children.length);
	};

	/**
	 * Adds a child to the display list at the specified index, bumping children at equal or greater indexes up one, and
	 * setting its parent to this Container.
	 *
	 * <h4>Example</h4>
	 *
	 *      addChildAt(child1, index);
	 *
	 *
	 * The index must be between 0 and numChildren. For example, to add myShape under otherShape in the display list,
	 * you could use:
	 *
	 *      container.addChildAt(myShape, container.getChildIndex(otherShape));
	 *
	 * This would also bump otherShape's index up by one. Fails silently if the index is out of range.
	 *
	 * @method addChildAt
	 * @param {DisplayObject} child The display object to add.
	 * @param {Number} index The index to add the child at.
	 **/
	p.addChildAt = function(child, index) {
		if (index < 0 || index > this.children.length || child == null) { return; }
		if (child.parent) { child.parent.removeChild(child); }
		child.parent = this;
        child.root = this.root;
		this.children.splice(index, 0, child);
	};

	/**
	 * Removes the specified child from the display list. Note that it is faster to use removeChildAt() if the index is
	 * already known.
	 *
	 * <h4>Example</h4>
	 *
	 *      container.removeChild(child);
	 *
	 * Returns true if the child (or children) was removed, or false if it was not in the display list.
	 * @method removeChild
	 * @param {DisplayObject} child The child to remove.
	 **/
	p.removeChild = function(child) {
		return this.removeChildAt(fanvas.indexOf(this.children, child));
	};

	/**
	 * Removes the child at the specified index from the display list, and sets its parent to null.
	 *
	 * <h4>Example</h4>
	 *
	 *      container.removeChildAt(2);
	 *
	 * Returns true if the child (or children) was removed, or false if any index was out of range.
	 * @method removeChildAt
	 * @param {Number} index The index of the child to remove.
	 **/
	p.removeChildAt = function(index) {
		if (index < 0 || index > this.children.length-1) { return; }
		var child = this.children[index];
		if (child) { child.parent = null; child.uncache();}     //及时uncache，如果child做了cache，这样就能及时释放cache canvas，否则浏览器的GC有点问题
		this.children.splice(index, 1);
	};

	/**
	 * Removes all children from the display list.
	 *
	 * <h4>Example</h4>
	 *
	 *      container.removeAlLChildren();
	 *
	 * @method removeAllChildren
	 **/
	p.removeAllChildren = function() {
		var kids = this.children;
		while (kids.length) { kids.pop().parent = null; }
	};

	/**
	 * Returns the child at the specified index.
	 *
	 * <h4>Example</h4>
	 *
	 *      container.getChildAt(2);
	 *
	 * @method getChildAt
	 * @param {Number} index The index of the child to return.
	 * @return {DisplayObject} The child at the specified index. Returns null if there is no child at the index.
	 **/
	p.getChildAt = function(index) {
		return this.children[index];
	};
	
	/**
	 * Returns the child with the specified name.
	 * @method getChildByName
	 * @param {String} name The name of the child to return.
	 * @return {DisplayObject} The child with the specified name.
	 **/
	p.getChildByName = function(name) {
		var kids = this.children;
		for (var i=0,l=kids.length;i<l;i++) {
			if(kids[i].name == name) { return kids[i]; }
		}
		return null;
	};

	/**
	 * Returns the index of the specified child in the display list, or -1 if it is not in the display list.
	 *
	 * <h4>Example</h4>
	 *
	 *      var index = container.getChildIndex(child);
	 *
	 * @method getChildIndex
	 * @param {DisplayObject} child The child to return the index of.
	 * @return {Number} The index of the specified child. -1 if the child is not found.
	 **/
	p.getChildIndex = function(child) {
		return fanvas.indexOf(this.children, child);
	};

	/**
	 * Returns the number of children in the display list.
	 * @method getNumChildren
	 * @return {Number} The number of children in the display list.
	 **/
	p.getNumChildren = function() {
		return this.children.length;
	};
	
	/**
	 * Returns true if the specified display object either is this container or is a descendent (child, grandchild, etc)
	 * of this container.
	 * @method contains
	 * @param {DisplayObject} child The DisplayObject to be checked.
	 * @return {Boolean} true if the specified display object either is this container or is a descendent.
	 **/
	p.contains = function(child) {
		while (child) {
			if (child == this) { return true; }
			child = child.parent;
		}
		return false;
	};


fanvas.Container = Container;
}());// namespace:
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
        if (instanceData.filters && instanceData.filters.length > 0 && child.rect.width && child.rect.height) {
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
        this._prebuildShapes(swfData.definitionPool);

        var mainMC = new fanvas.MovieClip(swfData.definitionPool, 0, config);
        config.scale && (mainMC.scaleX = mainMC.scaleY = config.scale);
        canvas.width = swfData.stageWidth*mainMC.scaleX;
        canvas.height = swfData.stageHeight*mainMC.scaleY;
        this.dirtyThresholdArea = canvas.width * canvas.height * 2 / 3;
        mainMC.globalMatrix = mainMC.getMatrix();       //use in dirty rect redrawing
        this.addChild(mainMC);
        config.showFPS && (this.stats = new fanvas.Stats(this.canvas.getContext("2d")));
	};

// public methods:

	/**
	 * update method used to be Timer onFrame callback
	 *
	 * @method update
     * @param delta 毫秒
     * @param noDraw 只形变，不实际绘制，gotoAndStop时使用
     */
	p.update = function(delta, noDraw) {
		if (!this.canvas) { return; }

        var mc = this.getChildAt(0);
        var dirtyRectList = this.dirtyRectList = [];
        mc.update();    //push the main MC to go forward, and calculate a new dirtyRect list

        if(noDraw){
            return;
        }

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
        this.config.scale && (mainMC.scaleX = mainMC.scaleY = this.config.scale);
        mainMC.globalMatrix = mainMC.getMatrix();       //use in dirty rect redrawing
    };

fanvas.Stage = Stage;
}());

// namespace:
this.fanvas = this.fanvas||{};

(function() {
	"use strict";

/**
 * Base class that all filters should inherit from. Filters need to be applied to objects that have been cached using
 * the {{#crossLink "DisplayObject/cache"}}{{/crossLink}} method. If an object changes, please cache it again, or use
 * {{#crossLink "DisplayObject/updateCache"}}{{/crossLink}}. Note that the filters must be applied before caching.
 *
 * Note that each filter can implement a {{#crossLink "Filter/getBounds"}}{{/crossLink}} method, which returns the
 * margins that need to be applied in order to fully display the filter. For example, the {{#crossLink "BlurFilter"}}{{/crossLink}}
 * will cause an object to feather outwards, resulting in a margin around the shape.
 *
 * <h4>EaselJS Filters</h4>
 * EaselJS comes with a number of pre-built filters. Note that individual filters are not compiled into the minified
 * version of EaselJS. To use them, you must include them manually in the HTML.
 * <ul><li>{{#crossLink "AlphaMapFilter"}}{{/crossLink}} : Map a greyscale image to the alpha channel of a display object</li>
 *      <li>{{#crossLink "AlphaMaskFilter"}}{{/crossLink}}: Map an image's alpha channel to the alpha channel of a display object</li>
 *      <li>{{#crossLink "BlurFilter"}}{{/crossLink}}: Apply vertical and horizontal blur to a display object</li>
 *      <li>{{#crossLink "ColorFilter"}}{{/crossLink}}: Color transform a display object</li>
 *      <li>{{#crossLink "ColorMatrixFilter"}}{{/crossLink}}: Transform an image using a {{#crossLink "ColorMatrix"}}{{/crossLink}}</li>
 * </ul>
 *
 * @class Filter
 * @constructor
 **/
var Filter = function() {
  this.initialize();
};
var p = Filter.prototype;

// constructor:
	/**
	 * Initialization method.
	 * @method initialize
	 * @protected
	 **/
	p.initialize = function() {}

// public methods:
	/**
	 * Returns a rectangle with values indicating the margins required to draw the filter or null.
	 * For example, a filter that will extend the drawing area 4 pixels to the left, and 7 pixels to the right
	 * (but no pixels up or down) would return a rectangle with (x=-4, y=0, width=11, height=0).
	 * @method getBounds
	 * @return {Rectangle} a rectangle object indicating the margins required to draw the filter or null if the filter does not effect bounds.
	 **/
	p.getBounds = function() {
		return null;
	};

	/**
	 * Applies the filter to the specified context.
	 * @method applyFilter
	 * @param {CanvasRenderingContext2D} ctx The 2D context to use as the source.
	 * @param {Number} x The x position to use for the source rect.
	 * @param {Number} y The y position to use for the source rect.
	 * @param {Number} width The width to use for the source rect.
	 * @param {Number} height The height to use for the source rect.
	 * @param {CanvasRenderingContext2D} [targetCtx] The 2D context to draw the result to. Defaults to the context passed to ctx.
	 * @param {Number} [targetX] The x position to draw the result to. Defaults to the value passed to x.
	 * @param {Number} [targetY] The y position to draw the result to. Defaults to the value passed to y.
	 * @return {Boolean} If the filter was applied successfully.
	 **/
	p.applyFilter = function(ctx, x, y, width, height, targetCtx, targetX, targetY) {}

fanvas.Filter = Filter;
}());

// namespace:
this.fanvas = this.fanvas||{};

(function() {
	"use strict";

/**
 * Applies a box blur to DisplayObjects. Note that this filter is fairly CPU intensive, particularly if the quality is
 * set higher than 1.
 *
 * <h4>Example</h4>
 * This example creates a red circle, and then applies a 5 pixel blur to it. It uses the {{#crossLink "Filter/getBounds"}}{{/crossLink}}
 * method to account for the spread that the blur causes.
 *
 *      var shape = new fanvas.Shape().set({x:100,y:100});
 *      shape.graphics.beginFill("#ff0000").drawCircle(0,0,50);
 *
 *      var blurFilter = new fanvas.BlurFilter(5, 5, 1);
 *      shape.filters = [blurFilter];
 *      var bounds = blurFilter.getBounds();
 *
 *      shape.cache(-50+bounds.x, -50+bounds.y, 100+bounds.width, 100+bounds.height);
 *
 * See {{#crossLink "Filter"}}{{/crossLink}} for an more information on applying filters.
 * @class BlurFilter
 * @extends Filter
 * @constructor
 * @param {Number} [blurX=0] The horizontal blur radius in pixels.
 * @param {Number} [blurY=0] The vertical blur radius in pixels.
 * @param {Number} [quality=1] The number of blur iterations.
 **/
var BlurFilter = function( blurX, blurY, quality ) {
  this.initialize( blurX, blurY, quality );
};
var p = BlurFilter.prototype = new fanvas.Filter();

// constructor:
	/** @ignore */
	p.initialize = function( blurX, blurY, quality ) {
		if ( isNaN(blurX) || blurX < 0 ) blurX = 0;
		this.blurX = blurX | 0;
		if ( isNaN(blurY) || blurY < 0 ) blurY = 0;
		this.blurY = blurY | 0;
		if ( isNaN(quality) || quality < 1  ) quality = 1;
		this.quality = quality | 0;
	};

// public properties:

	/**
	 * Horizontal blur radius in pixels
	 * @property blurX
	 * @default 0
	 * @type Number
	 **/
	p.blurX = 0;

	/**
	 * Vertical blur radius in pixels
	 * @property blurY
	 * @default 0
	 * @type Number
	 **/
	p.blurY = 0;

	/**
	 * Number of blur iterations. For example, a value of 1 will produce a rough blur. A value of 2 will produce a
	 * smoother blur, but take twice as long to run.
	 * @property quality
	 * @default 1
	 * @type Number
	 **/
	p.quality = 1;
	
	//TODO: There might be a better better way to place these two lookup tables:
	p.mul_table = [ 1,171,205,293,57,373,79,137,241,27,391,357,41,19,283,265,497,469,443,421,25,191,365,349,335,161,155,149,9,278,269,261,505,245,475,231,449,437,213,415,405,395,193,377,369,361,353,345,169,331,325,319,313,307,301,37,145,285,281,69,271,267,263,259,509,501,493,243,479,118,465,459,113,446,55,435,429,423,209,413,51,403,199,393,97,3,379,375,371,367,363,359,355,351,347,43,85,337,333,165,327,323,5,317,157,311,77,305,303,75,297,294,73,289,287,71,141,279,277,275,68,135,67,133,33,262,260,129,511,507,503,499,495,491,61,121,481,477,237,235,467,232,115,457,227,451,7,445,221,439,218,433,215,427,425,211,419,417,207,411,409,203,202,401,399,396,197,49,389,387,385,383,95,189,47,187,93,185,23,183,91,181,45,179,89,177,11,175,87,173,345,343,341,339,337,21,167,83,331,329,327,163,81,323,321,319,159,79,315,313,39,155,309,307,153,305,303,151,75,299,149,37,295,147,73,291,145,289,287,143,285,71,141,281,35,279,139,69,275,137,273,17,271,135,269,267,133,265,33,263,131,261,130,259,129,257,1];
        
   
	p.shg_table = [0,9,10,11,9,12,10,11,12,9,13,13,10,9,13,13,14,14,14,14,10,13,14,14,14,13,13,13,9,14,14,14,15,14,15,14,15,15,14,15,15,15,14,15,15,15,15,15,14,15,15,15,15,15,15,12,14,15,15,13,15,15,15,15,16,16,16,15,16,14,16,16,14,16,13,16,16,16,15,16,13,16,15,16,14,9,16,16,16,16,16,16,16,16,16,13,14,16,16,15,16,16,10,16,15,16,14,16,16,14,16,16,14,16,16,14,15,16,16,16,14,15,14,15,13,16,16,15,17,17,17,17,17,17,14,15,17,17,16,16,17,16,15,17,16,17,11,17,16,17,16,17,16,17,17,16,17,17,16,17,17,16,16,17,17,17,16,14,17,17,17,17,15,16,14,16,15,16,13,16,15,16,14,16,15,16,12,16,15,16,17,17,17,17,17,13,16,15,17,17,17,16,15,17,17,17,16,15,17,17,14,16,17,17,16,17,17,16,15,17,16,14,17,16,15,17,16,17,17,16,17,15,16,17,14,17,16,15,17,16,17,13,17,16,17,17,16,17,14,17,16,17,16,17,16,17,9];

// public methods:
	/** docced in super class **/
	p.getBounds = function() {
		var q = Math.pow(this.quality, 0.6)*0.5;
		return new fanvas.Rectangle(-this.blurX*q,-this.blurY*q,2*this.blurX*q,2*this.blurY*q);
	};

	p.applyFilter = function(ctx, x, y, width, height, targetCtx, targetX, targetY) {
		targetCtx = targetCtx || ctx;
		if (targetX == null) { targetX = x; }
		if (targetY == null) { targetY = y; }
		try {
			var imageData = ctx.getImageData(x, y, width, height);
		} catch(e) {
			//if (!this.suppressCrossDomainErrors) throw new Error("unable to access local image data: " + e);
			return false;
		}

		var radiusX = this.blurX/2;
		if ( isNaN(radiusX) || radiusX < 0 ) return false;
		radiusX |= 0;

		var radiusY = this.blurY/2;
		if ( isNaN(radiusY) || radiusY < 0 ) return false;
		radiusY |= 0;

		if ( radiusX == 0 && radiusY == 0 ) return false;

		var iterations = this.quality;
		if ( isNaN(iterations) || iterations < 1  ) iterations = 1;
		iterations |= 0;
		if ( iterations > 3 ) iterations = 3;
		if ( iterations < 1 ) iterations = 1;

		var pixels = imageData.data;

		var x, y, i, p, yp, yi, yw, r_sum, g_sum, b_sum, a_sum, 
		r_out_sum, g_out_sum, b_out_sum, a_out_sum,
		r_in_sum, g_in_sum, b_in_sum, a_in_sum, 
		pr, pg, pb, pa, rbs;

		var divx = radiusX + radiusX + 1;
		var divy = radiusY + radiusY + 1;
		var w4 = width << 2;
		var widthMinus1  = width - 1;
		var heightMinus1 = height - 1;
		var rxp1  = radiusX + 1;
		var ryp1  = radiusY + 1;
		var stackStartX = {r:0,b:0,g:0,a:0,next:null};
		var stackx = stackStartX;
		for ( i = 1; i < divx; i++ )
		{
			stackx = stackx.next = {r:0,b:0,g:0,a:0,next:null};
			if ( i == rxp1 ) var stackEndX = stackx;
		}
		stackx.next = stackStartX;
		
		var stackStartY = {r:0,b:0,g:0,a:0,next:null};
		var stacky = stackStartY;
		for ( i = 1; i < divy; i++ )
		{
			stacky = stacky.next = {r:0,b:0,g:0,a:0,next:null};
			if ( i == ryp1 ) var stackEndY = stacky;
		}
		stacky.next = stackStartY;
		
		var stackIn = null;



		
		while ( iterations-- > 0 ) {
			yw = yi = 0;
			var mul_sum = this.mul_table[radiusX];
			var shg_sum = this.shg_table[radiusX];
			for ( y = height; --y > -1; )
			{
				r_sum = rxp1 * ( pr = pixels[yi] );
				g_sum = rxp1 * ( pg = pixels[yi+1] );
				b_sum = rxp1 * ( pb = pixels[yi+2] );
				a_sum = rxp1 * ( pa = pixels[yi+3] );

				stackx = stackStartX;

				for( i = rxp1; --i > -1; )
				{
					stackx.r = pr;
					stackx.g = pg;
					stackx.b = pb;
					stackx.a = pa;
					stackx = stackx.next;
				}

				for( i = 1; i < rxp1; i++ )
				{
					p = yi + (( widthMinus1 < i ? widthMinus1 : i ) << 2 );
					r_sum += ( stackx.r = pixels[p]);
					g_sum += ( stackx.g = pixels[p+1]);
					b_sum += ( stackx.b = pixels[p+2]);
					a_sum += ( stackx.a = pixels[p+3]);

					stackx = stackx.next;
				}

				stackIn = stackStartX;
				for ( x = 0; x < width; x++ )
				{
					pixels[yi++] = (r_sum * mul_sum) >>> shg_sum;
					pixels[yi++] = (g_sum * mul_sum) >>> shg_sum;
					pixels[yi++] = (b_sum * mul_sum) >>> shg_sum;
					pixels[yi++] = (a_sum * mul_sum) >>> shg_sum;

					p =  ( yw + ( ( p = x + radiusX + 1 ) < widthMinus1 ? p : widthMinus1 ) ) << 2;

					r_sum -= stackIn.r - ( stackIn.r = pixels[p]);
					g_sum -= stackIn.g - ( stackIn.g = pixels[p+1]);
					b_sum -= stackIn.b - ( stackIn.b = pixels[p+2]);
					a_sum -= stackIn.a - ( stackIn.a = pixels[p+3]);

					stackIn = stackIn.next;

				}
				yw += width;
			}

			mul_sum = this.mul_table[radiusY];
			shg_sum = this.shg_table[radiusY];
			for ( x = 0; x < width; x++ )
			{
				yi = x << 2;

				r_sum = ryp1 * ( pr = pixels[yi]);
				g_sum = ryp1 * ( pg = pixels[yi+1]);
				b_sum = ryp1 * ( pb = pixels[yi+2]);
				a_sum = ryp1 * ( pa = pixels[yi+3]);

				stacky = stackStartY;

				for( i = 0; i < ryp1; i++ )
				{
					stacky.r = pr;
					stacky.g = pg;
					stacky.b = pb;
					stacky.a = pa;
					stacky = stacky.next;
				}

				yp = width;

				for( i = 1; i <= radiusY; i++ )
				{
					yi = ( yp + x ) << 2;

					r_sum += ( stacky.r = pixels[yi]);
					g_sum += ( stacky.g = pixels[yi+1]);
					b_sum += ( stacky.b = pixels[yi+2]);
					a_sum += ( stacky.a = pixels[yi+3]);

					stacky = stacky.next;

					if( i < heightMinus1 )
					{
						yp += width;
					}
				}

				yi = x;
				stackIn = stackStartY;
				if ( iterations > 0 )
				{
					for ( y = 0; y < height; y++ )
					{
						p = yi << 2;
						pixels[p+3] = pa =(a_sum * mul_sum) >>> shg_sum;
						if ( pa > 0 )
						{
							pixels[p]   = ((r_sum * mul_sum) >>> shg_sum ); 
							pixels[p+1] = ((g_sum * mul_sum) >>> shg_sum );
							pixels[p+2] = ((b_sum * mul_sum) >>> shg_sum );
						} else {
							pixels[p] = pixels[p+1] = pixels[p+2] = 0
						}

						p = ( x + (( ( p = y + ryp1) < heightMinus1 ? p : heightMinus1 ) * width )) << 2;

						r_sum -= stackIn.r - ( stackIn.r = pixels[p]);
						g_sum -= stackIn.g - ( stackIn.g = pixels[p+1]);
						b_sum -= stackIn.b - ( stackIn.b = pixels[p+2]);
						a_sum -= stackIn.a - ( stackIn.a = pixels[p+3]);

						stackIn = stackIn.next;

						yi += width;
					}
				} else {
					for ( y = 0; y < height; y++ )
					{
						p = yi << 2;
						pixels[p+3] = pa =(a_sum * mul_sum) >>> shg_sum;
						if ( pa > 0 )
						{
							pa = 255 / pa;
							pixels[p]   = ((r_sum * mul_sum) >>> shg_sum ) * pa; 
							pixels[p+1] = ((g_sum * mul_sum) >>> shg_sum ) * pa;
							pixels[p+2] = ((b_sum * mul_sum) >>> shg_sum ) * pa;
						} else {
							pixels[p] = pixels[p+1] = pixels[p+2] = 0
						}

						p = ( x + (( ( p = y + ryp1) < heightMinus1 ? p : heightMinus1 ) * width )) << 2;

						r_sum -= stackIn.r - ( stackIn.r = pixels[p]);
						g_sum -= stackIn.g - ( stackIn.g = pixels[p+1]);
						b_sum -= stackIn.b - ( stackIn.b = pixels[p+2]);
						a_sum -= stackIn.a - ( stackIn.a = pixels[p+3]);

						stackIn = stackIn.next;

						yi += width;
					}
				}
			}
		}
		targetCtx.putImageData(imageData, targetX, targetY);
		return true;
	};

	fanvas.BlurFilter = BlurFilter;

}());

// namespace:
this.fanvas = this.fanvas||{};

(function() {
	"use strict";

	/**
	 * Provides helper functions for assembling a matrix for use with the {{#crossLink "ColorMatrixFilter"}}{{/crossLink}},
	 * or can be used directly as the matrix for a ColorMatrixFilter. Most methods return the instance to facilitate
	 * chained calls.
	 *
	 * See {{#crossLink "Filter"}}{{/crossLink}} for an example of how to apply filters, or {{#crossLink "ColorMatrixFilter"}}{{/crossLink}}
	 * for an example of how to use ColorMatrix to change a DisplayObject's color.
	 * @class ColorMatrix
	 * @param {Number} brightness
	 * @param {Number} contrast
	 * @param {Number} saturation
	 * @param {Number} hue
	 * @constructor
	 **/
	var ColorMatrix = function(brightness, contrast, saturation, hue) {
	  this.initialize(brightness, contrast, saturation, hue);
	};
	var p = ColorMatrix.prototype;

	/**
	 * Array of delta values for contrast calculations.
	 * @property DELTA_INDEX
	 * @type Array
	 * @protected
	 * @static
	 **/
	ColorMatrix.DELTA_INDEX = [
		0,    0.01, 0.02, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1,  0.11,
		0.12, 0.14, 0.15, 0.16, 0.17, 0.18, 0.20, 0.21, 0.22, 0.24,
		0.25, 0.27, 0.28, 0.30, 0.32, 0.34, 0.36, 0.38, 0.40, 0.42,
		0.44, 0.46, 0.48, 0.5,  0.53, 0.56, 0.59, 0.62, 0.65, 0.68,
		0.71, 0.74, 0.77, 0.80, 0.83, 0.86, 0.89, 0.92, 0.95, 0.98,
		1.0,  1.06, 1.12, 1.18, 1.24, 1.30, 1.36, 1.42, 1.48, 1.54,
		1.60, 1.66, 1.72, 1.78, 1.84, 1.90, 1.96, 2.0,  2.12, 2.25,
		2.37, 2.50, 2.62, 2.75, 2.87, 3.0,  3.2,  3.4,  3.6,  3.8,
		4.0,  4.3,  4.7,  4.9,  5.0,  5.5,  6.0,  6.5,  6.8,  7.0,
		7.3,  7.5,  7.8,  8.0,  8.4,  8.7,  9.0,  9.4,  9.6,  9.8,
		10.0
	];

	/**
	 * Identity matrix values.
	 * @property IDENTITY_MATRIX
	 * @type Array
	 * @protected
	 * @static
	 **/
	ColorMatrix.IDENTITY_MATRIX = [
		1,0,0,0,0,
		0,1,0,0,0,
		0,0,1,0,0,
		0,0,0,1,0,
		0,0,0,0,1
	];

	/**
	 * The constant length of a color matrix.
	 * @property LENGTH
	 * @type Number
	 * @protected
	 * @static
	 **/
	ColorMatrix.LENGTH = ColorMatrix.IDENTITY_MATRIX.length;


	/**
	 * Initialization method.
	 * @method initialize
	 * @param {Number} brightness
	 * @param {Number} contrast
	 * @param {Number} saturation
	 * @param {Number} hue
	 * @protected
	 */
	p.initialize = function(brightness,contrast,saturation,hue) {
		this.reset();
		this.adjustColor(brightness,contrast,saturation,hue);
		return this;
	};

	/**
	 * Resets the matrix to identity values.
	 * @method reset
	 * @return {ColorMatrix} The ColorMatrix instance the method is called on (useful for chaining calls.)
	 */
	p.reset = function() {
		return this.copyMatrix(ColorMatrix.IDENTITY_MATRIX);
	};

	/**
	 * Shortcut method to adjust brightness, contrast, saturation and hue.
	 * Equivalent to calling adjustHue(hue), adjustContrast(contrast),
	 * adjustBrightness(brightness), adjustSaturation(saturation), in that order.
	 * @method adjustColor
	 * @param {Number} brightness
	 * @param {Number} contrast
	 * @param {Number} saturation
	 * @param {Number} hue
	 * @return {ColorMatrix} The ColorMatrix instance the method is called on (useful for chaining calls.)
	 **/
	p.adjustColor = function(brightness,contrast,saturation,hue) {
		this.adjustHue(hue);
		this.adjustContrast(contrast);
		this.adjustBrightness(brightness);
		return this.adjustSaturation(saturation);
	};

	/**
	 * Adjusts the brightness of pixel color by adding the specified value to the red, green and blue channels.
	 * Positive values will make the image brighter, negative values will make it darker.
	 * @method adjustBrightness
	 * @param {Number} value A value between -255 & 255 that will be added to the RGB channels.
	 * @return {ColorMatrix} The ColorMatrix instance the method is called on (useful for chaining calls.)
	 **/
	p.adjustBrightness = function(value) {
		if (value == 0 || isNaN(value)) { return this; }
		value = this._cleanValue(value,255);
		this._multiplyMatrix([
			1,0,0,0,value,
			0,1,0,0,value,
			0,0,1,0,value,
			0,0,0,1,0,
			0,0,0,0,1
		]);
		return this;
	};

	/**
	 * Adjusts the contrast of pixel color.
	 * Positive values will increase contrast, negative values will decrease contrast.
	 * @method adjustContrast
	 * @param {Number} value A value between -100 & 100.
	 * @return {ColorMatrix} The ColorMatrix instance the method is called on (useful for chaining calls.)
	 **/
	p.adjustContrast = function(value) {
		if (value == 0 || isNaN(value)) { return this; }
		value = this._cleanValue(value,100);
		var x;
		if (value<0) {
			x = 127+value/100*127;
		} else {
			x = value%1;
			if (x == 0) {
				x = ColorMatrix.DELTA_INDEX[value];
			} else {
				x = ColorMatrix.DELTA_INDEX[(value<<0)]*(1-x)+ColorMatrix.DELTA_INDEX[(value<<0)+1]*x; // use linear interpolation for more granularity.
			}
			x = x*127+127;
		}
		this._multiplyMatrix([
			x/127,0,0,0,0.5*(127-x),
			0,x/127,0,0,0.5*(127-x),
			0,0,x/127,0,0.5*(127-x),
			0,0,0,1,0,
			0,0,0,0,1
		]);
		return this;
	};

	/**
	 * Adjusts the color saturation of the pixel.
	 * Positive values will increase saturation, negative values will decrease saturation (trend towards greyscale).
	 * @method adjustSaturation
	 * @param {Number} value A value between -100 & 100.
	 * @return {ColorMatrix} The ColorMatrix instance the method is called on (useful for chaining calls.)
	 **/
	p.adjustSaturation = function(value) {
		if (value == 0 || isNaN(value)) { return this; }
		value = this._cleanValue(value,100);
		var x = 1+((value > 0) ? 3*value/100 : value/100);
		var lumR = 0.3086;
		var lumG = 0.6094;
		var lumB = 0.0820;
		this._multiplyMatrix([
			lumR*(1-x)+x,lumG*(1-x),lumB*(1-x),0,0,
			lumR*(1-x),lumG*(1-x)+x,lumB*(1-x),0,0,
			lumR*(1-x),lumG*(1-x),lumB*(1-x)+x,0,0,
			0,0,0,1,0,
			0,0,0,0,1
		]);
		return this;
	};


	/**
	 * Adjusts the hue of the pixel color.
	 * @method adjustHue
	 * @param {Number} value A value between -180 & 180.
	 * @return {ColorMatrix} The ColorMatrix instance the method is called on (useful for chaining calls.)
	 **/
	p.adjustHue = function(value) {
		if (value == 0 || isNaN(value)) { return this; }
		value = this._cleanValue(value,180)/180*Math.PI;
		var cosVal = Math.cos(value);
		var sinVal = Math.sin(value);
		var lumR = 0.213;
		var lumG = 0.715;
		var lumB = 0.072;
		this._multiplyMatrix([
			lumR+cosVal*(1-lumR)+sinVal*(-lumR),lumG+cosVal*(-lumG)+sinVal*(-lumG),lumB+cosVal*(-lumB)+sinVal*(1-lumB),0,0,
			lumR+cosVal*(-lumR)+sinVal*(0.143),lumG+cosVal*(1-lumG)+sinVal*(0.140),lumB+cosVal*(-lumB)+sinVal*(-0.283),0,0,
			lumR+cosVal*(-lumR)+sinVal*(-(1-lumR)),lumG+cosVal*(-lumG)+sinVal*(lumG),lumB+cosVal*(1-lumB)+sinVal*(lumB),0,0,
			0,0,0,1,0,
			0,0,0,0,1
		]);
		return this;
	};

	/**
	 * Concatenates (multiplies) the specified matrix with this one.
	 * @method concat
	 * @param {Array} matrix An array or ColorMatrix instance.
	 * @return {ColorMatrix} The ColorMatrix instance the method is called on (useful for chaining calls.)
	 **/
	p.concat = function(matrix) {
		matrix = this._fixMatrix(matrix);
		if (matrix.length != ColorMatrix.LENGTH) { return this; }
		this._multiplyMatrix(matrix);
		return this;
	};

	/**
	 * Return a length 25 (5x5) array instance containing this matrix's values.
	 * @method toArray
	 * @return {Array} An array holding this matrix's values.
	 **/
	p.toArray = function() {
		var arr = [];
		for (var i= 0, l=ColorMatrix.LENGTH; i<l; i++) {
			arr[i] = this[i];
		}
		return arr;
	};

	/**
	 * Copy the specified matrix's values to this matrix.
	 * @method copyMatrix
	 * @param {Array} matrix An array or ColorMatrix instance.
	 * @return {ColorMatrix} The ColorMatrix instance the method is called on (useful for chaining calls.)
	 **/
	p.copyMatrix = function(matrix) {
		var l = ColorMatrix.LENGTH;
		for (var i=0;i<l;i++) {
			this[i] = matrix[i];
		}
		return this;
	};
	

// private methods:

	/**
	 * @method _multiplyMatrix
	 * @param {Array} matrix
	 * @protected
	 **/
	p._multiplyMatrix = function(matrix) {
		var col = [];

		for (var i=0;i<5;i++) {
			for (var j=0;j<5;j++) {
				col[j] = this[j+i*5];
			}
			for (var j=0;j<5;j++) {
				var val=0;
				for (var k=0;k<5;k++) {
					val += matrix[j+k*5]*col[k];
				}
				this[j+i*5] = val;
			}
		}
	};

	/**
	 * Make sure values are within the specified range, hue has a limit of 180, brightness is 255, others are 100.
	 * @method _cleanValue
	 * @param {Number} value The raw number
	 * @param {Number} limit The maximum that the number can be. The minimum is the limit * -1.
	 * @protected
	 **/
	p._cleanValue = function(value, limit) {
		return Math.min(limit,Math.max(-limit,value));
	};

	//
	/**
	 * Makes sure matrixes are 5x5 (25 long).
	 * @method _fixMatrix
	 * @param {Array} matrix
	 * @protected
	 **/
	p._fixMatrix = function(matrix) {
		if (matrix instanceof ColorMatrix) { matrix = matrix.toArray(); }
		if (matrix.length < ColorMatrix.LENGTH) {
			matrix = matrix.slice(0,matrix.length).concat(ColorMatrix.IDENTITY_MATRIX.slice(matrix.length,ColorMatrix.LENGTH));
		} else if (matrix.length > ColorMatrix.LENGTH) {
			matrix = matrix.slice(0,ColorMatrix.LENGTH);
		}
		return matrix;
	};

	fanvas.ColorMatrix = ColorMatrix;

}());

// namespace:
this.fanvas = this.fanvas||{};

(function() {
	"use strict";

/**
 * Applies a color transform to DisplayObjects.
 *
 * See {{#crossLink "Filter"}}{{/crossLink}} for an more information on applying filters.
 * @class ColorFilter
 * @param {Number} [redMultiplier=1] The amount to multiply against the red channel. This is a range between 0 and 1.
 * @param {Number} [greenMultiplier=1] The amount to multiply against the green channel. This is a range between 0 and 1.
 * @param {Number} [blueMultiplier=1] The amount to multiply against the blue channel. This is a range between 0 and 1.
 * @param {Number} [alphaMultiplier=1] The amount to multiply against the alpha channel. This is a range between 0 and 1.
 * @param {Number} [redOffset=0] The amount to add to the red channel after it has been multiplied. This is a range
 * between -255 and 255.
 * @param {Number} [greenOffset=0] The amount to add to the green channel after it has been multiplied. This is a range
  * between -255 and 255.
 * @param {Number} [blueOffset=0] The amount to add to the blue channel after it has been multiplied. This is a range
  * between -255 and 255.
 * @param {Number} [alphaOffset=0] The amount to add to the alpha channel after it has been multiplied. This is a range
  * between -255 and 255.
 * @constructor
 * @extends Filter
 **/
var ColorFilter = function(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset) {
  this.initialize(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
}
var p = ColorFilter.prototype = new fanvas.Filter();

// public properties:
	/**
	 * Red channel multiplier.
	 * @property redMultiplier
	 * @type Number
	 **/
	p.redMultiplier = 1;

	/**
	 * Green channel multiplier.
	 * @property greenMultiplier
	 * @type Number
	 **/
	p.greenMultiplier = 1;

	/**
	 * Blue channel multiplier.
	 * @property blueMultiplier
	 * @type Number
	 **/
	p.blueMultiplier = 1;

	/**
	 * Alpha channel multiplier.
	 * @property alphaMultiplier
	 * @type Number
	 **/
	p.alphaMultiplier = 1;

	/**
	 * Red channel offset (added to value).
	 * @property redOffset
	 * @type Number
	 **/
	p.redOffset = 0;

	/**
	 * Green channel offset (added to value).
	 * @property greenOffset
	 * @type Number
	 **/
	p.greenOffset = 0;

	/**
	 * Blue channel offset (added to value).
	 * @property blueOffset
	 * @type Number
	 **/
	p.blueOffset = 0;

	/**
	 * Alpha channel offset (added to value).
	 * @property alphaOffset
	 * @type Number
	 **/
	p.alphaOffset = 0;

// constructor:
	/**
	 * Initialization method.
	 * @method initialize
	 * @param {Number} [redMultiplier=1] The amount to multiply against the red channel. This is a range between 0 and 1.
	 * @param {Number} [greenMultiplier=1] The amount to multiply against the green channel. This is a range between 0 and 1.
	 * @param {Number} [blueMultiplier=1] The amount to multiply against the blue channel. This is a range between 0 and 1.
	 * @param {Number} [alphaMultiplier=1] The amount to multiply against the alpha channel. This is a range between 0 and 1.
	 * @param {Number} [redOffset=0] The amount to add to the red channel after it has been multiplied. This is a range
	 * between -255 and 255.
	 * @param {Number} [greenOffset=0] The amount to add to the green channel after it has been multiplied. This is a range
	 * between -255 and 255.
	 * @param {Number} [blueOffset=0] The amount to add to the blue channel after it has been multiplied. This is a range
	 * between -255 and 255.
	 * @param {Number} [alphaOffset=0] The amount to add to the alpha channel after it has been multiplied. This is a range
	 * between -255 and 255.
	 * @protected
	 **/
	p.initialize = function(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset) {
		this.redMultiplier = redMultiplier != null ? redMultiplier : 1;
		this.greenMultiplier = greenMultiplier != null ? greenMultiplier : 1;
		this.blueMultiplier = blueMultiplier != null ? blueMultiplier : 1;
		this.alphaMultiplier = alphaMultiplier != null ? alphaMultiplier : 1;
		this.redOffset = redOffset || 0;
		this.greenOffset = greenOffset || 0;
		this.blueOffset = blueOffset || 0;
		this.alphaOffset = alphaOffset || 0;
	}

// public methods:
	p.applyFilter = function(ctx, x, y, width, height, targetCtx, targetX, targetY) {
		targetCtx = targetCtx || ctx;
		if (targetX == null) { targetX = x; }
		if (targetY == null) { targetY = y; }
		try {
			var imageData = ctx.getImageData(x, y, width, height);
		} catch(e) {
			//if (!this.suppressCrossDomainErrors) throw new Error("unable to access local image data: " + e);
			return false;
		}
		var data = imageData.data;
		var l = data.length;
		for (var i=0; i<l; i+=4) {
			data[i] = data[i]*this.redMultiplier+this.redOffset;
			data[i+1] = data[i+1]*this.greenMultiplier+this.greenOffset;
			data[i+2] = data[i+2]*this.blueMultiplier+this.blueOffset;
			data[i+3] = data[i+3]*this.alphaMultiplier+this.alphaOffset;
		}
		targetCtx.putImageData(imageData, targetX, targetY);
		return true;
	}

	fanvas.ColorFilter = ColorFilter;

}());

// namespace:
this.fanvas = this.fanvas||{};

(function() {
	"use strict";

/**
 * Allows you to carry out complex color operations such as modifying saturation, brightness, or inverting. See the
 * {{#crossLink "ColorMatrix"}}{{/crossLink}} for more information on changing colors. For an easier color transform,
 * consider the {{#crossLink "ColorFilter"}}{{/crossLink}}.
 *
 * See {{#crossLink "Filter"}}{{/crossLink}} for an more information on applying filters.
 * @class ColorMatrixFilter
 * @constructor
 * @extends Filter
 * @param {Array} matrix A 4x5 matrix describing the color operation to perform. See also the {{#crossLink "ColorMatrix"}}{{/crossLink}}
 * class.
 **/
var ColorMatrixFilter = function(matrix) {
  this.initialize(matrix);
};
var p = ColorMatrixFilter.prototype = new fanvas.Filter();

// public properties:
	p.matrix = null;

// constructor:
	// TODO: detailed docs.
	/**
	 * @method initialize
	 * @protected
	 * @param {Array} matrix A 4x5 matrix describing the color operation to perform.
	 **/
	p.initialize = function(matrix) {
		this.matrix = matrix;
	};

// public methods:
	p.applyFilter = function(ctx, x, y, width, height, targetCtx, targetX, targetY) {
		targetCtx = targetCtx || ctx;
		if (targetX == null) { targetX = x; }
		if (targetY == null) { targetY = y; }
		try {
			var imageData = ctx.getImageData(x, y, width, height);
		} catch(e) {
			//if (!this.suppressCrossDomainErrors) throw new Error("unable to access local image data: " + e);
			return false;
		}
		var data = imageData.data;
		var l = data.length;
		var r,g,b,a;
		var mtx = this.matrix;
		var m0 =  mtx[0],  m1 =  mtx[1],  m2 =  mtx[2],  m3 =  mtx[3],  m4 =  mtx[4];
		var m5 =  mtx[5],  m6 =  mtx[6],  m7 =  mtx[7],  m8 =  mtx[8],  m9 =  mtx[9];
		var m10 = mtx[10], m11 = mtx[11], m12 = mtx[12], m13 = mtx[13], m14 = mtx[14];
		var m15 = mtx[15], m16 = mtx[16], m17 = mtx[17], m18 = mtx[18], m19 = mtx[19];

		for (var i=0; i<l; i+=4) {
			r = data[i];
			g = data[i+1];
			b = data[i+2];
			a = data[i+3];
			data[i] = r*m0+g*m1+b*m2+a*m3+m4; // red
			data[i+1] = r*m5+g*m6+b*m7+a*m8+m9; // green
			data[i+2] = r*m10+g*m11+b*m12+a*m13+m14; // blue
			data[i+3] = r*m15+g*m16+b*m17+a*m18+m19; // alpha
		}
		targetCtx.putImageData(imageData, targetX, targetY);
		return true;
	};

	fanvas.ColorMatrixFilter = ColorMatrixFilter;

}());
