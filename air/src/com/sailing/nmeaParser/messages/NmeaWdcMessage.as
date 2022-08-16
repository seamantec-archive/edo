package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Wdc;

public class NmeaWdcMessage implements NmeaMessage
	{
		
		private var data:Wdc = new Wdc();
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			data.distance = new Number(parts[1]);
			data.waypointID = new String(parts[3]);
		}
		
		public function process():Object
		{
			return {key: "wdc", data:data};
		}
	}
}