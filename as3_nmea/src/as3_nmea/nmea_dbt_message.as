package as3_nmea
{
	/*
	DBT - Depth below transducer
	DBT,0017.6,f,0005.4,M
	0017.6,f     17.6 feet
	0005.4,M     5.4 Metres
	*/
	public class nmea_dbt_message
	{
		static protected var headers:Array = ["IIDBT"];
		
		public var depth_feet: Number;
		public var depth_meters: Number;
		
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			if (parts[1].length != 0 && parts[3].length != 0)
			{
				var depth1: Number = Number(parts[1]);
				var type1: String = parts[2];
				
				var depth2: Number = parts[3];
				var type2: String = parts[4];
				
				// feet
				if (type1 == "f" || type1 == "F")
				{
					depth_feet = depth1;
					depth_meters = depth2;
				}
				else
				{
					depth_feet = depth2;
					depth_meters = depth1;
				}
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.depth_below_transducer_feet = depth_feet;
			nmea_data.depth_below_transducer_meters = depth_meters;
			
			return true;
		}
		
		public function nmea_dbt_message()
		{
		}
	}
}