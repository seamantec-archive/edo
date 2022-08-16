/**
 * Created by pepusz on 2014.07.30..
 */
package com.sailing.units {
public class Humidity extends Unit {

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

    override public function getUnitShortString():String {
        return "%";
    }
}
}
