package com.akifox.plik.atlas;

import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Assets;

import com.akifox.plik.atlas.AtlasData;

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
		var xml = Xml.parse(Assets.getText(Gfx.bitmapPath(file)));
		var root = xml.firstElement();
		var atlas = new TextureAtlas(root.get("imagePath"));
		for (sprite in root.elements())
		{
			PLIK.point.x = 0;
			PLIK.point.y = 0;
			if (sprite.exists("frame_x")) PLIK.point.x = Std.parseInt(sprite.get("frame_x"));
			if (sprite.exists("frame_y")) PLIK.point.y = Std.parseInt(sprite.get("frame_y"));

			//rect
			PLIK.rect.x = Std.parseInt(sprite.get("x"));
			PLIK.rect.y = Std.parseInt(sprite.get("y"));
			if (sprite.exists("w")) PLIK.rect.width = Std.parseInt(sprite.get("w"));
			else if (sprite.exists("width")) PLIK.rect.width = Std.parseInt(sprite.get("width"));
			if (sprite.exists("h")) PLIK.rect.height = Std.parseInt(sprite.get("h"));
			else if (sprite.exists("height")) PLIK.rect.height = Std.parseInt(sprite.get("height"));

			// frame
			PLIK.rect2.x = 0;
			PLIK.rect2.y = 0;
			PLIK.rect2.width = PLIK.rect.width;
			PLIK.rect2.height = PLIK.rect.width;
			if (sprite.exists("frame_x")) PLIK.rect2.x = Std.parseInt(sprite.get("frame_x"));
			if (sprite.exists("frame_y")) PLIK.rect2.y = Std.parseInt(sprite.get("frame_y"));
			if (sprite.exists("frame_width")) PLIK.rect2.width = Std.parseInt(sprite.get("frame_width"));
			if (sprite.exists("frame_height")) PLIK.rect2.height = Std.parseInt(sprite.get("frame_height"));

			// set the defined region
			var name = if (sprite.exists("n")) sprite.get("n")
						else if (sprite.exists("name")) sprite.get("name")
						else throw("Unable to find the region's name.");

			var region = atlas.defineRegion(name, PLIK.rect, PLIK.rect2);

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
	public function defineRegion(name:String, rect:Rectangle, ?frame:Rectangle):AtlasRegion
	{
		var region = _data.createRegion(rect, frame);
		_regions.set(name, region);
		return region;
	}

	private var _regions:Map<String,AtlasRegion>;
}
