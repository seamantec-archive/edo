package com.loggers
{
import com.store.SettingsConfigs;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class NmeaLogger
	{
		private static var _instance:NmeaLogger;
		private var file:File;
		public function NmeaLogger()
		{
			if(_instance != null){
				
			}else{
				_instance = this;
//				var formatter:DateTimeFormatter = new DateTimeFormatter(flash.globalization.LocaleID.DEFAULT, DateTimeStyle.CUSTOM);
//                formatter.dateTimePattern("yyyy dd hmmss")
				var now:Date = new Date();

				file = File.documentsDirectory;
				file = file.resolvePath("Edo instruments/")
                if(!file.exists){
                    file.createDirectory();
                }
				file = file.resolvePath("nmea/");
                if(!file.exists){
                    file.createDirectory();
                }
				file = file.resolvePath("edo_nmea_"+now.time+".nmea");
			}
		}
		public function getNativePath():String{
			return file.nativePath;
		}
		
		public function getLogFile():File{
			if(!file.exists){
				writeLog("");
			}
			return file;
		}
		public function writeLog(message:String):void{
			//var file:File = File.applicationStorageDirectory;
		    if(SettingsConfigs.instance.logging){
                var fs:FileStream = new FileStream();
                fs.open(file, FileMode.APPEND);
                fs.writeUTFBytes(message);
                fs.close();

           }
		}
		
		
		
		public static function get instance():NmeaLogger{
			if(_instance == null){
				_instance = new NmeaLogger();
			}
			return _instance;
		}
	}
}