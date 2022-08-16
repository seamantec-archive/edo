package com.events 
{
import flash.events.Event;

public class UpdateNmeaDatasEvent extends Event
	{
		public var data:Object;
		public static const UPDATE_NMEA_DATAS:String = "updateNmeaDatas";
		public function UpdateNmeaDatasEvent(data:Object)
		{
			super(UPDATE_NMEA_DATAS, true);
			this.data = data;
		}
		
	}
}