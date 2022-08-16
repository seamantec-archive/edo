/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.04.02.
 * Time: 19:13
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
public class HistoryAlarm {
    private var _labelText:String;
    private var _value:Number;
    private var _timeStamp:Number;

    public function HistoryAlarm(labelText:String, value:Number, timestamp:Number) {
        this._labelText = labelText;
        this._value = value;
        this._timeStamp = timestamp;
    }
}
}
