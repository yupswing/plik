package com.akifox.lib;

import openfl.net.SharedObject;

/* Based on Haxepunk/Data.hx */

/**
 * Static helper class used for saving and loading data from stored cookies.
 */
class Data
{
	/**
	 * If you want to share data between different SWFs on the same host, use this id.
	 */
	private var id:String = "";
	private var file:String = "";

	public function new(file:String="",?id:String="") {
		this.id = id;
		this.file = file;
		load();
	}

	/**
	 * Overwrites the current data with the file.
	 * @param	file		The filename to load.
	 */
	public function load()
	{
		var data:Dynamic = loadData();
		_data = new Map<String,Dynamic>();
		for (str in Reflect.fields(data)) _data.set(str, Reflect.field(data, str));
	}

	/**
	 * Overwrites the file with the current data. The current data will not be saved until this function is called.
	 * @param	file		The filename to save.
	 * @param	overwrite	Clear the file before saving.
	 */
	public function save(overwrite:Bool = true)
	{
		if (_shared != null) _shared.clear();
		var data:Dynamic = loadData();
		var str:String;
		if (overwrite)
			for (str in Reflect.fields(data)) Reflect.deleteField(data, str);
		for (str in _data.keys()) Reflect.setField(data, str, _data.get(str));

#if js
		_shared.flush();
#else
		_shared.flush(SIZE);
#end
	}

	/**
	 * Reads an int from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public function readInt(name:String, defaultValue:Int = 0):Int
	{
		return Std.int(read(name, defaultValue));
	}

	/**
	 * Reads a Boolean from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public function readBool(name:String, defaultValue:Bool = true):Bool
	{
		return read(name, defaultValue);
	}

	/**
	 * Reads a String from the current data.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public function readString(name:String, defaultValue:String = ""):String
	{
		return Std.string(read(name, defaultValue));
	}

	/**
	 * Reads a property from the data object.
	 * @param	name			Property to read.
	 * @param	defaultValue	Default value.
	 * @return	The property value, or defaultValue if the property is not assigned.
	 */
	public function read(name:String, defaultValue:Dynamic = null):Dynamic
	{
		if (_data.get(name) != null) return _data.get(name);
		return defaultValue;
	}

	/**
	 * Writes a Dynamic object to the current data.
	 * @param	name		Property to write.
	 * @param	value		Value to write.
	 */
	public function write(name:String, value:Dynamic)
	{
		_data.set(name, value);
	}

	/** @private Loads the data file, or return it if you're loading the same one. */
	private function loadData():Dynamic
	{
		if (file == null) file = DEFAULT_FILE;
		if (id != "") _shared = SharedObject.getLocal(PREFIX + "/" + id + "/" + file, "/");
		else _shared = SharedObject.getLocal(PREFIX + "/" + file);
		return _shared.data;
	}

	// Data information.
	private var _shared:SharedObject;
	private var _data:Map<String,Dynamic> = new Map<String,Dynamic>();
	private static inline var PREFIX:String = "Akifox";
	private static inline var DEFAULT_FILE:String = "_default";
	private static inline var SIZE:Int = 10000;
}