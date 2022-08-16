package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Mta;

public class NmeaMtaMessage implements NmeaMessage
	{
		
		private var data:Mta = new Mta();
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			data.temperature.value = new Number(parts[1]);
			
		}
		
		public function process():Object
		{
			return {key:"mta", data:data};
		}
	}
}