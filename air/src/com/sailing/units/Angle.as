/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.21.
 * Time: 15:54
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.alarm.ThresholdString;
import com.common.SysConfig;

public class Angle extends Unit {

    protected static var _degreeHigh:String = (!SysConfig.isNull("alarmThresholds.angle.degree.high")) ? SysConfig.getString() : ">0:15";
    protected static var _degreeLow:String = (!SysConfig.isNull("alarmThresholds.angle.degree.low")) ? SysConfig.getString() : ">0:30";

    protected static var _degreeMedium:String = (!SysConfig.isNull("alarmThresholds.angle.degree.medium")) ? SysConfig.getString() : ">=90:20;<90:15";

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

    public function getAlarmMaxmwvt():int {
        return 180;
    }

    public function getAlarmMinmwvt():int {
        return 20;
    }

    public function getAlarmMaxmwvr():int {
        return 180;
    }

    public function getAlarmMinmwvr():int {
        return 0;
    }

    public function getAlarmMaxtruewindc():int {
        return 180;
    }

    public function getAlarmMintruewindc():int {
        return 20;
    }

    public function getAlarmMaxapparentwind():int {
        return 180;
    }

    public function getAlarmMinapparentwind():int {
        return 0;
    }
}
}
