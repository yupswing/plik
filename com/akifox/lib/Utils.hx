package akifox;
import openfl.Lib;

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

}
