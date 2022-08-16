package as3_nmea
{
	/*
	MTW - Water temperature, Celcius
	MTW,11.,C
	11.,C        11 deg. C
	*/
	public class nmea_mtw_message
	{
		static protected var headers:Array = ["IIMTW"];
		
		public var temperature_celsius: Number;
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			if (parts[1].length)
			{
				temperature_celsius = Number(parts[1]);
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.water_temperature = temperature_celsius;
			
			return true;
		}
		
		public function nmea_mtw_message()
		{
		}
	}
}