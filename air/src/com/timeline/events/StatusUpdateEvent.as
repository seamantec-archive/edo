package com.timeline.events
{
import flash.events.Event;

public class StatusUpdateEvent extends Event
	{
		public static const STATUS_UPDATE:String = "status-update";
		public var completed:Number;
		public var total:Number;
		public function StatusUpdateEvent(completed:Number, total:Number)
		{
			super(STATUS_UPDATE, true, true);
			this.completed = completed;
			this.total = total;
		}
	}
}