/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.05.
 * Time: 11:14
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.sailing.WindowsHandler;
import com.sailing.units.Unit;
import com.utils.GeneralUtils;

import flash.events.Event;
import flash.utils.getQualifiedClassName;

public class ShiftAlarm extends LimitAlarm {
    private var startValue:Number = NaN

    public function ShiftAlarm() {
        super(LimitAlarm.HIGH);
    }


    public override function toXML():XML {
        var className:String = getQualifiedClassName(this).split("::")[1];
        var sXml:XML = <{className}>
            <uuid>{xmlUUID}</uuid>
            <listenerKey>{listenerKey.key + "_" + listenerKey.parameter + "_shift"}</listenerKey>
            <type>high</type>
            <initAlertLimit>{_actualAlertLimit}</initAlertLimit>
            <initInfoLimit>{_actualInfoLimit}</initInfoLimit>
            <textLabel>{_textLabel}</textLabel>
            <severity>{mapSeverityToXML()}</severity>
            <sliderStep>{_steps}</sliderStep>
            <enabled>{_enabled}</enabled>
            <speechEnabled>{_speechEnabled}</speechEnabled>
            <alertEnabled>{_alertEnabled}</alertEnabled>
            <thresholdLevel>{mapThresholdLevelToXML()}</thresholdLevel>
        </{className}>
        return sXml;

    }


    public static function create(props:XML):ShiftAlarm {
        var labelText:String = props.textLabel.text().toString();
        var listenerKey:String = props.listenerKey.text().toString();
        if (AlarmHandler.instance.hasAlarm(labelText, listenerKey.split("_")[0], LimitAlarm.HIGH, ShiftAlarm)) {
            return null;
        }
        var alarm:ShiftAlarm = new ShiftAlarm();
        alarm.listenerKey = ListenerKeys[listenerKey] as ListenerKey;

        alarm.actualInfoLimit = props.initInfoLimit.text()
        alarm.actualAlertLimit = props.initAlertLimit.text()
        alarm.min = alarm.listenerKey.possibleMin;
        alarm.max = alarm.listenerKey.possibleMax;
        alarm.textLabel = labelText;
        alarm.alarmSeverity = mapTextToSeverity(props.severity.text());
        alarm.steps = new Number(props.sliderStep.text());
        alarm.enabled = GeneralUtils.stringToBoolean(props.enabled.text().toString());
        alarm.setRoundTo();
        alarm.xmlUUID = props.uuid.text();
        alarm.setActualThresholdLevelFromXML(props.thresholdLevel.text())
        return alarm;
    }

    private var gotValue:Number;

    public override function set actualValue(value:Number):void {
        if (!_isValid) {
            isValid = true;
        }
        if (isNaN(startValue)) {
            resetLockedValue();
        }
        gotValue = value;
        _lastTimestamp = WindowsHandler.instance.actualSailData.sailDataTimestamp;
//        var notRoundedAValue:Number = relativeDiff(startValue,gotValue);
        calculateActualValue();
        var needCheck:Boolean = false;
        if (enabled) {
            _lastThreshold = listenerKey.getThreshold(_actualValue, _actualThresholdLevel);
            needCheck = (Math.abs(_actualValue - _lastSaidValue) >= _lastThreshold && (isInInfo(_actualValue) || isInAlert(_actualValue)))
                    || isNaN(_actualValue);
        }

        if (needCheck && enabled) {
            addAlarmToSpeechAndHistory();
        }
    }

    private function diffOneWay(n1:Number, n2:Number):Number {
        if (n1 < n2) {
            return n2 - n1;
        }
        if (n2 < n1) {
            return 360 - n1 + n2;
        }
        return 0;
    }

    private function relativeDiff(n1, n2):Number {
        var x:Number = Math.abs(n1 - n2);
        if (x <= 180) {
            return x;
        } else {
            return 360 - x;
        }
    }


    override public function unitChanged(typeKlass:Class):void {
        super.unitChanged(typeKlass);
        if (_listenerKey.listenerParameter is typeKlass) {
            startValue = Math.round(_listenerKey.listenerParameter.convertFromOldToNew(startValue));
        }

    }

    private function calculateActualValue():void {
        if (isNaN(gotValue)) {
            return;
        }
        _actualValue = relativeDiff(startValue, gotValue);
        _actualValue = Math.round(_listenerKey.listenerParameter.convertNumber(_actualValue) * 10) / 10
//        //TODO implement shift for
//        if (_actualValue > _listenerKey.possibleMax) {
//            _actualValue = _listenerKey.possibleMax;
//        }
//        if (_actualValue < _listenerKey.possibleMin) {
//            _actualValue = _listenerKey.possibleMin;
//        }
        addRemoveFromAlertContainer();

        dispatchEvent(new Event("actualValueChanged"))

    }

    public override function set enabled(value:Boolean):void {
        _enabled = value;
        if (_enabled) {
            AlarmHandler.instance.addActiveAlarm(toString());
            resetLockedValue();
            calculateActualValue();
        } else {
            AlarmHandler.instance.removeActiveAlarm(toString());
        }
        dispatchEvent(new Event("alarmEnableChanged"))

        addRemoveFromAlertContainer();
    }


    override public function resetLockedValue():void {
        if (!WindowsHandler.instance.actualSailData[_listenerKey.key].isValid()) {
            return;
        }
        if (WindowsHandler.instance.actualSailData[_listenerKey.key][_listenerKey.parameter] is Unit) {
            startValue = WindowsHandler.instance.actualSailData[_listenerKey.key][_listenerKey.parameter].value;
        } else {
            startValue = WindowsHandler.instance.actualSailData[_listenerKey.key][_listenerKey.parameter]
        }
        _lastSaidValue = 0;
        calculateActualValue();
    }
}
}
