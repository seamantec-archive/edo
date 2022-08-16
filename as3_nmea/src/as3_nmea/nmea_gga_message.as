package as3_nmea 
{
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
	public class nmea_gga_message 
	{
		static protected var headers:Array = ["IIGGA", "GPGGA"];
		
		private var time_ms_utc: Number;
		private var lat: Number;
		private var lon: Number;
		private var num_tracked_sat: Number;
		private var alt: Number;
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			// utc time
			var hour: int = parseInt(parts[1].substr(0, 2));
			var minute: int = parseInt(parts[1].substr(2, 2));
			var second: int = parseInt(parts[1].substr(4, 2));

			time_ms_utc = 1000 * (second + 60 * (minute + 60 * hour));

			var p1: Number;
			var p2: Number;
			
			// latitude
			if (parts[2].length)
			{
				var latitude: Number = Number(parts[2]) / 100.0;
				p1 = Math.floor(latitude);
				p2 = 100.0 * (latitude - p1);
			
				lat = p1 + p2 / 60.0;
				if (parts[3] == "S")
				{
					lat = -lat;
				}
			}

			// longitude
			if (parts[4].length)
			{
				var longitude: Number = Number(parts[4]) / 100.0;
				p1 = Math.floor(longitude);
				p2 = 100.0 * (longitude - p1);
			
				lon = p1 + p2 / 60.0;
				if (parts[5] == "W")
				{
					lon = -lon;
				}
			}

			// num of tracked satellites
			if (parts[7].length)
			{
				num_tracked_sat = Number(parts[7]);
			}

			// altitude
			if (parts[9].length)
			{
				alt = Number(parts[9]);
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.gps_latitude = lat;
			nmea_data.gps_longitude = lon;
			nmea_data.gps_num_tracked_satellites = num_tracked_sat;
			nmea_data.gps_altitude = alt;
			nmea_data.gps_utc_ms = time_ms_utc;
			
			return true;
		}
		
		public function nmea_gga_message() 
		{
			
		}
		
	}

}