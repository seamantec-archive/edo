package as3_nmea 
{
	/*
	HDG - Heading - Deviation & Variation

	1   2   3 4   5 6
	|   |   | |   | |
	$--HDG,x.x,x.x,a,x.x,a*hh<CR><LF>

	Field Number: 
	1) Magnetic Sensor heading in degrees
	2) Magnetic Deviation, degrees
	3) Magnetic Deviation direction, E = Easterly, W = Westerly
	4) Magnetic Variation degrees
	5) Magnetic Variation direction, E = Easterly, W = Westerly
	6) Checksum
	*/
	public class nmea_hdg_message 
	{
		static protected var headers:Array = ["IIHDG"];
		
		private var magnetic_sensor_heading: Number;
		private var magnetic_deviation: Number;
		private var magnetic_deviation_direction: String;
		private var magnetic_variation: Number;
		private var magnetic_variation_direction: String;
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");
			
			if (parts[1].length)
			{
				magnetic_sensor_heading = Number(parts[1]);
			}
			
			if (parts[2].length)
			{
				magnetic_deviation = Number(parts[2]);
			}
			
			if (parts[3].length)
			{
				magnetic_deviation_direction = parts[3];
			}
			
			if (parts[4].length)
			{
				magnetic_variation = Number(parts[4]);
			}
			
			if (parts[5].length)
			{
				magnetic_variation_direction = parts[5];
			}
			
			return true;
		}
		
		public function process():Boolean
		{
			nmea_data.magnetic_sensor_heading = magnetic_sensor_heading;
			
			nmea_data.magnetic_deviation = magnetic_deviation;
			nmea_data.magnetic_deviation_direction = magnetic_deviation_direction;
			
			nmea_data.magnetic_variation = magnetic_variation;
			nmea_data.magnetic_variation_direction = magnetic_variation_direction;
			
			return true;
		}
		
		public function nmea_hdg_message() 
		{
			
		}
		
	}

}