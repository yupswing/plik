package com.akifox.plik.gui;
import com.akifox.plik.*;


class DialogConfirm extends Dialog
{
    var _box:Box;
    var _buttonOk:Button;
    var _buttonCancel:Button;
    var _text:Text;

    var _boxStyle:Style;

  	public function new (callback:Dialog->Void,message:String,style:Style,boxStyle:Style,buttonStyle:Style,textStyle:Style) {
      super(style,false,callback);
      _box = new Box(boxStyle);
      _boxStyle = boxStyle;

      _buttonOk = new Button("ok");
      _buttonOk.listen = true;
      _buttonOk.actionF = function(_) { this.value = true; _callback(this); };
      _buttonOk.style = buttonStyle;
      _buttonOk.makeText("OK");

      _buttonCancel = new Button("cancel");
      _buttonCancel.listen = true;
      _buttonCancel.actionF = function(_) { this.value = false; _callback(this); };
      _buttonCancel.style = buttonStyle;
      _buttonCancel.makeText("Cancel");

      _text = new Text(message,textStyle.font_size,Style.toColor(textStyle.color),null,textStyle.font_name);
      _text.alpha = Style.toAlpha(textStyle.color);

      _box.addChild(_buttonOk);
      _box.addChild(_buttonCancel);
      _box.addChild(_text);

      // positions and first draw
      var boxWidth = getBoxWidth();
      var boxHeight = getBoxHeight();
      _text.x = boxStyle.padding + boxWidth/2-_text.width/2;
      _text.y = boxStyle.padding;
      _buttonCancel.y = _text.y+_text.height+boxStyle.offset;
      _buttonOk.y = _text.y+_text.height+boxStyle.offset;
      updateButtonsPosition();

      addChild(_box);
    }

    private function updateButtonsPosition() {
      var boxWidth = getBoxWidth();
      var boxHeight = getBoxHeight();
      _buttonCancel.x = boxWidth/2+_boxStyle.padding-_buttonCancel.getGrossWidth()-_boxStyle.offset/2;
      _buttonOk.x = boxWidth/2+_boxStyle.padding+_boxStyle.offset/2;
    }

    public var textOk(never,set):String;
    private function set_textOk(value:String):String {
      _buttonOk.makeText(value);
      updateButtonsPosition();
      return value;
    }

    public var textCancel(never,set):String;
    private function set_textCancel(value:String):String {
      _buttonCancel.makeText(value);
      updateButtonsPosition();
      return value;
    }

    private function getBoxWidth():Float{
      return Math.max(Math.max(_text.width,_buttonOk.getGrossWidth()+_boxStyle.offset+_buttonCancel.getGrossWidth()),_boxStyle.minWidth);
    }

    private function getBoxHeight():Float{
      return Math.max(_text.height+_boxStyle.offset+_buttonOk.getGrossHeight(),_boxStyle.minHeight);
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
