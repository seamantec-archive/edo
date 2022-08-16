package com.sailing.datas {
import com.sailing.interfaces.IHeading;
import com.sailing.units.Direction;

public class Hdg extends BaseSailData implements IHeading {

    public var sensorHeading:Direction = new Direction();
    public var magneticDeviation:Number = 0;
    public var magneticDeviationDirection:String;
    public var magneticVariation:Number = 0;
    public var magneticVariationDirection:String;

    public function Hdg() {
        super();
        _paramsDisplayName["sensorHeading"] = { displayName: "Magnetic sensor heading", order: 0 };
        _paramsDisplayName["magneticDeviation"] = { displayName: "Magnetic deviation", order: 1 };
        _paramsDisplayName["magneticDeviationDirection"] = { displayName: "Magnetic deviation direction", order: 2 };
        _paramsDisplayName["magneticVariation"] = { displayName: "Magnetic variation", order: 3 };
        _paramsDisplayName["magneticVariationDirection"] = { displayName: "Magnetic variation direction", order: 4 };
    }

    public override function get displayName():String {
        return "Heading, Deviation & Variation (HDG)";
    }

    public function heading():Number {
        return sensorHeading.value;
    }

//    public function get magneticDeviation():Number {
//        return _magneticDeviation;
//    }
//
//    public function set magneticDeviation(value:Number):void {
//        _magneticDeviation = value;
//    }
}
}