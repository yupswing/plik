# Performance.hx
Haxe/OpenFL class to display FPS stats and memory usage.

Based on this post written by Kirill Poletaev
http://haxecoder.com/post.php?id=24

# Example
![Screenshot](https://dl.dropboxusercontent.com/u/683344/akifox/akifox-lib/performance-screenshot.png)

# Info
The class (if added as a child of a DisplayObject, like a Sprite) shows a bar (as small as possible, according to the font) with few useful information when you are in a development phase.

- your logo (useful for screenshots)
- app info (directly from your project.xml, still for screenshots) [**NOTE:** not available in flash]
- FPS Graph that show the color coded perfomance of your frame rate in the last 30 seconds
- current FPS, memory usage and memory peak. [**NOTE:** all flash instances share the same memory]

# Usage
Copy the class in your project (or use this library if you prefer) and in your main add it as a child

**Example**
```haxe

import openfl.Lib;
import openfl.Assets;
import openfl.display.Sprite;

import Performance; // or com.akifox.plik.debug.Performance
                    // if you use the whole library via haxelib git

class Main extends Sprite
{
	public function new () {
		super ();

		// [...]your stuff

    #if debug
    var performance = new Performance(Assets.getFont("fonts/square.ttf"),        //any font you want
                                      Assets.getBitmapData("graphics/logo.png"), //null or any BitmapData (suggested 50x50pixels)
                                      true,  // true if you want to see the APP information
                                      true); // true if you want to see the FPS Graph
    Lib.current.stage.addChild(performance);
    #end
	}
}
```

That's it!

You should see the debug bar in your application if you launch it with the ```-debug``` option.



