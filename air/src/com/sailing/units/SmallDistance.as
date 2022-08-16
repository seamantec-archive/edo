/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.23.
 * Time: 10:36
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;
import com.common.SysConfig;

public class SmallDistance extends Unit {
    public static const METER:Number = 1852;
    public static const FEET:Number = 6076.1155;

    private static var _mHigh:String = (!SysConfig.isNull("alarmThresholds.distance.m.high")) ? SysConfig.getString() : ">=5:1";
    private static var _mLow:String = (!SysConfig.isNull("alarmThresholds.distance.m.low")) ? SysConfig.getString() : ">=5:1";

    private static var _feetHigh:String = (!SysConfig.isNull("alarmThresholds.distance.feet.high")) ? SysConfig.getString() : ">=5:1";
    private static var _feetLow:String = (!SysConfig.isNull("alarmThresholds.distance.feet.low")) ? SysConfig.getString() : ">=5:1";

    override public function getValueWithShortUnitInString(digits:uint = 2):String {
        if (_value === INVALID_VALUE) {
            return INVALID_STRING;
        } else {
            return super.getValueWithShortUnitInString();
        }
    }

    override public function isValidValue():Boolean {
        return _value !== INVALID_VALUE;
    }

    public override function get value():Number {
        return _value * UnitHandler.instance.smallDistance;
    }

    public function getDynamicValue():Number {
        if (_value >= 1) {
            return _value * UnitHandler.instance.distance;
        } else {
            return value;
        }
    }

    override public function convertNumber(n:Number):Number {
        return n * UnitHandler.instance.smallDistance;
    }

    public override function convertFromOldToNew(n:Number):Number {
        return (n / UnitHandler.instance.prevSmallDistance) * UnitHandler.instance.smallDistance;
    }

    override public function getUnitStringForAlarm():String {
        switch (UnitHandler.instance.smallDistance) {
            case SmallDistance.METER:
                return "meter";
            case SmallDistance.FEET:
                return "feet";

        }
        return ""
    }

    override public function getUnitString():String {
        switch (UnitHandler.instance.smallDistance) {
            case SmallDistance.METER:
                return "meter";
            case SmallDistance.FEET:
                return "feet";

        }
        return ""
    }

    override public function getUnitShortString():String {
        switch (UnitHandler.instance.smallDistance) {
            case SmallDistance.METER:
                return "m";
            case SmallDistance.FEET:
                return "f";

        }
        return ""
    }

    private function getUnitShortStringDistance():String {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return "nm"
                break;
            case Distance.MILE:
                return "mi"
            case Distance.KM:
                return "km"
            case Distance.METER:
                return "m"
        }
        return ""
    }

    public function getDynamicShortString():String {
        if (_value >= 1) {
            return getUnitShortStringDistance()
        } else {
            return getUnitShortString();
        }
    }


    override public function getPossibleMax():int {
        switch (UnitHandler.instance.smallDistance) {
            case SmallDistance.METER:
                return 1000
            case SmallDistance.FEET:
                return 3000
        }
        return 1000;
    }

    override public function getAlarmMax():int {
        switch (UnitHandler.instance.smallDistance) {
            case SmallDistance.METER:
                return 1000
            case SmallDistance.FEET:
                return 3200
        }
        return 1000;
    }


    override public function getThreshold():ThresholdString {
        switch (UnitHandler.instance.smallDistance) {
//            case Distance.NM:
//                return new ThresholdString(_nmHigh, _nmHigh, _nmLow);
//                break;
//            case Distance.MILE:
//                return new ThresholdString(_mileHigh, _mileHigh, _mileLow);
//                break;
//            case Distance.KM:
//                return new ThresholdString(_kmHigh, _kmHigh, _kmLow);
//                break;
            case SmallDistance.METER:
                return new ThresholdString(_mHigh, _mHigh, _mLow);
                break;
            case SmallDistance.FEET:
                return new ThresholdString(_feetHigh, _feetHigh, _feetLow);
                break;
        }
        return new ThresholdString();
    }
}
}
