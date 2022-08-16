/**
 * Created by pepusz on 2014.07.31..
 */
package com.sailing.datas {
import com.sailing.units.Direction;
import com.sailing.units.WindDirection;

public class Heading extends BaseSailData {
    public var heading:Direction = new Direction()
    private static var _variationAngle:WindDirection = new WindDirection();

    public function get variation():WindDirection {
        _variationAngle.value = Direction.variation;
        return _variationAngle;
    }

    public function Heading() {
        super();
        _paramsDisplayName["heading"] = { displayName: "Heading", order: 0 };
    }

    public override function get displayName():String {
        return "Heading";
    }
}
}
