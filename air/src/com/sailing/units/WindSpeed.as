/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.21.
 * Time: 16:52
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;
import com.common.SysConfig;

public class WindSpeed extends Unit {
    public static const MS:Number = 0.514444;
    public static const KMH:Number = 1.852;
    public static const MPH:Number = 1.150779;
    public static const KTS:Number = 1;
    public static const FTS:Number = 1.687810;
    public static const BF:Number = -1;

    private static var _ktsHigh:String = (!SysConfig.isNull("alarmThresholds.windSpeed.kts.high")) ? SysConfig.getString() : "<=10:2;<=30:5 ;>30:10";
    private static var _ktsLow:String = (!SysConfig.isNull("alarmThresholds.windSpeed.kts.low")) ? SysConfig.getString() :   "<=10:5;<=30:10;>30:10";

    private static var _msHigh:String = (!SysConfig.isNull("alarmThresholds.windSpeed.ms.high")) ? SysConfig.getString() : "<=5:1;<=15:2;>15:5";
    private static var _msLow:String = (!SysConfig.isNull("alarmThresholds.windSpeed.ms.low")) ? SysConfig.getString() :   "<=5:3;<=15:5;>15:5";

    private static var _kmhHigh:String = (!SysConfig.isNull("alarmThresholds.windSpeed.kmh.high")) ? SysConfig.getString() : "<=20:5 ;<=50:10;>50:20";
    private static var _kmhLow:String = (!SysConfig.isNull("alarmThresholds.windSpeed.kmh.low")) ? SysConfig.getString() :   "<=20:10;<=50:20;>50:20";

    private static var _mphHigh:String = (!SysConfig.isNull("alarmThresholds.windSpeed.mph.high")) ? SysConfig.getString() : "<=10:2;<=30:5 ;>30:10";
    private static var _mphLow:String = (!SysConfig.isNull("alarmThresholds.windSpeed.mph.low")) ? SysConfig.getString() :   "<=10:5;<=30:10;>30:10";

    private static var _bfHigh:String = (!SysConfig.isNull("alarmThresholds.windSpeed.bf.high")) ? SysConfig.getString() : ">=1:1";
    private static var _bfLow:String = (!SysConfig.isNull("alarmThresholds.windSpeed.bf.low")) ? SysConfig.getString() :   ">=1:1";


    private static var _msMedium:String = (!SysConfig.isNull("alarmThresholds.windSpeed.ms.medium")) ? SysConfig.getString() : "<10:2;<30:5;>=30:10";
    private static var _kmhMedium:String = (!SysConfig.isNull("alarmThresholds.windSpeed.kmh.medium")) ? SysConfig.getString() : ">=0:0.5";
    private static var _mphMedium:String = (!SysConfig.isNull("alarmThresholds.windSpeed.mph.medium")) ? SysConfig.getString() : ">=0:0.5";
    private static var _ktsMedium:String = (!SysConfig.isNull("alarmThresholds.windSpeed.kts.medium")) ? SysConfig.getString() : ">=0:0.5";
    private static var _bfMedium:String = (!SysConfig.isNull("alarmThresholds.windSpeed.bf.medium")) ? SysConfig.getString() : ">=0:1";

    public static function getInvalidSpeed():WindSpeed {
        var s:WindSpeed = new WindSpeed();
        s.value = INVALID_VALUE;
        return s;
    }

    public override function get value():Number {
        return convertNumber(_value);
    }

    public static function knotsFromMeterPerSec(msecValue:Number):Number {
        return msecValue / MS;
    }

    public static function knotsFromMile(mileValue:Number):Number {
        return mileValue / MPH;
    }

    public static function knotsFromKm(kmValue:Number):Number {
        return kmValue / KMH;
    }

    public static function toKnots(n:Number):Number {
        if (UnitHandler.instance.windSpeed != BF) {
            return n / UnitHandler.instance.windSpeed;
        } else {
            switch (n) {
                case 0:
                    return 0.5;
                case 1:
                    return 2;
                case 2:
                    return 4.5;
                case 3:
                    return 8;
                case 4:
                    return 12.5;
                case 5:
                    return 18;
                case 6:
                    return 24;
                case 7:
                    return 30;
                case 8:
                    return 36.5;
                case 9:
                    return 43.5;
                case 10:
                    return 51;
                case 11:
                    return 59;
                case 12:
                    return 64;
            }
        }
        return n;
    }

