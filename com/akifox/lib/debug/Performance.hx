package com.akifox.lib.debug;
import haxe.Timer;
import openfl.display.FPS;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Assets;
import com.akifox.lib.Utils;

/**
 * FPS class extension to display memory usage.
 * @author Kirill Poletaev
 *	var performance:Performance = new Performance(10, 10, 0x000000);
 *  addChild(performance);
 */
class Performance extends TextField
{
	private var times:Array<Float>;
	private var memPeak:Float = 0;
    private var skipped = 0;
    var skip = 10;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000) 
	{
		super();
		
		x = inX;
		y = inY;
		selectable = false;
		
		defaultTextFormat = new TextFormat("_sans", 12, inCol);
		
		text = "FPS: ";
		
		times = [];
		addEventListener(Event.ENTER_FRAME, onEnter);
		width = 150;
		height = 70;
	}
	
	private function onEnter(_)
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
                text = "FPS: " + times.length + "\nMEM: " + mem + " MB\nMEM peak: " + memPeak + " MB";	
            }
        }
        skipped++;
	}
	
}
