package com.sailing.datas
{
import com.sailing.units.Direction;

public class Hdt extends BaseSailData {

	public var heading:Direction = new Direction();

    public function Hdt() {
        super();
        _paramsDisplayName["heading"] = { displayName: "True heading", order: 0 };
    }

    public override function get displayName():String {
        return "True heading (HDT)";
    }
}
}