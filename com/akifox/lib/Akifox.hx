package com.akifox.lib;

import openfl.display.Tilesheet;
import openfl.text.Font;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.display.StageDisplayState;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import motion.Actuate;
import motion.easing.*;

import openfl.system.Capabilities;

import openfl.events.TouchEvent;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;

import com.akifox.lib.Screen;

class Akifox
{

	//##########################################################################################
	
	/** Constant factor to pass from degrees to radians **/
    public static var DEG2RAD:Float = Math.PI/180;
	/** Constant factor to pass from radians to degrees **/
    public static var RAD2DEG:Float = 180/Math.PI;

	public static inline var TRANSITION_NONE:String = "NONE";
	public static inline var TRANSITION_ALPHA:String = "ALPHA";
	public static inline var TRANSITION_SLIDE_DOWN:String = "SLIDEUP";
	public static inline var TRANSITION_SLIDE_UP:String = "SLIDEDOWN";
	public static inline var TRANSITION_SLIDE_LEFT:String = "SLIDELEFT";
	public static inline var TRANSITION_SLIDE_RIGHT:String = "SLIDERIGHT";

    // temporary objects (always reset them before using)
    public static var point:Point = new Point();
    public static var point2:Point = new Point();
    public static var rect:Rectangle = new Rectangle();
    public static var matrix:Matrix = new Matrix();

	//##########################################################################################


	public static var id:String = "";

	private static var inTransition:Bool = false;

	public static function initialize(screenContainer:DisplayObjectContainer,appid:String):Void {								
		if (screenContainer != null){
			_screenContainer = screenContainer;			
		} else {
			throw new Error("AKIFOX Error: Cannot initialize screen container. The value is null.");
		}
		id = appid;
		_transition_mode = TRANSITION_NONE;

		//sound init
		initSfx();

		Lib.current.stage.addEventListener(FocusEvent.FOCUS_IN,focus);
		Lib.current.stage.addEventListener(FocusEvent.FOCUS_OUT,defocus);
		Lib.current.stage.addEventListener(Event.ACTIVATE,focus);
		Lib.current.stage.addEventListener(Event.DEACTIVATE,defocus);
		//#if !mobile
		//Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP,keyUp);
		//#end


/*		trace(openfl.system.Capabilities.screenResolutionX,'x',
			  openfl.system.Capabilities.screenResolutionY,'@',
			  openfl.system.Capabilities.screenDPI);*/
		#if !flash
		realresolution = [Capabilities.screenResolutionX,Capabilities.screenResolutionY];
		#else
		realresolution = [Lib.current.stage.stageWidth,Lib.current.stage.stageHeight];
		#end
		setResolution();

		multitouchEnable();

	}


	//##########################################################################################
	//
	// RESOLUTION MANAGEMENT
	//
	//##########################################################################################

	private static var realresolution = [0.0,0.0];
	private static var resolution = [0.0,0.0];
	public static var resolutionX(get,never):Float;
	private static function get_resolutionX():Float{
		return resolution[0];
	}
	public static var resolutionY(get,never):Float;
	private static function get_resolutionY():Float{
		return resolution[1];
	}
	private static inline var _ratio:Float = 16/9;

	private static var _pointFactor:Float = 1;
	public static var pointFactor(get, never):Float;
	private static function get_pointFactor():Float {
		return _pointFactor;
	}

	public static function setResolution(){
		var w:Float = realresolution[0];
		#if !ios
		if (w > 1920) { //2560
				resolution = [2560,2560/_ratio];
		} else 
		#end
		if (w > 1280) { //1920
				resolution = [1920,1920/_ratio];
		} else if (w > 640) { //1280
				resolution = [1280,1280/_ratio];
		} else { //640
				resolution = [640,640/_ratio];
		}
		//resolution = [640,640/_ratio];
		//resolution = [2560,2560/_ratio];
		_pointFactor = resolution[0]/2560;
		//trace('real: ',realresolution,' game: ',resolution);
		//trace(_pointFactor);
	}

	public static var multitouchOn:Bool = false;

