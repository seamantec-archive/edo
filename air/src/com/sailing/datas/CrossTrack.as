/**
 * Created by pepusz on 2014.07.08..
 */
package com.sailing.datas {
import com.sailing.units.Direction;
import com.sailing.units.SmallDistance;

public class CrossTrack extends BaseSailData {
    public var crossTrackError:SmallDistance = new SmallDistance();
    public var directionToSteer:String; //L/R
    public var bearingToDest:Direction = new Direction();
    public var destWaypointId:String;
    public var headingToSteer:Direction = new Direction();

    public function CrossTrack() {
        super();
        _paramsDisplayName["crossTrackError"] = { displayName: "Magnitude of Cross-Track-Error", order: 0 };
        _paramsDisplayName["directionToSteer"] = { displayName: "Direction to steer", order: 1 };
        _paramsDisplayName["bearingToDest"] = { displayName: "Bearing to destination", order: 2 };
        _paramsDisplayName["destWaypointId"] = { displayName: "Destination waypoint ID", order: 3 };
        _paramsDisplayName["headingToSteer"] = { displayName: "Heading to steer", order: 4 };
    }

    public override function get displayName():String {
        return "Cross track";
    }

    public function mergeFromApb(apb:Apb):void {
        crossTrackError = apb.crossTrackError;
        directionToSteer = apb.directionToSteer;
        bearingToDest = apb.bearingToDest;
        destWaypointId = apb.destWaypointId;
        headingToSteer = apb.headingToSteer;
    }
    public function mergeFromRmb(rmb:Rmb):void {
        crossTrackError = rmb.crossTrackError;
        directionToSteer = rmb.directionToSteer;
        bearingToDest = rmb.bearingToDest;
        destWaypointId = rmb.originalWaypointId;
    }
    public function mergeFromXte(xte:Xte):void {
        crossTrackError = xte.xteMagnitude;
        directionToSteer = xte.directionToSteer;
    }
}
}
