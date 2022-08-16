package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Xte;

/*
XTE - Cross-Track Error, Measured
$--XTE,A,A,x.x,a,N,a*hh<CR><LF>
*/
	public class NmeaXteMessage implements NmeaMessage
	{
		
		private var data:Xte = new Xte();
		
		
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
            data.xteMagnitude.value = new Number(parts[3]);
			data.directionToSteer = parts[4];
		}
		
		public function process():Object
		{
			return {key:"xte", data:data};
		}
		
		
	}
}