/**
 * Created by seamantec on 06/02/14.
 */
package com.sailing.datas {
import com.sailing.units.Speed;

public class VmgWaypoint extends BaseSailData {

    public var waypoint:Speed = new Speed();

    public function VmgWaypoint() {
        super();
        _paramsDisplayName["waypoint"] = { displayName: "Waypoint", order: 0 };
    }

    public override function get displayName():String {
        return "Velocity Made Good (Waypoint)";
    }
}
}
