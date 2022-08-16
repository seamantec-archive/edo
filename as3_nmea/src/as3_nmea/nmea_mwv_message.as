package as3_nmea 
{
	/*
	MWV - Wind Speed and Angle

	1   2 3   4 5
	|   | |   | |
	$--MWV,x.x,a,x.x,a*hh<CR><LF>

	Field Number: 
	1) Wind Angle, 0 to 360 degrees
	2) Reference, R = Relative, T = True
	3) Wind Speed
	4) Wind Speed Units, K/M/N
	5) Status, A = Data Valid
	6) Checksum
	*/
	public class nmea_mwv_message 
	{
		static protected var headers:Array = ["IIMWV"];
		
		private var wind_direction: Number;
		private var wind_direction_ref: String;
		private var wind_speed_knots: Number;
		
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
			
			if (parts[2].length)
			{
				wind_direction_ref = parts[2];
			}

			if (parts[3].length)
			{
				var speed: Number = Number(parts[3]);
				
				if (parts[4] == "N" || parts[4] == "n")
				{
					wind_speed_knots = speed;
				}
				else if (parts[4] == "M" || parts[4] == "m")
				{
					wind_speed_knots = 1.94384449 * speed;
				}
				else if (parts[4] == "K" || parts[4] == "k")
				{
					wind_speed_knots = 0.539956803 * speed;
				}
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.wind_direction = wind_direction;
			nmea_data.wind_direction_reference = wind_direction_ref;
			nmea_data.relative_wind_speed_knots = wind_speed_knots;
			
			return true;
		}
		
		public function nmea_mwv_message() 
		{
			
		}
		
	}

}