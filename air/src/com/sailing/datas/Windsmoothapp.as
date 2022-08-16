/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.16.
 * Time: 14:37
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.datas {
import com.sailing.units.Angle;

public class Windsmoothapp extends BaseSailData{
    public var windDirectionExpAvg:Angle = new Angle();

    public function Windsmoothapp() {
        super();
        _paramsDisplayName["windDirectionExpAvg"] = { displayName: "Wind direction exponential average", order: 0 };
    }

    public override function get displayName():String {
        return "Apparent Wind Average";
    }
}
}
