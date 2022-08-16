package com.sailing.datas {
import com.sailing.units.Temperature;

public class Mtw  extends BaseSailData{
    public var temperature:Temperature = new Temperature();

    public function Mtw() {
        super();
        _paramsDisplayName["temperature"] = { displayName: "Temperature", order: 0 };
    }

    public override function get displayName():String {
        return "Water Temperature (MTW)";
    }


}
}