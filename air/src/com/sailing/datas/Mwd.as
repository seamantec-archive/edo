package com.sailing.datas
{
import com.sailing.units.Direction;
import com.sailing.units.WindSpeed;

public class Mwd extends BaseSailData
	{
		public var windDirection:Direction = new Direction()
		public var windSpeed:WindSpeed = new WindSpeed(); //knots

    public function Mwd() {
        super();
        _paramsDisplayName["windDirection"] = { displayName: "Wind direction", order: 0 };
        _paramsDisplayName["windSpeed"] = { displayName: "Wind speed", order: 1 };
    }

    public override function get displayName():String {
        return "Wind Direction & Speed (MWD)";
    }

	}
}