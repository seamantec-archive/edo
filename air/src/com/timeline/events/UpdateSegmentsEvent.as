package com.timeline.events
{
import flash.events.Event;

public class UpdateSegmentsEvent extends Event
	{
		public static const UPDATE_SEGMENTS:String = "update-segments";
		public var fileName:String;
		public function UpdateSegmentsEvent(fileName:String)
		{
			super(UPDATE_SEGMENTS);
			this.fileName = fileName;
		}
	}
}