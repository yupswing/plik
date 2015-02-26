package com.akifox.lib.gui;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.filters.GlowFilter;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextFormatAlign;
import openfl.display.BitmapData;
/**
 *  Based on https://github.com/dmitryhryppa/dhFramework
 * */
class Button extends Sprite
{
	public var _textBitmap:Bitmap;
	private var _text:TextField;
	private var _textFormat:TextFormat;
	
	private var _bitmap:Bitmap;		
	private var _container:Sprite;
	private var scrollValue:Float;
	private var _states:Int;
	public function new(bitmapData:BitmapData, states:Int = 3,text = "", textSize:Int = 12, textColor:Int = 0x000000, smoothBitmap:Bool = true, stroke:Bool = false, strokeColor:Int = 0x000000, strokeSize:Float = 0) {
		super();				
		//this.buttonMode = true;
		
		//_container = new Sprite();
		_bitmap = new Bitmap(bitmapData);	
		_bitmap.smoothing = smoothBitmap;
		_bitmap.scaleX = 2;
		_bitmap.scaleY = 2;
		
/*		if (states > 3) states = 3; 
		if (states <= 0) states = 1;		
		_states = states;*/
		//scrollValue = _bitmap.height / states;
		
		//this.scrollRect = new Rectangle(0, 0, _bitmap.width, scrollValue);
		
		
/*		if (text != "") {			
			_textFormat = new TextFormat();
			_textFormat.size = textSize;
			_textFormat.color = textColor;
			_textFormat.bold = true;
			_textFormat.align = TextFormatAlign.CENTER;		
			
			_text = new TextField();		
			_text.defaultTextFormat = _textFormat;
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.width = _bitmap.width;					
			_text.height = scrollValue;					
			_text.embedFonts = true;		
			_text.selectable = false;	
			_text.text = text;
		
			if (stroke) {			
				_text.filters = [new GlowFilter(strokeColor, 1, strokeSize, strokeSize, 300, 1)];
			}		
		
			_container.addChild(_text);	
				
			//_textBitmap = //Funcs.spriteToBitmap(_container, true);
			//_textBitmap.x = _bitmap.width / 2 - _textBitmap.width / 2;
			//_textBitmap.y = scrollValue / 2 - _textBitmap.height / 2;
				
		}*/
		//_container.addChild(_bitmap);
		//this.addChild(_container);
		addChild(_bitmap);
		
/*		if (text != ""){
			this.addChild(_textBitmap);		
		
			_text.filters = null;
			_text = null;
			_textFormat = null;		
		}*/
		
/*		this.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
		this.addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
		this.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
		this.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
		
		this.addEventListener(Event.REMOVED_FROM_STAGE, unload);	*/			
	}
	
	private function mouseHandler(e:MouseEvent):Void {
		if (e.type == "mouseOver") {
			if (_states >= 2)
				_container.scrollRect = new Rectangle(0, scrollValue, _bitmap.width, scrollValue);			
			onOver(e.currentTarget);
		}		
		if (e.type == "mouseOut") {			
			_container.scrollRect = new Rectangle(0, 0, _bitmap.width, scrollValue);			
			onOut(e.currentTarget);
		}			
		if (e.type == "mouseDown") {
			if (_states == 3)
				_container.scrollRect = new Rectangle(0, scrollValue * 2, _bitmap.width, scrollValue);						
		}
		if (e.type == "mouseUp") {
			if (_states >= 2)
				_container.scrollRect = new Rectangle(0, scrollValue, _bitmap.width, scrollValue);						
			onClick(e.currentTarget);
		}		
	}
	
	
	//dynamic functions
	public dynamic function onClick(target:Dynamic):Void { };
	public dynamic function onOver(target:Dynamic):Void { };
	public dynamic function onOut(target:Dynamic):Void { };
	
	//clearing
	private function unload(e:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE, unload);			
		this.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
		this.removeEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
		this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);		
		this.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
		
		onClick = null;		
		onOut = null;
		onOver = null;		
				
		this.removeChild(_container);			
		
		_container = null;
		
		_bitmap.bitmapData.dispose();
		_bitmap = null;
		
		if (_textBitmap != null) {
			this.removeChild(_textBitmap);		
			_textBitmap.bitmapData.dispose();
			_textBitmap.bitmapData = null;
		}

	}
	
}