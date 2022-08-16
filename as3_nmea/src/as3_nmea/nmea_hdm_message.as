package as3_nmea
{
	/*
	HDM - Heading, Magnetic
	HDM,235.,M
	HDM          Heading, Magnetic
	235.,M       Heading 235 deg. Magnetic
	(HDG, which includes deviation and variation, is recommended instead)
	*/
	
	public class nmea_hdm_message
	{
		static protected var headers:Array = ["IIHDM"];
		
		public var heading_magnetic: Number;
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			if (parts[1].length)
			{
				heading_magnetic = Number(parts[1]);
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.heading_magnetic = heading_magnetic;
			
			return true;
		}
		
		public function nmea_hdm_message()
		{
		}
	}
}