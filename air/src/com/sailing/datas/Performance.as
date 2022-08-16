/**
 * Created by pepusz on 2014.08.02..
 */
package com.sailing.datas {
import com.sailing.units.Direction;
import com.sailing.units.Percent;
import com.sailing.units.Speed;

public class Performance extends BaseSailData {

    public var performance:Percent = new Percent();
    public var polarSpeed:Speed = new Speed();
    public var beatAngle:Direction = new Direction();
    public var beatVmg:Speed = new Speed();
    public var runAngle:Direction = new Direction();
    public var runVmg:Speed = new Speed();

    public function Performance() {
        super();
        _paramsDisplayName["performance"] = { displayName: "Performance", order: 0 };
        _paramsDisplayName["polarSpeed"] = { displayName: "Target speed", order: 1 };
        _paramsDisplayName["beatAngle"] = { displayName: "Beat angle", order: 2 };
        _paramsDisplayName["beatVmg"] = { displayName: "Beat vmg", order: 3 };
        _paramsDisplayName["runAngle"] = { displayName: "Run angle", order: 4 };
        _paramsDisplayName["runVmg"] = { displayName: "Run vmg", order: 5 };
    }

    public override function get displayName():String {
        return "Performance";
    }
}
}
