package com.akifox.plik;

import openfl.Assets;
import openfl.Lib;
import openfl.geom.Point;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Graphics;
import openfl.display.DisplayObject;
import com.akifox.plik.atlas.TextureAtlas;
import com.akifox.plik.geom.Transformation;
import com.akifox.plik.geom.ITransformable;

class Gfx extends Bitmap implements ITransformable implements IDestroyable {

	private var _name:String;

    public function new(name:String,?smoothing:Bool=true){
    	super(getBitmap(name));
    	_name = name;
    	this.smoothing = smoothing;
    	initTransformation();
    }

    public override function toString():String {
        return '[PLIK.Gfx "'+_name+'"]';
    }

    public function destroyCache() {
        #if gbcheck
        trace('AKIFOX Destroy cache for ' + this);
        #end
    	// destroy this element and the global cache from memory
    	removeBitmap(_name);
    }

    //## INTERFACE
    private var _transformation:Transformation;

    public function updateTransformation() {
        _transformation.updateSize();
    }

    private function initTransformation() {
    	_transformation = new Transformation(this);
    }

    public function setAnchoredPivot(value:Int){
    	_transformation.setAnchoredPivot(value);
    }

    public function setPivot(x:Float,y:Float){
    	_transformation.setPivot(new Point(x,y));
    }

    public function flipX():Void {
        _transformation.flipX();
    }
    public function flipY():Void{
        _transformation.flipY();
    }

    public var scale(get,set):Float;
    private function get_scale():Float{
    	return _transformation.scalingX;
    }
    private function set_scale(value:Float):Float{
    	_transformation.setScale(value); //x and y
    	return value;
    }

    private override function get_scaleX():Float{
    	return _transformation.scalingX;
    }
    private override function set_scaleX(value:Float):Float{ 
    	return _transformation.scalingX = value;
    }

    private override function get_scaleY():Float{
    	return _transformation.scalingY;
    }
    private override function set_scaleY(value:Float):Float{ 
    	return _transformation.scalingY = value;
    }

    public var skewX(get,set):Float;
    private function get_skewX():Float{
    	return _transformation.skewingX;
    }
    private function set_skewX(value:Float):Float{ 
    	return _transformation.skewingX = value;
    }

    public var skewY(get,set):Float;
    private function get_skewY():Float{
    	return _transformation.skewingY;
    }
    private function set_skewY(value:Float):Float{ 
    	return _transformation.skewingY = value;
    }

    //public override var rotation(get,set):Float;
    private override function get_rotation():Float{
    	return _transformation.rotation;
    }
    private override function set_rotation(value:Float):Float{
    	_transformation.rotation = value;
    	return value;
    }

    //public override var x(get,set):Float;
    private override function get_x():Float{
    	return _transformation.translationX;
    }
    private override function set_x(value:Float):Float{
    	_transformation.translationX = value;
    	return value;
    }

    //public override var y(get,set):Float;
    private override function get_y():Float{
    	return _transformation.translationY;
    }
    private override function set_y(value:Float):Float{
    	_transformation.translationY = value;
    	return value;
    }

    private var _dead:Bool=false;
    public var dead(get,never):Bool;
    public function get_dead():Bool { return _dead; }

    public function destroy() {
        _dead = true;
        //motion.Actuate.stop(this);

        #if gbcheck
        trace('AKIFOX Destroy ' + this);
        #end
    	// destroy this element
        if (this._transformation!=null) {
    	   this._transformation.destroy();
    	   this._transformation = null;
        }
    }

	//##########################################################################################
	//##########################################################################################
	//##########################################################################################
	//##########################################################################################


	// Bitmap storage.
	private static var _bitmapCache:Map<String,BitmapData> = new Map<String,BitmapData>();


	private static function reloadBitmaps():Bool {
		for (el in _bitmapCache.keys()) {
			removeBitmap(el);
			getBitmap(el);
		}
		return true;
	}

	public static function bitmapPath(name:String):String {
		return "graphics_"+PLIK.resolutionX+"/"+name;
	}

	public static function preloadBitmap(name:String):Void {
        if (_bitmapCache.exists(name)) return;
		var data:BitmapData = openfl.Assets.getBitmapData(bitmapPath(name), false);
		if (data != null) _bitmapCache.set(name, data);
		data = null;
	}

	public static function getBitmap(name:String):BitmapData
	{
		if (_bitmapCache.exists(name))
			return _bitmapCache.get(name);

		var data:BitmapData = openfl.Assets.getBitmapData(bitmapPath(name), false);

		if (data != null)
			_bitmapCache.set(name, data);

		return data;
	}

	public static function overwriteBitmapCache(name:String, data:BitmapData):Void
	{
		removeBitmap(name);
		_bitmapCache.set(name, data);
	}

	public static function removeBitmap(name:String):Bool
	{
		if (_bitmapCache.exists(name))
		{        
            #if gbcheck
            trace('Remove bitmap ' + name);
            #end
			var bitmap = _bitmapCache.get(name);
			bitmap.dispose();
			bitmap = null;
			return _bitmapCache.remove(name);
		}
		return false;
	}

	//##########################################################################################
	//##########################################################################################
	//##########################################################################################
	//##########################################################################################

	// Tilesheets storage.
	private static var _textureatlas:Map<String,TextureAtlas> = new Map<String,TextureAtlas>();

	public static function getTextureAtlas(name:String):TextureAtlas
	{
		if (_textureatlas.exists(name))
			return _textureatlas.get(name);
		else {
			var data:TextureAtlas = TextureAtlas.loadTexturePacker(name);
			_textureatlas.set(name, data);
			return data;
		}
	}

	public static function removeTextureAtlas(name:String):Bool
	{
		if (_textureatlas.exists(name))
		{
			var textureAtlas = _textureatlas.get(name);
			textureAtlas.destroy();
			return _textureatlas.remove(name);
		}
		return false;
	}

	public static function drawTextureAtlas(target:Graphics,name:String,region:String,x:Float,y:Float):Void {
        getTextureAtlas(name).getRegion(region).drawNow(target,x,y);
	}

}