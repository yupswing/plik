
package com.akifox.plik;
import openfl.display.Shape;
import com.akifox.plik.geom.Transformation;

class ShapeContainer extends Shape implements IDestroyable {

    private var _transformation:Transformation=null;
    public var t(get,never):Transformation;
    private function get_t():Transformation {
        return _transformation;
    }

    public function new(?transformation=true) {
        _dead = false;
		super();
        if (transformation) {
            _transformation = new Transformation(this.transform.matrix,this.width,this.height);
            _transformation.bind(this);
        }
	}

    public function updateTransformation() {
        if (_transformation!=null) _transformation.updateSize(this.width,this.height);
    }

    //##########################################################################################
    // IDestroyable

	public override function toString():String {
		return "[PLIK.ShapeContainer]";
	}

	private var _dead:Bool=false;
	public var dead(get,never):Bool;
    public function get_dead():Bool { return _dead; }

	public function destroy() {
        #if gbcheck
        trace('GB Destroy > ' + this);
        #end
        _dead = true;
	}

}