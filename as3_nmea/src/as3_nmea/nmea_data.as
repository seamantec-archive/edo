package as3_nmea
{
	public class nmea_data
	{
		// bearing and distance to waypoint
		public static var waypoint_id:Number;
		public static var waypoint_distance:Number; // nautical miles
		public static var waypoint_bearing_true:Number;
		public static var waypoint_bearing_magnetic:Number;
		public static var waypoint_longitude:Number;
		public static var waypoint_latitude:Number;
		public static var waypoint_utcms:Number;
		
		// heading to steer
		public static var heading_to_stear_true:Number;
		public static var heading_to_stear_magnetic:Number;
		
		// depth below transducer
		public static var depth_below_transducer_meters:Number;
		public static var depth_below_transducer_feet:Number;
		
		// heading
		public static var heading_magnetic:Number;
		public static var heading_true:Number;
		
		// water temperature
		public static var water_temperature:Number;
		
		// water speed
		public static var water_speed_knots:Number;
		public static var water_speed_kph:Number;
		
		// water heading
		public static var water_heading_true:Number;
		public static var water_heading_magnetic:Number;
		
		// relative wind direction and speed
		public static var relative_wind_direction:Number;
		public static var relative_wind_direction_side:String;
		public static var relative_wind_speed_knots:Number;
		public static var relative_wind_speed_mps:Number;
		public static var relative_wind_speed_kmh:Number;
		
		// gps
		public static var gps_utc_ms:Number;
		public static var gps_latitude:Number;
		public static var gps_longitude:Number;
		public static var gps_num_tracked_satellites:Number;
		public static var gps_altitude:Number;
		
		// heading deviation and variation
		public static var magnetic_sensor_heading:Number;
		public static var magnetic_deviation:Number;
		public static var magnetic_deviation_direction:String;
		public static var magnetic_variation:Number;
		public static var magnetic_variation_direction:String;
		
		// rudder sensor angle
		public static var rudder_sensor_starboard:Number;
		public static var rudder_sensor_starboard_valid:Boolean;
		public static var rudder_sensor_port:Number;
		public static var rudder_sensor_port_valid:Boolean;
		
		// wind speed and direction
		public static var wind_direction:Number;
		public static var wind_direction_reference:String; // R: relative, T: true
		public static var wind_speed_knots:Number;
		
		public function nmea_data()
		{
		}
	}
}
