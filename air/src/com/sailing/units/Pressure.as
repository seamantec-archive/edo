/**
 * Created by pepusz on 2014.07.30..
 */
package com.sailing.units {
public class Pressure extends Unit {
    override public function getValueWithShortUnitInString(digits:uint = 2):String {
        if (_value === INVALID_VALUE) {
            return INVALID_STRING;
        } else {
            return super.getValueWithShortUnitInString(5);
        }
    }

//    public override function get value():Number {
//        return Math.round(_value * 1000);
//    }

    override public function isValidValue():Boolean {
           return _value !== INVALID_VALUE;
       }



    override public function getUnitShortString():String {
        return "hpa";
    }
}
}
