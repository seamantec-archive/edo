package com.events
{
	import flash.events.Event;
	
	public class UpdateStateEvent extends Event
	{
		public var stateType:String;		
		public function UpdateStateEvent(stateType:String)
		{
			super("update-state", true);
			this.stateType = stateType;
			
		}
	}
}