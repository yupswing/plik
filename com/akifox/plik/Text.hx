
package com.akifox.plik;

import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.text.AntiAliasType;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import com.akifox.plik.geom.Transformation;

// TODO Editing going on to support transformations
// will be finished when Transform.hx is done

#if (flash || next)
import openfl.events.Event;
// this class it's a TextField
// Flash renders the TextField beautifully and it doesn't need any trick
class Text extends TextField implements IDestroyable
#else
// this class is a Bitmap encapsulating a TextField
// the TextField will be drawn every time it changes (now only .text)
import openfl.display.Bitmap;
import openfl.display.BitmapData;
class Text extends Bitmap implements IDestroyable
#end
{
	var textField:TextField;
	var textFieldFont:Font;
	var textFieldColor:Int;
	var textFieldFormat:TextFormat;
	var textFieldSize:Int;

 	#if (!flash && !next)
 	// make the use of .text the same in every target
 	var textFieldBitmapData:BitmapData;
 	
	public var text(get, set):String;

	function get_text():String {
	  return textField.text;
	}

	function set_text(value:String):String {
	    textField.text = value;
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
	    return value;
	}

    public function setText(value:String) {
        set_text(value);
    }

	#else

    public function setText(value:String) {
        this.text = value;
        if (_transformation != null) _transformation.updateSize();
    }

	#end

	private static var _defaultFont:Font=null;
	private static var _defaultFontName:String="";
	public static var defaultFont(get,set):String;
	private static function get_defaultFont():String {
		return _defaultFontName;

	}
	private static function set_defaultFont(value:String):String {
		_defaultFont = PLIK.getFont(value);
		return _defaultFontName = value;
	}

	public function new (stringText:String="",?size:Int=20,?color:Int=0x000000,?font:String="",?smoothing:Bool=true) {
		
		super ();
        _dead = false;

	    textFieldSize = size;
	    textFieldColor = color;
	    if (font=="") {
	    	textFieldFont = _defaultFont;
	    } else {
	    	textFieldFont = PLIK.getFont(font);
	    }


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
	
	private var _dead:Bool=false;
	public var dead(get,never):Bool;
    public function get_dead():Bool { return _dead; }

    public function destroy() {
	 	_dead = true;
        //motion.Actuate.stop(this);

        #if gbcheck
        trace('AKIFOX Destroy ' + this);
        #end

    	// destroy this element
    	this._transformation.destroy();
    	this._transformation = null;

	 	#if (!flash && !next)
		bitmapData = null;
	 	textFieldBitmapData.dispose();
	 	textFieldBitmapData = null;
	 	#end
    }
	

}