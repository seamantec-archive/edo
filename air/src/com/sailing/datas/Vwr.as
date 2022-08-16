package com.sailing.datas {
import com.sailing.units.Angle;
import com.sailing.units.WindSpeed;

public class Vwr  extends BaseSailData{
    public var windDirection:Angle = new Angle();
    public var windDirectionSide:String = "";
    public var windSpeed:WindSpeed = new WindSpeed();

    public function Vwr() {
        super();
        _paramsDisplayName["windDirection"] = { displayName: "Wind direction", order: 0 };
        _paramsDisplayName["windDirectionSide"] = { displayName: "Wind direction side", order: 1 };
        _paramsDisplayName["windSpeed"] = { displayName: "Wind speed", order: 2 };
    }

    public override function get displayName():String {
        return "Relative wind direction and speed (VWR)";
    }

}
}