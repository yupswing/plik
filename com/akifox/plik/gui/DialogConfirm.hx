package com.akifox.plik.gui;
import com.akifox.plik.*;


class DialogConfirm extends Dialog
{
    var _box:Box;
    var _buttonOk:Button;
    var _buttonCancel:Button;
    var _text:Text;

  	public function new (callback:Dialog->Void=null) {
      super(null,false,callback);
      _box = new Box(null);
      _buttonOk = new Button("ok");
      _buttonCancel = new Button("cancel");
      _text = new Text();
    }

    public function setText()

    private var _styleBox:Style;
    public var styleBox(never,set):Style;
    private function set_styleBox(style:Style):Style {
      return _box.style = style;
    }

    private var _styleButton:Style;
    public var styleButton(never,set):Style;
    private function set_styleButton(style:Style):Style {
      _buttonOk.style = style;
      _buttonCancel.style = style;
    }

    private var _styleText:Style;
    public var styleText(never,set):Style;
    private function set_styleText(style:Style):Style {
      _text.setColor(Style.toColor(style.color));
      _text.alpha = Style.toAlpha(style.color);
      return style;
    }

}
