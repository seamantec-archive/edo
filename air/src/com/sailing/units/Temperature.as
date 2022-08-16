/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.21.
 * Time: 17:04
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;
import com.common.SysConfig;

public class Temperature extends Unit {
    public static const CELSIUS:Number = 1;
    public static const FAHRENHEIT:Number = 2;
    public static const KELVIN:Number = 3;

    private static var _celsiusHigh:String = (!SysConfig.isNull("alarmThresholds.temperature.celsius.high")) ? SysConfig.getString() : ">=0:0.5";
    private static var _celsiusLow:String = (!SysConfig.isNull("alarmThresholds.temperature.celsius.low")) ? SysConfig.getString() : ">=0:0.5";

    private static var _fahrenheitHigh:String = (!SysConfig.isNull("alarmThresholds.temperature.fahrenheit.high")) ? SysConfig.getString() : ">=0:1";
    private static var _fahrenheitLow:String = (!SysConfig.isNull("alarmThresholds.temperature.fahrenheit.low")) ? SysConfig.getString() : ">=0:1";

    private static var _kelvinHigh:String = (!SysConfig.isNull("alarmThresholds.temperature.kelvin.high")) ? SysConfig.getString() : ">=0:1";
    private static var _kelvinLow:String = (!SysConfig.isNull("alarmThresholds.temperature.kelvin.low")) ? SysConfig.getString() : ">=0:1";


    private static var _celsiusMedium:String = (!SysConfig.isNull("alarmThresholds.temperature.celsius.medium")) ? SysConfig.getString() : ">=0:0.5";
    private static var _fahrenheitMedium:String = (!SysConfig.isNull("alarmThresholds.temperature.fahrenheit.medium")) ? SysConfig.getString() : ">=0:0.5";
    private static var _kelvinMedium:String = (!SysConfig.isNull("alarmThresholds.temperature.kelvin.medium")) ? SysConfig.getString() : ">=0:0.5";

    public static function getInvalidTemp():Temperature {
        var t:Temperature = new Temperature();
        t.value = INVALID_VALUE;
        return t;
    }

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
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return _value;
                break;
            case FAHRENHEIT:
                return (_value * 1.8 + 32);
                break;
            case KELVIN:
                return (_value + 273.15);
                break;
        }
        return _value;
    }

    public override function convertNumber(n:Number):Number {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return n;
                break;
            case FAHRENHEIT:
                return (n * 1.8 + 32);
                break;
            case KELVIN:
                return (n + 273.15);
                break;
        }
        return _value;
    }

    public override function convertFromOldToNew(n:Number):Number {
        switch (UnitHandler.instance.prevTemperature) {
            case CELSIUS:
                return convertNumber(n);
            case FAHRENHEIT:
                return  convertNumber(100 / (212 - 32) * (n - 32 ));
            case KELVIN:
                return convertNumber((n - 273.15));
        }
        return n;
    }

    override public function getUnitStringForAlarm():String {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return "celsius";
            case FAHRENHEIT:
                return "fahrenheit";
            case KELVIN:
                return "kelvin"
        }
        return "";
    }

    override public function getUnitShortString():String {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return "C";
            case FAHRENHEIT:
                return "F";
            case KELVIN:
                return "K"
        }
        return "";
    }

    override public function getThreshold():ThresholdString {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return new ThresholdString(_celsiusHigh, _celsiusMedium, _celsiusLow);
            case FAHRENHEIT:
                return new ThresholdString(_fahrenheitHigh, _fahrenheitMedium, _fahrenheitLow);
            case KELVIN:
                return new ThresholdString(_kelvinHigh, _kelvinMedium, _kelvinLow);
        }
        return new ThresholdString(_celsiusHigh, _celsiusMedium, _celsiusLow);
    }

    override public function getPossibleMax():int {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return 1000;
            case FAHRENHEIT:
                return 10000;
            case KELVIN:
                return 1000
        }
        return 10000;
    }

    override public function getPossibleMin():int {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return -273;
            case FAHRENHEIT:
                return -459;
            case KELVIN:
                return 0
        }
        return 0;
    }

    override public function getAlarmMax():int {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return 50;
            case FAHRENHEIT:
                return 125;
            case KELVIN:
                return 325
        }
        return 10000;
    }

    public function getAlarmMaxmtw():int {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return 45;
            case FAHRENHEIT:
                return 100;
            case KELVIN:
                return 308
        }
        return 10000;
    }

    public function getAlarmMinmtw():int {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return -5;
            case FAHRENHEIT:
                return 20;
            case KELVIN:
                return 268
        }
        return 10000;
    }

    override public function getAlarmMin():int {
        switch (UnitHandler.instance.temperature) {
            case CELSIUS:
                return -20;
            case FAHRENHEIT:
                return -60;
            case KELVIN:
                return 0
        }
        return 0;
    }
}
}
