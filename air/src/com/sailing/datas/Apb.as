package com.sailing.datas {
import com.sailing.units.Direction;
import com.sailing.units.Distance;
import com.sailing.units.SmallDistance;

public class Apb extends BaseSailData {
    public var dataIsValid:Boolean = false;
    public var crossTrackError:SmallDistance = new SmallDistance();
    public var directionToSteer:String; //L/R
    public var bearingToDest:Direction = new Direction();
    public var destWaypointId:String;
    public var headingToSteer:Direction = new Direction();

    public function Apb() {
        super();
        _paramsDisplayName["dataIsValid"] = { displayName: "Data valid", order: 0 };
        _paramsDisplayName["crossTrackError"] = { displayName: "Magnitude of XTE", order: 1 };
        _paramsDisplayName["directionToSteer"] = { displayName: "Direction to steer", order: 2 };
        _paramsDisplayName["bearingToDest"] = { displayName: "Bearing to destination", order: 3 };
        _paramsDisplayName["destWaypointId"] = { displayName: "Destination waypoint ID", order: 4 };
        _paramsDisplayName["headingToSteer"] = { displayName: "Heading to steer", order: 5 };
    }

    public override function get displayName():String {
        return "Autopilot (APB)";
    }

}
}