package as3_nmea 
{
	/*
	RSA - Rudder Sensor Angle

	1   2 3   4 5
	|   | |   | |
	$--RSA,x.x,A,x.x,A*hh<CR><LF>

	Field Number: 
	1) Starboard (or single) rudder sensor, "-" means Turn To Port
	2) Status, A means data is valid
	3) Port rudder sensor
	4) Status, A means data is valid
	5) Checksum
	*/
	public class nmea_rsa_message 
	{
		static protected var headers:Array = ["IIRSA"];
		
		private var rudder_sensor_starboard: Number;
		private var rudder_sensor_starboard_valid: Boolean;
		private var rudder_sensor_port: Number;
		private var rudder_sensor_port_valid: Boolean;
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			if (parts[1].length)
			{
				rudder_sensor_starboard = Number(parts[1]);
			}
			
			if (parts[2].length)
			{
				rudder_sensor_starboard_valid = (parts[2] == "A");
			}
			
			if (parts[3].length)
			{
				rudder_sensor_port = Number(parts[3]);
			}
			
			if (parts[4].length)
			{
				rudder_sensor_port_valid = (parts[4] == "A");
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.rudder_sensor_starboard = rudder_sensor_starboard;
			nmea_data.rudder_sensor_starboard_valid = rudder_sensor_starboard_valid;
			
			nmea_data.rudder_sensor_port = rudder_sensor_port;
			nmea_data.rudder_sensor_port_valid = rudder_sensor_port_valid;
			
			return true;
		}
		
		public function nmea_rsa_message() 
		{
			
		}
		
	}

}