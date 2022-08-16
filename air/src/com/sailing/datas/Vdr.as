package com.sailing.datas
{
import com.sailing.units.Direction;
import com.sailing.units.Speed;

public class Vdr  extends BaseSailData {
	public var direction:Direction = new Direction()
	public var currentSpeed:Speed = new Speed();

    public function Vdr() {
        super();
        _paramsDisplayName["direction"] = { displayName: "Direction", order: 0 };
        _paramsDisplayName["currentSpeed"] = { displayName: "Speed", order: 1 };
    }

    public override function get displayName():String {
        return "Set and Drift (VDR)";
    }
}
}