package com.sailing.datas
{
import com.sailing.units.Direction;

public class Hsc extends BaseSailData {

	public var commandHeading:Direction = new Direction();

    public function Hsc() {
        super();
        _paramsDisplayName["commandHeading"] = { displayName: "Commanded heading", order: 0 };
    }

    public override function get displayName():String {
        return "Heading Steering Command (HSC)";
    }
}
}