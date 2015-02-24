
package com.akifox.lib.screens;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.Lib;

// import for ghost
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import motion.Actuate;
import motion.easing.*;
/**
 * Based on https://github.com/dmitryhryppa/dhFramework
 */
class Manager
{			

	public static var transitionMode:String = "";
	public static inline var TRANSITION_NONE:String = "NONE";
	public static inline var TRANSITION_ALPHA:String = "ALPHA";
	public static inline var TRANSITION_SLIDE_DOWN:String = "SLIDEUP";
	public static inline var TRANSITION_SLIDE_UP:String = "SLIDEDOWN";
	public static inline var TRANSITION_SLIDE_LEFT:String = "SLIDELEFT";
	public static inline var TRANSITION_SLIDE_RIGHT:String = "SLIDERIGHT";

	public static inline var offset = 250; //offset drawing for the ghost
	public static inline var span = 100; // distance between slides

	private static var _currentScene(default, null):IScreen;
	private static var _screenContainer:DisplayObjectContainer;
	
	public static function initialize(screenContainer:DisplayObjectContainer):Void {								
		if (screenContainer != null){
			_screenContainer = screenContainer;			
		} else {
			throw new Error("Error: Cannot initialize screen container in ScreenManager. The value is null.");
		}
	}
	
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

	private static function makeBitmap(target:DisplayObject):BitmapData {
		// bounds and size of parent in its own coordinate space
		var rect:Rectangle = target.parent.getBounds(target);
		var bmp:BitmapData = new BitmapData(Std.int(rect.width)+offset*2, Std.int(rect.height)+offset*2, true, 0);

		// offset for drawing
		var matrix:Matrix = target.transform.matrix.clone();//new Matrix();
		matrix.tx+=offset;
		matrix.ty+=offset;

		// Note: we are drawing parent object, not target itself: 
		// this allows to save all transformations and filters of target
		bmp.draw(target, matrix);
		return bmp;
	}
	
	private static var ghost:Bitmap;
	private static function deleteGhost():Void {
		if (ghost==null) return;
		_screenContainer.removeChild(ghost);
		ghost = null;
	}
	
	public static function loadScreen(newScreen:IScreen,?transition:String=""):Void {

		if (_screenContainer != null) {

			Actuate.stop(ghost);
			ghost = null;

			if (transition != "") transitionMode = transition;

			if (_currentScene != null) {
				Actuate.stop(cast _currentScene);

				if (transition != Manager.TRANSITION_NONE) {
					ghost = new Bitmap(makeBitmap(cast _currentScene));
					ghost.alpha = 1;
					ghost.visible = true;
					ghost.x=-offset;
					ghost.y=-offset;
					_screenContainer.addChild(ghost);
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

			switch (transitionMode) {
				case Manager.TRANSITION_ALPHA:
					cast(_currentScene, Sprite).alpha = 0;
					if (ghost!=null) Actuate.tween (ghost, timing, { alpha: 0 }).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { alpha: 1 });
				case Manager.TRANSITION_SLIDE_DOWN:
					cast(_currentScene, Sprite).y += currentHeight+span;
					if (ghost!=null) Actuate.tween (ghost, timing, { y: -currentHeight-span-offset }).ease(ghostEase).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { y: sceneY }).ease(sceneEase);
				case Manager.TRANSITION_SLIDE_UP:
					cast(_currentScene, Sprite).y -= currentHeight+span;
					if (ghost!=null) Actuate.tween (ghost, timing, { y: currentHeight+span-offset }).ease(ghostEase).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { y: sceneY }).ease(sceneEase);
				case Manager.TRANSITION_SLIDE_RIGHT:
					cast(_currentScene, Sprite).x += currentWidth+span;
					if (ghost!=null) Actuate.tween (ghost, timing, { x: -currentWidth-span-offset }).ease(ghostEase).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { x: sceneX }).ease(sceneEase);
				case Manager.TRANSITION_SLIDE_LEFT:
					cast(_currentScene, Sprite).x -= currentWidth+span;
					if (ghost!=null) Actuate.tween (ghost, timing, { x: currentWidth+span-offset }).ease(ghostEase).onComplete(deleteGhost);	
					Actuate.tween (_currentScene, timing, { x: sceneX }).ease(sceneEase);
			}
		}
	}
}