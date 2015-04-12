package com.akifox.plik.gui;
using hxColorToolkit.ColorToolkit;


class Style {

    private static var _styleSet:Dynamic = {};

    public static function loadStyle(style:String) {
      try {
        _styleSet = haxe.Json.parse(style);
      } catch(e:Dynamic) {
        trace('error loading style');
      }
    }

    public static function getStyle(stylePattern:String):Style {
      var styles = stylePattern.split('.');
      var style:Style = new Style();
      for (el in styles) {
        if (Reflect.hasField(_styleSet,el)) {
          style.set(Reflect.getProperty(_styleSet,el));
        } else {
          trace('no style "$el"');
        }
      }
      return style;
    }

    //==========================================================================

    public static function toColor(color:UInt):UInt {
      if (color<0) return -1;
      return color>>8;
    }

    public static function toAlpha(color:UInt):Float {
      if (color<0) return -1;
      return (color&0xFF)/256;
    }

    //==========================================================================


    public var padding:Int = 0;
    public var offset:Int = 0; //offset between internal elements
    public var rounded:Int = 0;
    public var minWidth:Int = 0;
    public var minHeight:Int = 0;
    public var outline_size:Int = 0;
    public var bevel:Int = 0;
    public var color:UInt = 0;
    public var font_name:String = "";
    public var font_size:Int = 16;
    public var font_offset_x:Int = 0;
    public var font_offset_y:Int = 0;
    public var background_color:UInt = 0;
    public var over_background_color:UInt = 0;
    public var selected_background_color:UInt = 0;
    public var outline_color:UInt = 0;
    public var over_outline_color:UInt = 0;
    public var selected_outline_color:UInt = 0;

    public function getFullWidth():Int {
      return minHeight + padding*2;
    }
    public function getFullHeight():Int {
      return minWidth + padding*2;
    }

    public function copy(style:Style) {
      this.minWidth = style.minWidth;
      this.minHeight = style.minHeight;
      this.padding = style.padding;
      this.offset = style.offset;
      this.rounded = style.rounded;
      this.color = style.color;
      this.font_name = style.font_name;
      this.font_size = style.font_size;
      this.font_offset_x = style.font_offset_x;
      this.font_offset_y = style.font_offset_y;
      this.outline_size = style.outline_size;
      this.background_color = style.background_color;
      this.over_background_color = style.over_background_color;
      this.selected_background_color = style.selected_background_color;
      this.outline_color = style.outline_color;
      this.over_outline_color = style.over_outline_color;
      this.selected_outline_color = style.selected_outline_color;
    }

    public function new(defaults:Dynamic = null) {
    	set(defaults);
    }

    public function set(values:Dynamic = null):Style {
      if (values==null) return this;
    	for (field in Reflect.fields(values)) {
    		if (Reflect.getProperty(this, field) != null) {
          var value:Dynamic = Reflect.field(values, field);
          if (Type.getClass(value)==String) {
              if (value.substr(0,2)=='0x') value = Std.parseInt(value);
          }
    			Reflect.setProperty(this, field, value);
    		}
    	}
      return this;
    }

    //****************************************************************/

    public static function drawBackground(target:IStyle,targetStyle:Style,?isSelected:Bool=false,?isOver:Bool=false,?width:Float=0,?height:Float=0) {

      var w = Math.max(target.getNetWidth(),targetStyle.minWidth)+targetStyle.padding*2;
      var h = Math.max(target.getNetHeight(),targetStyle.minHeight)+targetStyle.padding*2;
      if (width>0) w = width;
      if (height>0) h = height;
      #if v2
      var graphics = target.graphics;
      #else
      var graphics:openfl.display.Graphics = Reflect.getProperty(target, 'graphics');
      #end

      // draw background
      if (targetStyle.outline_size>0) {
        var outline = targetStyle.outline_color;
        if (isSelected) outline = targetStyle.selected_outline_color;
        var outline_color = toColor(outline);
        var outline_alpha = toAlpha(outline);

        graphics.lineStyle(targetStyle.outline_size,outline_color,outline_alpha);
        graphics.drawRoundRect(0,0,w,h,targetStyle.rounded,targetStyle.rounded);
        #if v2
        graphics.lineStyle(null);
        #else
        graphics.lineStyle(null,null);
        #end


        if (isOver) {
          outline_color = toColor(targetStyle.over_outline_color);
          outline_alpha = toAlpha(targetStyle.over_outline_color);

          if (outline_alpha>0) {
            graphics.lineStyle(targetStyle.outline_size,outline_color,outline_alpha);
            graphics.drawRoundRect(0,0,w,h,targetStyle.rounded,targetStyle.rounded);
            #if v2
            graphics.lineStyle(null);
            #else
            graphics.lineStyle(null,null);
            #end
          }
        }

      }

      var background = targetStyle.background_color;
      if (isSelected) background = targetStyle.selected_background_color;
      if (isOver) background = targetStyle.over_background_color;

      var background_color = toColor(background);
      var background_alpha = toAlpha(background);

      if (targetStyle.bevel>0) {
  			var matrix = new openfl.geom.Matrix();
  			matrix.createGradientBox(w,h,90*Math.PI/180);
  			graphics.beginGradientFill(openfl.display.GradientType.LINEAR,[ColorToolkit.shiftBrighteness(background_color,15),ColorToolkit.shiftBrighteness(background_color,-15)],[background_alpha,background_alpha],[0,255],matrix);
  			graphics.drawRoundRect(0,0,w,h,targetStyle.rounded,targetStyle.rounded);
  			graphics.endFill();
      }

			graphics.beginFill(background_color,background_alpha);
      if (targetStyle.rounded>0)
			   graphics.drawRoundRect(targetStyle.bevel,targetStyle.bevel,w-targetStyle.bevel*2,h-targetStyle.bevel*2,targetStyle.rounded,targetStyle.rounded);
			else
			   graphics.drawRect(targetStyle.bevel,targetStyle.bevel,w-targetStyle.bevel*2,h-targetStyle.bevel*2);
      graphics.endFill();
    }

}
