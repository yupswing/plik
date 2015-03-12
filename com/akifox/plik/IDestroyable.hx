
package com.akifox.plik;

interface IDestroyable {

	public function toString():String;

	public function destroy():Void;

	private var _dead:Bool=false;
	public var dead(get,never):Bool;
    public function get_dead():Bool;

}