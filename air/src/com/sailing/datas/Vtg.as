package com.sailing.datas
{
import com.sailing.units.Direction;
import com.sailing.units.Speed;

public class Vtg  extends BaseSailData {
	public var courseOverGround:Direction = new Direction()
	public var speedOverGround:Speed = new Speed();
	public var mode:String;

    public function Vtg() {
        super();
        _paramsDisplayName["courseOverGround"] = { displayName: "Course over ground", order: 0 };
        _paramsDisplayName["speedOverGround"] = { displayName: "Speed over ground", order: 1 };
        _paramsDisplayName["mode"] = { displayName: "Mode", order: 2 };
    }

    public override function get displayName():String {
        return "Course Over Ground and Ground Speed (VTG)";
    }
}
}