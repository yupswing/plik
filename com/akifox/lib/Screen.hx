package com.akifox.lib;

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
class Screen extends Sprite
{				
	public var currentScale:Float = 1;
	private var rwidth:Float = 500;
	private var rheight:Float = 500;

	private var resizePow:Bool = false;

	public var paused:Bool = false;
	public var pausable:Bool = true;
	private var cycle:Bool = false;


	public function new () {
		super();
	}

	// call at the loading
	public function initialize():Void {
		addEventListener(Event.ADDED_TO_STAGE, construct);
		if (cycle) Lib.current.stage.addEventListener(Event.ENTER_FRAME, onUpdate);
	}

	public function construct(event:Event) {
		removeEventListener(Event.ADDED_TO_STAGE, construct);

		resize();
		Akifox.sceneReady();
	}

	// call at the unloading
	public function unload():Void { }

	// the screen is ready
	public function start():Void {
		resume();
		if (paused) pause(); //handle the pause triggered during transitions Akifox
	}

	// the screen is stopped on an hold
	public function hold():Void { }

	// the screen is ready after an hold
	public function resume():Void { }

	public function play():Void {
		if (!paused) return; //no double play
		paused = false;
		if (cycle) Lib.current.stage.addEventListener(Event.ENTER_FRAME, onUpdate);
		Actuate.resumeAll();
	}

	public function pause():Void {
		if (paused) return; //no double pause
		if (cycle) Lib.current.stage.removeEventListener(Event.ENTER_FRAME, onUpdate);
		Actuate.pauseAll();
		paused = true;
	}

	private function onUpdate(event:Event) {
		update();
	}
	private function update():Void { }

	public function resize():Void {
		//Lib.application.window.width
		//Lib.application.window.height
		var screenWidth = Lib.current.stage.stageWidth;
		var screenHeight = Lib.current.stage.stageHeight;

		// leave margins
		var maxWidth = screenWidth * 1.05;
		var maxHeight = screenHeight * 1.05;
		
		currentScale = 1;
		scaleX = 1;
		scaleY = 1;
		
		var currentWidth = rwidth; //use width foau
		var currentHeight = rheight;
		
		if (currentWidth > maxWidth || currentHeight > maxHeight) {
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
		}
		
		x = screenWidth / 2 - (currentWidth * currentScale) / 2;
		y = screenHeight / 2 - (currentHeight * currentScale) / 2;
	}
}