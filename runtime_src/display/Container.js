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
		if (child) { child.parent = null; }
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
}());