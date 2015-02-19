
package akifox;

import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.display.DisplayObject;

// This page was very helpful to understand matrix affine transformation
// http://www.senocular.com/flash/tutorials/transformmatrix/

class Transformation
{

	//TODO: NEED TO BE REFACTORED AND DOCUMENTED

	// Radians to Degrees and viceversa
    public static var DEG2RAD:Float = Math.PI/180;
    public static var RAD2DEG:Float = 180/Math.PI;

    // the pivot offset
	private var offsetPoint:Point;

	// the target object
	private var target:DisplayObject;

	// original target properties
    private var ox:Float; //original x
    private var oy:Float; //original y
    private var ow:Float; //original width
    private var oh:Float; //original height

    // Instance
    //  var trf = new Transformation(target);
	public function new(target:DisplayObject,?pivotX:Int=null,?pivotY:Int=null)
	{
		// set the target and get the original properties
		this.target = target;
		ow = target.width;
		oh = target.height;
		ox = target.x;
		oy = target.y;

		if (pivotX==null) {
			//set the pivot point TOPLEFT of the target
			setInternalPoint([0,0]);
		} else {
			//set the pivot point to the specified coords
			setAbsolutePoint(pivotX,pivotY);
		}
	}



    // SETTERs
	// #########################################################################

	public function setInternalPoint(pivotPosition:Array<Int>) {
		offsetPoint = getPivotPositionPoint(pivotPosition,false);
	}

	public function setAbsolutePoint(x:Int,y:Int) {
        var pos = getPosition();

        var m = getMatrix();
        m.invert();

		offsetPoint = m.transformPoint(new Point(x,y));
	}



    // GETTERs
	// #########################################################################

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


	// #########################################################################


	private function adjustOffset(originalPoint:Point) {

        //get the target matrix to apply the transformation
	    var m:Matrix = getMatrix();

		//get the pivot NEW absolute position
        var transformedPoint:Point = m.transformPoint(offsetPoint);
        // get the Pivot position offset between before and after the transformation
        var offset:Point = new Point(transformedPoint.x-originalPoint.x,
        							 transformedPoint.y-originalPoint.y);

        // apply the offset with a translation to the target
        // to keep the pivot relative position coherent
	    m.tx-=offset.x;
	    m.ty-=offset.y;

		//apply the matrix to the target
	    target.transform.matrix = m;

	}



    // POINT TRANSFORMATIONS
	// #########################################################################

	// Transform a point using the current matrix

    public function transformPoint(point:Point):Point {
        return target.transform.matrix.transformPoint(point);
    }

    public function deltaTransformPoint(point:Point):Point {
    	// Ignore the translation
        return target.transform.matrix.deltaTransformPoint(point);
    }



    // ROTATE TRANSFORMATION
	// #########################################################################


	// Rotate in Radians
	public function rotateRad(angle:Float=0):Void 
	{
		//get the pivot absolute position
        var absolutePoint:Point = getAbsolutePoint();

        //get the target matrix to apply the transformation
	    var m:Matrix = getMatrix();

	    //move the target(matrix)
	    //the pivot point will match the origin (0,0)
		m.tx-=absolutePoint.x;
		m.ty-=absolutePoint.y;

		//rotate the target(matrix)
		// SAME AS m.rotate(angle);
		var sin = Math.sin(angle);
		var cos = Math.cos(angle);
		var a = m.a;
		var b = m.b;
		var c = m.c;
		var d = m.d;
		var tx = m.tx;
		var ty = m.ty;
		m.a = a*cos - b*sin;
		m.b = a*sin + b*cos;
		m.c = c*cos - d*sin;
		m.d = c*sin + d*cos;
		m.tx = tx*cos - ty*sin;
		m.ty = tx*sin + ty*cos;

		// restore the target(matrix) position
		m.tx+=absolutePoint.x;
		m.ty+=absolutePoint.y;

		//apply the matrix to the target
		target.transform.matrix = m;
	}

	// Rotate in Degrees
	public function rotate(angle:Float=0):Void { rotateRad(angle*DEG2RAD); }


	// TODO these functions need to be tested
    public function getRotation():Float { return getRotationRadians()*DEG2RAD; }
   	public function getRotationRadians():Float { return getSkewYRadians(); }



    // SKEW TRANSFORMATION
	// #########################################################################


	// Skew in Radians
	public function skewRad(skewXRad:Float=null, ?skewYRad:Float=null):Void
	{
		//TODO need to be changed
		//doesn't work as expected

		//get the pivot absolute position
	    // (keep this BEFORE applying the new matrix to the target)
        var absolutePoint:Point = getAbsolutePoint();

        //get the target matrix to apply the transformation
	    var m:Matrix = getMatrix();

		// apply the skew (matrix.c is HORIZONTAL, matrix.b is VERTICAL)
	    if (skewXRad!=null && skewXRad!=0.0) {
	    	m.c = Math.tan(skewXRad);
	    }
	    if (skewYRad!=null && skewYRad!=0.0) {
	    	m.b = Math.tan(skewYRad);
	    }

		//apply the matrix to the target
	    target.transform.matrix = m;

	    //adjust the target position to match the pivot
	    // (keep this AFTER applying the new matrix to the target)
	    adjustOffset(absolutePoint);
	}

	// Skew in Degrees
	public function skew(skewXDeg:Float=null, ?skewYDeg:Float=null):Void
	{
		// check null to avoid error on multiplication
	    if (skewXDeg==null) skewXDeg = 0.0;
	    if (skewYDeg==null) skewYDeg = 0.0;
		skewRad(skewXDeg*DEG2RAD,skewYDeg*DEG2RAD);
	}

