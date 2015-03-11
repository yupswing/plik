
package com.akifox.lib;
import openfl.display.Sprite;

class SpriteContainer extends Sprite implements IDestroyable {

	public function new() {
		super();
	}

	public override function toString():String {
		return "[Akifox.SpriteContainer <"+numChildren+" Elements>]";
	}

	private var _dead:Bool=false;
	public var dead(get,never):Bool;
    public function get_dead():Bool { return _dead; }

	public function destroy() {
        #if gbcheck
        trace('AKIFOX Destroy ' + this);
        #end
        _dead = true;
	}
}