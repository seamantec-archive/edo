package com.sailing.nmeaParser.messages
{
import com.sailing.datas.Bwc;

/*
	BWC - Bearing and distance to waypoint - great circle
	BWC,225444,4917.24,N,12309.57,W,051.9,T,031.6,M,001.3,N,004*29
	225444       UTC time of fix 22:54:44
	4917.24,N    Latitude of waypoint
	12309.57,W   Longitude of waypoint
	051.9,T      Bearing to waypoint, degrees true
	031.6,M      Bearing to waypoint, degrees magnetic
	001.3,N      Distance to waypoint, Nautical miles
	004          Waypoint ID
	*/
	
	public class NmeaBwcMessage implements NmeaMessage
	{
		
		
		private var data:Bwc = new Bwc();
		
		public function NmeaBwcMessage()
		{
			
		}
		
		public function parse(packet:String):void
		{
			var parts:Array = packet.split(",");
			// utc time
			var hour: int = parseInt(parts[1].substr(0, 2));
			var minute: int = parseInt(parts[1].substr(2, 2));
			var second: int = parseInt(parts[1].substr(4, 2));

			data.timeOfFixUtcMs = 1000 * (second + 60 * (minute + 60 * hour));

			var p1: Number;
			var p2: Number;
			
			// latitude
			if (parts[2].length)
			{
				var latitude: Number = Number(parts[2]) / 100.0;
				p1 = Math.floor(latitude);
				p2 = 100.0 * (latitude - p1);
			
				data.waypointLat = p1 + p2 / 60.0;
				if (parts[3] == "S")
				{
					data.waypointLat = -data.waypointLat;
				}
			}

			// longitude
			if (parts[4].length)
			{
				var longitude: Number = Number(parts[4]) / 100.0;
				p1 = Math.floor(longitude);
				p2 = 100.0 * (longitude - p1);
			
				data.waypointLon = p1 + p2 / 60.0;
				if (parts[5] == "W")
				{
					data.waypointLon = -data.waypointLon;
				}
			}
            var bearingTrue:Number =0;
			for (var i:int = 6; i < 10; i += 2)
			{
				if (parts[i].length)
				{
					var bearing: Number = Number(parts[i]);
					var heading_type: String = parts[i + 1];

					if (heading_type == "t" || heading_type == "T")
					{
//						data.waypointBearing.value = bearing - Direction.;
                        bearingTrue = bearing;
					}
					else if (heading_type == "m" || heading_type == "M")
					{
						data.waypointBearing.value = bearing;
					}
				}
			}
//            if(bearingTrue-data.waypointBearing.getPureData() != Direction.variation){
//                SystemLogger.Debug("BWC bearing variation ERROR "+(bearingTrue-data.waypointBearing.getPureData())+" dirvar "+ Direction.variation +" "+ data.waypointBearing.getPureData() + " "+ bearingTrue)
//            }

			if (parts[10].length)
			{
				data.waypointDistance.value = Number(parts[10]);
			}
			
			if (parts[12].length)
			{
				data.waypointId = String(parts[12]);
			}
			
		}
		
		public function process():Object
		{
			

			return {key: "bwc", data:data}
		}
	}
}