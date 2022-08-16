/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.02.
 * Time: 15:51
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.datas {
import com.sailing.units.Speed;

public class Vmg extends BaseSailData {
    public var wind:Speed = new Speed();
    public var waypoint:Speed = new Speed();

    public function Vmg() {
        super();
        _paramsDisplayName["wind"] = { displayName: "Wind", order: 0 };
        _paramsDisplayName["waypoint"] = { displayName: "Waypoint", order: 1 };
    }

    public override function get displayName():String {
        return "Velocity Made Good";
    }

}
}
