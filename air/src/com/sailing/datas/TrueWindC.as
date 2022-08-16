/**
 * Created by pepusz on 2014.07.31..
 */
package com.sailing.datas {
import com.sailing.units.Angle;
import com.sailing.units.WindDirection;
import com.sailing.units.WindSpeed;

public class TrueWindC extends BaseSailData {
    public var windDirection:WindDirection = new WindDirection();
    public var windSpeed:WindSpeed = new WindSpeed();
    public var windAngle:Angle = new Angle();

    public function TrueWindC() {
        super();
        _paramsDisplayName["windAngle"] = { displayName: "Wind angle", order: 0 };
        _paramsDisplayName["windDirection"] = { displayName: "Wind direction", order: 1 };
        _paramsDisplayName["windSpeed"] = { displayName: "Wind speed", order: 2 };
    }

    public override function get displayName():String {
        return "True Wind Speed & Angle";
    }
}
}
