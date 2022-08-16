package as3_nmea
{
	public class nmea_interpreter
	{
		private var messages:Array;
		
		public function nmea_interpreter()
		{
			messages = new Array();
			messages.push(new nmea_bwc_message());
			messages.push(new nmea_hsc_message());
			messages.push(new nmea_dbt_message());
			messages.push(new nmea_gga_message());
			messages.push(new nmea_hdm_message());
			messages.push(new nmea_mtw_message());
			messages.push(new nmea_gll_message());
			messages.push(new nmea_hdt_message());
			messages.push(new nmea_hdg_message());
			messages.push(new nmea_rsa_message());
			messages.push(new nmea_mwv_message());
			messages.push(new nmea_aivdm_message());
		}
		
		public function interpret(packet:String):Boolean
		{
			for (var i:int = 0; i < messages.length; i++)
			{
				if (messages[i].parse(packet))
				{
					messages[i].process();
					return true;
				}
			}
			
			return false;
		}
	}
}