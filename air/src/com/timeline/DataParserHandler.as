package com.timeline
{
import com.timeline.events.ParsingStartedEvent;
import com.timeline.events.ReadyEvent;
import com.timeline.events.StatusUpdateEvent;
import com.timeline.events.StopForSegmentationEvent;
import com.timeline.events.UpdateSegmentsEvent;
import com.workers.WorkersHandler;

import flash.display.Sprite;
import flash.filesystem.File;

public class DataParserHandler extends Sprite
	{
		private static var _instance:DataParserHandler;
		
		public function DataParserHandler()
		{
			if(_instance != null){
				
			}else{
				
			}
		}
		
		public function parseNmeaData(logFile:File):void{					
			WorkersHandler.instance.mainToNmeaReader.send({action:"start", logFile:logFile});				
		}
		
		public function setProgress(completed:Number, total:Number):void{
			dispatchEvent(new StatusUpdateEvent(completed, total));
		}
		
		public function readyLoadingHandler(fileName:String, logFileNativePath:String):void{
			dispatchEvent(new ReadyEvent(fileName, logFileNativePath));
		}
		public function updateSegmentsStatusHandler(fileNativePath:String):void{
			dispatchEvent(new UpdateSegmentsEvent(fileNativePath));
		}
		
		public function refreshLoadingHandler(fileName:String, actualIndex:Number, nativePath:String, actualSegment:Number):void{
			dispatchEvent(new StopForSegmentationEvent(fileName, actualIndex,nativePath, actualSegment));
		}
		public function logFileParsingStartedHandler(fileNativePath:String, lastTimestamp:Number):void{
			dispatchEvent(new ParsingStartedEvent(fileNativePath, lastTimestamp));
		}
		public static function get instance():DataParserHandler{
			if(_instance == null){
				_instance = new DataParserHandler();
			}
			return _instance;
		}
	}
}