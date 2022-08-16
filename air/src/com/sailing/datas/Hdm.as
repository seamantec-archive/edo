package com.sailing.datas
{
import com.sailing.units.Direction;

public class Hdm extends BaseSailData {

	public var heading:Direction = new Direction();

    public function Hdm() {
        super();
        _paramsDisplayName["heading"] = { displayName: "Magnetic heading", order: 0 };
    }

    public override function get displayName():String {
        return "Magnetic heading (HDM)";
    }
}
}