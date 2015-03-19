package com.akifox.plik;

import haxe.Timer;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

import motion.Actuate;

/**
 
	Cycle is

	AKIFOX create -> NEW -> INITIALIZE -> listen ADDED_TO_STAGE event
	ADDED_TO_STAGE event -> construct -> fire SCENE_READY event
	AKIFOX listen SCENE_READY -> TRANSITION -> AKIFOX fire START

	AKIFOX unload -> UNLOAD


 */
class Screen extends Sprite implements IDestroyable
{				
	public var currentScale:Float = 1;
	public var rwidth:Float = 1;
	public var rheight:Float = 1;

	public var title:String = "Screen";

	private var resizePow:Bool = false;

	private var cycle:Bool = false;

	public var holdable:Bool = false;


	public function new () {
		super();
		rwidth = PLIK.resolutionX;
		rheight = PLIK.resolutionY;
	}

	// call at the loading
	public function initialize():Void {
		addEventListener(Event.ADDED_TO_STAGE, construct);
	}

	public function construct(event:Event) {
		removeEventListener(Event.ADDED_TO_STAGE, construct);
		resize();
		PLIK.sceneReady();
	}

	public override function toString():String {
		return "[PLIK.Screen \""+title+"\"]";
	}

	private var _dead:Bool=false;
	public var dead(get,never):Bool;
    public function get_dead():Bool { return _dead; }

	public function destroy():Void {
		_dead = true;

		if (numChildren != 0) {
			var i:Int = numChildren;	
			var child:Dynamic;
			do {
				i--;
				child = getChildAt(i);
		    	//#if gbcheck
		    	//trace("GB > -- Screen " + this + " -- > Launch destroy on " + child);
		    	//#end
				child.destroy();
				removeChildAt(i);							
			} while (i > 0);
		}
	}

	// call at the unloading
	public function unload():Void {
		//trace('unload'+this);
	}

	// the screen is ready (called by PLIK)
	public function start():Void {
		//trace('start'+this);
		resume();
	}

	// the screen is stopped on an hold (called by PLIK)
	public function hold():Void {
		//trace('hold'+this);
		if (cycle) Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onUpdate);
	}

	// the screen is ready after an hold (called by PLIK)
	public function resume():Void {
		//trace('resume'+this);
		_time = Timer.stamp();
		if (cycle) Lib.current.stage.addEventListener(Event.ENTER_FRAME, onUpdate);
	}

	private var _time:Float = 0;

	private function onUpdate(event:Event) {
		var now:Float = Timer.stamp();
		update(now-_time);
		_time = now;
	}
	private function update(delta:Float):Void { }

	public function resize():Void {
		//resizePow = true;
		//Lib.application.window.width
		//Lib.application.window.height
		var screenWidth = Lib.current.stage.stageWidth;
		var screenHeight = Lib.current.stage.stageHeight;

		// leave margins
		var maxWidth = screenWidth;// * 1.05;
		var maxHeight = screenHeight;// * 1.05;
		
		currentScale = 1;
		scaleX = 1;
		scaleY = 1;
		
		var currentWidth = rwidth; //use width foau
		var currentHeight = rheight;
		
		//if (currentWidth > maxWidth || currentHeight > maxHeight) {
			var maxScaleX = maxWidth / currentWidth;
			var maxScaleY = maxHeight / currentHeight;
			if (maxScaleX < maxScaleY) {
				currentScale = maxScaleX;
			} else {
				currentScale = maxScaleY;
			}

			//---
			// find closest 'round' scale (es: 0.125, 0.25, 0.5, 1, 2, 4, 8, 16...)
			if (resizePow) {
				var testNextScale:Float=0;
				var testCurrentScale:Float;
				var testSwapScale:Float;
				var factor:Float;
				if (currentScale > 1) factor = 2;
				else factor = 0.5;
				testCurrentScale = 1;
				testNextScale = testCurrentScale * factor;
				while (Math.abs(testNextScale-currentScale)<Math.abs(testCurrentScale-currentScale)) {
					testNextScale *= factor;
					testCurrentScale *= factor;
	    		}
				currentScale = testCurrentScale;
			}
			//---

			scaleX = currentScale;
			scaleY = currentScale;
		//}
		
		x = screenWidth / 2 - (currentWidth * currentScale) / 2;
		y = screenHeight / 2 - (currentHeight * currentScale) / 2;
	}
}