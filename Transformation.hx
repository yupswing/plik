
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

    // Pivot Point Anchors (used by setAnchoredPivot and getAnchoredPivot)
    public inline static var LEFT:Int = 0;    // x value
    public inline static var CENTER:Int = 1;  // x value
    public inline static var RIGHT:Int = 2;   // x value
    public inline static var TOP:Int = 0;     // y value
    public inline static var MIDDLE:Int = 1;  // y value
    public inline static var BOTTOM:Int = 2;  // y value

    // the pivot anchor point (using Pivot Point Anchors)
    // example: Point(Transformation.LEFT,Transformation.MIDDLE)
    private var anchor:Point = null;

    // the pivot offset
	private var offsetPoint:Point;

	// the target object
	private var target:DisplayObject;

	// target properties
    private var realX:Float;
    private var realY:Float;
    private var realWidth:Float;
    private var realHeight:Float;

    // Instance
    //  var trf = new Transformation(target);
	public function new(target:DisplayObject,?pivot:Point=null)
	{
		// set the target and get the original properties
		this.target = target;
		realWidth = target.width;
		realHeight = target.height;
		realX = target.x;
		realY = target.y;

		if (pivot==null) {
			//set the pivot point TOPLEFT of the target if nothing specified
			setAnchoredPivot(Transformation.LEFT,Transformation.TOP);
		} else {
			//set the pivot point to the specified coords
			setPivot(pivot);
		}
	}

    public function updateSize() {
    	/* when the size is changed externally of the Transformation class
    	   you should use this method to update the size internally
    	   (for example a textfield object with text changed will change size
    	   	but the Transformation class can't be aware of that if you don't
    	   	call this method) */

		// get current translation and the complete matrix
    	var translation:Point = getTranslation();
    	var currentMatrix:Matrix = getMatrix();

    	// remove all transformation
    	this.identity();

    	// get the real width and height without transformations
    	realWidth = target.width;
    	realHeight = target.height;

    	// reset the anchored pivot (based on new size)
    	if (anchor!=null) setAnchoredPivot(Std.int(anchor.x),Std.int(anchor.y));

    	// restore the transformation
    	this.setMatrixInternal(currentMatrix);

    	// restore the original translation
        // (the new given anchored pivot will count)
    	this.setTranslation(translation);
    }



    // PIVOT MANAGMENT
	// #########################################################################

    // Pivot Point Anchors
    // -------------------
    // X: Transformation.LEFT | Transformation.CENTER | Transformation.RIGHT
    // Y: Transformation.TOP | Transformation.MIDDLE | Transformation.BOTTOM
    //
	//     0,0 - 1,0 - 2,0    x=> LEFT=0 CENTER=1 RIGHT=2
	//      |     |     |     y=> TOP=0 MIDDLE=1 BOTTOM=2
	//     0,1 - 1,1 - 2,1
	//      |     |     |
	//     0,2 - 1,2 - 2,2

	// set the pivot in the Pivot Point Anchor specified
	public function setAnchoredPivot(pivotPositionX:Int,pivotPositionY:Int) {
		//set the Pivot Point Anchor as specified
		anchor = new Point(pivotPositionX,pivotPositionY);
		//set the pivot offset based on the Pivot Point Anchor specified
		offsetPoint = getAnchoredPivotOffset(pivotPositionX,pivotPositionY);
	}

	// set the pivot in an arbitrary point
	public function setPivot(point:Point) {
		//unset the Pivot Point Anchor
		anchor = null;
		//set the pivot offset
		offsetPoint = inverseTransformPoint(point);
	}

	// set the pivot offset (from target 0,0) in an arbitrary point
	public function setPivotOffset(point:Point) {
		//unset the Pivot Point Anchor
		anchor = null;
		//set the pivot offset
		offsetPoint = point;
	}

	// get the pivot absolute position
	public function getPivot():Point {
		return transformPoint(offsetPoint);
	}

	// get the pivot offset (from target 0,0) position
	public function getPivotOffset():Point {
		return offsetPoint;
	}

	// get the offset (from target 0,0) position of a specified Pivot Point Anchor
	public function getAnchoredPivotOffset(?pivotPositionX:Int=0,?pivotPositionY:Int=0):Point {
		return getAnchorPivot(pivotPositionX,pivotPositionY,false);
	}

	// get the position of a specified Pivot Point Anchor
	public function getAnchoredPivot(?pivotPositionX:Int=0,?pivotPositionY:Int=0):Point 
	{
		return getAnchorPivot(pivotPositionX,pivotPositionY,true);
	}

	// internal (used by getAnchoredPivotOffset and getAnchoredPivot)
	private function getAnchorPivot(pivotPositionX:Int,pivotPositionY:Int,absolute:Bool):Point {
		// realWidth / 2 * 0 is LEFT      .______
		// realWidth / 2 * 1 is CENTER    ___.___
		// realWidth / 2 * 2 is RIGHT     ______.
		// and so on for the Y
		var x = realWidth/2*pivotPositionX;
		var y = realHeight/2*pivotPositionY;

		// add the current translation to the point
		// to get the absolute position
		if (absolute) {
			var translation = getPosition();
			x+=translation.x; // pos.x is matrix.tx
			y+=translation.y; // pos.y is matrix.ty
		}
		return new Point(x,y);
	}

	// #########################################################################


    private function setMatrixInternal(m:Matrix,?adjust=false):Void
    {
    	// adjust==true is needed to respect the Pivot Point

    	var originalPoint:Point = new Point(0,0);
    	if (adjust) originalPoint = getPivot();  //this before apply the transform
        target.transform.matrix = m; 			 //apply the transformation
        if (adjust) adjustOffset(originalPoint); //this after apply the transform
    }

    public function setMatrix(m:Matrix):Void { 
    	// change the matrix and adjust to respect the Pivot Point
    	setMatrixInternal(m,true);
    }


    public function setMatrixTo(a:Float,b:Float,c:Float,d:Float,tx:Float,ty:Float) {
    	// make a matrix with the specified parameters
    	var m:Matrix = new Matrix(a,b,c,d,tx,ty);
    	// update the matrix and adjust to respect the Pivot Point
    	setMatrixInternal(m,true);
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
        var transformedPoint:Point;
        transformedPoint = m.transformPoint(offsetPoint);
        // get the Pivot position offset between before and after the transformation
        var offset:Point = new Point(transformedPoint.x-originalPoint.x,
        							 transformedPoint.y-originalPoint.y);

        // apply the offset with a translation to the target
        // to keep the pivot relative position coherent
	    m.tx-=offset.x;
	    m.ty-=offset.y;

		//apply the matrix to the target
	    setMatrixInternal(m);

	}



    // POINT TRANSFORMATIONS
	// #########################################################################

	// Transform a point using the current matrix

    public function transformPoint(point:Point):Point {
        // apply the current transformation on a point
        return target.transform.matrix.transformPoint(point);
    }

    public function deltaTransformPoint(point:Point):Point {
        // apply the current transformation on a point
        // [ignore the translation]
        return target.transform.matrix.deltaTransformPoint(point);
    }

    public function inverseTransformPoint(point:Point):Point {
        // remove the current transformation on a point
        // (give a transformed point to get a 'identity' point)
    	var m:Matrix = getMatrix();
    	m.invert();
        return m.transformPoint(point);
    }

    public function inverseDeltaTransformPoint(point:Point):Point {
        // remove the current transformation on a point
        // (give a transformed point to get a 'identity' point)
        // [ignore the translation]
    	var m:Matrix = getMatrix();
    	m.invert();
        return m.deltaTransformPoint(point);
    }



    // IDENTITY
	// #########################################################################

    public function identity(){
		 // reset the matrix
         var m = new Matrix();
         m.tx = realX - offsetPoint.x;
         m.ty = realY - offsetPoint.y;
         setMatrixInternal(m);
    }



    // TRANSLATE TRANSFORMATION
	// #########################################################################


	// delta translation (x,y)
	public function translate(dx:Float=0, dy:Float=0):Void
	{
	    var m:Matrix = getMatrix();
	    m.tx += dx;
	    m.ty += dy;
	    setMatrixInternal(m);
	}
	public function translateX(dx:Float=0):Void { translate(dx,0); } 
	public function translateY(dy:Float=0):Void { translate(0,dy); }    

	// absolute translation (x,y)
	public function setTranslation(transaltion:Point):Void
	{
	    var m:Matrix = getMatrix();
	    var transformedOffset:Point = deltaTransformPoint(offsetPoint);
	    m.tx = transaltion.x-transformedOffset.x;
	    m.ty = transaltion.y-transformedOffset.y;
	    setMatrixInternal(m);
	}
	public function setTranslationX(tx:Float=0):Void {
	    var m:Matrix = getMatrix();
	    m.tx = tx-deltaTransformPoint(offsetPoint).x;
	    setMatrixInternal(m);
	} 
	public function setTranslationY(ty:Float=0):Void {
	    var m:Matrix = getMatrix();
	    m.ty = ty-deltaTransformPoint(offsetPoint).y;
	    setMatrixInternal(m);
	}   

	public function getTranslation():Point
	{
		var transformedOffset:Point = deltaTransformPoint(offsetPoint);
	    return new Point(target.transform.matrix.tx+transformedOffset.x,target.transform.matrix.ty+transformedOffset.y);
	}
	public function getTranslationX():Float
	{
		return getTranslation().x;
	}
	public function getTranslationY():Float
	{
		return getTranslation().y;
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
	public function setSkewRad(skewXRad:Float=0, ?skewYRad:Float=0):Void
	{

        //get the target matrix to apply the transformation
	    var m:Matrix = getMatrix();

		// apply the skew (matrix.c is HORIZONTAL, matrix.b is VERTICAL)
	    if (skewXRad!=0) {
	    	m.c = Math.tan(skewXRad)*getScaleX();
	    }
	    if (skewYRad!=0) {
	    	m.b = Math.tan(skewYRad)*getScaleY();
	    }

		//apply the matrix to the target
	    setMatrixInternal(m,true);
	}

	// Skew in Degrees
	public function setSkew(skewXDeg:Float=0, ?skewYDeg:Float=0):Void
	{
		// check null to avoid error on multiplication
		var skewXRad:Float=0;
		var skewYRad:Float=0;
		if (skewXDeg!=0) skewXRad = skewXDeg*DEG2RAD;
		if (skewYDeg!=0) skewYRad = skewYDeg*DEG2RAD;
		setSkewRad(skewXRad,skewYRad);
	}

	// one parameter shortcuts
	public function setSkewX(skewXDeg:Float=null):Void { setSkew(skewXDeg,0); }
	public function setSkewY(skewYDeg:Float=null):Void { setSkew(0,skewYDeg); }
	public function setSkewXRad(skewXRad:Float=null):Void { setSkewRad(skewXRad,0); }
	public function setSkewYRad(skewYRad:Float=null):Void { setSkewRad(0,skewYRad); }

	// Sum Skew in Radians
	public function skewRad(skewXRad:Float=0.0, skewYRad:Float=0.0):Void
	{

        //get the target matrix to apply the transformation
	    var m:Matrix = new Matrix();

		// apply the skew (matrix.c is HORIZONTAL, matrix.b is VERTICAL)
	    if (skewXRad!=0.0) {
	    	m.c = Math.tan(skewXRad);
	    }
	    if (skewYRad!=0.0) {
	    	m.b = Math.tan(skewYRad);
	    }
	    
		//apply the matrix to the target
	    m.concat(getMatrix());
	    setMatrixInternal(m,true);

	}
	// one parameter shortcuts
	public function skew(skewDeg:Float=0.0,?skewYDeg:Float=null):Void {
		var skewXDeg:Float = skewDeg;
		// if not specified it will set the x and y skew using the same value
		if (skewYDeg==null) skewYDeg = skewDeg;
		skewRad(skewXDeg*DEG2RAD,skewYDeg*DEG2RAD);
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
	    setMatrixInternal(m,true);

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
		setMatrixInternal(m,true);
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
		setMatrixInternal(m,true);
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
        var absolutePoint:Point = getPivot();

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
		setMatrixInternal(m);
	}

	// Rotate in Degrees
	public function rotate(angle:Float=0):Void { rotateRad(angle*DEG2RAD); }

	// Rotate in Radians
	public function setRotationRad(angle:Float=0):Void 
	{
		//get the current angle
		var currentRotation:Float = getRotationRad();
		
		//find the complementary angle to reset the rotation to 0
		var resetAngle:Float = -currentRotation;
			
		//reset the rotation
		rotateRad(resetAngle);
		
		//set the new rotation value
		rotateRad(angle);
	}

	// Set rotation in Degrees
	public function setRotation(angle:Float=0):Void { setRotationRad(angle*DEG2RAD); }

	// Rotate in Radians
	public function getRotationRad(angle:Float=0):Float 
	{

		// apply the transformation matrix to a point and
		// calculate the rotation happened\
		// thanks to http://stackoverflow.com/users/1035293/bugshake

		var translate:Point;
		var scale:Float;

		var m:Matrix = getMatrix();

		// extract translation
		var p:Point = new Point();
		translate = m.transformPoint(p);
		m.translate( -translate.x, -translate.y);

		// extract (uniform) scale...
		p.x = 1.0;
		p.y = 0.0;
		p = m.transformPoint(p);
		scale = p.length;

		// ...and rotation
		return Math.atan2(p.y, p.x);
	}
	// Set rotation in Degrees
	public function getRotation(angle:Float=0):Float { return getRotationRad() * RAD2DEG; }


	// #########################################################################
	// #########################################################################



}


