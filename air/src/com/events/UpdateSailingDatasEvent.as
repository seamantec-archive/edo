package com.events
{
import com.sailing.SailData;

import flash.events.Event;

public class UpdateSailingDatasEvent extends Event
	{
		public var data:SailData;
        public var needTween:Boolean;
		public function UpdateSailingDatasEvent(data:SailData, needTween:Boolean = true)
		{
			super(UPDATE_SAILING, true);
			this.data = data;
            this.needTween = needTween;
			
		}
		public static const UPDATE_SAILING:String = "updateSailing";


	}
}