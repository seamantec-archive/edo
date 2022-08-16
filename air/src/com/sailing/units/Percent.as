/**
 * Created by pepusz on 2014.08.02..
 */
package com.sailing.units {
public class Percent extends Unit {

    override public function get value():Number {
        return Math.round(_value);
    }

    override public function convertNumber(n:Number):Number {
        return Math.round(n);
    }

    override public function getValueWithShortUnitInString(digits:uint = 2):String {
        if (_value === -1) {
            return INVALID_STRING;
        } else {
            return super.getValueWithShortUnitInString();
        }
    }

    override public function isValidValue():Boolean {
        return _value != -1
    }

    override public function getUnitStringForAlarm():String {
        return "percent";
    }

    override public function getUnitShortString():String {
        return "%";
    }

    override public function getPossibleMax():int {
        return 200;
    }

    override public function getPossibleMin():int {
        return 0;
    }


}
}
