package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Mtw;

/*
MTW - Water temperature, Celcius
MTW,11.,C
11.,C        11 deg. C
*/
	public class NmeaMtwMessage
	{
		
		private var data:Mtw = new Mtw();
		
		public function parse(packet:String):void
		{
		
			var parts:Array = packet.split(",");
			
			if (parts[1].length)
			{
				data.temperature.value = Number(parts[1]);
			}
			
		}
		
		public function process():Object
		{
			return {key:"mtw", data:data};
		}
		
		public function NmeaMtwMessage()
		{
		}
	}
}