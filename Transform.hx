
package akifox;

import openfl.geom.Matrix;
import openfl.geom.Point;

class Transform
{
	public function new(){}

	public static function rotate(target:DisplayObject,?angle:Float=45,?center:Point):Void 
	{ 
		if (center==null) center = new Point(0,0);
	    target.transform.matrix = rotateMatrix(target,angle,center);
	}

	public static function rotateCenter(target:DisplayObject,?angle:Float=45):Void 
	{
	    target.transform.matrix = rotateCenterMatrix(target,angle);
	}

	public static function rotateMatrix(target:DisplayObject,?angle:Float=45,?center:Point):Matrix
	{
		if (center==null) center = new Point(0,0);
	    var m:Matrix = target.transform.matrix.clone();
	    var base = new Point(m.tx,m.ty);
	    center.x+=m.tx;
	    center.y+=m.ty;
		m.tx-=center.x; 
		m.ty-=center.y;
		m.rotate(angle * (Math.PI / 180)); 
		m.tx+=center.x; 
		m.ty+=center.y; 
		return m;
	}

	public static function rotateCenterMatrix(target:DisplayObject,?angle:Float=45):Matrix 
	{
		var center:Point = new Point(target.width/2, target.height/2);
		return rotateMatrix(target,angle,center);
	}

	private static var _DEG2RAD:Float = Math.PI/180;

	public static function skew(target:DisplayObject, skewXDegree:Float, skewYDegree:Float):Void
	{
	    var m:Matrix = target.transform.matrix.clone();
	    m.b = Math.tan(skewYDegree*_DEG2RAD);
	    m.c = Math.tan(skewXDegree*_DEG2RAD);
	    target.transform.matrix = m;
	}   

	public static function skewY(target:DisplayObject, skewDegree:Float):Void
	{
	    var m:Matrix = target.transform.matrix.clone();
	    m.b = Math.tan(skewDegree*_DEG2RAD);
	    target.transform.matrix = m;
	}       

	public static function skewX(target:DisplayObject, skewDegree:Float):Void
	{
	    var m:Matrix = target.transform.matrix.clone();
	    m.c = Math.tan(skewDegree*_DEG2RAD);
	    target.transform.matrix = m;
	}

}
