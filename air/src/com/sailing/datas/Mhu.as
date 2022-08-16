package com.sailing.datas
{
import com.sailing.units.Temperature;

public class Mhu extends BaseSailData
	{
		public var relativeHumidity:Number = 0;
		public var absoluteHumidity:Number = 0;
		public var dewPoint:Temperature = new Temperature();

    public function Mhu() {
        super();
        _paramsDisplayName["relativeHumidity"] = { displayName: "Relative humidity", order: 0 };
        _paramsDisplayName["absoluteHumidity"] = { displayName: "Absolute humidity", order: 1 };
        _paramsDisplayName["dewPoint"] = { displayName: "Dew point", order: 2 };
    }

    public override function get displayName():String {
        return "Humidity (MHU)";
    }
	}
}