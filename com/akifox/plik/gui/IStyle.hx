package com.akifox.plik.gui;

interface IStyle {
  private var _style:Style;
  public var style(get,set):Style;
  private function get_style():Style;
  private function set_style(value:Style):Style;

  public function getNetWidth():Float;
  public function getNetHeight():Float;
  public function getGrossWidth():Float;
  public function getGrossHeight():Float;

  #if flash
  public var graphics(default,never):flash.display.Graphics;
  #else
  public var graphics(get,null):openfl.display.Graphics;
  #end

}
