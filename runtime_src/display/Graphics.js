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
