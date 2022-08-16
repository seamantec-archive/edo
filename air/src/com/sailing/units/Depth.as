/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.21.
 * Time: 17:01
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;
import com.common.SysConfig;

public class Depth extends Unit {
    public static const METER:Number = 1;
    public static const FATHOM:Number = 0.546806649;
    public static const FEET:Number = 3.2808399;

    private static var _meterHigh:String = (!SysConfig.isNull("alarmThresholds.depth.meter.high")) ? SysConfig.getString() : "<=2:0.2 ; <=10:0.5 ; <=20:1 ; <=40:5  ; >40:10" ;
    private static var _meterLow:String =  (!SysConfig.isNull("alarmThresholds.depth.meter.low"))  ? SysConfig.getString() : "<=5:1   ; <=10:2   ; <=20:5 ; <=40:10 ; >40:20";

 //   private static var _meterHigh:String = (!SysConfig.isNull("alarmThresholds.depth.meter.high")) ? SysConfig.getString() : "<100:0.5";
 //   private static var _meterLow:String = (!SysConfig.isNull("alarmThresholds.depth.meter.low")) ? SysConfig.getString() : "<100:1";

    private static var _feetHigh:String = (!SysConfig.isNull("alarmThresholds.depth.feet.high")) ? SysConfig.getString() : "<=6:0.5;<=30:1;<=60:3;<=120:15;>120:30";
    private static var _feetLow:String = (!SysConfig.isNull("alarmThresholds.depth.feet.low")) ? SysConfig.getString() : "<=15:3;<=30:5;<=60:15;<=120:30;>120:60";

    private static var _fathomHigh:String = (!SysConfig.isNull("alarmThresholds.depth.fathom.high")) ? SysConfig.getString() : "<=1:0.1;<=5:0.2;<=10:0.5;<=20:2;>20:5";
    private static var _fathomLow:String = (!SysConfig.isNull("alarmThresholds.depth.fathom.low")) ? SysConfig.getString() : "<=3:0.5;<=5:1;<=10:2;<=20:5;>20:10";

//ezeket nen hasznaljuk
    private static var _meterMedium:String = (!SysConfig.isNull("alarmThresholds.depth.meter.medium")) ? SysConfig.getString() : "<20:3;<40:6;>=40:10";
    private static var _feetMedium:String = (!SysConfig.isNull("alarmThresholds.depth.feet.medium")) ? SysConfig.getString() : "<20:1;<40:5;>=40:10";
    private static var _fathomMedium:String = (!SysConfig.isNull("alarmThresholds.depth.fathom.medium")) ? SysConfig.getString() : "<20:1;<40:5;>=40:10";

    public static function getInvalidDepth():Depth {
        var d:Depth = new Depth();
        d.value = INVALID_VALUE;
        return d;
    }

    public override function get value():Number {
        return _value * UnitHandler.instance.depth;
    }


    override public function convertNumber(n:Number):Number {
        return n * UnitHandler.instance.depth;
    }

    public static function convertFromFeet(feetValue:Number):Number {
        return feetValue / FEET;
    }

    public override function convertFromOldToNew(n:Number):Number {
        return (n / UnitHandler.instance.prevDepth) * UnitHandler.instance.depth;
    }


    override public function getUnitStringForAlarm():String {
        switch (UnitHandler.instance.depth) {
            case Depth.METER:
                return "meter"
                break;
            case Depth.FEET:
                return "feet"
                break;
            case Depth.FATHOM:
                return "fathom";
                break;
        }
        return "";
    }
    override public function getUnitString():String {
        switch (UnitHandler.instance.depth) {
            case Depth.METER:
                return "meter"
                break;
            case Depth.FEET:
                return "feet"
                break;
            case Depth.FATHOM:
                return "fathom";
                break;
        }
        return "";
    }

    override public function getUnitShortString():String {
        switch (UnitHandler.instance.depth) {
            case Depth.METER:
                return "m"
                break;
            case Depth.FEET:
                return "f"
                break;
            case Depth.FATHOM:
                return "fa";
                break;
        }
        return "";
    }

    override public function getThreshold():ThresholdString {
        switch (UnitHandler.instance.depth) {
            case Depth.METER:
                return new ThresholdString(_meterHigh, _meterMedium, _meterLow);
                break;
            case Depth.FEET:
                return new ThresholdString(_feetHigh, _feetMedium, _feetLow);
                break;
            case Depth.FATHOM:
                return new ThresholdString(_fathomHigh, _fathomMedium, _fathomLow);
                break;
        }
        return new ThresholdString(_meterHigh, _meterMedium, _meterLow);
    }

    override public function getPossibleMax():int {
        switch (UnitHandler.instance.depth) {
            case Depth.METER:
                return 1000;
                break;
            case Depth.FEET:
                return 1000;
                break;
            case Depth.FATHOM:
                return 1000;
                break;
        }
        return 1000;
    }

    override public function getPossibleMin():int {
        return 0;
    }

    override public function getAlarmMax():int {
        switch (UnitHandler.instance.depth) {
            case Depth.METER:
                return 100;
                break;
            case Depth.FEET:
                return 328;
                break;
            case Depth.FATHOM:
                return 55;
                break;
        }
        return 1000;
    }

    override public function getAlarmMin():int {
        return 0;
    }
}
}
