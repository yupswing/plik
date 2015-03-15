
package com.akifox.plik.geom;

interface ITransformable 
{
    private var _transformation:Transformation;

    public function updateTransformation():Void;
    private function initTransformation():Void;
    public function setAnchoredPivot(value:Int):Void;
    public function setPivot(x:Float,y:Float):Void;

    public function flipX():Void;
    public function flipY():Void;

	public var scale(get,set):Float;
    private function get_scale():Float;
    private function set_scale(value:Float):Float;

	//public var scale(get,set):Float;
    private function get_scaleX():Float;
    private function set_scaleX(value:Float):Float;

	//public var scale(get,set):Float;
    private function get_scaleY():Float;
    private function set_scaleY(value:Float):Float;

    public var skewX(get,set):Float;
    private function get_skewX():Float;
    private function set_skewX(value:Float):Float;

    public var skewY(get,set):Float;
    private function get_skewY():Float;
    private function set_skewY(value:Float):Float;

    //public var rotation(get,set):Float;
    private function get_rotation():Float;
    private function set_rotation(value:Float):Float;

    //public var x(get,set):Float;
    private function get_x():Float;
    private function set_x(value:Float):Float;

    //public var y(get,set):Float;
    private function get_y():Float;
    private function set_y(value:Float):Float;

    public function destroy():Void;

}