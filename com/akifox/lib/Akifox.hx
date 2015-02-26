package com.akifox.lib;

import openfl.display.Tilesheet;
import openfl.text.Font;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import motion.Actuate;
import motion.easing.*;

import com.akifox.lib.screens.IScreen;

class Akifox
{

	
	public static function initialize(screenContainer:DisplayObjectContainer):Void {								
		if (screenContainer != null){
			_screenContainer = screenContainer;			
		} else {
			throw new Error("AKIFOX Error: Cannot initialize screen container. The value is null.");
		}
	}


	//##########################################################################################
	//
	// SCENE MANAGMENT
	//
	//##########################################################################################

	public static inline var _transition_offset = 250; //offset drawing for the ghost
	public static inline var _transition_span = 100; // distance between slides

	private static var _currentScene(default, null):IScreen;
	private static var _screenContainer:DisplayObjectContainer;

	public static var _transition_mode:String = ""; // USE Constants.TRANSITION_XXX
	
/*	private static var previousTime:Int = 0;	
	public static function update():Void {
		var currentTime:Int = Lib.getTimer();
		var deltaTime = (currentTime - previousTime) / 1000;	
		
		_currentScene.update(deltaTime);
		
		previousTime = currentTime;
	}*/

	public static function resize(screenWidth:Int,screenHeight:Int):Void {
		_currentScene.resize(screenWidth,screenHeight);
	}
	
	private static var _transition_ghost:Bitmap;
	private static function deleteGhost():Void {
		if (_transition_ghost==null) return;
		_screenContainer.removeChild(_transition_ghost);
		_transition_ghost = null;
	}
	
	public static function loadScreen(newScreen:IScreen,?transition:String=""):Void {

		if (_screenContainer != null) {

			Actuate.stop(_transition_ghost);
			_transition_ghost = null;

			if (transition != "") _transition_mode = transition;

			if (_currentScene != null) {
				Actuate.stop(cast _currentScene);

				if (transition != Constants.TRANSITION_NONE) {
					_transition_ghost = new Bitmap(Utils.makeBitmap(cast _currentScene,_transition_offset));
					_transition_ghost.smoothing = true;
					_transition_ghost.alpha = 1;
					_transition_ghost.visible = true;
					_transition_ghost.x=-_transition_offset;
					_transition_ghost.y=-_transition_offset;
					_screenContainer.addChild(_transition_ghost);
				}

				_screenContainer.removeChild(cast _currentScene);
				
				if (cast(_currentScene, Sprite).numChildren != 0) {			
					var i:Int = cast(_currentScene, Sprite).numChildren;			
					do {
						i--;
						cast(_currentScene, Sprite).removeChildAt(i);												
					} while (i > 0);
				}				
				
				_currentScene.unload();
				_currentScene = null;
			}		
			
			#if flash
			openfl.system.System.gc();
			#elseif cpp
			cpp.vm.Gc.run(true);
			#elseif neko		
			neko.vm.Gc.run(true);
			#end
			
			newScreen.initialize();
			_currentScene = newScreen;
			_screenContainer.addChild(cast _currentScene);

			var currentWidth = Lib.current.stage.stageWidth;
			var currentHeight = Lib.current.stage.stageHeight;
			var sceneX = cast(_currentScene,Sprite).x;
			var sceneY = cast(_currentScene,Sprite).y;
			var timing = 0.5;

			var ghostEase = Sine.easeIn;
			var sceneEase = Expo.easeOut;

			switch (_transition_mode) {
				case Constants.TRANSITION_ALPHA:
					cast(_currentScene, Sprite).alpha = 0;
					if (_transition_ghost!=null) Actuate.tween (_transition_ghost, timing, { alpha: 0 }).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { alpha: 1 });
				case Constants.TRANSITION_SLIDE_DOWN:
					cast(_currentScene, Sprite).y += currentHeight+_transition_span;
					if (_transition_ghost!=null) Actuate.tween (_transition_ghost, timing, { y: -currentHeight-_transition_span-_transition_offset }).ease(ghostEase).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { y: sceneY }).ease(sceneEase);
				case Constants.TRANSITION_SLIDE_UP:
					cast(_currentScene, Sprite).y -= currentHeight+_transition_span;
					if (_transition_ghost!=null) Actuate.tween (_transition_ghost, timing, { y: currentHeight+_transition_span-_transition_offset }).ease(ghostEase).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { y: sceneY }).ease(sceneEase);
				case Constants.TRANSITION_SLIDE_RIGHT:
					cast(_currentScene, Sprite).x += currentWidth+_transition_span;
					if (_transition_ghost!=null) Actuate.tween (_transition_ghost, timing, { x: -currentWidth-_transition_span-_transition_offset }).ease(ghostEase).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { x: sceneX }).ease(sceneEase);
				case Constants.TRANSITION_SLIDE_LEFT:
					cast(_currentScene, Sprite).x -= currentWidth+_transition_span;
					if (_transition_ghost!=null) Actuate.tween (_transition_ghost, timing, { x: currentWidth+_transition_span-_transition_offset }).ease(ghostEase).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { x: sceneX }).ease(sceneEase);
			}
		}
	}



	//##########################################################################################
	//
	// STORAGE
	//
	//##########################################################################################

	// Bitmap storage.
	private static var _bitmap:Map<String,BitmapData> = new Map<String,BitmapData>();

	public static function getBitmap(name:String):BitmapData
	{
		if (_bitmap.exists(name))
			return _bitmap.get(name);

		var data:BitmapData = openfl.Assets.getBitmapData(name, false);

		if (data != null)
			_bitmap.set(name, data);

		return data;
	}

