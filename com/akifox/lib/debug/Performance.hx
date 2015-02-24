package com.akifox.lib.debug;
import haxe.Timer;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.Font;
import openfl.text.TextFormat;
import openfl.Assets;
import openfl.Lib;

/**
 * FPS class extension to display memory usage.
 * @author Kirill Poletaev
 *	var performance:Performance = new Performance(10, 10, 0x000000);
 *  addChild(performance);
 */
class Performance extends Sprite
{
	private var times:Array<Float>;
	private var memPeak:Float = 0;
    private var skipped = 0;
    private var skip = 10;

    public var performanceText:TextField;

    private var bound:Bitmap;
    private var boundData:BitmapData;

    private var scene:Dynamic;

	public function new(scene:Dynamic,font:Font) 
	{
		super();
		
		x = 0;
		y = 0;
    	performanceText = new TextField();
    	performanceText.x = 6;
    	performanceText.y = 6;
    	performanceText.width = 500;
		performanceText.selectable = false;
		performanceText.defaultTextFormat = new TextFormat(font.fontName, 12, 0xFFFFFF);
		performanceText.text = "Performance";
		performanceText.embedFonts = true;

		this.scene = scene;

		bound = new Bitmap();
		onResize(null);

		addChild(bound);
		addChild(performanceText);
		
		times = [];
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnter);
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
	}

	private function onEnter(_):Void
	{	
		var now = Timer.stamp();
		times.push(now);
		
		while (times[0] < now - 1)
			times.shift();

        if (skipped == skip) {
            skipped = 0;
            var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100)/100;
            if (mem > memPeak) memPeak = mem;
            
            if (visible)
            {	
                performanceText.text = "FPS: " + times.length + "\nMEM: " + mem + " MB\nMEM peak: " + memPeak + " MB";	
            }
        }
        skipped++;
	}

	private function onResize(_):Void
	{
		boundData = new BitmapData(Lib.current.stage.stageWidth,50);
		boundData.fillRect(new Rectangle(0,0,Lib.current.stage.stageWidth,50),0xAA000000);
		bound.bitmapData = boundData;
	}
	
}
