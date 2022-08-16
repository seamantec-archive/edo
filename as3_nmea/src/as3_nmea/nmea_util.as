package as3_nmea
{
	public class nmea_util
	{
		public function nmea_util()
		{
		}
		
		public static function parsable(headers:Array, packet:String):Boolean
		{
			for (var i:int = 0; i < headers.length; i++)
			{
				if (packet.substr(0, headers[i].length) == headers[i])
				{
					return true;
				}
			}
			
			return false;
		}
	}
}
