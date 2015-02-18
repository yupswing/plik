
package ;

import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;

#if flash
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

 	#if !flash
 	// make the use of .text the same in every target
 	var textFieldBitmapData:BitmapData;
 	
	public var text(get, set):String;

	function get_text() {
	  return textField.text;
	}

	function set_text(text) {
		trace(text);
	    textField.text = text;
 	    textFieldBitmapData = new BitmapData(Std.int(textField.textWidth), Std.int(textField.textHeight), true, 0x000000);
    	textFieldBitmapData.draw(textField);
	    bitmapData = textFieldBitmapData;
	    return text;
	}
	#end

	public function new (stringText:String="",font:Font,?size:Int=20,?color:Int=0x000000,?smoothing:Bool=true) {
		
		super ();

	    textFieldSize = size;
	    textFieldColor = color;
	    textFieldFont = font;


	    #if flash
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
	    textField.defaultTextFormat = textFieldFormat;
	    textField.embedFonts = true;
	    textField.selectable = false;
	    textField.wordWrap = false;
	    textField.border = false;
	    textField.autoSize = TextFieldAutoSize.LEFT;
		text = stringText;
	}
	

}