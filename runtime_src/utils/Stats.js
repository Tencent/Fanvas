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
