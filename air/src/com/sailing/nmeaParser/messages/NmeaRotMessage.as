package com.sailing.nmeaParser.messages
{
	/**
	 * ROT - Rate Of Turn
	 * 
	 * 		   1. 2.
	 *         |  | 
	 * $--ROT,x.x,A*hh<CR><LF>
	 * 
	 * 1. Rate of turn, degrees/minute, "-" = bow turns to port
	 * 2. status A valid, V invalid
	 * 
	 * */

import com.sailing.datas.Rotnmea;

public class NmeaRotMessage implements NmeaMessage
	{

		
		private var data:Rotnmea = new Rotnmea();
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			
			if(parts[1] === "-1"){
				data.rateOfTurn = -1;
			}else{
				data.rateOfTurn = new Number(parts[1]);
			}
			
			if(parts[2] === "A"){
				data.rotStatus = 1;
			}else{
				data.rotStatus = 0;
			}
		}
		
		public function process():Object
		{
			return {key:"rotnmea", data:data};
		}
	}
}