package com.sailing.datas
{
import com.sailing.units.Direction;
import com.sailing.units.Distance;
import com.sailing.units.SmallDistance;
import com.sailing.units.Speed;

public class Rmb  extends BaseSailData {
		public var dataStatus:String;
		public var crossTrackError:SmallDistance = new SmallDistance();
		public var directionToSteer:String; //L/R
		public var originalWaypointId:String;
		public var destWaypointLat:Number = 0;
		public var destWaypointLon:Number = 0;
		public var rangeToDest:Distance = new Distance();
		public var bearingToDest:Direction = new Direction();
		public var destClosingVelocity:Speed = new Speed();
		public var arrivalStatus:String;
		public var modeIndicator:String;

    public function Rmb() {
        super();
        _paramsDisplayName["dataStatus"] = { displayName: "Data status", order: 0 };
        _paramsDisplayName["crossTrackError"] = { displayName: "Cross track error", order: 1 };
        _paramsDisplayName["directionToSteer"] = { displayName: "Direction to steer", order: 2 };
        _paramsDisplayName["originalWaypointId"] = { displayName: "Original waypoint ID", order: 3 };
        _paramsDisplayName["destWaypointLat"] = { displayName: "Destination waypoint latitude", order: 4 };
        _paramsDisplayName["destWaypointLon"] = { displayName: "Destination waypoint longitude", order: 5 };
        _paramsDisplayName["rangeToDest"] = { displayName: "Range to destination", order: 6 };
        _paramsDisplayName["bearingToDest"] = { displayName: "Bearing to destination", order: 7 };
        _paramsDisplayName["destClosingVelocity"] = { displayName: "Destination closing velocity", order: 8 };
        _paramsDisplayName["arrivalStatus"] = { displayName: "Arrival status", order: 9 };
        _paramsDisplayName["modeIndicator"] = { displayName: "Mode indicator", order: 10 };
    }

    public override function get displayName():String {
        return "Recommended Minimum Specific Loran-C Data (RMB)";
    }
		
}
}