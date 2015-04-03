
package com.akifox.plik;

import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.text.AntiAliasType;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import com.akifox.transform.Transformation;

class Text extends TextField
{

	// DefaultFont is used by TextAA as well
	private static var _defaultFont:String="";
	public static var defaultFont(get,set):String;
	private static function get_defaultFont():String {
		return _defaultFont;
	}
	private static function set_defaultFont(value:String):String {
		return _defaultFont = value;
	}

  //##########################################################################################

	var textField:TextField;
	var textFieldFont:Font;
	var textFieldColor:Int;
	var textFieldFormat:TextFormat;
	var textFieldSize:Int;

	private function redraw() {
		if (_transformation != null) _transformation.updateSize();
	}

  public function setText(value:String) {
      textField.text = value;
      redraw();
    return value;
  }

	public function setColor(value:Int) {
        textFieldFormat.color = value;
        textField.defaultTextFormat = textFieldFormat;
        textField.setTextFormat(textFieldFormat);
        redraw();
        return value;
    }

	public function new (stringText:String="",?size:Int=20,?color:Int=0,?align:#if !v2 TextFormatAlign #else String = null #end,?font:String="",?smoothing:Bool=true) {

		super ();

    if (align==null) align = TextFormatAlign.LEFT;

    textFieldSize = size;
    textFieldColor = color;
    if (font=="") font = _defaultFont;
    textFieldFont = PLIK.getFont(font);

		textField = this;

		//prepare the TextFormat
    textFieldFormat = new TextFormat(textFieldFont.fontName, textFieldSize , textFieldColor);

    textFieldFormat.align = align;
    textField.autoSize = TextFieldAutoSize.LEFT;
    textField.antiAliasType = AntiAliasType.ADVANCED;
    textField.defaultTextFormat = textFieldFormat;
    textField.embedFonts = true;
    textField.selectable = false;
    textField.wordWrap = false;
    textField.border = false;
		text = stringText;

    _transformation = new Transformation(this.transform.matrix,this.width,this.height);
    _transformation.bind(this);

	}

	private var _transformation:Transformation;
	public var t(get,never):Transformation;
	private function get_t():Transformation {
	    return _transformation;
	}

	//##########################################################################################
	// IDestroyable

	public override function toString():String {
	    return '[PLIK.Text "'+text+'"]';
	}

	public function destroy() {

	  #if gbcheck
	  trace('GB Destroy > ' + this);
	  #end

		// destroy this element
		this._transformation.destroy();
		this._transformation = null;
	}

}
