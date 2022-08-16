/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.05.
 * Time: 10:51
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;
import com.common.SysConfig;

public class AnchorDistance extends Unit {
    public static const METER:Number = 1852;
    public static const FEET:Number = 6076.1155;

    private static var _meterHigh:String = (!SysConfig.isNull("alarmThresholds.anchorDistance.meter.high")) ? SysConfig.getString() : ">=0:5";
    private static var _meterMedium:String = (!SysConfig.isNull("alarmThresholds.anchorDistance.meter.medium")) ? SysConfig.getString() : ">=0:5";
    private static var _meterLow:String = (!SysConfig.isNull("alarmThresholds.anchorDistance.meter.low")) ? SysConfig.getString() : ">=0:5";
    private static var _feetHigh:String = (!SysConfig.isNull("alarmThresholds.anchorDistance.feet.high")) ? SysConfig.getString() : ">=0:10";
    private static var _feetMedium:String = (!SysConfig.isNull("alarmThresholds.anchorDistance.feet.medium")) ? SysConfig.getString() : ">=0:10";
    private static var _feetLow:String = (!SysConfig.isNull("alarmThresholds.anchorDistance.feet.low")) ? SysConfig.getString() : ">=0:10";

    public override function get value():Number {
        return _value * UnitHandler.instance.anchorDistance;
    }

    override public function convertNumber(n:Number):Number {
        return n * UnitHandler.instance.anchorDistance;
    }

    public override function convertFromOldToNew(n:Number):Number {
        return (n / UnitHandler.instance.prevAnchorDistance) * UnitHandler.instance.anchorDistance;
    }

    override public function getUnitStringForAlarm():String {
        switch (UnitHandler.instance.anchorDistance) {
            case AnchorDistance.METER:
                return "meter";
            case AnchorDistance.FEET:
                return "feet";

        }
        return ""
    }
    override public function getUnitString():String {
           switch (UnitHandler.instance.anchorDistance) {
               case AnchorDistance.METER:
                   return "meter";
               case AnchorDistance.FEET:
                   return "feet";

           }
           return ""
       }

    override public function getUnitShortString():String {
        switch (UnitHandler.instance.anchorDistance) {
            case AnchorDistance.METER:
                return "m";
            case AnchorDistance.FEET:
                return "f";

        }
        return ""
    }

    override public function getThreshold():ThresholdString {
        switch (UnitHandler.instance.anchorDistance) {
            case AnchorDistance.METER:
                return new ThresholdString(_meterHigh, _meterMedium, _meterLow);
            case AnchorDistance.FEET:
                return new ThresholdString(_feetHigh, _feetMedium, _feetLow);
        }
        return new ThresholdString(_meterHigh, _meterMedium, _meterLow);
    }


    override public function getPossibleMax():int {
        switch (UnitHandler.instance.anchorDistance) {
            case AnchorDistance.METER:
                return 200;
            case AnchorDistance.FEET:
                return 656;

        }
        return 100000;
    }

    override public function getAlarmMax():int {
        switch (UnitHandler.instance.anchorDistance) {
            case AnchorDistance.METER:
                return 200;
            case AnchorDistance.FEET:
                return 656;

        }
        return 200;
    }


    override public function getPossibleMin():int {
        return 0;
    }
}
}
