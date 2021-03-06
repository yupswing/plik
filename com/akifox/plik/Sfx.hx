package com.akifox.plik;

import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.Assets;

/**
 * Sound effect object used to play embedded sounds.
 * BASED ON HAXEPUNK SFX
 */
class Sfx
{

	#if flash
	public static inline var FORMAT = ".mp3";
	#else
	public static inline var FORMAT = ".ogg";
	#end
	/**
	 * Optional callback function for when the sound finishes playing.
	 */
	@:dox(hide) // mistaken for a class function
	public var complete:Void -> Void;

    public function toString():String {
        return '[PLIK.Sfx]';
    }

	/**
	 * Creates a sound effect from an embedded source. Store a reference to
	 * this object so that you can play the sound using play() or loop().
	 * @param	source		The embedded sound class to use.
	 * @param	complete	Optional callback function for when the sound finishes playing.
	 */
	public function new(source:String, ?isMusic:Bool = false, ?complete:Void -> Void = null)
	{
		_transform = new SoundTransform();
		_volume = 1;
		_pan = 0;
		_position = 0;
		_type = "";

		if (_sounds.exists(source)) {
			//trace('cache '+source);
			_sound = _sounds[source];
		} else {
			//trace('load '+source);
			if (isMusic) {
				_sound = Assets.getMusic(source + FORMAT,false);
			} else {
				_sound = Assets.getSound(source + FORMAT,false);
			}
			_sounds.set(source, _sound);
		}

		this.complete = complete;
	}

	/**
	 * Plays the sound once.
	 * @param	vol	   Volume factor, a value from 0 to 1.
	 * @param	pan	   Panning factor, a value from -1 to 1.
	 * @param   loop   If the audio should loop infinitely
	 */
	public function play(volume:Float = 1, pan:Float = 0, loop:Bool = false)
	{
		if (_sound == null) return;
		if (playing) stop();
		_pan = Utils.clamp(pan, -1, 1);
		_volume = volume < 0 ? 0 : volume;
		_filteredPan = Utils.clamp(_pan + getPan(_type), -1, 1);
		_filteredVol = Math.max(0, _volume * getVolume(_type));
		_transform.pan = _filteredPan;
		_transform.volume = _filteredVol;
#if flash
		_channel = _sound.play(0, 0, _transform);
#else
		_channel = _sound.play(0, loop ? -1 : 0, _transform);
#end
		if (playing)
		{
			addPlaying();
			_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		}
		_looping = loop;
		_position = 0;
	}

	/**
	 * Plays the sound looping. Will loop continuously until you call stop(), play(), or loop() again.
	 * @param	vol		Volume factor, a value from 0 to 1.
	 * @param	pan		Panning factor, a value from -1 to 1.
	 */
	public function loop(vol:Float = 1, pan:Float = 0)
	{
		play(vol, pan, true);
	}

	/**
	 * Stops the sound if it is currently playing.
	 *
	 * @return If the sound was stopped.
	 */
	public function stop():Bool
	{
		if (!playing) return false;
		removePlaying();
		_position = _channel.position;
		_channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
		_channel.stop();
		_channel = null;
		return true;
	}

	/**
	 * Resumes the sound from the position stop() was called on it.
	 */
	public function resume()
	{
#if flash
		_channel = _sound.play(_position, 0, _transform);
#else
		_channel = _sound.play(_position, _looping ? -1 : 0, _transform);
#end
		if (playing)
		{
			addPlaying();
			_channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		}
		_position = 0;
	}

	/** @private Event handler for sound completion. */
	private function onComplete(e:Event = null)
	{
		if (_looping) loop(_volume, _pan);
		else stop();

		_position = 0;
		if (complete != null) complete();
	}

	/** @private Add the sound to the global list. */
	private function addPlaying()
	{
		var list:Array<Sfx>;
		if (!_typePlaying.exists(_type))
		{
			list = new Array<Sfx>();
			_typePlaying.set(_type, list);
		}
		else
		{
			list = _typePlaying.get(_type);
		}
		list.push(this);
	}

	/** @private Remove the sound from the global list. */
	private function removePlaying()
	{
		if (_typePlaying.exists(_type))
		{
			_typePlaying.get(_type).remove(this);
		}
	}

	/**
	 * Alter the volume factor (a value from 0 to 1) of the sound during playback.
	 */
	public var volume(get, set):Float;
	private function get_volume():Float { return _volume; }
	private function set_volume(value:Float):Float
	{
		if (value < 0) value = 0;
		if (_channel == null) return value;
		_volume = value;
		var filteredVol:Float = value * getVolume(_type);
		if (filteredVol < 0) filteredVol = 0;
		if (_filteredVol == filteredVol) return value;
		_filteredVol = _transform.volume = filteredVol;
		_channel.soundTransform = _transform;
		return _volume;
	}

	/**
	 * Alter the panning factor (a value from -1 to 1) of the sound during playback.
	 */
	public var pan(get, set):Float;
	private function get_pan():Float { return _pan; }
	private function set_pan(value:Float):Float
	{
		value = Utils.clamp(value, -1, 1);
		if (_channel == null) return value;
		var filteredPan:Float = Utils.clamp(value + getPan(_type), -1, 1);
		if (_filteredPan == filteredPan) return value;
		_pan = value;
		_filteredPan = _transform.pan = filteredPan;
		_channel.soundTransform = _transform;
		return _pan;
	}

