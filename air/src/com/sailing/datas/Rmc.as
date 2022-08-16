package com.sailing.datas {

import com.sailing.units.Direction;
import com.sailing.units.Speed;

public class Rmc extends BaseSailData {

    public var gpsSog:Speed = new Speed();
    public var gpsCog:Direction = new Direction();
    public var utc:Date = new Date();
    public var hour:Number = 0;
    public var min:Number = 0;
    public var sec:Number = 0;
    public var lat:Number = 0;
    public var lon:Number = 0;
    public var magneticVariation:Number = 0;

    public function Rmc() {
        super();
        _paramsDisplayName["gpsSog"] = { displayName: "Speed over ground", order: 5 };
        _paramsDisplayName["gpsCog"] = { displayName: "Course over ground", order: 6 };
        _paramsDisplayName["hour"] = { displayName: "Hour", order: 0 };
        _paramsDisplayName["min"] = { displayName: "Minute", order: 1 };
        _paramsDisplayName["sec"] = { displayName: "Second", order: 2 };
        _paramsDisplayName["lat"] = { displayName: "Latitude", order: 3 };
        _paramsDisplayName["lon"] = { displayName: "Longitude", order: 4 };
        _paramsDisplayName["magneticVariation"] = { displayName: "Magnetic variation", order: 7 };
    }

    public override function get displayName():String {
        return "Recommended Minimum Specific GNSS Data (RMC)";
    }
}
}