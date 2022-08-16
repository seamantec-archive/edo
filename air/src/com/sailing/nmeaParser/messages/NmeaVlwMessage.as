package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Vlw;

public class NmeaVlwMessage implements NmeaMessage
	{
		
		private var data:Vlw = new Vlw();
		
		public function NmeaVlwMessage()
		{
		}
		
		public function parse(packet:String):void{
			
			var parts:Array = packet.split(",");
			data.totalComWaterDist.value = new Number(parts[1]);
			data.waterDistSinceReset.value = new Number(parts[3]);
			if(parts.length > 5){
				data.totalComGroundDist.value = new Number(parts[5]);
				data.groundDistSinceReset.value = new Number(parts[7]);
			}
		}
		
		public function process():Object{
			return {key: "vlw", data: data};	
		}
	}
}