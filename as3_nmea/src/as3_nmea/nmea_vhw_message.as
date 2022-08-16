package as3_nmea
{
	/*
	VHW - Water speed and heading
	VHW,259.,T,237.,M,05.00,N,09.26,K
	259.,T       Heading 259 deg. True
	237.,M       Heading 237 deg. Magnetic
	05.00,N      Speed 5 knots through the water
	09.26,K      Speed 9.26 KPH
	*/
	
	public class nmea_vhw_message
	{
		static protected var headers:Array = ["IIVHW"];
		
		private var water_heading_true: Number;
		private var water_heading_magnetic: Number;
		private var water_speed_knots: Number;
		private var water_speed_kph: Number;
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			if (parts[1].length != 0 && parts[3].length != 0)
			{
				var heading1: Number = Number(parts[1]);
				var type1: String = parts[2];
				
				var heading2: Number = Number(parts[3]);
				var type2:: String = parts[4];
				
				// true
				if (type1 == "t" || type1 == "T")
				{
					water_heading_true = heading1;
					water_heading_magnetic = heading2;
				}
				else
				{
					water_heading_true = heading2;
					water_heading_magnetic = heading1;
				}
			}
			
			if (parts[5].length != 0 && parts[7].length != 0)
			{
				var speed1: Number = Number(parts[5]);
				var type1: String = parts[6];
				
				var speed2: Number = Number(parts[7]);
				var type2: String = parts[8];
				
				// knots
				if (type1 == "n" || type1 == "N")
				{
					water_speed_knots = speed1;
					water_speed_kph = speed2;
				}
				else
				{
					water_speed_knots = speed2;
					water_speed_kph = speed1;
				}
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.water_heading_true = water_heading_true;
			nmea_data.water_heading_magnetic = water_heading_magnetic;
			nmea_data.water_speed_knots = water_speed_knots;
			nmea_data.water_speed_kph = water_speed_kph;
			
			return true;
		}
		
		public function nmea_vhw_message()
		{
		}
	}
}