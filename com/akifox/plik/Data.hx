package com.akifox.plik;

import openfl.net.SharedObject;

/* Based on Haxepunk/Data.hx */

typedef Datas = {
    var data:Data;
    var fields:Map<String,Int>;
}

/**
 * Static helper class used for saving and loading data from stored cookies.
 */
class Data
{

	/////////////////////////////////////////////////////////////////////////

	public static inline var DYNAMIC = 0;
	public static inline var BOOL = 1;
	public static inline var INT = 2;
	public static inline var STRING = 3;

	private static var datas:Map<String,Datas> = new Map<String,Datas>();

	private static function getData(id:String) {
		if (!datas.exists(id)) return null;
		return datas[id];
	}

	public static function setDataField(id:String,name:String,type:Int,defaultValue:Dynamic){
		var data:Datas = getData(id);
		if (data==null) return;
		if (data.fields==null) return;
		data.fields[name] = type;
		writeData(id,name,readData(id,name,defaultValue));
	}

	public static function loadData(id:String) {
		datas[id] = {data : new Data(id), fields : new Map<String,Int>()};
	}

	public static function saveData(id:String) {
		var data:Datas = getData(id);
		if (data==null) return;
		data.data.save();
	}

	//standard are 'music' 'sound' 'fullscreen'
	public static function readData(id:String,name:String,?defaultValue:Dynamic=null):Dynamic {
		var data:Datas = getData(id);
		if (data==null) return null;

		var type:Int = DYNAMIC;
		if (data.fields.exists(name)) {
			type = data.fields[name];
		}

		switch (type) {
			case STRING:
				return data.data.readString(name,defaultValue);
			case INT:
				return data.data.readInt(name,defaultValue);
			case BOOL:
				return data.data.readBool(name,defaultValue);
		}
		return data.data.read(name,defaultValue);
	}

	public static function writeData(id:String,name:String,value:Dynamic) {
		var data:Datas = getData(id);
		if (data==null) return;
		data.data.write(name,value);
	}

	/////////////////////////////////////////////////////////////////////////



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
		var data:Dynamic = loadD();
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
		var data:Dynamic = loadD();
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
	private function loadD():Dynamic
	{
		if (file == null) file = DEFAULT_FILE;
		if (id != "") _shared = SharedObject.getLocal(PREFIX + "/" + id + "/" + file, "/");
		else _shared = SharedObject.getLocal(PREFIX + "/" + file);
		return _shared.data;
	}

	// Data information.
	private var _shared:SharedObject;
	private var _data:Map<String,Dynamic> = new Map<String,Dynamic>();
	private static inline var PREFIX:String = "PLIK";
	private static inline var DEFAULT_FILE:String = "_default";
	private static inline var SIZE:Int = 10000;
}