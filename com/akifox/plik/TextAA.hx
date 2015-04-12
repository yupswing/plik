package com.akifox.plik;

#if (flash || (!v2 && !legacy))

// this class it's a TextField
// Flash renders the TextField beautifully and it doesn't need any trick
typedef TextAA = Text;

#else

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.text.AntiAliasType;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import com.akifox.transform.Transformation;

class TextAA extends Bitmap
{
	var textField:TextField;
	var textFieldFont:Font;
	var textFieldColor:Int;
	var textFieldFormat:TextFormat;
	var textFieldSize:Int;

 	// make the use of .text the same in every target
 	var textFieldBitmapData:BitmapData;

	public var text(get, set):String;

	function get_text():String {
	  return textField.text;
	}
	function set_text(value:String):String {
	  return setText(value);
	}

	function redraw() {
		var nw = Std.int(textField.textWidth);
		var nh = Std.int(textField.textHeight);
		bitmapData = null;

		if (textFieldBitmapData != null) {
			if (nw <= textFieldBitmapData.width && nh <= textFieldBitmapData.height) {
				// inside the old rect
				textFieldBitmapData.fillRect(new Rectangle(0,0,textFieldBitmapData.width,textFieldBitmapData.height), 0x00000000);
			} else {
				// bigger
				textFieldBitmapData.dispose();
				textFieldBitmapData = null;
	 	    	textFieldBitmapData = new BitmapData(nw, nh, true, 0x000000);
			}
	 	} else {
	 	    textFieldBitmapData = new BitmapData(nw, nh, true, 0x000000);
	 	}

  	textFieldBitmapData.draw(textField);

  	bitmapData = textFieldBitmapData;
    if (_transformation != null) _transformation.updateSize(nw,nh);
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

	public function new (stringText:String="",?size:Int=20,?color:Int=0,?align:#if (!v2 || flash) TextFormatAlign #else String = null #end,?font:String="",?smoothing:Bool=true) {

		super ();

    if (align==null) align = :#if (!v2 || flash) TextFormatAlign.LEFT #else "left" #end;

    textFieldSize = size;
    textFieldColor = color;
    if (font=="") font = Text.defaultFont;
    textFieldFont = PLIK.getFont(font);

		// this class is a Bitmap encapsulating a TextField
		textField = new TextField();
		bitmapData = textFieldBitmapData;
		this.smoothing = smoothing;

		//prepare the TextFormat
    textFieldFormat = new TextFormat(textFieldFont.fontName, textFieldSize , textFieldColor);

    textFieldFormat.align = align;
    textField.autoSize = TextFieldAutoSize.LEFT;
    textField.antiAliasType = AntiAliasType.ADVANCED;
    textField.defaultTextFormat = textFieldFormat;
		textField.setTextFormat(textFieldFormat);
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
      return '[PLIK.TextAA "'+text+'"]';
  }

  public function destroy() {

    #if gbcheck
    trace('GB Destroy > ' + this);
    #end

		// destroy this element
		this._transformation.destroy();
		this._transformation = null;

		bitmapData = null;
	 	textFieldBitmapData.dispose();
	 	textFieldBitmapData = null;
  }

}
#end
