/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.21.
 * Time: 16:56
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;
import com.common.SysConfig;

public class Distance extends Unit {

    public static const NM:Number = 1;
    public static const MILE:Number = 1.150779;
    public static const KM:Number = 1.852;
    public static const METER:Number = 1852;
    public static const YARD:Number = 2025.372;
    public static const FEET:Number = 6076.1155;

    private static var _nmHigh:String = (!SysConfig.isNull("alarmThresholds.distance.nm.high")) ? SysConfig.getString() : ">=5:1";
    private static var _nmLow:String = (!SysConfig.isNull("alarmThresholds.distance.nm.low")) ? SysConfig.getString() : ">=5:1";

    private static var _mileHigh:String = (!SysConfig.isNull("alarmThresholds.distance.mile.high")) ? SysConfig.getString() : ">=5:1";
    private static var _mileLow:String = (!SysConfig.isNull("alarmThresholds.distance.mile.low")) ? SysConfig.getString() : ">=5:1";

    private static var _kmHigh:String = (!SysConfig.isNull("alarmThresholds.distance.km.high")) ? SysConfig.getString() : ">=5:1";
    private static var _kmLow:String = (!SysConfig.isNull("alarmThresholds.distance.km.low")) ? SysConfig.getString() : ">=5:1";

    private static var _mHigh:String = (!SysConfig.isNull("alarmThresholds.distance.m.high")) ? SysConfig.getString() : ">=5:1";
    private static var _mLow:String = (!SysConfig.isNull("alarmThresholds.distance.m.low")) ? SysConfig.getString() : ">=5:1";

    private static var _feetHigh:String = (!SysConfig.isNull("alarmThresholds.distance.feet.high")) ? SysConfig.getString() : ">=5:1";
    private static var _feetLow:String = (!SysConfig.isNull("alarmThresholds.distance.feet.low")) ? SysConfig.getString() : ">=5:1";

    public static function getInvalidDistance():Distance {
        var d:Distance = new Distance();
        d.value = INVALID_VALUE;
        return d;
    }

    public override function get value():Number {
        return Math.round(_value * UnitHandler.instance.distance * 100) / 100;
    }

    override public function convertNumber(n:Number):Number {
        return Math.round(n * UnitHandler.instance.distance * 100) / 100;
    }

    public override function convertFromOldToNew(n:Number):Number {
        return (n / UnitHandler.instance.prevDistance) * UnitHandler.instance.distance;
    }

    public function getNumberInNm(n:Number):Number {
        return n / UnitHandler.instance.distance;
    }

    override public function getUnitStringForAlarm():String {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return "nauticalmile"
                break;
            case Distance.MILE:
                return "mile"
            case Distance.KM:
                return "kilometer"
            case Distance.METER:
                return "meter"
        }
        return ""
    }

    override public function getUnitString():String {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return "nauticalmile"
                break;
            case Distance.MILE:
                return "mile"
            case Distance.KM:
                return "kilometer"
            case Distance.METER:
                return "meter"
        }
        return ""
    }

    override public function getUnitShortString():String {
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

    override public function getThreshold():ThresholdString {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return new ThresholdString(_nmHigh, _nmHigh, _nmLow);
                break;
            case Distance.MILE:
                return new ThresholdString(_mileHigh, _mileHigh, _mileLow);
                break;
            case Distance.KM:
                return new ThresholdString(_kmHigh, _kmHigh, _kmLow);
                break;
            case Distance.METER:
                return new ThresholdString(_mHigh, _mHigh, _mLow);
                break;
        }
        return new ThresholdString();
    }


    override public function getPossibleMax():int {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return 10000000
            case Distance.MILE:
                return 10000000
            case Distance.KM:
                return 10000000
            case Distance.METER:
                return 10000000
        }
        return 100000;
    }

    override public function getAlarmMax():int {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return 20;
            case Distance.MILE:
                return 20
            case Distance.KM:
                return 30
            case Distance.METER:
                return 30000
        }
        return 100000;
    }

    public function getAlarmMaxrmc():int {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return 1
            case Distance.MILE:
                return 1
            case Distance.KM:
                return 1
            case Distance.METER:
                return 1000
        }
        return 100000;
    }

    public function getAlarmMinrmc():int {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return 0;
            case Distance.MILE:
                return 0
            case Distance.KM:
                return 0
            case Distance.METER:
                return 0
        }
        return 100000;
    }

    public function getAlarmMaxbwc():int {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return 2
            case Distance.MILE:
                return 2
            case Distance.KM:
                return 4
            case Distance.METER:
                return 4000
        }
        return 100000;
    }

    public function getAlarmMinbwc():int {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return 0;
            case Distance.MILE:
                return 0
            case Distance.KM:
                return 0
            case Distance.METER:
                return 0
        }
        return 100000;
    }

    public function getAlarmMaxais():int {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return 5
            case Distance.MILE:
                return 5
            case Distance.KM:
                return 10
            case Distance.METER:
                return 10000
        }
        return 4000;
    }

    public function getAlarmMinais():int {
        switch (UnitHandler.instance.distance) {
            case Distance.NM:
                return 0;
            case Distance.MILE:
                return 0
            case Distance.KM:
                return 0
            case Distance.METER:
                return 0
        }
        return 0;
    }

    override public function getPossibleMin():int {
        return 0;
    }
}

}

