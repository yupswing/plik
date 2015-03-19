package com.akifox.plik;

import openfl.Assets;
import openfl.Lib;
import openfl.geom.Point;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Graphics;
import openfl.display.DisplayObject;
import com.akifox.plik.geom.Transformation;
import com.akifox.plik.atlas.TextureAtlas;

class Gfx extends Bitmap implements IDestroyable {

    
    private var _name:String;

    private var _transformation:Transformation;
    public var t(get,never):Transformation;
    private function get_t():Transformation {
        return _transformation;
    }

    public function new(name:String){
    	_dead = false;
        _name = name;
        super(getBitmap(name));
        this.smoothing = true;
        _transformation = new Transformation(this.transform.matrix,this.width,this.height);
        _transformation.bind(this);
    }

    public override function toString():String {
        return '[PLIK.Gfx '+_name+'"]';
    }

    public function destroyCache() {
    	// destroy this element and the global cache from memory
    	removeBitmap(_name);
    }

    //##########################################################################################
    // IDestroyable

    private var _dead:Bool=false;
    public var dead(get,never):Bool;
    public function get_dead():Bool { return _dead; }

    public function destroy() {
        _dead = true;
        //motion.Actuate.stop(this);

        #if gbcheck
        trace('GB Destroy > ' + this);
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
            trace('GB > Cache destroy > Bitmap ' + name);
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