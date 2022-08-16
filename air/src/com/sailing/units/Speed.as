/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.21.
 * Time: 15:48
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;
import com.common.SysConfig;

public class Speed extends Unit {
    public static const MS:Number = 0.514444;
    public static const KMH:Number = 1.852;
    public static const MPH:Number = 1.150779;
    public static const KTS:Number = 1;
    public static const FTS:Number = 1.687810;

    private static var _msHigh:String = (!SysConfig.isNull("alarmThresholds.speed.ms.high")) ? SysConfig.getString() : ">=5:0.5";
    private static var _msLow:String = (!SysConfig.isNull("alarmThresholds.speed.ms.low")) ? SysConfig.getString() :   ">=5:1";

    private static var _kmhHigh:String = (!SysConfig.isNull("alarmThresholds.speed.kmh.high")) ? SysConfig.getString() : "<=20:1 ; >20:2";
    private static var _kmhLow:String = (!SysConfig.isNull("alarmThresholds.speed.kmh.low")) ? SysConfig.getString() :   "<=10:2 ; >10:5";

    private static var _mphHigh:String = (!SysConfig.isNull("alarmThresholds.speed.mph.high")) ? SysConfig.getString() : "<=10:0.5 ; >10:1";
    private static var _mphLow:String = (!SysConfig.isNull("alarmThresholds.speed.mph.low")) ? SysConfig.getString() :   "<=5:1    ; >5:2";

    private static var _ktsHigh:String = (!SysConfig.isNull("alarmThresholds.speed.kts.high")) ? SysConfig.getString() : "<=10:0.5 ; >10:1";
    private static var _ktsLow:String = (!SysConfig.isNull("alarmThresholds.speed.kts.low")) ? SysConfig.getString() :   "<=5:1    ; >5:2";


    private static var _msMedium:String = (!SysConfig.isNull("alarmThresholds.speed.ms.medium")) ? SysConfig.getString() : ">=0:0.5";
    private static var _kmhMedium:String = (!SysConfig.isNull("alarmThresholds.speed.kmh.medium")) ? SysConfig.getString() : ">=0:0.5";
    private static var _mphMedium:String = (!SysConfig.isNull("alarmThresholds.speed.mph.medium")) ? SysConfig.getString() : ">=0:0.5";
    private static var _ktsMedium:String = (!SysConfig.isNull("alarmThresholds.speed.kts.medium")) ? SysConfig.getString() : ">=0:0.5";

    public static function getInvalidSpeed():Speed {
        var s:Speed = new Speed();
        s.value = INVALID_VALUE;
        return s;
    }

    public override function get value():Number {
        return Math.round(_value * UnitHandler.instance.speed * 100) / 100;
    }


    override public function convertNumber(n:Number):Number {
        return Math.round(n * UnitHandler.instance.speed * 100) / 100;
    }

    public override function convertFromOldToNew(n:Number):Number {
        return (n / UnitHandler.instance.prevSpeed) * UnitHandler.instance.speed;
    }

    override public function getUnitStringForAlarm():String {
        switch (UnitHandler.instance.speed) {
            case Speed.KTS:
                return "knots"
            case Speed.MPH:
                return "milesperhour";
            case Speed.KMH:
                return "kilometerperhour";
            case Speed.MS:
                return "meterpersecundum";
        }
        return ""
    }
    override public function getUnitString():String {
        switch (UnitHandler.instance.speed) {
            case Speed.KTS:
                return "knots"
            case Speed.MPH:
                return "milesperhour";
            case Speed.KMH:
                return "kilometerperhour";
            case Speed.MS:
                return "meterpersecundum";
        }
        return ""
    }

    override public function getUnitShortString():String {
        switch (UnitHandler.instance.speed) {
            case Speed.KTS:
                return "kts"
            case Speed.MPH:
                return "mph";
            case Speed.KMH:
                return "km/h";
            case Speed.MS:
                return "m/s";
        }
        return ""
    }

    override public function getThreshold():ThresholdString {
        switch (UnitHandler.instance.speed) {
            case Speed.KTS:
                return new ThresholdString(_ktsHigh, _ktsMedium, _ktsLow);
            case Speed.MPH:
                return new ThresholdString(_mphHigh, _mphMedium, _mphLow);
            case Speed.KMH:
                return new ThresholdString(_kmhHigh, _kmhMedium, _kmhLow);
            case Speed.MS:
                return new ThresholdString(_msHigh, _msMedium, _msLow);
        }
        return new ThresholdString(_ktsHigh, _ktsMedium, _ktsLow);
    }

    override public function getPossibleMax():int {
        switch (UnitHandler.instance.speed) {
            case Speed.KTS:
                return 20;
            case Speed.MPH:
                return 23;
            case Speed.KMH:
                return 37;
            case Speed.MS:
                return 10;
        }
        return 100;
    }

    override public function getPossibleMin():int {
        return 0;
    }
}
}
