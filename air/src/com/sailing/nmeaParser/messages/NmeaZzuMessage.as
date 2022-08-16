package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Zzu;

public class NmeaZzuMessage implements NmeaMessage
	{
				
		private var data:Zzu = new Zzu();
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			data.utc = parts[1];
			
			
		}
		
		public function process():Object
		{
			return {key:"zzu", data:data};
		}
	}
}