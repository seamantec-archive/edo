/**
 * Created by seamantec on 13/05/14.
 */
package com.sailing.datas {
import com.sailing.units.Direction;
import com.sailing.units.Speed;

public class PositionAndSpeed extends BaseSailData {

    public var lat:Number = 0;
    public var lon:Number = 0;
    public var sog:Speed = new Speed();
    public var cog:Direction = new Direction();

    public function PositionAndSpeed() {
        super();
        _paramsDisplayName["lat"] = { displayName: "Latitude", order: 0 };
        _paramsDisplayName["lon"] = { displayName: "Longitude", order: 1 };
        _paramsDisplayName["sog"] = { displayName: "Speed over ground", order: 2 };
        _paramsDisplayName["cog"] = { displayName: "Course over ground", order: 3 };
    }

    public override function get displayName():String {
        return "Position and Speed";
    }
}
}
