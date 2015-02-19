
package akifox;

import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.display.DisplayObject;

class Transformation
{

	//TODO: NEED TO BE REFACTORED AND DOCUMENTED

    public static var _DEG2RAD:Float = Math.PI/180;

	var offsetPoint:Point;
	var target:DisplayObject;

     var ow:Float; //original width
     var oh:Float; //original height
     var ox:Float; //original x
     var oy:Float; //original y

	public function new(target:DisplayObject,?x:Int=0,?y:Int=0){
		this.target = target;
		setAbsolutePoint(x,y);
		ow = target.width;
		oh = target.height;
		ox = target.x;
		oy = target.y;
	}



    // SETTERs

	public function setInternalPoint(pivotPosition:Array<Int>) {
		offsetPoint = getPivotPositionPoint(pivotPosition,false);
	}

	public function setAbsolutePoint(x:Int,y:Int) {
          var pos = getPosition();

          var m = target.transform.matrix.clone();
          m.invert();

		offsetPoint = m.transformPoint(new Point(x,y));
	}



    // GETTERs

	public function getOffsetPoint():Point {
		return offsetPoint;
	}

	public function getAbsolutePoint():Point {
		return transformPoint(offsetPoint);
	}

	public function getPosition():Point
	{
	    return new Point(target.transform.matrix.tx,target.transform.matrix.ty);
	}

	public function getPivotPositionPoint(?pivotPosition:Array<Int>,?absolute:Bool=true):Point 
	{
		// PIVOT POINTS (pivotPosition argument)
		// 0,0 - 1,0 - 2,0
		//  |     |     |
		// 0,1 - 1,1 - 2,1
		//  |     |     |
		// 0,2 - 1,2 - 2,2

		if (pivotPosition==null || pivotPosition.length<2) pivotPosition = [0,0];
		var x = ow/2*pivotPosition[0];
		var y = oh/2*pivotPosition[1];
		if (absolute) {
			var pos = getPosition();
			x+=pos.x;
			y+=pos.y;
		}
		return new Point(x,y);
	}

    public function getMatrix():Matrix
    {
        return target.transform.matrix.clone();
    }



    // POINT TRANSFORMATIONS

    public function transformPoint(point:Point):Point {
        return target.transform.matrix.transformPoint(point);
    }

    public function deltaTransformPoint(point:Point):Point {
        return target.transform.matrix.deltaTransformPoint(point);
    }



    // TRANSFORMATIONS

	public function rotate(?angle:Float=45):Void 
	{ 
          var absolutePoint = transformPoint(offsetPoint);
	     var m:Matrix = target.transform.matrix.clone();
		m.tx-=absolutePoint.x; 
		m.ty-=absolutePoint.y;
		m.rotate(angle * (Math.PI / 180)); 
		m.tx+=absolutePoint.x; 
		m.ty+=absolutePoint.y;
		target.transform.matrix = m;
	}

	public function skew(?skewXDegree:Float=null, ?skewYDegree:Float=null):Void
	{
		//TODO need to be changed
		//doesn't work as expected
        var absolutePoint = transformPoint(offsetPoint);
	    var m:Matrix = target.transform.matrix.clone();

        //v1
	    if (skewYDegree!=null) m.b = Math.tan(skewYDegree*_DEG2RAD);
	    if (skewXDegree!=null) m.c = Math.tan(skewXDegree*_DEG2RAD);    

		//v2
		/*     
		if (skewYDegree!=null) {
             m.a = Math.cos(skewYDegree*_DEG2RAD);
             m.b = Math.sin(skewYDegree*_DEG2RAD);
        }
        if (skewXDegree!=null) {
             m.c = -Math.sin(skewXDegree*_DEG2RAD);
             m.d = Math.cos(skewXDegree*_DEG2RAD);
        }*/

        var transformedPoint:Point = m.transformPoint(offsetPoint);
        var offset:Point = new Point(transformedPoint.x-absolutePoint.x,transformedPoint.y-absolutePoint.y);
	    m.tx-=offset.x;
	    m.ty-=offset.y;
	    target.transform.matrix = m;
	}

	public function translate(dx:Float=0, ?dy:Float=0):Void
	{
	    var m:Matrix = target.transform.matrix.clone();
	    m.tx += dx;
	    m.ty += dy;
	    target.transform.matrix = m;
	}   

	public function moveTo(tx:Float=0, ?ty:Float=0):Void
	{
	    var m:Matrix = target.transform.matrix.clone();
	    var transformedOffset:Point = deltaTransformPoint(offsetPoint);
	    m.tx = tx-transformedOffset.x;
	    m.ty = ty-transformedOffset.y;
	    target.transform.matrix = m;
	}


