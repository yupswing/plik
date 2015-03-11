
package com.akifox.lib;

import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import openfl.text.AntiAliasType;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import com.akifox.lib.geom.*;

// TODO Editing going on to support transformations
// will be finished when Transform.hx is done

#if (flash || next || debug)
// this class it's a TextField
// Flash renders the TextField beautifully and it doesn't need any trick
class Text extends TextField implements ITransformable implements IDestroyable
#else
// this class is a Bitmap encapsulating a TextField
// the TextField will be drawn every time it changes (now only .text)
import openfl.display.Bitmap;
import openfl.display.BitmapData;
class Text extends Bitmap implements ITransformable implements IDestroyable
#end
{
	var textField:TextField;
	var textFieldFont:Font;
	var textFieldColor:Int;
	var textFieldFormat:TextFormat;
	var textFieldSize:Int;

 	#if (!flash && !next && !debug)
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
	#else

	//public override var text(get, set):String;
	override function get_text():String {
	  return super.text;
	}

	override function set_text(value:String) {
	    super.text = value;
	    if (_transformation != null) _transformation.updateSize();
	    return value;
	}

	#end

	private static var _defaultFont:Font=null;
	private static var _defaultFontName:String="";
	public static var defaultFont(get,set):String;
	private static function get_defaultFont():String {
		return _defaultFontName;

	}
	private static function set_defaultFont(value:String):String {
		_defaultFont = Akifox.getFont(value);
		return _defaultFontName = value;
	}

    public override function toString():String {
        return '[Akifox.Text "'+text+'"]';
    }

	public function new (stringText:String="",?size:Int=20,?color:Int=0x000000,?font:String="",?smoothing:Bool=true) {
		
		super ();

	    textFieldSize = size;
	    textFieldColor = color;
	    if (font=="") {
	    	textFieldFont = _defaultFont;
	    } else {
	    	textFieldFont = Akifox.getFont(font);
	    }


 		#if (flash || next || debug)
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

    	initTransformation(); //before set_test

	}

	//###############

    //## INTERFACE
    private var _transformation:Transformation;

    private function initTransformation() {
    	_transformation = new Transformation(this);
    }

    public function setAnchoredPivot(value:Int){
    	_transformation.setAnchoredPivot(value);
    }

    public function setPivot(x:Float,y:Float){
    	_transformation.setPivot(new Point(x,y));
    }

    public function flipX():Void {
    	_transformation.flipX();
    }
    public function flipY():Void{
    	_transformation.flipY();
    }

    public var scale(get,set):Float;
    private function get_scale():Float{
    	return _transformation.scalingX;
    }
    private function set_scale(value:Float):Float{
    	_transformation.setScale(value); //x and y
    	return value;
    }

    private override function get_scaleX():Float{
    	return _transformation.scalingX;
    }
    private override function set_scaleX(value:Float):Float{ 
    	return _transformation.scalingX = value;
    }

    private override function get_scaleY():Float{
    	return _transformation.scalingY;
    }
    private override function set_scaleY(value:Float):Float{ 
    	return _transformation.scalingY = value;
    }

    public var skewX(get,set):Float;
    private function get_skewX():Float{
    	return _transformation.skewingX;
    }
    private function set_skewX(value:Float):Float{ 
    	return _transformation.skewingX = value;
    }

    public var skewY(get,set):Float;
    private function get_skewY():Float{
    	return _transformation.skewingY;
    }
    private function set_skewY(value:Float):Float{ 
    	return _transformation.skewingY = value;
    }

    //public override var rotation(get,set):Float;
    private override function get_rotation():Float{
    	return _transformation.rotation;
    }
    private override function set_rotation(value:Float):Float{
    	_transformation.rotation = value;
    	return value;
    }

    //public override var x(get,set):Float;
    private override function get_x():Float{
    	return _transformation.translationX;
    }
    private override function set_x(value:Float):Float{
    	_transformation.translationX = value;
    	return value;
    }

    //public override var y(get,set):Float;
    private override function get_y():Float{
    	return _transformation.translationY;
    }
    private override function set_y(value:Float):Float{
    	_transformation.translationY = value;
    	return value;
    }
	
	private var _dead:Bool=false;
	public var dead(get,never):Bool;
    public function get_dead():Bool { return _dead; }

    public function destroy() {
	 	_dead = true;
        motion.Actuate.tween(this,0,{});
        motion.Actuate.stop(this);

        #if gbcheck
        trace('AKIFOX Destroy ' + this);
        #end

    	// destroy this element
    	this._transformation.destroy();
    	this._transformation = null;

	 	#if (!flash && !next && !debug)
		bitmapData = null;
	 	textFieldBitmapData.dispose();
	 	textFieldBitmapData = null;
	 	#end
    }
	

}