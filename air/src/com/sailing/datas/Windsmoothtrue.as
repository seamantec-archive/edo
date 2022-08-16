/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.16.
 * Time: 14:37
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.datas {
import com.sailing.units.WindSpeed;

public class Windsmoothtrue extends BaseSailData{

    public var windSpeedAvg:WindSpeed = new WindSpeed();
    public var windSpeedWeightedAvg:WindSpeed = new WindSpeed();
    public var windSpeedExpAvg:WindSpeed = new WindSpeed();
    public var windSpeedLowPass:WindSpeed = new WindSpeed();

    public function Windsmoothtrue() {
        super();
        _paramsDisplayName["windSpeedAvg"] = { displayName: "Wind speed average", order: 0 };
        _paramsDisplayName["windSpeedWeightedAvg"] = { displayName: "Wind speed weighted average", order: 1 };
        _paramsDisplayName["windDirectionExpAvg"] = { displayName: "Wind direction exponential average", order: 2 };
        _paramsDisplayName["windSpeedLowPass"] = { displayName: "Low-pass filtered wind speed", order: 3 };
    }

    public override function get displayName():String {
        return "True Wind Average";
    }
}
}
