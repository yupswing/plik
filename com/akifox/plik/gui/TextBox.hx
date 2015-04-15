package com.akifox.plik.gui;
import com.akifox.plik.*;
import systools.Clipboard;
import openfl.events.KeyboardEvent;

class TextBox extends Box
{
    private var _width:Float = 0;
    private var _height:Float = 0;

    public var value(get,set):String;
    private function get_value():String {return _text.text;}
    private function set_value(value:String):String {
      return _text.text = value;
    }

    var _text:Text;

    public override function getNetWidth():Float {
      return Math.max(_width,_text.width);
    }

    public override function getNetHeight():Float {
      return Math.max(_height,_text.height);
    }

    var _isInput:Bool = false;

    var _supportPaste:Bool = false;
    public var supportPaste(get,set):Bool;
    private function get_supportPaste():Bool {return _supportPaste;}
    private function set_supportPaste(value:Bool):Bool {
      if (value==_supportPaste) return value;
      if (value) {
        addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
      } else {
        removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
      }
      return _supportPaste = value;
    }

  	public function new (style:Style,isInput:Bool,?width:Float=0,?height:Float=0,?defaultText:String) {
      super(style);
      _width = width;
      _height = height;
      _isInput = isInput;

      _text = new Text(defaultText,_style.font_size,Style.toColor(_style.color),null,_style.font_name);
      if (isInput) {
        _text.setInput(true);
        _text.setFocus();
      } else {
        _text.setAlign(#if (!v2 || flash) TextFormatAlign.CENTER #else "center" #end);
      }
      if (width > 0 || height > 0) {
        _text.width = width;
        _text.height = height;
        _text.setWordWrap(true);
        _text.setSelectable(true);
      }
      addChild(_text);
      updatePosition();
      super.draw();

    }

    public function setWordWrap(wrap:Bool,maxWidth:Int=0,maxHeight:Int=0) {
      _text.setWordWrap(wrap);
      if (maxWidth>0) {
        _text.width = maxWidth;
        if (_isInput) _width = maxWidth;
      }
      if (maxHeight>0) {
        _text.height = maxHeight;
        if (_isInput) _height = maxWidth;
      }
      updatePosition();
      super.draw();
    }

    public function setFocus() {
      if (_isInput) _text.setFocus();
    }

    private function updatePosition() {
      _text.x = _style.padding;//getNetWidth()/2-_text.width/2+_style.padding;
      _text.y = _style.padding;//getNetHeight()/2-_text.height/2+_style.padding;
    }

    public function setSelectable(value:Bool):Bool {
      return _text.setSelectable(true);
    }

    public override function destroy() {
      supportPaste = false; // this removes the event listener if present
      super.destroy();
    }


    // Unable to
    var _lastKeyCode = 0;
    private function onKeyDown(event:KeyboardEvent) {
      //trace('event! CTRL ${event.ctrlKey} ALT ${event.altKey} SHIFT ${event.shiftKey} ${event.charCode} ${event.keyCode}');
      if ((_lastKeyCode == openfl.ui.Keyboard.COMMAND || _lastKeyCode == openfl.ui.Keyboard.CONTROL) && event.keyCode==openfl.ui.Keyboard.V) {
        motion.Actuate.timer(0.01).onComplete(function() { value = systools.Clipboard.getText(); });
      }
      _lastKeyCode = event.keyCode;
    }

}
