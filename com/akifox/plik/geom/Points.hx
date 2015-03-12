package ;

import openfl.geom.Point;

// all angle in radians
// GOT FROM HAXE.ORG
class Points 
{
    // just a shortcut to create the Point
    public static inline function create(x:Float, y:Float) : Point
    {
        return new Point(x, y );
    }
    
    // to clone a point
    public static inline function clone(p0:Point) : Point
    {
        return new Point(p0.x, p0.y );
    }
    
    // to get the length squared
    public static inline function lengthSqr(p0:Point) : Float
    {
        return p0.x*p0.x + p0.y*p0.y;
    }
    
    // to get the length
    public static inline function length(p0:Point) : Float
    {
        return Math.sqrt(p0.x*p0.x + p0.y*p0.y);
    }
    
    // to get the angle
    public static inline function angle(p0:Point) : Float
    {
        return Math.atan2(p0.y, p0.x);
    }
    
    // calculate the angle between first point and the second
    public static inline function angleBetween(p0:Point, p1:Point) : Float
    {
        return Math.atan2(p0.y, p0.x) - Math.atan2(p1.y, p1.x);
    }
    
    // to get the distance squared between first point and second point
    public static inline function distanceSqr(p0:Point, p1:Point) : Float
    {
        var x = p0.x-p1.x;
        var y = p0.y-p1.y;
        return x*x + y*y;
    }
    
    // to get the distance between first point and second point
    public static inline function distance(p0:Point, p1:Point) : Float
    {
        var x = p0.x-p1.x;
        var y = p0.y-p1.y;
        return Math.sqrt(x*x + y*y);
    }
    
    // to get the dot product
    public static inline function dot(p0:Point, p1:Point) : Float
    {
        return p0.x*p1.x + p0.y*p1.y;
    }
    
    // to get the cross product
    public static inline function cross(p0:Point, p1:Point) : Float
    {
        return p0.x*p1.y - p0.y*p1.x;
    }
    
    // see whether first point has equal position with second point
    public static inline function equals(p0:Point, p1:Point) : Bool
    {
        return (p0.x == p1.x) && (p0.y == p1.y);
    }
    
    // see whether first point has nearly equal with second point *with tolerance
    public static inline function nearEquals(p0:Point, p1:Point, ?t:Float=0.0) : Bool
    {
        var x = Math.abs(p0.x-p1.x);
        var y = Math.abs(p0.y-p1.y);
        return (x <= t) && (y <= t);
    }
    
    // see whether first point is greater than second point
    public static inline function gt(p0:Point, p1:Point) : Bool
    {
        return (p0.x > p1.x) && (p0.y > p1.y);
    }
    
    // see whether first point is greater than or equal second point
    public static inline function gte(p0:Point, p1:Point) : Bool
    {
        return (p0.x >= p1.x) && (p0.y >= p1.y);
    }
    
    // see whether first point is less than second point
    public static inline function lt(p0:Point, p1:Point) : Bool
    {
        return (p0.x < p1.x) && (p0.y < p1.y);
    }
    
    // see whether first point is less than or equal second point
    public static inline function lte(p0:Point, p1:Point) : Bool
    {
        return (p0.x <= p1.x) && (p0.y <= p1.y);
    }
    
    // to get the point from length and angle
    public static inline function polar(l:Float, a:Float) : Point
    {
        return new Point(l*Math.cos(a), l*Math.sin(a) );
    }
    
    // add first point and second point
    public static inline function add(p0:Point, p1:Point) : Point
    {
        return new Point(p0.x+p1.x, p0.y+p1.y );
    }
    
    // subtract first point and second point
    public static inline function sub(p0:Point, p1:Point) : Point
    {
        return new Point(p0.x-p1.x, p0.y-p1.y );
    }
    
    // multiply point with scalar
    public static inline function mul(p0:Point, s:Float) : Point
    {
        return new Point(p0.x*s, p0.y*s );
    }
    
    // divide point with scalar
    public static inline function div(p0:Point, s:Float) : Point
    {
        return new Point(p0.x/s, p0.y/s );
    }
    
    // to get the absolute position of a point
    public static inline function abs(p0:Point) : Point
    {
        return new Point(Math.abs(p0.x), Math.abs(p0.y) );
    }
    
    // to get the opposite direction of point
    public static inline function opposite(p0:Point) : Point
    {
        return new Point(-p0.x, -p0.y );
    }
    
    // to get the perpendicular point
    public static inline function perpendicular(p0:Point) : Point
    {
        return new Point(-p0.y, p0.x );
    }
    
    // to normalize point with the thickness
    public static inline function normalize(p0:Point, ?t:Float=1.0) : Point
    {
        var m = t/Math.sqrt(p0.x*p0.x + p0.y*p0.y);
        return new Point(p0.x*m, p0.y*m);
    }
    
    // to interpolate between first point and second point, with f between 0 and 1 *although you can pass any number
    public static inline function interpolate(p0:Point, p1:Point, f:Float) : Point
    {
        return new Point((p1.x-p0.x)*f+p0.x, (p1.y-p0.y)*f+p0.y);
    }
    
    // to get point with rotate the first point with second point as pivot
    public static inline function pivot(p0:Point, p1:Point, a:Float) : Point
    {
        var x = p0.x - p1.y;
        var y = p0.y - p1.y;
        var l = Math.sqrt(x*x + y*y);
        var an = Math.atan2(y, x)+a;
        return new Point(p1.x+l*Math.cos(a), p1.y+l*Math.sin(a) );
    }
    
    // to project a point
    public static inline function project(p0:Point, p1:Point) : Point
    {
        var il = 1/(Math.sqrt(p0.x*p0.x + p0.y*p0.y) * Math.sqrt(p1.x*p1.x + p1.y*p1.y));
        var m = (p0.x*p1.x + p0.y*p1.y) * il;
        return new Point(p1.x*m, p1.y*m );
    }
}