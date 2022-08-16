package as3_nmea
{
	/*
	HSC - Command heading to steer
	HSC,258.,T,236.,M
	258.,T       258 deg. True
	236.,M       136 deg. Magnetic
	*/
	
	public class nmea_hsc_message implements nmea_message
	{
		static protected var headers:Array = ["IIHSC"];
		
		public var heading_true: Number;
		public var heading_magnetic: Number;
		
		public function nmea_hsc_message()
		{
		}
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			// todo: fix this
			if (parts[1].length != 0 && parts[3].length != 0)
			{
				var heading1: Number = Number(parts[1]);
				var type1: String = parts[2];
				
				var heading2: Number = Number(parts[3]);
				var type2: String = parts[4];
				
				// feet
				if (type1 == "t" || type1 == "T")
				{
					heading_true = heading1;
					heading_magnetic = heading2;
				}
				else
				{
					heading_true = heading2;
					heading_magnetic = heading1;
				}
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.heading_true = heading_true;
			nmea_data.heading_magnetic = heading_magnetic;
			
			return true;
		}
	}
}