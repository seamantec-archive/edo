/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.26.
 * Time: 22:47
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.sailing.WindowsHandler;
import com.sailing.socket.SocketDispatcher;
import com.utils.GeneralUtils;

import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

public class SystemAlarm extends Alarm {

    public static const CONNECTION:int = 0;
    public static const KEY_VALIDATION:int = 1;
    private var _threshold:int = 0;
    private var _lastSaidTime:Number = 0;
    private static const REPEATE_INT:int = 15000;

    public function SystemAlarm(type:int) {
        super(type);
    }

    public override function isInAlert(valueToCheck:Number = NaN):Boolean {
        return isValidValue();
    }

    public override function isInInfo(valueToCheck:Number = NaN):Boolean {
        return isValidValue();
    }

    public function checkAlert():void {
        if (isValidValue() && enabled && (getTimer() - _lastSaidTime) > REPEATE_INT) {
            addAlarmToSpeechAndHistory();
        }
    }


    public override function set actualValue(value:Number):void {
        _lastTimestamp = WindowsHandler.instance.actualSailData.sailDataTimestamp;
        _actualValue = value;

    }

    public override function isValidValue():Boolean {
        if (_alarmType === KEY_VALIDATION) {
            return ((WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).getStatus() == 1 &&
                    (WindowsHandler.instance.actualSailData.sailDataTimestamp - _lastTimestamp) > _threshold)
        } else {
            if (WindowsHandler.instance.application != null) {
                return (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).getStatus() < 1;
            } else {
                return false;
            }
        }
    }

    public static function create(props:XML):SystemAlarm {
        var type:int = props.type.text() == "connection" ? SystemAlarm.CONNECTION : SystemAlarm.KEY_VALIDATION;
        var labelText:String = props.textLabel.text().toString();
        var listenerKey:String = props.listenerKey.text().toString();
        if (AlarmHandler.instance.hasAlarm(labelText, listenerKey.split("_")[0], type, SystemAlarm)) {
            return null;
        }
        var alarm:SystemAlarm = new SystemAlarm(type)
        alarm.listenerKey = ListenerKeys[listenerKey] as ListenerKey;
        alarm.actualInfoLimit = new Number(props.threshold.text());
        alarm.textLabel = labelText;
        alarm.threshold = new Number(props.threshold.text());
        alarm.min = alarm.listenerKey.possibleMin;
        alarm.max = alarm.listenerKey.possibleMax;
        alarm.steps = new Number(props.sliderStep.text());
        alarm.enabled = GeneralUtils.stringToBoolean(props.enabled.text().toString());
        alarm.xmlUUID = props.uuid.text();
        //alarm.speechEnabled = GeneralUtils.stringToBoolean(props.speechEnabled.text().toString());
        //alarm.alertEnabled = GeneralUtils.stringToBoolean(props.alertEnabled.text().toString());
        return alarm;
    }

    public override function toXML():XML {
        var className:String = getQualifiedClassName(this).split("::")[1];
        var sXml:XML = <{className}>
            <uuid>{xmlUUID}</uuid>
            <listenerKey>{listenerKey.key + "_" + listenerKey.parameter + "_sys"}</listenerKey>
            <type>{_alarmType == CONNECTION ? "connection" : "key_validation"}</type>
            <textLabel>{_textLabel}</textLabel>
            <severity>{mapSeverityToXML()}</severity>
            <sliderStep>{_steps}</sliderStep>
            <enabled>{_enabled}</enabled>
            <speechEnabled>{_speechEnabled}</speechEnabled>
            <alertEnabled>{_alertEnabled}</alertEnabled>
            <threshold>{threshold}</threshold>
        </{className}>
        return sXml;
    }


    public function get lastSaidTime():Number {
        return _lastSaidTime;
    }

    public function set lastSaidTime(value:Number):void {
        _lastSaidTime = value;
    }

    public function get threshold():int {
        return _threshold;
    }

    public function set threshold(value:int):void {
        _threshold = value;
    }
}
}
