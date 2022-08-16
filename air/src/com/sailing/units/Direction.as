/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.21.
 * Time: 15:55
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;
import com.common.SysConfig;

public class Direction extends Unit {
    public static const MAGNETIC:uint = 1;
    public static const TRUE:uint = 2;
    public static const FORCED_MAGNETIC:uint = 3;
    public static var variation:Number = 0;
    private static var _isVariationValid:Boolean = false;

    private static var _degreeHigh:String = (!SysConfig.isNull("alarmThresholds.direction.degree.high")) ? SysConfig.getString() : ">=0:10";
    private static var _degreeLow:String = (!SysConfig.isNull("alarmThresholds.direction.degree.low")) ? SysConfig.getString() : ">=0:30";

    private static var _degreeMedium:String = (!SysConfig.isNull("alarmThresholds.direction.degree.medium")) ? SysConfig.getString() : ">=0:10";

    public override function get value():Number {
        if (_isVariationValid && UnitHandler.instance.direction == TRUE && _value != INVALID_VALUE) {
//            if (_value + variation < 360) {
//                return _value + variation;
//            } else {
//                return _value + variation - 360;
//            }
            return Unit.toInterval(_value + variation)
        } else {
            return _value;
        }
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

    public static function set isVariationValid(value:Boolean):void {
//        if(_isVariationValid === value){
//            return;
//        }
        _isVariationValid = value;
        checkVariation();
    }

    public static function get isVariationValid():Boolean {
        return _isVariationValid;
    }

    public static function checkVariation():void {
        if (_isVariationValid && UnitHandler.instance.direction == FORCED_MAGNETIC) {
            UnitHandler.instance.direction = TRUE;
        }
        if (!_isVariationValid && UnitHandler.instance.direction == TRUE) {
            UnitHandler.instance.direction = FORCED_MAGNETIC;
        }
    }

    override public function getUnitStringForAlarm():String {
        return "degree";
    }

    override public function getUnitString():String {
        return "degree";
    }

    override public function getUnitShortString():String {
        return "°";
    }

    override public function getThreshold():ThresholdString {
        return new ThresholdString(_degreeHigh, _degreeMedium, _degreeLow);
    }

    override public function getPossibleMax():int {
        return 360;
    }

    override public function getPossibleMin():int {
        return 0;
    }

    public function getAlarmMinmwvt():int {
        return 0
    }

    public function getAlarmMaxmwvt():int {
        return 180;
    }

    public function getAlarmMinmwd_shift():int {
        return 0;
    }

    public function getAlarmMaxmwd_shift():int {
        return 180;
    }
}
}
