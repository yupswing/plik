
package com.akifox.plik;
import openfl.display.Shape;
import openfl.geom.Point;
import com.akifox.plik.geom.Transformation;
import com.akifox.plik.geom.ITransformable;

class ShapeContainer extends Shape implements ITransformable  implements IDestroyable {


	public function new() {
		super();
    	initTransformation();
	}

	public override function toString():String {
		return "[PLIK.ShapeContainer]";
	}

	private var _dead:Bool=false;
	public var dead(get,never):Bool;
    public function get_dead():Bool { return _dead; }

	public function destroy() {
        #if gbcheck
        trace('AKIFOX Destroy ' + this);
        #end
        _dead = true;
	}

	   //## INTERFACE
    private var _transformation:Transformation;

    public function updateTransformation() {
    	_transformation.updateSize();
    }

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
}