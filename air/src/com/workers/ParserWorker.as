package com.workers
{
import com.loggers.SystemLogger;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;
import com.sailing.nmeaParser.utils.NmeaUtil;

import flash.display.Sprite;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.system.MessageChannel;
import flash.system.Worker;

public class ParserWorker extends Sprite
	{
        NmeaUtil.registerNmeaDatas();
		private var parserToMain:MessageChannel;
		private var mainToParser:MessageChannel;
		private var file:File;
		public function ParserWorker()
		{
			parserToMain = Worker.current.getSharedProperty("parserToMain");
			mainToParser = Worker.current.getSharedProperty("mainToParser");			
			mainToParser.addEventListener(Event.CHANNEL_MESSAGE, onMainToParser, false, 0, true);
			file = File.desktopDirectory;
			file = file.resolvePath("sailing/nmea_data_"+new Date().time+".log");
		}



		protected function onMainToParser(event:Event):void
		{
			
				try{
						var message:String = mainToParser.receive();						
						logNMEAToFile(message);
						
						var packeter = new NmeaPacketer();		
						var packet_data: Array = packeter.newReadPacket(message);
						
												for each(var a:String in packet_data){
							//interpreter.interpret(a);
							var x = NmeaInterpreter.processWithMessageCode(a);
							if(x != null){	
								/*var data = x.data;
								var bArray:ByteArray = new ByteArray();
								bArray.writeObject(data);
								bArray.position = 0;
								var oldData = bArray.readObject();*/
								
								parserToMain.send(x);
								
							}else{
								trace("x is null", a);
								SystemLogger.Error(a);
							}
						}
				
				}catch(e:Error){
					trace(e.message);
				}
			
		}
		
		private function logNMEAToFile(message:String){
			var fs:FileStream = new FileStream();
			fs.open(file,FileMode.APPEND);
			fs.writeUTFBytes(message + "\r\n");
			fs.close();
		}

	}
}