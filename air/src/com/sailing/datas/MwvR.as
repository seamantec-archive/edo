/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.08.
 * Time: 17:10
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.datas {
import com.sailing.units.Angle;
import com.sailing.units.WindDirection;
import com.sailing.units.WindSpeed;

public class MwvR extends BaseSailData {
    public var windDirection:WindDirection = new WindDirection();
    public var windSpeed:WindSpeed = new WindSpeed();
    public var windAngle:Angle = new Angle();

    public function MwvR() {
        super();
        _paramsDisplayName["windAngle"] = { displayName: "Wind angle", order: 0 };
        _paramsDisplayName["windDirection"] = { displayName: "Wind direction", order: 1 };
        _paramsDisplayName["windSpeed"] = { displayName: "Wind speed", order: 2 };
    }

    public override function get displayName():String {
        return "Apparent Wind Speed & Angle";
    }
}
}
