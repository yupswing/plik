package com.akifox.lib.atlas;

import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Assets;

import com.akifox.lib.atlas.AtlasData;

class TextureAtlas extends Atlas
{

	private function new(source:AtlasDataType)
	{
		_regions = new Map<String,AtlasRegion>();

		super(source);
	}

	/**
	 * Loads a TexturePacker xml file and generates all tile regions.
	 * Uses the Generic XML exporter format from Texture Packer.
	 * @param	file	The TexturePacker file to load
	 * @return	A TextureAtlas with all packed images defined as regions
	 */
	public static function loadTexturePacker(file:String):TextureAtlas
	{
		var xml = Xml.parse(Assets.getText(Akifox.bitmapPath(file)));
		var root = xml.firstElement();
		var atlas = new TextureAtlas(root.get("imagePath"));
		for (sprite in root.elements())
		{
			Akifox.point.x = 0;
			Akifox.point.y = 0;
			if (sprite.exists("frame_x")) Akifox.point.x = Std.parseInt(sprite.get("frame_x"));
			if (sprite.exists("frame_y")) Akifox.point.y = Std.parseInt(sprite.get("frame_y"));

			Akifox.rect.x = Std.parseInt(sprite.get("x"));
			Akifox.rect.y = Std.parseInt(sprite.get("y"));
			if (sprite.exists("w")) Akifox.rect.width = Std.parseInt(sprite.get("w"));
			else if (sprite.exists("width")) Akifox.rect.width = Std.parseInt(sprite.get("width"));
			if (sprite.exists("h")) Akifox.rect.height = Std.parseInt(sprite.get("h"));
			else if (sprite.exists("height")) Akifox.rect.height = Std.parseInt(sprite.get("height"));

			// set the defined region
			var name = if (sprite.exists("n")) sprite.get("n")
						else if (sprite.exists("name")) sprite.get("name")
						else throw("Unable to find the region's name.");

			var region = atlas.defineRegion(name, Akifox.rect, Akifox.point);

			if (sprite.exists("r") && sprite.get("r") == "y") region.rotated = true;
		}
		return atlas;
	}

	/**
	 * Gets an atlas region based on an identifier
	 * @param	name	The name identifier of the region to retrieve.
	 *
	 * @return	The retrieved region.
	 */
	public function getRegion(name:String):AtlasRegion
	{
		if (_regions.exists(name))
			return _regions.get(name);
			
		throw 'Region has not been defined yet "$name".';
	}

	/**
	 * Creates a new AtlasRegion and assigns it to a name
	 * @param	name	The region name to create
	 * @param	rect	Defines the rectangle of the tile on the tilesheet
	 * @param	offset	Offset
	 *
	 * @return	The new AtlasRegion object.
	 */
	public function defineRegion(name:String, rect:Rectangle, ?offset:Point):AtlasRegion
	{
		var region = _data.createRegion(rect, offset);
		_regions.set(name, region);
		return region;
	}

	private var _regions:Map<String,AtlasRegion>;
}
