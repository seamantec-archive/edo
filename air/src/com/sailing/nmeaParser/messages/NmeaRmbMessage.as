package com.sailing.nmeaParser.messages
{
	/**
	 * RMB - Recommended Minimum Navigation Information
	 * 
	 * 
	 *       1. 2. 3. 4.   5.    6.    7.    8.  9. 10. 11. 12.13.14  
	 *       |  |  |  |    |     |     |     |    |  |   |   |  | | 
	 *$--RMB,A,x.x,a,c--c,c--c,llll.ll,a,yyyyy.yy,a,x.x,x.x,x.x,A,a*hh<CR><LF>
	 * 
	 * 1. Data status4, A = Data valid, V = Navigation receiver warning
	 * 2.Cross track error2 - nautical miles
	 * 3.Direction to steer - L/R
	 * 4.Origin waypoint ID
	 * 5.Destination waypoint ID
	 * 6.7. Destination waypoint lat. - N/S
	 * 
	 * 8.9.Destination waypoint longitude, E/W
	 * 10.Range to destination, nautical miles1
	 * 11.Bearing to destination, degrees True
	 * 12.Destination closing velocity, knots
	 * 13.Arrival status, A = arrival circle entered or perpendicular passed. V = not entered/passed
	 * 14. Mode Indicator
	 * 
	 * 
	 * 
	 *  
	*/


import com.sailing.datas.Rmb;
import com.sailing.units.Direction;
import com.sailing.units.Unit;

public class NmeaRmbMessage implements NmeaMessage
	{
		private var data:Rmb = new Rmb();
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			
			data.dataStatus = parts[1];
			data.crossTrackError.value = parts[2].length === 0 ? Unit.INVALID_VALUE : new Number(parts[2]);
			data.directionToSteer = parts[3];
			data.originalWaypointId = new String(parts[4]);
			
			data.destWaypointLat = new Number(parts[6]);
			data.destWaypointLat = new Number(parts[8]);
			data.rangeToDest.value = new Number(parts[10]);
			data.bearingToDest.value = Unit.toInterval(new Number(parts[11])- Direction.variation);
			data.destClosingVelocity.value = new Number(parts[12]);
			data.modeIndicator = parts[13];
			
		}
		
		public function process():Object
		{
			return { key: "rmb", data:data };
		}
	}
}