	private static function multitouchEnable(){
		multitouchOn = Multitouch.supportsTouchEvents;
		if (multitouchOn)
		{
			// If so, set the input mode and hook up our event handlers
			// TOUCH_POINT means simple touch events will be dispatched, 
			// rather than gestures or mouse events
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
	}

	private static function keyUp(event:KeyboardEvent) {
/*		if(_currentScene==null) return;
		switch (event.keyCode) {
			case Keyboard.P:
				if(_currentScene.paused) play();
				else pause();
			case Keyboard.F:
				toggleFullscreen();
			case Keyboard.M:
				toggleMusic();
		}*/
	}

	public static function pause():Void {
		if (_currentScene==null) return;
		if (_currentScene.pausable) {
			if (inTransition) _currentScene.paused = true; // start() will handle it
			else _currentScene.pause();
		}
	}

	public static function play():Void {
		if (_currentScene==null) return;
			if (inTransition) _currentScene.paused = false; // start() will handle it
			else _currentScene.play();
	}

	private static function focus(event:Dynamic):Void {
		if (_currentScene==null) return;
		_currentScene.resume();
	}

	private static function defocus(event:Dynamic):Void { 
		if (_currentScene==null) return;
		_currentScene.hold();
	}


	//##########################################################################################
	//
	// SCENE MANAGEMENT
	//
	//##########################################################################################

	public static inline var _transition_offset = 300; // offset drawing for the ghost
	public static inline var _transition_span = 250; // distance between slides

	private static var _currentScene(default, null):Screen;
	private static var _oldScene(default, null):Screen;
	private static var _holdScene(default, null):Screen;
	private static var _screenContainer:DisplayObjectContainer;

	public static var _transition_mode:String = ""; // USE TRANSITION_XXX

	private static var _isSceneOnHold:Bool=false;
	private static var _makeSceneOnHold:Bool=false;


	private static var currentWidth:Float;
	private static var currentHeight:Float;
	
/*	private static var previousTime:Int = 0;	
	public static function update():Void {
		var currentTime:Int = Lib.getTimer();
		var deltaTime = (currentTime - previousTime) / 1000;	
		
		_currentScene.update(deltaTime);
		
		previousTime = currentTime;
	}*/

	public static function resize():Void {
		_currentScene.resize();
	}

	public static function hasHoldScene():Bool {
		return !(_holdScene==null);
	}

	public static function getHoldScene():Dynamic {
		return _holdScene;
	}

	public static function getScene():Screen {
		return _currentScene;
	}

	private static function destroyScene(scene:Screen) {
		if (scene==null) return;
    	#if gbcheck
    	trace('AKIFOX ---------- start removing scene ---------------');
    	#end
		scene.unload();
		scene.destroy();
		_screenContainer.removeChild(scene);
		scene = null;
    	#if gbcheck
    	trace('AKIFOX ---------- scene removed ---------------');
    	#end
	}

	public static function changeScreen(?newScreen:Screen=null,?transition:String="") {
		loadScreen(newScreen,transition,false);
	}

	public static function resumeScreen(?transition:String="") {
		loadScreen(null,transition,false);
	}

	public static function holdScreen(?newScreen:Screen=null,?transition:String="") {
		loadScreen(newScreen,transition,true);
	}

	public static function destroyHold(){
		if (_holdScene==null) return;
		destroyScene(_holdScene);
		_holdScene==null;
	}
	
	private static function loadScreen(?newScreen:Screen=null,?transition:String="",?modal:Bool=false):Void {
		
		// newScreen == null && modal = false    -->  get hold screen
		// newScreen == screen && modal = true   -->  make hold screen
		// newScreen == screen && modal = false  -->  change screen

		if (newScreen==null) modal = false;

		var isResume = (newScreen==null && modal == false);
		var isMakeHold = (newScreen!=null && modal == true);

		//if (_holdScene==null && !isMakeHold) Actuate.reset();

		if (_screenContainer != null) {

			inTransition = true;

			currentWidth = Lib.current.stage.stageWidth;
			currentHeight = Lib.current.stage.stageHeight;

			if (transition != "") _transition_mode = transition;
			//_transition_mode = TRANSITION_NONE;

			if (_currentScene != null) {

				_currentScene.hold();
				
				if (isMakeHold) {
					//trace('1. modal hold scene');
					destroyHold();
					_holdScene = _currentScene;
					_makeSceneOnHold = true;
				}// else {
					//trace('1. not modal destroy scene');
					//if (_holdScene!=null && newScreen!=null) {
						//trace('1.5 not modal destroyhold');
					//}
				//}
				_oldScene = _currentScene;
				_currentScene = null;
			}
			//else{
				//trace('0. NO PREVIOUS SCREEN');
				//trace('1. NO PREVIOUS SCREEN');
			//}	
			
			#if flash
			openfl.system.System.gc();
			#elseif cpp
			cpp.vm.Gc.run(true);
			#elseif neko		
			neko.vm.Gc.run(true);
			#end

			if (isResume) {
				//trace('2. get hold screen');
				_currentScene = _holdScene;
				_currentScene.resize(); //reset the x,y
				_holdScene = null;
				_isSceneOnHold = true;
				sceneReady(); //launch manually
			} else {
				//trace('2. get new screen');
				newScreen.initialize();
				_currentScene = newScreen;
				newScreen = null;
				// sceneReady(); will be launch automatically by the newScreen
			}
			_screenContainer.addChild(_currentScene); //add the next screen on stage
		}
	}


	public static function sceneReady():Void {
		//trace('3. scene ready');

		if (_transition_mode == TRANSITION_NONE) {
			sceneStart();
			return;
		}

		var timing = 1;
		var delay = 0;//#if mobile 0.2 #else 0 #end; //ios needs bit of delay

		var ghostEase = Sine.easeIn;
		var sceneEase = Expo.easeOut;

		_currentScene.alpha = 1; //reset the alpha

		var baseX = _currentScene.x;
		var baseY = _currentScene.y;
		var oldX:Float = 0;
		var oldY:Float = 0;
		if (_oldScene != null) {
			oldX = _oldScene.x;
			oldY = _oldScene.y;
		}

		switch (_transition_mode) {
			case TRANSITION_ALPHA:
				_currentScene.alpha = 0;
				if (_oldScene!=null) Actuate.tween (_oldScene, timing, { alpha: 0 }).delay(delay);
				Actuate.tween (_currentScene, timing, { alpha: 1 }).delay(delay).onComplete(sceneStart);
			case TRANSITION_SLIDE_UP:
				_currentScene.y += currentHeight+_transition_span;
				if (_oldScene!=null) {
					Actuate.tween (_oldScene, timing, { y: oldY-currentHeight-_transition_span }).ease(ghostEase).delay(delay);
					Actuate.tween (_oldScene, timing/3+0.1, { alpha:0 }).ease(ghostEase).delay(delay);
				}
				Actuate.tween (_currentScene, timing, { y: baseY }).ease(sceneEase).delay(delay).onComplete(sceneStart);
			case TRANSITION_SLIDE_DOWN:
				_currentScene.y -= currentHeight+_transition_span;
				if (_oldScene!=null) {
					Actuate.tween (_oldScene, timing, { y: oldY+currentHeight+_transition_span }).ease(ghostEase).delay(delay);
					Actuate.tween (_oldScene, timing/3+0.1, { alpha:0 }).ease(ghostEase).delay(delay);	
				}
				Actuate.tween (_currentScene, timing, { y: baseY }).ease(sceneEase).delay(delay).onComplete(sceneStart);
			case TRANSITION_SLIDE_LEFT:
				_currentScene.x += currentWidth+_transition_span;
				if (_oldScene!=null) {
					Actuate.tween (_oldScene, timing, { x: oldX-currentWidth-_transition_span }).ease(ghostEase).delay(delay);
					Actuate.tween (_oldScene, timing/3+0.1, { alpha:0 }).ease(ghostEase).delay(delay);	
				}
				Actuate.tween (_currentScene, timing, { x: baseX }).ease(sceneEase).delay(delay).onComplete(sceneStart);
			case TRANSITION_SLIDE_RIGHT:
				_currentScene.x -= currentWidth+_transition_span;
				if (_oldScene!=null) {
					Actuate.tween (_oldScene, timing, { x: oldX+currentWidth+_transition_span }).ease(ghostEase).delay(delay);	
					Actuate.tween (_oldScene, timing/3+0.1, { alpha:0 }).ease(ghostEase).delay(delay);
				}
				Actuate.tween (_currentScene, timing, { x: baseX }).ease(sceneEase).delay(delay).onComplete(sceneStart);
		}
	}

	private static function sceneStart():Void {
		if (_makeSceneOnHold) {
			_oldScene = null;
		}else{
			destroyScene(_oldScene);
		}
		inTransition = false;

		if (_isSceneOnHold) {
			sceneContinue();
			return;
		}
		//trace('4. scene start');
		_currentScene.start();
		_makeSceneOnHold = false;
	}

	private static function sceneContinue():Void {
		//trace('4. scene continue');
		_currentScene.resume();
		_isSceneOnHold = false;
	}



	//##########################################################################################
	//
	// STORAGE
	//
	//##########################################################################################

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

	private static var _music:Sfx;
	private static var _musicOut:Sfx;
	private static var _musicLast:String;
	private static var _musicOn:Bool=false;
	private static var _soundOn:Bool=false;

	public static function initSfx(){
		Sfx.setVolume('sound',0);
		Sfx.setVolume('music',1); //fixed
	}

	public static function startMusic(file:String=null,?direct:Bool=false) {
		if (!_musicOn) {
			if (file!=null) _musicLast = file;
			return;
		}
		if ((file==_musicLast) || (file==null && _music != null)) return; //already started

		Actuate.stop(_music);
		Actuate.stop(_musicOut);

		if (_musicOut!=null) _musicOut.stop();
		if (_music!=null) {
			_musicOut = _music;
			_musicOut.volume = 1;
			Actuate.tween(_musicOut, 2, {volume:0}).ease(Sine.easeOut).onComplete(function(){
				_musicOut.stop();
				_musicOut = null;
			});
		}

		if (file==null) {
			if (_musicLast==null) return;
			file = _musicLast;
		} else {
			_musicLast = file;
		}
		
		_music = getMusic(file);
		_music.loop();
		if (!direct) {
			_music.volume = 0;
			Actuate.tween(_music, 2, {volume:1}).ease(Sine.easeOut);
		}
	}

	public static function stopMusic() {
		if (!_musicOn || _music == null) return;
		Actuate.stop(_music);
		_music.volume = 1;
		Actuate.tween(_music, 0.5, {volume:0}).ease(Sine.easeOut).onComplete(function(){
			_music.stop();
			_music = null;
		});
	}

	public static function prepareMusic(file:String) {
		_musicLast = file;
	}

	private static function getMusic(file:String):Sfx {
		var _m = new Sfx(file);
		_m.type = "music";
		return _m;
	}

	public static function getMusicOn():Bool {
		return _musicOn;
	}

	public static function getSoundOn():Bool {
		return _soundOn;
	}

	public static function toggleMusic():Bool {
		if(_musicOn) {
			stopMusic();
			_musicOn = false;
		} else {
			_musicOn = true;
			startMusic();
		}
		setPref('music',_musicOn);
		savePref();
		return _musicOn;
	}

	public static function toggleSound():Bool {
		if(_soundOn) {
			_soundOn = false;
			Sfx.setVolume('sound',0);
		} else {
			_soundOn = true;
			Sfx.setVolume('sound',1);
		}
		setPref('sound',_soundOn);
		savePref();
		return _soundOn;
	}


	//##########################################################################################
	//
	// PREFERENCES
	//
	//##########################################################################################
	
	private static inline var prefID = 'pref';

	public static function setPrefField(name:String,type:Int,defaultValue:Dynamic){
		Data.setDataField(prefID,name,type,defaultValue);
	}

	public static function initPref() {

		Data.loadData(prefID);

		setPrefField('music',Data.BOOL,true);
		setPrefField('sound',Data.BOOL,true);
		setPrefField('fullscreen',Data.BOOL,true);

		// toggle base pref
		if (getPref('music')) toggleMusic();
		if (getPref('sound')) toggleSound();
		if (getPref('fullscreen')) toggleFullscreen();
	}

	public static function savePref() {
		Data.saveData(prefID);
	}


	//standard are 'music' 'sound' 'fullscreen'
	public static function getPref(name:String,?defaultValue:Dynamic=null):Dynamic {
		return Data.readData(prefID,name,defaultValue);
	}

	public static function setPref(name:String,value:Dynamic) {
		Data.writeData(prefID,name,value);
	}

	//##########################################################################################
	//
	// UID
	//
	//##########################################################################################
	
	private static var UID_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

	public static function randomUID(?size:Int=32):String
	{
		var nchars = UID_CHARS.length;
		var uid = new StringBuf();
		for (i in 0 ... size){
			uid.addChar(UID_CHARS.charCodeAt( Std.random(nchars) ));
		}
		return uid.toString();
	}

	//##########################################################################################
	//
	// OTHERS
	//
	//##########################################################################################

	public static function getFullscreenOn():Bool {
	#if mobile
		return true;
	#else
		return Lib.current.stage.displayState != StageDisplayState.NORMAL;
	#end
	}

	public static function toggleFullscreen():Bool {
	var _fullscreenOn = false;
	#if mobile
		_fullscreenOn = true;
	#elseif !flash
		if(Lib.current.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
			Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			_fullscreenOn = true;
		}else {
			Lib.current.stage.displayState = StageDisplayState.NORMAL;
			_fullscreenOn = false;
		}
	#end
	setPref('fullscreen',_fullscreenOn);
	savePref();
	return _fullscreenOn;
	}

	public static function quit(){
		#if (!flash && !html5 && !next)
		Lib.exit();
		#end
	}

}