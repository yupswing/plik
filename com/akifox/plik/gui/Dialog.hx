package com.akifox.plik.gui;
import com.akifox.plik.*;


class Dialog extends Box
{
    private var _width:Float = 0;
    private var _height:Float = 0;

    var _value:Dynamic;
    public var value(get,set):Dynamic;
    private function get_value():Dynamic {return _value;}
    private function set_value(value:Dynamic):Dynamic {
      return _value = value;
    }

    var _callback:Dialog->Void;

    public override function getNetWidth():Float {
      return _width;
    }

    public override function getNetHeight():Float {
      return _height;
    }

    public function drawDialog(?newWidth:Float=0,?newHeight:Float=0) {
      if (newWidth>0) _width = newWidth;
      if (newHeight>0) _height = newHeight;
      draw(_width,_height);
    }

  	public function new (style:Style,?startValue:Dynamic=null,?callback:Dialog->Void=null) {
      super(style);
      _value = startValue;
      _callback = callback;
    }

    public function close(value:Dynamic) {
      if (_callback!=null) _callback(this);
    }

}
