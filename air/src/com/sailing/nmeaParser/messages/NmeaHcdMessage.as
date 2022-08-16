package com.sailing.nmeaParser.messages
{
	/**
	 * 
	 * HCD - Heading and Deviation
	 * 
	 *        1. 2. 3. 4. 5. 6. 
	 *         |  |  |  |  |  |
	 * $--HCD,x.x,M,x.x,H,x.x,a*hh<CR><LF>
	 * 
	 * 
	 * 1.2. Magnetic heading, degrees
	 * 
	 * 3.4. Compass heading, degrees
	 * 
	 * 5.6 Magnetic deviation, degrees E/W1
	 * 
	 * */


import com.sailing.datas.Hcd;

public class NmeaHcdMessage implements NmeaMessage
	{
		
		private var data:Hcd = new Hcd();
		
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			
			data.magneticHeading = new Number(parts[1]);
			data.compassHeading = new Number(parts[3]);
			data.magneticDeviation = new Number(parts[5]);
		}
		
		public function process():Object
		{
			return {key:"hcd", data:data};
		}
	}
}