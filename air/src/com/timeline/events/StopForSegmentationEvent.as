package com.timeline.events
{
import flash.events.Event;

public class StopForSegmentationEvent extends Event
	{
		public static const STOP_FOR_SEGMENTATION:String = "stop-for-segmentation"
		
		public var fileName:String;
		public var actualIndex:Number;
		public var fileNativePath:String;

		public var actualSegment:Number;
		
		public function StopForSegmentationEvent(fileName:String, actualIndex:Number, fileNativePath:String, actualSegment:Number)
		{
			super(STOP_FOR_SEGMENTATION,true, true);
			this.actualSegment = actualSegment;
			this.fileNativePath = fileNativePath;
			this.fileName = fileName;
			this.actualIndex = actualIndex;
		}
	}
}