	// one parameter shortcuts
	public function skewX(skewDeg:Float=null):Void { skew(skewDeg,null); }
	public function skewY(skewDeg:Float=null):Void { skew(null,skewDeg); }
	public function skewXRad(skewRad:Float=null):Void { skew(skewRad,null); }
	public function skewYRad(skewRad:Float=null):Void { skew(null,skewRad); }


	// TODO these functions need to be tested
    public function getSkewXRadians():Float
    {
        var m:Matrix = getMatrix();
        return Math.atan2(-m.c, m.d);
    }
	public function getSkewYRadians():Float
	{
        var m:Matrix = getMatrix();
		return Math.atan2(m.b, m.a);
	} 
    public function getSkewX():Float { return getSkewXRadians()*RAD2DEG; }
	public function getSkewY():Float { return getSkewYRadians()*RAD2DEG; }



	// SCALE TRANSFORMATION
	// #########################################################################


	public function scale(factor:Float=1.0, ?yFactor:Float=null):Void
	{

		var xFactor:Float = factor;
		// if not specified it will scale x and y using the same factor
		if (yFactor==null) yFactor = factor;

		//get the pivot absolute position
	    // (keep this BEFORE applying the new matrix to the target)
        var absolutePoint:Point = getAbsolutePoint();

        //get the target matrix to apply the transformation
	    var m:Matrix = getMatrix();

		// apply the scaling
		m.a *= xFactor;
		m.b *= yFactor;
		m.c *= xFactor;
		m.d *= yFactor;
		m.tx *= xFactor;
		m.ty *= yFactor;

		//apply the matrix to the target
	    target.transform.matrix = m;

	    //adjust the target position to match the pivot
	    // (keep this AFTER applying the new matrix to the target)
	    adjustOffset(absolutePoint);

	}

	public function scaleX(factor:Float=1):Void { scale(factor,1.0); }
	public function scaleY(factor:Float=1):Void { scale(1.0,factor); }

	public function setScale(value:Float=1.0, ?scaleY:Float=null):Void
	{

		var scaleX:Float = value;
		// if not specified it will set the x and y scale using the same value
		if (scaleY==null) scaleY = value;
		
		//get the pivot absolute position
	    // (keep this BEFORE applying the new matrix to the target)
        var absolutePoint:Point = getAbsolutePoint();

        //apply the transformation
		setScaleX(scaleX);
		setScaleY(scaleY);

	    //adjust the target position to match the pivot
	    // (keep this AFTER applying the new matrix to the target)
	    adjustOffset(absolutePoint);

	}

	public function setScaleX(scaleX:Float):Void
	{
        var m:Matrix = getMatrix();
		var oldValue:Float = getScaleX();
		// avoid division by zero 
		if (oldValue!=0)
		{
			var ratio:Float = scaleX / oldValue;
			m.a *= ratio;
			m.b *= ratio;
		}
		else
		{
			var skewYRad:Float = getSkewYRadians();
			m.a = Math.cos(skewYRad) * scaleX;
			m.b = Math.sin(skewYRad) * scaleX;
		}
		target.transform.matrix = m;
	}

	public function setScaleY(scaleY:Float):Void
	{
        var m:Matrix = getMatrix();
		var oldValue:Float = getScaleY();
		// avoid division by zero 
		if (oldValue!=0)
		{
			var ratio:Float = scaleY / oldValue;
			m.c *= ratio;
			m.d *= ratio;
		}
		else
		{
			var skewXRad:Float = getSkewXRadians();
			m.c = -Math.sin(skewXRad) * scaleY;
			m.d =  Math.cos(skewXRad) * scaleY;
		}
		target.transform.matrix = m;
	}


	public function getScaleX():Float
	{
        var m:Matrix = target.transform.matrix;
		return Math.sqrt(m.a*m.a + m.b*m.b);
	}

	public function getScaleY():Float
	{
        var m:Matrix = target.transform.matrix;
		return Math.sqrt(m.c*m.c + m.d*m.d);
	}



    // TRANSLATE TRANSFORMATION
	// #########################################################################


	// delta translation (x,y)
	public function translate(dx:Float=0, ?dy:Float=0):Void
	{
	    var m:Matrix = getMatrix();
	    m.tx += dx;
	    m.ty += dy;
	    target.transform.matrix = m;
	}   

	// absolute translation (x,y)
	public function moveTo(tx:Float=0, ?ty:Float=0):Void
	{
	    var m:Matrix = getMatrix();
	    var transformedOffset:Point = deltaTransformPoint(offsetPoint);
	    m.tx = tx-transformedOffset.x;
	    m.ty = ty-transformedOffset.y;
	    target.transform.matrix = m;
	}


    // IDENTITY
	// #########################################################################

	//TODO (looks like bug on offsetpoint)
    public function identity(){
		 // reset the matrix
         var m = new Matrix();
         m.tx = ox - offsetPoint.x;
         m.ty = oy - offsetPoint.x;
         target.transform.matrix = m;
    }


	// #########################################################################
	// #########################################################################


    //TODO: BELOW FUNCTIONS NEED TO BE TESTED TO BE INCLUDED


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
          setSkewXRadians(m, skewX*DEG2RAD);
     }

     public static function setSkewY(m:Matrix, skewY:Float):Void
     {
          var m = getMatrix();
          setSkewYRadians(m, skewY*DEG2RAD);
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
		setRotationRadians(m, rotation*DEG2RAD);
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