	/**
	 * Change the sound type. This an arbitrary string you can use to group
	 * sounds to mute or pan en masse.
	 */
	public var type(get, set):String;
	private function get_type():String { return _type; }
	private function set_type(value:String):String
	{
		if (_type == value) return value;
		if (playing)
		{
			removePlaying();
			_type = value;
			addPlaying();
			// reset, in case type has different global settings
			pan = pan;
			volume = volume;
		}
		else
		{
			_type = value;
		}
		return value;
	}

	/**
	 * If the sound is currently playing.
	 */
	public var playing(get, null):Bool;
	private inline function get_playing():Bool { return _channel != null; }

	/**
	 * Position of the currently playing sound, in seconds.
	 */
	public var position(get, null):Float;
	private function get_position():Float { return (playing ? _channel.position : _position) / 1000; }

	/**
	 * Length of the sound, in seconds.
	 */
	public var length(get, null):Float;
	private function get_length():Float { return _sound.length / 1000; }

	/**
	 * Return the global pan for a type.
	 *
	 * @param	type	The type to get the pan from.
	 *
	 * @return	The global pan for the type.
	 */
	static public function getPan(type:String):Float
	{
		if (_typeTransforms.exists(type))
		{
			var transform = _typeTransforms.get(type);
			return transform != null ? transform.pan : 0;
		}
		return 0;
	}

	/**
	 * Return the global volume for a type.
	 *
	 * @param	type	The type to get the volume from.
	 *
	 * @return	The global volume for the type.
	 */
	static public function getVolume(type:String):Float
	{
		if (_typeTransforms.exists(type))
		{
			var transform = _typeTransforms.get(type);
			return transform != null ? transform.volume : 1;
		}
		return 1;
	}

	/**
	 * Set the global pan for a type. Sfx instances of this type will add
	 * this pan to their own.
	 *
	 * @param	type	The type to set.
	 * @param	pan		The pan value.
	 */
	static public function setPan(type:String, pan:Float)
	{
		var transform:SoundTransform = _typeTransforms.get(type);
		if (transform == null)
		{
			transform = new SoundTransform();
			_typeTransforms.set(type, transform);
		}
		transform.pan = Utils.clamp(pan, -1, 1);

		if (_typePlaying.exists(type))
		{
			for (sfx in _typePlaying.get(type))
			{
				sfx.pan = sfx.pan;
			}
		}
	}

	/**
	 * Set the global volume for a type. Sfx instances of this type will
	 * multiply their volume by this value.
	 *
	 * @param	type	The type to set.
	 * @param	volume	The volume value.
	 */
	static public function setVolume(type:String, volume:Float)
	{
		var transform:SoundTransform = _typeTransforms.get(type);
		if (transform == null)
		{
			transform = new SoundTransform();
			_typeTransforms.set(type, transform);
		}
		transform.volume = volume < 0 ? 0 : volume;

		if (_typePlaying.exists(type))
		{
			for (sfx in _typePlaying.get(type))
			{
				sfx.volume = sfx.volume;
			}
		}
	}

	static public function removeSound(name:String):Bool {
		if (_soundFastPlaying.exists(name)) {
			_soundFastPlaying.remove(name);
		}
		if (_sounds.exists(name))
		{
			var sound = _sounds.get(name);
			sound.close();
			sound = null;
			return _sounds.remove(name);
		}
		return false;
	}

	static public function preloadSound(name:String, ?isMusic:Bool = false):Void {
    if (_sounds.exists(name)) return;
		var data:Sound;
		if (isMusic) {
			data = Assets.getMusic(name + FORMAT,false);
		} else {
			data = Assets.getSound(name + FORMAT,false);
		}
		if (data != null) _sounds.set(name, data);
		data = null;
	}

	// fast way to play a sound directly with a cache (no new Sfx instances)
	private static var _soundFastPlaying:Map<String,Sfx> = new Map<String,Sfx>();

	static public function fastPlay(name:String,?volume:Float=1,?pan:Float=0.5,?type:String="sound") {

		if (!_soundEnabled) return;

		var sound:Sfx;
		if (!_soundFastPlaying.exists(name))
		{
			sound = new Sfx(name);
			_soundFastPlaying.set(name, sound);
		}
		else
		{
			sound = _soundFastPlaying.get(name);
		}
		sound.type = type;
		sound.volume = volume;
		sound.pan = pan;
		sound.play();

	}

	private static var _soundEnabled:Bool = true;
	public static var soundEnabled(get,set):Bool;
	private static function get_soundEnabled():Bool {
		return _soundEnabled;
	}
	private static function set_soundEnabled(value:Bool):Bool {
		for (type in _typePlaying.keys()) {
			//setVolume(type,(value?1:0));
		}
		return _soundEnabled = value;
	}

	// Sound infromation.

	private var _type:String;
	private var _volume:Float = 1;
	private var _pan:Float = 0;
	private var _filteredVol:Float;
	private var _filteredPan:Float;
	private var _sound:Sound;
	private var _channel:SoundChannel;
	private var _transform:SoundTransform;
	private var _position:Float = 0;
	private var _looping:Bool;

	// Stored Sound objects.
	private static var _sounds:Map<String,Sound> = new Map<String,Sound>();
	private static var _typePlaying:Map<String,Array<Sfx>> = new Map<String,Array<Sfx>>();
	private static var _typeTransforms:Map<String,SoundTransform> = new Map<String,SoundTransform>();
}