    public function identity(){
         var m = new Matrix();
         m.tx = ox - offsetPoint.x;
         m.ty = oy - offsetPoint.x;
         target.transform.matrix = m;
    }


    //TODO: BELOW FUNCTIONS NEED TO BE TESTED
    // GETTERs TRANSFORMATION

     public function getSkewX():Float
     {
          var m = getMatrix();
          return Math.atan2(-m.c, m.d) * _DEG2RAD;
     }

     public function getSkewXRadians():Float
     {
          var m = getMatrix();
          return Math.atan2(-m.c, m.d);
     }
	public function getSkewYRadians():Float
	{
          var m = getMatrix();
		return Math.atan2(m.b, m.a);
	} 

	public function getSkewY():Float
	{
          var m = getMatrix();
		return Math.atan2(m.b, m.a) * _DEG2RAD;
	}
     public function getRotation():Float
     {
          return getRotationRadians()*_DEG2RAD;
     }
   	public function getRotationRadians():Float
	{
		return getSkewYRadians();
	}

/*

	//TODO: BELOW FUNCTIONS NEED TO BE IMPLEMENTED
    // OTHER TRANSFORMATIONS

	public static function getScaleX(m:Matrix):Float
	{
		return Math.sqrt(m.a*m.a + m.b*m.b);
	}

	public static function setScaleX(m:Matrix, scaleX:Float):Void
	{
		var oldValue:Float = getScaleX(m);
		// avoid division by zero 
		if (oldValue!=0)
		{
			var ratio:Float = scaleX / oldValue;
			m.a *= ratio;
			m.b *= ratio;
		}
		else
		{
			var skewYRad:Float = getSkewYRadians(m);
			m.a = Math.cos(skewYRad) * scaleX;
			m.b = Math.sin(skewYRad) * scaleX;
		}
	}


   	public static function getScaleY(m:Matrix):Float
	{
		return Math.sqrt(m.c*m.c + m.d*m.d);
	}
	public static function setScaleY(m:Matrix, scaleY:Float):Void
	{
		var oldValue:Float = getScaleY(m);
		// avoid division by zero 
		if (oldValue!=0)
		{
			var ratio:Float = scaleY / oldValue;
			m.c *= ratio;
			m.d *= ratio;
		}
		else
		{
			var skewXRad:Float = getSkewXRadians(m);
			m.c = -Math.sin(skewXRad) * scaleY;
			m.d =  Math.cos(skewXRad) * scaleY;
		}
	}*/




/*	public static function setSkewXRadians(m:Matrix, skewX:Float):Void
	{
		var scaleY:Float = getScaleY(m);
		m.c = -scaleY * Math.sin(skewX);
		m.d =  scaleY * Math.cos(skewX);
	}

     public static function setSkewYRadians(m:Matrix, skewY:Float):Void
     {
          var scaleX:Float = getScaleX(m);
          m.a = scaleX * Math.cos(skewY);
          m.b = scaleX * Math.sin(skewY);
     }

     public static function setSkewX(m:Matrix, skewX:Float):Void
     {
          setSkewXRadians(m, skewX*(Math.PI/180));
     }

     public static function setSkewY(m:Matrix, skewY:Float):Void
     {
          var m = getMatrix();
          setSkewYRadians(m, skewY*(Math.PI/180));
     }
     */

/*	public static function setRotationRadians(m:Matrix, rotation:Float):Void
	{
		var oldRotation:Float = getRotationRadians(m);
		var oldSkewX:Float = getSkewXRadians(m);
		setSkewXRadians(m, oldSkewX + rotation-oldRotation);
		setSkewYRadians(m, rotation);		
	}*/
/*	public static function setRotation(m:Matrix, rotation:Float):Void
	{
		setRotationRadians(m, rotation*(Math.PI/180));
	}
	public static function rotateAroundInternalPoint(m:Matrix, x:Float, y:Float, angleDegrees:Float):Void
	{
		var point:Point = new Point(x, y);
		point = m.transformPoint(point);
		m.tx -= point.x;
		m.ty -= point.y;
		m.rotate(angleDegrees*(Math.PI/180));
		m.tx += point.x;
		m.ty += point.y;
	}
	public static function rotateAroundExternalPoint(m:Matrix, x:Float, y:Float, angleDegrees:Float):Void
	{
		m.tx -= x;
		m.ty -= y;
		m.rotate(angleDegrees*(Math.PI/180));
		m.tx += x;
		m.ty += y;
	}
    public static function matchInternalPointWithExternal(m:Matrix, internalPoint:Point, externalPoint:Point):Void
	{
		var internalPointTransformed:Point = m.transformPoint(internalPoint);
		var dx:Float = externalPoint.x - internalPointTransformed.x;
		var dy:Float = externalPoint.y - internalPointTransformed.y;	
		m.tx += dx;
		m.ty += dy;
	}*/

}


