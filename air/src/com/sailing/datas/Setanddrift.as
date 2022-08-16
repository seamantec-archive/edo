/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 10/11/13
 * Time: 9:27 AM
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.datas {
import com.sailing.units.Direction;
import com.sailing.units.Speed;

public class Setanddrift extends BaseSailData {
    public var angleset:Direction = new Direction();
    public var drift:Speed = new Speed();

    public function Setanddrift() {
        super();
        _paramsDisplayName["angleset"] = { displayName: "Direction", order: 0 };
        _paramsDisplayName["drift"] = { displayName: "Speed", order: 1 };
    }

    public override function get displayName():String {
        return "Set and Drift";
    }
}
}
