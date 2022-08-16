/**
 * Created by seamantec on 06/02/14.
 */
package com.sailing.datas {
import com.sailing.units.Speed;

public class VmgWind extends BaseSailData {

    public var wind:Speed = new Speed();

    public function VmgWind() {
        super();
        _paramsDisplayName["wind"] = { displayName: "Wind", order: 0 };
    }

    public override function get displayName():String {
        return "Velocity Made Good (Wind)";
    }
}
}
