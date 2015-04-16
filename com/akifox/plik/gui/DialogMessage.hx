package com.akifox.plik.gui;
import com.akifox.plik.*;


class DialogMessage extends Dialog
{
    var _box:Box;
    var _buttonOk:Button;
    var _buttonCancel:Button;
    var _text:TextBox;

    var _boxStyle:Style;

  	public function new (callback:Dialog->Void,input:Bool,message:String,style:Style,boxStyle:Style,buttonStyle:Style,textStyle:Style) {
      super(style,false,callback);
      _box = new Box(boxStyle);
      _boxStyle = boxStyle;

      _buttonOk = new Button("ok");
      _buttonOk.listen = true;
      _buttonOk.actionF = function(_) {
          if (input) this.value = _text.value;
          else this.value = true;
          _callback(this);
      };
      _buttonOk.style = buttonStyle;
      _buttonOk.makeText("OK");

      _buttonCancel = new Button("cancel");
      _buttonCancel.listen = true;
      _buttonCancel.actionF = function(_) {
          if (input) this.value = "";
          else this.value = false;
          _callback(this);
      };
      _buttonCancel.style = buttonStyle;
      _buttonCancel.makeText("Cancel");

      _text = new TextBox(textStyle,input,0,0,message);
      _text.alpha = Style.toAlpha(textStyle.color);

      _box.addChild(_text);
      _box.addChild(_buttonOk);
      _box.addChild(_buttonCancel);

      updatePosition();

      addChild(_box);
    }

    public override function destroy() {
      _text.destroy();
      _buttonOk.destroy();
      _buttonCancel.destroy();
      _box.destroy();
      super.destroy();
    }

    var _showCancelButton:Bool=true;
    public var showCancelButton(never,set):Bool;
    private function set_showCancelButton(value:Bool):Bool {
      if (value==_showCancelButton) return value;
      if (value) {
        _box.addChild(_buttonCancel);
      } else {
        _box.removeChild(_buttonCancel);
      }
      _showCancelButton = value;
      updatePosition();
      return value;
    }

    public var selectable(never,set):Bool;
    private function set_selectable(value:Bool):Bool {
      return _text.setSelectable(value);
    }

    public function setFocus() {
      _text.setCaretEnd();
      _text.supportPaste = true;
      _text.setFocus();
    }

    public function setWordWrap(wrap:Bool,?maxWidth:Int=0,?maxHeight:Int=0) {
      _text.setWordWrap(wrap,maxWidth,maxHeight);
      updatePosition();
    }

    private function updatePosition() {
      var boxWidth = getBoxWidth();
      var boxHeight = getBoxHeight();
      _text.x = _boxStyle.padding + boxWidth/2-_text.getGrossWidth()/2;
      _text.y = _boxStyle.padding;
      if (_showCancelButton) {
        _buttonCancel.y = _text.y+_text.getGrossHeight()+_boxStyle.offset;
        _buttonOk.y = _text.y+_text.getGrossHeight()+_boxStyle.offset;
        _buttonCancel.x = boxWidth/2+_boxStyle.padding-_buttonCancel.getGrossWidth()-_boxStyle.offset/2;
        _buttonOk.x = boxWidth/2+_boxStyle.padding+_boxStyle.offset/2;
      } else {
        _buttonOk.y = _text.y+_text.getGrossHeight()+_boxStyle.offset;
        _buttonOk.x = boxWidth/2-_buttonOk.getGrossWidth()/2+_boxStyle.padding;
      }
    }

    public var textOk(never,set):String;
    private function set_textOk(value:String):String {
      _buttonOk.makeText(value);
      updatePosition();
      return value;
    }

    public var textCancel(never,set):String;
    private function set_textCancel(value:String):String {
      _buttonCancel.makeText(value);
      updatePosition();
      return value;
    }

    private function getBoxWidth():Float{
      if (_showCancelButton) {
        return Math.max(Math.max(_text.getGrossWidth(),_buttonOk.getGrossWidth()+_boxStyle.offset+_buttonCancel.getGrossWidth()),_boxStyle.minWidth);
      } else {
        return Math.max(Math.max(_text.getGrossWidth(),_buttonOk.getGrossWidth()),_boxStyle.minWidth);
      }
    }

    private function getBoxHeight():Float{
      return Math.max(_text.getGrossHeight()+_boxStyle.offset+_buttonOk.getGrossHeight(),_boxStyle.minHeight);
    }

    public function drawDialogBox(width:Float,height:Float) {
      var boxWidth = getBoxWidth()+_boxStyle.padding*2;
      var boxHeight = getBoxHeight()+_boxStyle.padding*2;
      _box.x = width/2-boxWidth/2;
      _box.y = height/2-boxHeight/2;
      _box.draw(boxWidth,boxHeight);
      super.drawDialog(width,height);
    }

}