    override public function convertNumber(n:Number):Number {
        if (UnitHandler.instance.windSpeed != BF) {
            return n * UnitHandler.instance.windSpeed;
        } else {
            switch (true) {
                case n < 1:
                    return 0;
                case n >= 1 && n <= 3:
                    return 1;
                case n > 3 && n <= 6:
                    return 2;
                case n > 6 && n <= 10.3:
                    return 3;
                case n > 10.3 && n <= 15.1:
                    return 4;
                case n > 15.1 && n <= 21:
                    return 5;
                case n > 21 && n <= 27:
                    return 6;
                case n > 27 && n <= 33:
                    return 7;
                case n > 33 && n <= 40:
                    return 8;
                case n > 40 && n <= 47:
                    return 9;
                case n > 47 && n <= 55:
                    return 10;
                case n > 55 && n <= 63:
                    return 11;
                case n > 63:
                    return 12;
            }
        }
        return n
    }

    override public function convertFromOldToNew(n:Number):Number {
        if (UnitHandler.instance.prevWindSpeed != BF && UnitHandler.instance.windSpeed != BF) {
            return (n / UnitHandler.instance.prevWindSpeed) * UnitHandler.instance.windSpeed;
        } else if (UnitHandler.instance.prevWindSpeed == BF) {
            switch (true) {
                case n === 0:
                    return convertNumber(0);
                case n === 1:
                    return convertNumber(1);
                case n === 2:
                    return convertNumber(4);
                case n === 3:
                    return convertNumber(7);
                case n === 4:
                    return convertNumber(11);
                case n === 5:
                    return convertNumber(17);
                case n === 6:
                    return convertNumber(22);
                case n === 7:
                    return convertNumber(28);
                case n === 8:
                    return convertNumber(34);
                case n === 9:
                    return convertNumber(41);
                case n === 10:
                    return convertNumber(48);
                case n === 11:
                    return convertNumber(56);
                case n === 12:
                    return convertNumber(64);
            }
            return 0
        } else if (UnitHandler.instance.windSpeed == BF) {
            return convertNumber(n)
        }
        return 0;
    }

    override public function getUnitStringForAlarm():String {
        switch (UnitHandler.instance.windSpeed) {
            case WindSpeed.KTS:
                return "knots"
            case WindSpeed.MPH:
                return "milesperhour";
            case WindSpeed.KMH:
                return "kilometerperhour";
            case WindSpeed.MS:
                return "meterpersecundum";
            case WindSpeed.BF:
                return "beaufort";
        }
        return ""
    }

    override public function getUnitShortString():String {
        switch (UnitHandler.instance.windSpeed) {
            case WindSpeed.KTS:
                return "kts"
            case WindSpeed.MPH:
                return "mph";
            case WindSpeed.KMH:
                return "km/h";
            case WindSpeed.MS:
                return "m/s";
            case WindSpeed.BF:
                return "bf";
        }
        return ""
    }

    override public function getThreshold():ThresholdString {
        switch (UnitHandler.instance.windSpeed) {
            case WindSpeed.KTS:
                return new ThresholdString(_ktsHigh, _ktsMedium, _ktsLow);
            case WindSpeed.MPH:
                return new ThresholdString(_mphHigh, _mphMedium, _mphLow);
            case WindSpeed.KMH:
                return new ThresholdString(_kmhHigh, _kmhMedium, _kmhLow);
            case WindSpeed.MS:
                return new ThresholdString(_msHigh, _msMedium, _msLow);
            case WindSpeed.BF:
                return new ThresholdString(_bfHigh, _bfMedium, _bfLow);
        }
        return new ThresholdString(_ktsHigh, _ktsMedium, _ktsLow);
    }

    override public function getPossibleMax():int {
        switch (UnitHandler.instance.windSpeed) {
            case WindSpeed.KTS:
                return 50;
            case WindSpeed.MPH:
                return 50;
            case WindSpeed.KMH:
                return 100;
            case WindSpeed.MS:
                return 25;
            case WindSpeed.BF:
                return 12;
        }
        return 100;
    }

    override public function getPossibleMin():int {
        return 0;
    }
}
}
