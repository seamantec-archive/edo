package com.sailing.nmeaParser.messages
{
	/**
	 * 
	 * 
	 * 
	 *         1.  2.  3.
	 * $--MHU,x.x,x.x,x.x,C*hh<CR><LF>
	 * 
	 * 1. relative humidity
	 * 2. absolute humidity
	 * 3. dew point
	 * 
	 * */


import com.sailing.datas.Mhu;

public class NmeaMhuMessage implements NmeaMessage
	{
		private var data:Mhu = new Mhu();		
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			
			data.relativeHumidity = new Number(parts[1]);
			data.absoluteHumidity = new Number(parts[2]);
			data.dewPoint.value = new Number(parts[3]);
		}
		
		public function process():Object
		{
			return {key: "mhu", data:data};
		}
	}
}