package com.sailing.nmeaParser.messages
{
	/**
	 * MWD - Wind Direction & Speed
	 * 
	 * 
	 *         1. 2. 3. 4. 5. 6. 7. 8.
	 *         |  |  |  |  |  |  |  |
	 * $--MWD,x.x,T,x.x,M,x.x,N,x.x,M*hh<CR><LF>
	 *	1.2. Wind direction, 0 to 359 degrees True	
	 *	3.4  Wind direction, 0 to 359 degrees Magnetic
	 *	5.6. Wind speed, knots
	 *  7.8. Wind speed, meters/second	 
	 * */

import com.common.WindCorrection;
import com.sailing.datas.Mwd;
import com.sailing.nmeaParser.utils.NmeaUtil;

public class NmeaMwdMessage implements NmeaMessage
	{
		private var data:Mwd = new Mwd();
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");

            var angle:Number = Number(parts[3]) - WindCorrection.instance.windCorrection;
            if(angle<0) {
                angle += 360;
            } else if(angle>=360) {
                angle -= 360;
            }
            data.windDirection.value = angle;
			if(parts[5] != ""){
				data.windSpeed.value = new Number(parts[5]);
			}else{
				data.windSpeed.value = NmeaUtil.meterSecToKnots(parts[7]);
			}
//            if(Number(parts[1])-Number(parts[3])!= Direction.variation){
//                SystemLogger.Debug("MWD bearing variation ERROR"+(Number(parts[1])-Number(parts[3]))+" dirvar "+ Direction.variation)
//            }
			
		}
		
		public function process():Object {
            if (data.windSpeed.getPureData() > 200) {
                return null;
            }
			return {key: "mwd", data:data};
		}
	}
}