package com.sailing.datas
{
import com.sailing.units.Temperature;

public class Mta extends BaseSailData
	{
		public var temperature:Temperature = new Temperature();

    public function Mta() {
        super();
        _paramsDisplayName["temperature"] = { displayName: "Temperature", order: 0 };
    }

    public override function get displayName():String {
        return "Air Temperature (MTA)";
    }
	}
}