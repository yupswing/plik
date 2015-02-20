
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

    // Pivot Point Anchors (used by setInternalPoint and getPivotPositionPoint)
    public inline static var TOP:Int = 0;
    public inline static var MIDDLE:Int = 1;
    public inline static var BOTTOM:Int = 2;
    public inline static var LEFT:Int = 0;
    public inline static var CENTER:Int = 1;
    public inline static var RIGHT:Int = 2;

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
			setInternalPoint(0,0);
		} else {
			//set the pivot point to the specified coords
			setAbsolutePoint(pivotX,pivotY);
		}
	}



    // SETTERs
	// #########################################################################

	public function setInternalPoint(pivotPositionX:Int,pivotPositionY:Int) {
		offsetPoint = getPivotPositionPoint(pivotPositionX,pivotPositionY,false);
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

	public function getPivotPositionPoint(?pivotPositionX:Int=0,?pivotPositionY:Int=0,?absolute:Bool=true):Point 
	{
		// PIVOT POINTS (pivotPosition argument)
		// 0,0 - 1,0 - 2,0    x=> LEFT=0 CENTER=1 RIGHT=2
		//  |     |     |     y=> TOP=0 MIDDLE=1 BOTTOM=2
		// 0,1 - 1,1 - 2,1
		//  |     |     |
		// 0,2 - 1,2 - 2,2

		var x = ow/2*pivotPositionX;
		var y = oh/2*pivotPositionY;
		if (absolute) {
			var pos = getPosition();
			x+=pos.x;
			y+=pos.y;
		}
		return new Point(x,y);
	}

	// #########################################################################


    public function setMatrix(m:Matrix,?adjust=false):Void
    {
    	var originalPoint:Point = new Point(0,0);
    	if (adjust) originalPoint = getAbsolutePoint(); //this before apply the transform

    	//apply the transformation
        target.transform.matrix = m;

        if (adjust) adjustOffset(originalPoint);   //this after apply the transform
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
	    setMatrix(m);

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



    // IDENTITY
	// #########################################################################

    public function identity(){
		 // reset the matrix
         var m = new Matrix();
         m.tx = ox - offsetPoint.x;
         m.ty = oy - offsetPoint.y;
         setMatrix(m);
    }



    // TRANSLATE TRANSFORMATION
	// #########################################################################


	// delta translation (x,y)
	public function translate(dx:Float=0, dy:Float=0):Void
	{
	    var m:Matrix = getMatrix();
	    m.tx += dx;
	    m.ty += dy;
	    setMatrix(m);
	}
	public function translateX(dx:Float=0):Void { translate(dx,0); } 
	public function translateY(dy:Float=0):Void { translate(0,dy); }    

	// absolute translation (x,y)
	public function setTranslation(tx:Float=0, ty:Float=0):Void
	{
	    var m:Matrix = getMatrix();
	    var transformedOffset:Point = deltaTransformPoint(offsetPoint);
	    m.tx = tx-transformedOffset.x;
	    m.ty = ty-transformedOffset.y;
	    setMatrix(m);
	}
	public function setTranslationX(tx:Float=0):Void {
	    var m:Matrix = getMatrix();
	    m.tx = tx-deltaTransformPoint(offsetPoint).x;
	    setMatrix(m);
	} 
	public function setTranslationY(ty:Float=0):Void {
	    var m:Matrix = getMatrix();
	    m.ty = ty-deltaTransformPoint(offsetPoint).y;
	    setMatrix(m);
	}   

	public function getPosition():Point
	{
	    return new Point(target.transform.matrix.tx,target.transform.matrix.ty);
	}
	public function getPositionX():Float
	{
		return target.transform.matrix.tx;
	}
	public function getPositionY():Float
	{
		return target.transform.matrix.ty;
	}



    // SKEW TRANSFORMATION
	// #########################################################################


	// Skew in Radians
	//TODO skew need to be rewritten to be reliable
	public function setSkewRad(skewRad:Float=null, ?skewYRad:Float=null):Void
	{

		var skewXRad:Float = skewRad;
		// if not specified it will set the x and y skew using the same value
		if (skewYRad==null) skewYRad = skewRad;

		

        //get the target matrix to apply the transformation
	    //var m:Matrix = new Matrix();
	    var m:Matrix = getMatrix();

		// apply the skew (matrix.c is HORIZONTAL, matrix.b is VERTICAL)
	    if (skewXRad!=null) {
	    	m.c = Math.tan(skewXRad);
	    }
	    if (skewYRad!=null) {
	    	m.b = Math.tan(skewYRad);
	    }

		//apply the matrix to the target
	    setMatrix(m,true);
	}

	// Skew in Degrees
	public function setSkew(skewXDeg:Float=null, ?skewYDeg:Float=null):Void
	{
		// check null to avoid error on multiplication
		var skewXRad:Float=null;
		var skewYRad:Float=null;
		if (skewXDeg!=null) skewXRad = skewXDeg*DEG2RAD;
		if (skewYDeg!=null) skewYRad = skewYDeg*DEG2RAD;
		setSkewRad(skewXRad,skewYRad);
	}

	// one parameter shortcuts
	public function setSkewX(skewXDeg:Float=null):Void { setSkew(skewXDeg,null); }
	public function setSkewY(skewYDeg:Float=null):Void { setSkew(null,skewYDeg); }
	public function setSkewXRad(skewXRad:Float=null):Void { setSkewRad(skewXRad,null); }
	public function setSkewYRad(skewYRad:Float=null):Void { setSkewRad(null,skewYRad); }

	// Sum Skew in Radians
	public function skewRad(skewRad:Float=0.0, ?skewYRad:Float=null):Void
	{
		var skewXRad:Float = getSkewXRad()+skewRad;
		// if not specified it will set the x and y skew using the same value
		if (skewYRad==null) skewYRad = getSkewYRad()+skewRad;

		setSkewRad(skewXRad,skewYRad);

	}
	// one parameter shortcuts
	public function skew(skewDeg:Float=0.0,?skewYDeg:Float=null):Void {
		var skewXDeg:Float = skewDeg;
		// if not specified it will set the x and y skew using the same value
		if (skewYDeg==null) skewYDeg = skewDeg;
		skew(skewXDeg*DEG2RAD,skewYDeg*DEG2RAD);
	}
	public function skewX(skewXDeg:Float=null):Void { skew(skewXDeg,0.0); }
	public function skewY(skewYDeg:Float=null):Void { skew(0.0,skewYDeg); }
	public function skewXRad(skewXRad:Float=null):Void { skewRad(skewXRad,0.0); }
	public function skewYRad(skewYRad:Float=null):Void { skewRad(0.0,skewYRad); }


    public function getSkewXRad():Float
    {
    	var px = new Point(0, 1);
		px = deltaTransformPoint(px);
		return -(Math.atan2(px.y, px.x) - Math.PI/2);
    }
	public function getSkewYRad():Float
	{
		var py = new Point(1, 0);
		py = deltaTransformPoint(py);
		return Math.atan2(py.y, py.x);
	} 
    public function getSkewX():Float { return getSkewXRad()*RAD2DEG; }
	public function getSkewY():Float { return getSkewYRad()*RAD2DEG; }


	// SCALE TRANSFORMATION
	// #########################################################################


	public function scale(factor:Float=1.0, ?yFactor:Float=null):Void
	{

		var xFactor:Float = factor;
		// if not specified it will scale x and y using the same factor
		if (yFactor==null) yFactor = factor;

		//get the pivot absolute position
	    // (keep this BEFORE applying the new matrix to the target)

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
	    setMatrix(m,true);

	}

	public function scaleX(factor:Float=1):Void { scale(factor,1.0); }
	public function scaleY(factor:Float=1):Void { scale(1.0,factor); }

	public function setScale(value:Float=1.0, ?scaleY:Float=null):Void
	{

		var scaleX:Float = value;
		// if not specified it will set the x and y scale using the same value
		if (scaleY==null) scaleY = value;

        //apply the transformation
		setScaleX(scaleX);
		setScaleY(scaleY);

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
			var skewYRad:Float = getSkewYRad();
			m.a = Math.cos(skewYRad) * scaleX;
			m.b = Math.sin(skewYRad) * scaleX;
		}
		setMatrix(m,true);
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
			var skewXRad:Float = getSkewXRad();
			m.c = -Math.sin(skewXRad) * scaleY;
			m.d =  Math.cos(skewXRad) * scaleY;
		}
		setMatrix(m,true);
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



    // FLIP
	// #########################################################################

	public function flipX():Void { scaleX(-1); }
	public function flipY():Void { scaleY(-1); }


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
		setMatrix(m);
	}

	// Rotate in Degrees
	public function rotate(angle:Float=0):Void { rotateRad(angle*DEG2RAD); }


	// #########################################################################
	// #########################################################################


}


