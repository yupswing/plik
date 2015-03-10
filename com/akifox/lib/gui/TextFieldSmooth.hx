
package com.akifox.lib.gui;

import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.text.AntiAliasType;

// TODO Editing going on to support transformations
// will be finished when Transform.hx is done

#if (flash || next)
// this class it's a TextField
// Flash renders the TextField beautifully and it doesn't need any trick
class TextFieldSmooth extends TextField
#else
// this class is a Bitmap encapsulating a TextField
// the TextField will be drawn every time it changes (now only .text)
import openfl.display.Bitmap;
import openfl.display.BitmapData;
class TextFieldSmooth extends Bitmap
#end
{
	var textField:TextField;
	var textFieldFont:Font;
	var textFieldColor:Int;
	var textFieldFormat:TextFormat;
	var textFieldSize:Int;
	var textFieldAlign:String;

 	#if (!flash && !next)
 	// make the use of .text the same in every target
 	var textFieldBitmapData:BitmapData;
 	
	public var text(get, set):String;

	function get_text() {
	  return textField.text;
	}

	function set_text(text) {
	    textField.text = text;
		var nw = Std.int(textField.textWidth);
		var nh = Std.int(textField.textHeight);
		if (textFieldBitmapData != null) textFieldBitmapData.dispose();
		textFieldBitmapData = null;
 	    textFieldBitmapData = new BitmapData(nw, nh, true, 0x000000);
    	textFieldBitmapData.draw(textField);
	    bitmapData = textFieldBitmapData;
	    return text;
	}
	#end

	public function new (stringText:String="",font:Font,?align='LEFT',?size:Int=20,?color:Int=0x000000,?smoothing:Bool=true) {
		
		super ();

	    textFieldSize = size;
	    textFieldColor = color;
	    textFieldFont = font;
	    textFieldAlign = align;


 		#if (flash || next)
		    // this class it's actually a TextField
		    textField = this;
	    #else
		    // this class is a Bitmap encapsulating a TextField
			textField = new TextField();
		    bitmapData = textFieldBitmapData;
		    this.smoothing = smoothing;
		#end

		//prepare the TextFormat
	    var textFieldFormat:TextFormat = new TextFormat(textFieldFont.fontName, textFieldSize , textFieldColor);

	    textFieldFormat.align = TextFormatAlign.LEFT;
	    textField.autoSize = TextFieldAutoSize.LEFT;
	    textField.antiAliasType = AntiAliasType.ADVANCED;
	    textField.defaultTextFormat = textFieldFormat;
	    textField.embedFonts = true;
	    textField.selectable = false;
	    textField.wordWrap = false;
	    textField.border = false;
		text = stringText;
	}
	

}