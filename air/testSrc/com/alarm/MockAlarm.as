/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.22.
 * Time: 18:08
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
public class MockAlarm extends Alarm {

    public var _isInAlert:Boolean = false;
    public var _isInInfo:Boolean = false;
    public var _isValidValue:Boolean = false;


    public function MockAlarm() {
        super(LimitAlarm.LOW);
        _listenerKey = ListenerKeys["dbt_waterDepth"];
    }


    override public function set actualValue(value:Number):void {
        _actualValue = value;
    }


    override public function isInAlert(valueToCheck:Number = NaN):Boolean {
        return _isInAlert;
    }

    override public function isInInfo(valueToCheck:Number = NaN):Boolean {
        return _isInInfo
    }

    override public function isValidValue():Boolean {
        return _isValidValue;
    }
}
}
