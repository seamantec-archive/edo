package com.sailing.datas
{
import com.sailing.units.Speed;

public class Vpw extends BaseSailData {
	public var speed:Speed = new Speed(); //default in knots

    public function Vpw() {
        super();
        _paramsDisplayName["speed"] = { displayName: "Speed", order: 0 };
    }

    public override function get displayName():String {
        return "Speed - Measured Parallel to Wind (VPW)";
    }
}
}