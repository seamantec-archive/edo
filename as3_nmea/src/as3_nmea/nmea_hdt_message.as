package as3_nmea 
{
	/*
	HDT - Heading - True

	1   2 3
	|   | |
	$--HDT,x.x,T*hh<CR><LF>

	Field Number: 
	1) Heading Degrees, true
	2) T = True
	3) Checksum
	*/
	public class nmea_hdt_message 
	{
		
		static protected var headers:Array = ["IIHDT"];
		
		public var heading_true: Number;
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			if (parts[1].length)
			{
				heading_true = Number(parts[1]);
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.heading_true = heading_true;
			
			return true;
		}
		
		public function nmea_hdt_message() 
		{
			
		}
		
	}

}