/*	public static function overwriteBitmapCache(name:String, data:BitmapData):Void
	{
		removeBitmap(name);
		_bitmap.set(name, data);
	}*/

	public static function removeBitmap(name:String):Bool
	{
		if (_bitmap.exists(name))
		{
			var bitmap = _bitmap.get(name);
			bitmap.dispose();
			bitmap = null;
			return _bitmap.remove(name);
		}
		return false;
	}

	//##########################################################################################

	// Tilesheets storage.
	private static var _tilesheet:Map<String,Tilesheet> = new Map<String,Tilesheet>();

	public static function addTilesheet(name:String,columns:Int,rows:Int):Void {
		if (_tilesheet.exists(name)) return;
		var bitmap:BitmapData = getBitmap(name);
		var tileWidth = bitmap.width / columns;
		var tileHeight = bitmap.height / rows;
		if (bitmap!=null) {
			var data:Tilesheet = new Tilesheet(bitmap);
			for (x in 0...columns)
			{
				for (y in 0...rows) {
					data.addTileRect(new Rectangle(x*tileWidth, y*tileHeight, tileWidth, tileHeight));
				}
			}

			if (data != null)
				_tilesheet.set(name, data);
		}
	}

	public static function getTilesheet(name:String):Tilesheet
	{
		if (_tilesheet.exists(name))
			return _tilesheet.get(name);

		return null;
	}

	public static function removeTilesheet(name:String):Bool
	{
		if (_tilesheet.exists(name))
		{
			var tilesheet = _tilesheet.get(name);
			tilesheet = null;
			return _tilesheet.remove(name);
		}
		return false;
	}

	//##########################################################################################

	// Font storage.
	private static var _font:Map<String,Font> = new Map<String,Font>();

	public static function getFont(name:String):Font
	{
		if (_font.exists(name))
			return _font.get(name);

		var data:Font = openfl.Assets.getFont(name, false);

		if (data != null)
			_font.set(name, data);

		return data;
	}

/*	public static function overwriteBitmapCache(name:String, data:Font):Void
	{
		removeFont(name);
		_font.set(name, data);
	}*/

	public static function removeFont(name:String):Bool
	{
		if (_font.exists(name))
		{
			var font = _font.get(name);
			font = null;
			return _font.remove(name);
		}
		return false;
	}

	//##########################################################################################

}