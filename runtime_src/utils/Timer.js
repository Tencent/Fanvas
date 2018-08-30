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
