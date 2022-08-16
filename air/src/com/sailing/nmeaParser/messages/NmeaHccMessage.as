package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Hcc;

public class NmeaHccMessage implements NmeaMessage
	{
		
		
		private var data:Hcc = new Hcc();
		
		public function parse(packet:String):void
		{
			var parts:Array =packet.split(",");
			
			data.compassHeading = new Number(parts[1]);
			
		}
		
		public function process():Object
		{
			return {key: "hcc", data:data};
		}
	}
}