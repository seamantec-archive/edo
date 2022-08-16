package com.sailing.nmeaParser.messages 
{
import com.sailing.datas.Gga;

/*
GGA - Global Positioning System Fix Data
GGA,123519,4807.038,N,01131.324,E,1,08,0.9,545.4,M,46.9,M, , *42
    123519       Fix taken at 12:35:19 UTC
    4807.038,N   Latitude 48 deg 07.038' N
    01131.324,E  Longitude 11 deg 31.324' E
    1            Fix quality: 0 = invalid
                              1 = GPS fix
                              2 = DGPS fix
    08           Number of satellites being tracked
    0.9          Horizontal dilution of position
    545.4,M      Altitude, Metres, above mean sea level
    46.9,M       Height of geoid (mean sea level) above WGS84 ellipsoid
    (empty field) time in seconds since last DGPS update
    (empty field) DGPS station ID number
*/
	public class NmeaGgaMessage 
	{
		
		private var data:Gga = new Gga();
		
		
		public function parse(packet:String):void
		{
			
			
			var parts:Array = packet.split(",");
			// utc time
			var hour: int = parseInt(parts[1].substr(0, 2));
			var minute: int = parseInt(parts[1].substr(2, 2));
			var second: int = parseInt(parts[1].substr(4, 2));
			data.hour = hour;
			data.min = minute;
			data.sec = second;
			data.timeMsUtc = 1000 * (second + 60 * (minute + 60 * hour));

			var p1: Number;
			var p2: Number;
			
			// latitude
			if (parts[2].length)
			{
				var latitude: Number = Number(parts[2]) / 100.0;
				p1 = Math.floor(latitude);
				p2 = 100.0 * (latitude - p1);
			
				data.lat = p1 + p2 / 60.0;
				if (parts[3] == "S")
				{
					data.lat = -data.lat;
				}
			}

			// longitude
			if (parts[4].length)
			{
				var longitude: Number = Number(parts[4]) / 100.0;
				p1 = Math.floor(longitude);
				p2 = 100.0 * (longitude - p1);
			
				data.lon = p1 + p2 / 60.0;
				if (parts[5] == "W")
				{
					data.lon = -data.lon;
				}
			}

			// num of tracked satellites
			if (parts[7].length)
			{
				data.numTrackedSat = Number(parts[7]);
			}

			// altitude
			if (parts[9].length)
			{
				data.alt = Number(parts[9]);
			}
			
		}
		
		public function process():Object
		{
			
		
			return {key: "gga", data: data};
		}
		
		public function NmeaGgaMessage() 
		{
			
		}
		
	}

}