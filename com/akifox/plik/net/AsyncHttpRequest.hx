package com.akifox.plik.net;

import haxe.Timer;
using StringTools;

#if (neko || cpp || java)

	import haxe.io.Bytes;

	#if neko 
		typedef Thread = neko.vm.Thread;
		typedef Lib = neko.Lib;
	#elseif java
		typedef Thread = java.vm.Thread;
		typedef Lib = java.Lib;
	#elseif cpp
		typedef Thread = cpp.vm.Thread;
		typedef Lib = cpp.Lib;
	#end

#else

	import openfl.net.URLLoader;
	import openfl.net.URLRequest;
	import openfl.events.Event;
	import openfl.events.IOErrorEvent;

#end
 

enum TRANSFER_MODE {
  WHOLE;
  CHUNKED;
}
 
class AsyncHttpRequest
{

	public static var logEnabled:Bool = #if debug true #else false #end;
	private static inline function log(message:String) {
		if (logEnabled) trace('$message'); 
	}

	public static function send(url:String,response:AsyncHttpResponse->Void) {

		#if (neko || cpp || java)

		// Multithread version for NEKO, CPP + JAVA
		var worker = Thread.create(useSocket);
		worker.sendMessage(url);
		worker.sendMessage(response);

		#else

		// URLLoader version (HTML5 + FLASH)
		useURLLoader(url,response);

		#end

	}

	#if (neko || cpp || java)

	// Multithread version for NEKO, CPP + JAVA

	private static function useSocket()
	{
		var url:String = Thread.readMessage(true);
		var response:AsyncHttpResponse->Void = Thread.readMessage(true);

		var content:String=null;
		var start = Timer.stamp();

		// decode url (HTTP://$HOST:$PORT/$PATH?$DATA)
		var r = ~/https?:\/\/([^\/\?:]+)(:\d+|)(\/[^\?]*|)(\?.*|)/;
		r.match(url);
		var host = r.matched(1);
		var port = r.matched(2);
		if (port=="") port = "80";
		else port = port.substr(1); //removes ":"
		var path = r.matched(3);
		if (path=="") path = "/";
		var data = r.matched(4);
		if (data!="") data = data.substr(1); //removes "?"

		log('INFO: Begin http request $host:$port$path?$data"');
		var s = new sys.net.Socket();
		var connected = false;
		try {
			s.connect(new sys.net.Host(host), Std.parseInt(port));
			connected = true;
		} catch (m:String) {
		  	log('ERROR: Request failed -> $m');
		}

		var headers = new Map<String, String>();
		var response_code:Int = 0;
		var bytes_loaded:Int = 0;

		if (connected) {
			s.output.writeString('GET $path?$data HTTP/1.1\r\n');
			s.output.writeString('Host: $host\r\n');
			s.output.writeString('\r\n');

			var response:String = "";
			while (true)
			{
				var ln = s.input.readLine().trim();
				if (ln == '') break; //end of response headers

				if (response=="") {
					response = ln;
					var r = ~/^HTTP\/\d+\.\d+ (\d+)/;
					r.match(response);
					response_code = Std.parseInt(r.matched(1));
				} else {
					var a = ln.split(':');
					var key = a.shift().toLowerCase();
					headers[key] = a.join(':').trim();   
				}   
		  	}

			var chunked = (headers['transfer-encoding'] == 'chunked');
			//var content_length = Std.parseInt(headers['content-length']);

			var mode:TRANSFER_MODE = TRANSFER_MODE.WHOLE;
			//if (content_length>0) mode = TRANSFER_MODE.FIXED;
			if (chunked) mode = TRANSFER_MODE.CHUNKED;

			var bytes:Bytes;

			switch(mode) {
				case TRANSFER_MODE.WHOLE:

					bytes = s.input.readAll();
					bytes_loaded = bytes.length;
					content = bytes.toString();

				case TRANSFER_MODE.CHUNKED:

					var buffer = new Array<String>();
					var chunk:Int;
					while(true) {
						var v:String = s.input.readLine();
						//trace(v.toString());
						chunk = Std.parseInt('0x$v');
						//trace('chunk $chunk');
						if (chunk==0) break;
						bytes = s.input.read(chunk);
						bytes_loaded += chunk;
						buffer.push(bytes.toString());
						s.input.read(2); // \n\r between chunks = 2 bytes
					}
					content = buffer.join('');

					buffer = null;
			}

		  bytes = null;

		}

		s.close();
		s = null;

		var time = Std.int((Timer.stamp() - start)*1000)/1000;

		log('INFO: Response $response_code ($bytes_loaded bytes in $time s)\n> $host:$port$path?$data');
		response({request:url,status:response_code,content:content,time:time});
  	}

	#else
	  
	// URLLoader version (HTML5 + FLASH)

	private static function useURLLoader(url:String,response:AsyncHttpResponse->Void) {
		var urlLoader:URLLoader = new URLLoader();
		var start = Timer.stamp();
		log('INFO: Begin http request $url');

		urlLoader.addEventListener(Event.COMPLETE, function(e:Event) {
		    var time = Std.int((Timer.stamp() - start)*1000)/1000;
		    log('INFO: Response 200 ($time s)');
		    response({request:url,status:200,content:e.target.data,time:time});
		    urlLoader = null;
		});
		urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
		    var time = Std.int((Timer.stamp() - start)*1000)/1000;
		    log('INFO: Response ' + e.errorID + ' ($time s)');
		    response({request:url,status:e.errorID,content:null,time:time});
		    urlLoader = null;
		});

		try {
		  	urlLoader.load(new URLRequest(url));
		} catch ( msg : Dynamic ) {
		    var time = Std.int((Timer.stamp() - start)*1000)/1000;
		    log('ERROR: Request failed -> ' + msg.toString());
		    response({request:url,status:0,content:null,time:time});
		    urlLoader = null;
		} 
	}

	#end

}

typedef AsyncHttpResponse = {
  var request:String;
  var status:Int;
  var content:String;
  var time:Float;
}