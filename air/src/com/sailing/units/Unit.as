/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.21.
 * Time: 17:16
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;

public class Unit {
    protected var _value:Number = 0;
    public static const INVALID_VALUE:uint = 9999;
    public static const INVALID_STRING:String = "---";

    public function getPureData():Number {
        if (isNaN(_value)) {
            return 0;
        }
        return _value;
    }

    public function get value():Number {
        return _value;
    }


    public function set value(value:Number):void {
        _value = value;
    }

    public function getDinamicValue():Number {
        return value;
    }

    public function convertNumber(n:Number):Number {
        return n;
    }

    public function convertFromOldToNew(n:Number):Number {
        return n;
    }

    public function getUnitStringForAlarm():String {
        return "";
    }

    public function getUnitString():String {
        return getUnitStringForAlarm();
    }

    public function getUnitShortString():String {
        return "";
    }

    public function getValueWithShortUnitInString(digits:uint = 2):String {
        return  (value % 1 != 0 ? value.toFixed(digits) : value) + " " + getUnitShortString();
    }

    public function getThreshold():ThresholdString {
        return new ThresholdString()
    }

    public function getPossibleMax():int {
        return 0;
    }

    public function getPossibleMin():int {
        return 0;
    }

    public function getAlarmMax():int {
        return getPossibleMax();
    }

    public function getAlarmMin():int {
        return getPossibleMin();
    }

    public static function toInterval(value:Number):Number {
        value -= ((value / 360) >> 0) * 360;
        if (value < 0) {
            value += 360;
        }
        return value;
    }

    public function isValidValue():Boolean {
        return true;
    }

}
}
