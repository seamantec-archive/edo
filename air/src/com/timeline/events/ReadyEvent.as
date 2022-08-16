package com.timeline.events
{
import flash.events.Event;

public class ReadyEvent extends Event
	{
		public static const READY:String = "ready-parsing";
		public var fileName:String;

		public var logFileNativePath:String;
		public function ReadyEvent(fileName:String, logFileNativePath:String)
		{
			super(READY);
			this.logFileNativePath = logFileNativePath;
			this.fileName = fileName;
		}
	}
}