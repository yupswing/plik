[![akifox-transform](https://img.shields.io/badge/library-akifox%20transform%202.0-brightgreen.svg)]()
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Haxe 3](https://img.shields.io/badge/language-Haxe%203-orange.svg)](http://www.haxe.org)
[![OpenFL 2](https://img.shields.io/badge/require-OpenFL 2-red.svg)](http://www.openfl.org)
[![Cross platform](https://img.shields.io/badge/platform-cross%20platform-lightgrey.svg)](http://www.openfl.org)

# akifox-transform (com.akifox.plik.geom.Transformation)
**Transformation HAXE/OpenFL Class**

The akifox-transform class aims to provide an easy tool to manage affine transformations using a reliable pivot point.
What are the affine transformation you might ask...
- read <a href="http://en.wikipedia.org/wiki/Affine_transformation">this wikipedia page</a>
- read <a href="http://www.senocular.com/flash/tutorials/transformmatrix/">this great flash tutorial</a>

You can find a working example in the <a href="https://github.com/yupswing/akifox-transform/tree/master/example">example folder</a>. (read below for more information)

## Example demo

![Screenshot](https://dl.dropboxusercontent.com/u/683344/akifox/akifox-transform/transformation-example.png)

**Flash build:** <a href="https://dl.dropboxusercontent.com/u/683344/akifox/akifox-transform/transformation-example.swf" target="_blank">transformation-example.swf</a>

You should get a window with a OpenFL logo square.
- <code>Z</code> to toggle debug drawings
- <code>SPACE</code> to reset the transformations
- Drag to move
- Click to change the Pivot Point
- Drag+<code>SHIFT</code> to rotate around the pivot point
- Drag+<code>ALT</code> to scale related to the pivot point
- Drag+<code>CMD</code>/<code>CTRL</code> to skew related to the pivot point (the cross center represents a 0,0 skew)
- <code>1</code> to <code>9</code> to set the pivot point on the relative anchor point (TOPLEFT, MIDDLELEFT,BOTTOMLEFT,TOPCENTER... BOTTOMRIGHT)
- <code>UP</code>, <code>DOWN</code>, <code>RIGHT</code>, <code>LEFT</code> Move 15px
- <code>Q</code>, <code>A</code> to Skew X ±15deg
- <code>W</code>, <code>S</code> to Skew Y ±15deg
- <code>E</code>, <code>D</code> to Scale */1.5
- <code>R</code>, <code>F</code> to Rotate ±15deg


## Install

You can easily install the library from haxelib
```
haxelib install akifox-transform
```

In your project add the library reference in your ```project.xml```

```
<haxelib name="akifox-transform" />
```

and finally you can import it in your project class with this import
```
import com.akifox.transform.Transformation;
```

-------------

If you want to use instead the latest version you should use this library
**com.akifox.plik.geom.Transformation**
```
haxelib git akifox-transform https://github.com/yupswing/plik.git
```

In your project add the library reference in your ```project.xml```

```
<haxelib name="plik" />
```

and finally you can import it in your project class with this import
```
import com.akifox.plik.geom.Transformation;
```

## Documentation

You can read the full Library documentation <a href="https://dl.dropboxusercontent.com/u/683344/akifox/akifox-transform/docs/index.html" target="_blank">here</a>



## Using the library

Once you got a DisplayObject (Sprites, Bitmap...) you can create a Transformation object linked to it.
(Don't use more than one transformation at a given time. I will code this check later on)

````haxe
import com.akifox.transform.Transformation; //or com.akifox.plik.geom.Transformation

// [...]
    trf = new Transformation(YOUROBJECT);
    trf.setAnchoredPivot(Transformation.ANCHOR_TOP_LEFT);
                               
    // these are the Pivot Point coordinates (they will not change unless
    // you change the pivot point position)
    var pivotCoordinates:Point = trf.getPivot();

    trf.rotate(20); //rotate 20degrees clockwise
    trf.skewX(30); //skew X axis 20degrees
    Actuate.tween(trf,1,{'scalingX':2,'scalingY'"2}); //scale 2X in 1s using Actuate
````

## Work in progress

- [x] Package in a haxelib library (http://lib.haxe.org/p/akifox-transform)

#### Demos
- [x] Interactive desktop version ([x] flash,[x] native, [ ] html5)
- [ ] *Interactive mobile version* (android, ios)
- [ ] *Sprite example with Transformation encapsulated*

#### Transformation class
- [ ] *Unit test*
- [x] Cleaning and documenting code
- [x] Pivot point managing
- [x] Support for motion.Actuate (properties linked to functions get and set)
- [x] Events (Transform and Pivot change)
- [x] Translate
  - [x] Get
  - [x] Set
  - [x] Add
- [x] Skew
  - [x] Get
  - [x] Set 
  - [x] Add
- [x] Scale
  - [x] Get
  - [x] Set 
  - [x] Add
- [ ] Flip
  - [ ] Get (it looks like impossible!)
  - [x] Set 
- [x] Rotate
  - [x] Get
  - [x] Set 
  - [x] Add
