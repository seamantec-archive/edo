package com.sailing.datas {
import com.sailing.units.Angle;
import com.sailing.units.WindSpeed;

public class Mwv extends BaseSailData {
    public var windAngle:Angle = new Angle();
    public var windDirectionRef:String;
    public var windSpeed:WindSpeed = new WindSpeed();

    public function Mwv() {
        super();
        _paramsDisplayName["windAngle"] = { displayName: "Wind angle", order: 0 };
        _paramsDisplayName["windDirectionRef"] = { displayName: "Wind direction reference", order: 1 };
        _paramsDisplayName["windSpeed"] = { displayName: "Wind speed", order: 2 };
    }

    public override function get displayName():String {
        return "Wind Speed & Angle (MWV)";
    }


}
}