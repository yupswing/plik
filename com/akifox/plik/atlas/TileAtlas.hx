package com.akifox.plik.atlas;
import openfl.display.BitmapData;

class TileAtlas extends Atlas
{
	/**
	 * Constructor.
	 *
	 * @param	source		Source texture.
	 */
	public function new(source:AtlasDataType)
	{
		super(source);
		_regions = new Array<AtlasRegion>();
	}

	/**
	 * Gets an atlas region based on an identifier
	 * @param 	index	The tile index of the region to retrieve
	 *
	 * @return	The atlas region object.
	 */
	public function getRegion(index:Int):AtlasRegion
	{
		if (index >= _regions.length)
		{
			throw 'Atlas doesn\'t have a region number "$index"';
		}
		
		return _regions[index];
	}
	
	/**
	 * Prepares the atlas for drawing.
	 * @param	tileWidth	With of the tiles.
	 * @param	tileHeight	Height of the tiles.
	 * @param	tileMarginWidth		Tile horizontal margin.
	 * @param	tileMarginHeight	Tile vertical margin.
	 */
	public function prepare(tileWidth:Int, tileHeight:Int, tileMarginWidth:Int=0, tileMarginHeight:Int=0)
	{
		if (_regions.length > 0) return; // only prepare once
		var cols:Int = Math.floor(_data.width / tileWidth);
		var rows:Int = Math.floor(_data.height / tileHeight);

		PLIK.rect.width = tileWidth;
		PLIK.rect.height = tileHeight;

		PLIK.point.x = PLIK.point.y = 0;

		for (y in 0...rows)
		{
			PLIK.rect.y = y * (tileHeight+tileMarginHeight);

			for (x in 0...cols)
			{
				PLIK.rect.x = x * (tileWidth+tileMarginWidth);

				_regions.push(_data.createRegion(PLIK.rect, PLIK.point));
			}
		}
	}

	private var _regions:Array<AtlasRegion>;
}