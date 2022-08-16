package as3_nmea 
{
	/*
	GLL - Geographic Position - Latitude/Longitude

	1       2 3        4 5         6 7
	|       | |        | |         | |
	$--GLL,llll.ll,a,yyyyy.yy,a,hhmmss.ss,A*hh<CR><LF>

	Field Number: 
	1) Latitude
	2) N or S (North or South)
	3) Longitude
	4) E or W (East or West)
	5) Universal Time Coordinated (UTC)
	6) Status A - Data Valid, V - Data Invalid
	7) Checksum
	*/
	public class nmea_gll_message 
	{
		
		static protected var headers:Array = ["IIGLL", "GPGLL"];
		
		private var time_ms_utc: Number;
		private var lat: Number;
		private var lon: Number;
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			var p1: Number;
			var p2: Number;
			// latitude
			if (parts[1].length)
			{
				var latitude: Number = Number(parts[1]) / 100.0;
				p1 = Math.floor(latitude);
				p2 = 100.0 * (latitude - p1);
			
				lat = p1 + p2 / 60.0;
				if (parts[3] == "S")
				{
					lat = -lat;
				}
			}

			// longitude
			if (parts[3].length)
			{
				var longitude: Number = Number(parts[3]) / 100.0;
				p1 = Math.floor(longitude);
				p2 = 100.0 * (longitude - p1);
			
				lon = p1 + p2 / 60.0;
				if (parts[5] == "W")
				{
					lon = -lon;
				}
			}
			
			// utc time
			var hour: int = parseInt(parts[5].substr(0, 2));
			var minute: int = parseInt(parts[5].substr(2, 2));
			var second: int = parseInt(parts[5].substr(4, 2));

			time_ms_utc = 1000 * (second + 60 * (minute + 60 * hour));
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.gps_latitude = lat;
			nmea_data.gps_longitude = lon;
			nmea_data.gps_utc_ms = time_ms_utc;
			
			return true;
		}
		
		public function nmea_gll_message() 
		{
			
		}
		
	}

}