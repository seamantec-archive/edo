/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.25.
 * Time: 14:04
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.sailing.ais.AisContainer;
import com.sailing.units.Distance;
import com.utils.GeneralUtils;

import flash.events.Event;
import flash.utils.getQualifiedClassName;

public class AisAlarm extends LimitAlarm {

    public function AisAlarm() {
        super(LimitAlarm.LOW);
        AisContainer.instance.addEventListener("minCpaChanged", minCpaChangedHandler, false, 0, true);
        _isValid = true;
    }


    override public function get isValid():Boolean {
        if (_actualValue === 0) {
            return false;
        }
        return true;
    }

    override public function set isValid(value:Boolean):void {
        _isValid = true;
    }

    //no info just alert
    override public function isInInfo(valueToCheck:Number = NaN):Boolean {
        return isInAlert(valueToCheck);
    }

    public override function toXML():XML {
        var className:String = getQualifiedClassName(this).split("::")[1];
        var sXml:XML = <{className}>
            <uuid>{xmlUUID}</uuid>
            <initAlertLimit>{_actualAlertLimit}</initAlertLimit>
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


    public static function create(props:XML):AisAlarm {
        var labelText:String = props.textLabel.text().toString();
        var alarm:AisAlarm = new AisAlarm();
        alarm.listenerKey = ListenerKeys["ais"] as ListenerKey;
        if (AlarmHandler.instance.hasAlarm(labelText, alarm.listenerKey.key, LimitAlarm.LOW, AisAlarm)) {
            return null;
        }
        alarm.actualInfoLimit = -1
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


    override public function set actualAlertLimit(value:Number):void {
        super.actualAlertLimit = value;
        AisContainer.instance.cpaLimit = _listenerKey.listenerParameter.convertNumber(value)

    }

    var distance:Distance = new Distance();

    private function minCpaChangedHandler(event:Event):void {
        distance.value = AisContainer.instance.minCpa
        actualValue = distance.value;

        alarmUnitValue = distance;
    }


    public override function set actualValue(value:Number):void {
        if (_actualValue === value || value === 0) {
            return;
        }
        _actualValue = value;
        dispatchEvent(new Event("actualValueChanged"))

        var needCheck:Boolean = false;
        if (enabled) {
            _lastThreshold = listenerKey.getThreshold(_actualValue, _actualThresholdLevel);
            needCheck = (Math.abs(_actualValue - _lastSaidValue) >= _lastThreshold && isInAlert(_actualValue))
                    || isNaN(_actualValue);
        }

        if (needCheck && enabled) {
            addAlarmToSpeechAndHistory();
        }
        addRemoveFromAlertContainer();
    }


    override public function unitChanged(typeKlass:Class):void {
        super.unitChanged(typeKlass);
    }
}
}
