package com.akifox.plik;

import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.net.URLRequest;

class Utils
{
	public function new(){}

	public static function getHeight():Int
	{
        return openfl.Lib.current.stage.stageHeight;
	}
	
	
	public static function getWidth():Int
	{
        return openfl.Lib.current.stage.stageWidth;
	}

	public static function isArrayEqual(arr1:Dynamic, arr2:Dynamic):Bool
	{
		if (arr1.length != arr2.length) { return false; }
		
		for (i in 0...arr1.length) {
			if (arr1[i] != arr2[i]) { 
				return false;
			}
		}
		
		return true;
	}

	public static function makeBitmap(target:DisplayObject,?w:Float=0,?h:Float=0,?offset:Int=0,?transparent=true):BitmapData {
		// bounds and size of parent in its own coordinate space
		if (w==0 || h==0) {
			var rect:Rectangle = target.parent.getBounds(target);
			w = rect.width;
			h = rect.height;
		}
		var bmp:BitmapData = new BitmapData(Std.int(w)+offset*2, Std.int(h)+offset*2, transparent, Lib.current.stage.color);

		// offset for drawing
		var matrix:Matrix = target.transform.matrix.clone();//new Matrix();
		matrix.tx+=offset;
		matrix.ty+=offset;

		// Note: we are drawing parent object, not target itself: 
		// this allows to save all transformations and filters of target
		bmp.draw(cast target, matrix);
		return bmp;
	}
	
	/**
	 * Clamps the value within the minimum and maximum values.
	 * @param	value		The Float to evaluate.
	 * @param	min			The minimum range.
	 * @param	max			The maximum range.
	 * @return	The clamped value.
	 */
	public static function clamp(value:Float, min:Float, max:Float):Float
	{
		if (max > min)
		{
			if (value < min) return min;
			else if (value > max) return max;
			else return value;
		}
		else
		{
			// Min/max swapped
			if (value < max) return max;
			else if (value > min) return min;
			else return value;
		}
	}

    public static function gotoWebsite(website:String):Void 
    {
        // open an url
        Lib.getURL(new URLRequest (website));
    }

}
