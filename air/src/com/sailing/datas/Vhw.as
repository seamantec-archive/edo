package com.sailing.datas {
import com.sailing.interfaces.IHeading;
import com.sailing.units.Direction;
import com.sailing.units.Speed;

public class Vhw extends BaseSailData implements IHeading {
    public var waterHeading:Direction = new Direction()
    public var waterSpeed:Speed = new Speed();

    public function Vhw() {
        super();
        _paramsDisplayName["waterHeading"] = { displayName: "Heading", order: 0 };
        _paramsDisplayName["waterSpeed"] = { displayName: "Speed", order: 1 };
    }

    public override function get displayName():String {
        return "Water Speed and Heading (VHW)";
    }

    public function heading():Number {
        return waterHeading.value;
    }


}
}