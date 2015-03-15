
package com.akifox.plik;

import openfl.display.Graphics;

class Drawing {

	/**
     * Draw a segment of a circle
     * @param graphics      the graphics object to draw into
     * @param center        the center of the circle
     * @param start         start angle (radians)
     * @param end           end angle (radians)
     * @param r             radius of the circle
     * @param h_ratio       horizontal scaling factor
     * @param v_ratio       vertical scaling factor
     * @param new_drawing   if true, uses a moveTo call to start drawing at the start point of the circle; else continues drawing using only lineTo and curveTo
     * 
     */
    public static function circleSegment(graphics:Graphics, x:Float,y:Float, start:Float, end:Float, r:Float, ?h_ratio:Float=1, ?v_ratio:Float=1, ?new_drawing:Bool=true):Void
    {
        // first point of the circle segment
        if(new_drawing)
        {
            graphics.moveTo(x+Math.cos(start)*r*h_ratio, y+Math.sin(start)*r*v_ratio);
        }

        // draw the circle in segments
        var segments:Int = 8;

        var theta:Float = (end-start)/segments; 
        var angle:Float = start; // start drawing at angle ...

        var ctrlRadius:Float = r/Math.cos(theta/2); // this gets the radius of the control point
        for (i in 0...segments) {
             // increment the angle
             angle += theta;
             var angleMid:Float = angle-(theta/2);
             // calculate our control point
             var cx:Float = x+Math.cos(angleMid)*(ctrlRadius*h_ratio);
             var cy:Float = y+Math.sin(angleMid)*(ctrlRadius*v_ratio);
             // calculate our end point
             var px:Float = x+Math.cos(angle)*r*h_ratio;
             var py:Float = y+Math.sin(angle)*r*v_ratio;
             // draw the circle segment
             graphics.curveTo(cx, cy, px, py);
        }

    }
}