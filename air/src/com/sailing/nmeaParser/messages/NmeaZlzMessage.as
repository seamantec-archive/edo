package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Zlz;

public class NmeaZlzMessage implements NmeaMessage
	{
		private var data:Zlz = new Zlz();
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			data.utc = parts[1];
			data.localTime = parts[2];
			data.localZoneDesc = parts[3];
			
			// utc time
			var hour: int = parseInt(parts[1].substr(0, 2));
			var minute: int = parseInt(parts[1].substr(2, 2));
			var second: int = parseInt(parts[1].substr(4, 2));
			data.hour = hour;
			data.min = minute;
			data.sec = second;
			
		}
		
		public function process():Object
		{
			return {key:"zlz", data:data};
		}
	}
}