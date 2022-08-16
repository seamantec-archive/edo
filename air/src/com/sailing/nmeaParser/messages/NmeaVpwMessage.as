package com.sailing.nmeaParser.messages
{
	/**
	 * 
	 * VPW - Speed - Measured Parallel to Wind
	 * 
	 * 
	 *        1.  2. 3. 4.
	 *         |  |  |  |
	 * $--VPW,x.x,N,x.x,M*hh<CR><LF>
	 * 
	 * 1.2. Speed, knots, "-" = downwind
	 * 3.4. Speed, meters/second, "-" = downwind
	 * 
	 * */

import com.sailing.datas.Vpw;
import com.sailing.nmeaParser.utils.NmeaUtil;

public class NmeaVpwMessage implements NmeaMessage
	{
	
		private var data:Vpw = new Vpw();
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			
			if(parts[1] != ""){
				data.speed.value = new Number(parts[1]);
			}else{
				data.speed.value = NmeaUtil.meterSecToKnots(parts[3]);
			}
			
		}
		
		public function process():Object
		{
			return {key:"vpw", data:data};
		}
	}
}