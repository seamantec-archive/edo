package com.sailing.nmeaParser.messages 
{
import com.sailing.datas.Rsa;

/*
RSA - Rudder Sensor Angle

1   2 3   4 5
|   | |   | |
$--RSA,x.x,A,x.x,A*hh<CR><LF>

Field Number:
1) Starboard (or single) rudder sensor, "-" means Turn To Port
2) Status, A means data is valid
3) Port rudder sensor
4) Status, A means data is valid
5) Checksum
*/
	public class NmeaRsaMessage 
	{

		private var data:Rsa = new Rsa();	
		
		public function parse(packet:String):void
		{
						
			var parts:Array = packet.split(",");
			
			if (parts[1].length)
			{
				data.rudderSensorStarboard= Number(parts[1]);
			}
			
			if (parts[2].length)
			{
				data.rudderSensorStarboardValid= (parts[2] == "A" ? 1 : 0);
			}
			
			if (parts[3].length)
			{
				data.rudderSensorPort= Number(parts[3]);
			}
			
			if (parts[4].length)
			{
				data.rudderSensorPortValid= (parts[4] == "A" ? 1 : 0);
			}
			
		}
		
		public function process():Object
		{
			return {key:"rsa", data:data};
		}
		
		public function NmeaRsaMessage() 
		{
			
		}
		
	}

}