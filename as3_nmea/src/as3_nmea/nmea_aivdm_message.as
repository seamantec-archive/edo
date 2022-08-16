package as3_nmea 
{
	import as3_nmea.ais.ais_interpreter;
	
	public class nmea_aivdm_message 
	{
		static protected var headers:Array = ["AIVDM"];
		
		public function parse(packet:String):Boolean
		{
			if (!nmea_util.parsable(headers, packet))
			{
				return false;
			}
			
			var parts:Array = packet.split(",");

			var numFragments: Number = 0;
			var fragmentIndex: Number = 0;
			var messageId: Number = 0;
				
			if (parts[1].length != 0 && parts[2].length != 0)
			{
				numFragments = Number(parts[1]);
				fragmentIndex = Number(parts[2]);
			}
			
			if (parts[3].length != 0)
			{
				messageId = Number(parts[3]);
			}
			
			var channel: String = parts[4];
			var payload: String = parts[5];
			
			return ais_interpreter.getInstance().interpret(numFragments, fragmentIndex, messageId, payload);
		}
		
		public function process():Boolean
		{
			return true;
		}
		
		public function nmea_aivdm_message()
		{ }
	}
}
