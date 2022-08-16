package as3_nmea
{
	/*
	BWC - Bearing and distance to waypoint - great circle
	BWC,225444,4917.24,N,12309.57,W,051.9,T,031.6,M,001.3,N,004*29
	225444       UTC time of fix 22:54:44
	4917.24,N    Latitude of waypoint
	12309.57,W   Longitude of waypoint
	051.9,T      Bearing to waypoint, degrees true
	031.6,M      Bearing to waypoint, degrees magnetic
	001.3,N      Distance to waypoint, Nautical miles
	004          Waypoint ID
	*/
	
	public class nmea_bwc_message implements nmea_message
	{
		static protected var headers:Array = ["IIBWC"];
		
		private var waypoint_id: Number;
		private var waypoint_distance: Number;
		private var waypoint_bearing_magnetic: Number;
		private var waypoint_bearing_true: Number;
		private var waypoint_lat: Number;
		private var waypoint_lon: Number;
		private var time_of_fix_utc_ms: Number;
		
		public function nmea_bwc_message()
		{
			
		}
		
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

			time_of_fix_utc_ms = 1000 * (second + 60 * (minute + 60 * hour));

			var p1: Number;
			var p2: Number;
			
			// latitude
			if (parts[2].length)
			{
				var latitude: Number = Number(parts[2]) / 100.0;
				p1 = Math.floor(latitude);
				p2 = 100.0 * (latitude - p1);
			
				waypoint_lat = p1 + p2 / 60.0;
				if (parts[3] == "S")
				{
					waypoint_lat = -waypoint_lat;
				}
			}

			// longitude
			if (parts[4].length)
			{
				var longitude: Number = Number(parts[4]) / 100.0;
				p1 = Math.floor(longitude);
				p2 = 100.0 * (longitude - p1);
			
				waypoint_lon = p1 + p2 / 60.0;
				if (parts[5] == "W")
				{
					waypoint_lon = -waypoint_lon;
				}
			}

			for (var i:int = 6; i < 10; i += 2)
			{
				if (parts[i].length)
				{
					var bearing: Number = Number(parts[i]);
					var heading_type: String = parts[i + 1];

					if (heading_type == "t" || heading_type == "T")
					{
						waypoint_bearing_true = bearing;
					}
					else if (heading_type == "m" || heading_type == "M")
					{
						waypoint_bearing_magnetic = bearing;
					}
				}
			}

			if (parts[10].length)
			{
				waypoint_distance = Number(parts[10]);
			}
			
			if (parts[12].length)
			{
				waypoint_id = Number(parts[12]);
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			// TODO: beszelni Janival, itt majd eventet kell kuldenunk
			return true;
		}
	}
}