package com.sailing.nmeaParser.messages
{
	/**
	 * 
	 * 
	 *         1  2  3  4
	 * $--MMB,x.x,I,x.x,B*hh<CR><LF>
	 * 
	 * 1.2. Barometric pressure, inches of mercury
	 * 3.4. Barometric pressure, bars
	 * 
	 * 
	 * */


import com.sailing.datas.Mmb;

public class NmeaMmbMessage implements NmeaMessage
	{
		
		private var data:Mmb = new Mmb();
		
		public function parse(packet:String):void
		{
			
			var parts:Array = packet.split(",");
			
			data.pressureIncOfMercury = new Number(parts[1]);
			data.pressureBar = new Number(parts[3]);
			
			
			
		}
		
		public function process():Object
		{
			return {key: "mmb", data:data};
		}
	}
}