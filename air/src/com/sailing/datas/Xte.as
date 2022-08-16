package com.sailing.datas
{
import com.sailing.units.SmallDistance;

public class Xte extends BaseSailData {
	//meter
	public var xteMagnitude:SmallDistance = new SmallDistance();
	public var directionToSteer:String;

    public function Xte() {
        super();
        _paramsDisplayName["xteMagnitude"] = { displayName: "Magnitude of Cross-Track-Error", order: 0 };
        _paramsDisplayName["directionToSteer"] = { displayName: "Direction to steer", order: 1 };
    }

    public override function get displayName():String {
        return "Cross-Track Error (XTE)";
    }
}
}