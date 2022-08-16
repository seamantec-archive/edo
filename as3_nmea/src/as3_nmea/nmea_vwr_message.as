package as3_nmea 
{
	/*
	VWR - Relative wind direction and speed
	VWR,148.,L,02.4,N,01.2,M,04.4,K
		148.,L       Wind from 148 deg Left of bow
		02.4,N       Speed 2.4 Knots
		01.2,M       1.2 Metres/Sec
		04.4,K       Speed 4.4 Kilometers/Hr
	*/
	public class nmea_vwr_message 
	{
		static protected var headers:Array = ["IIVWR"];
		
		private var wind_direction: Number;
		private var wind_direction_side: Number;
		private var wind_speed_knots: Number;
		private var wind_speed_mps: Number;
		private var wind_speed_kmh: Number;
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			if (parts[1].length)
			{
				wind_direction = Number(parts[1]);
			}
			
			wind_direction_side = parts[2];
	
			for (var i:int = 3; i < 9; i += 2)
			{
				if (parts[i].length)
				{
					var speedValue: Number = Number(parts[i]);
					var speedType: String = parts[i + 1];

					if (speedType == "N" || speedType == "n")
					{
						wind_speed_knots = speedValue;
					}
					else if (speedType == "M" || speedType == "m")
					{
						wind_speed_mps = speedValue;
					}
					else if (speedType == "K" || speedType == "k")
					{
						wind_speed_kmh = speedValue;
					}
				}
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.relative_wind_direction = wind_direction;
			nmea_data.relative_wind_direction_side = wind_direction_side;
			nmea_data.relative_wind_speed_knots = wind_speed_knots;
			nmea_data.relative_wind_speed_mps = wind_speed_mps;
			nmea_data.relative_wind_speed_kmh = wind_speed_kmh;
			
			return true;
		}
		
		public function nmea_vwr_message() 
		{
			
		}
		
	}

}