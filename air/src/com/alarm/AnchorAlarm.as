/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.04.
 * Time: 17:39
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.common.Coordinate;
import com.sailing.WindowsHandler;
import com.sailing.datas.Rmc;
import com.utils.CoordinateSystemUtils;
import com.utils.GeneralUtils;

import flash.events.Event;
import flash.utils.getQualifiedClassName;

public class AnchorAlarm extends LimitAlarm {
    private var startCoordinate:Coordinate

    public function AnchorAlarm() {
        super(LimitAlarm.HIGH);
        if(!isNaN(super.actualAlertLimit)) {
            AnchorChange.instance.max = super.actualAlertLimit;
            AnchorChange.instance.enable = super.enabled;
        }
    }

    public override function toXML():XML {
        var className:String = getQualifiedClassName(this).split("::")[1];
        var sXml:XML = <{className}>
            <uuid>{xmlUUID}</uuid>
            <listenerKey>anchor</listenerKey>
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


    override public function set actualAlertLimit(value:Number):void {
        super.actualAlertLimit = value;
        AnchorChange.instance.maxChange(value);
    }

    public static function create(props:XML):AnchorAlarm {
        var labelText:String = props.textLabel.text().toString();
        var listenerKey:String = props.listenerKey.text().toString();
        var alarm:AnchorAlarm = new AnchorAlarm();
        alarm.listenerKey = ListenerKeys[listenerKey] as ListenerKey;
        if (AlarmHandler.instance.hasAlarm(labelText, alarm.listenerKey.key, LimitAlarm.HIGH, AnchorAlarm)) {
            return null;
        }
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


    var rmc:Rmc

    public override function set actualValue(value:Number):void {
        if (!_enabled) {
            _actualValue = 0;
            dispatchEvent(new Event("actualValueChanged"))
            return;
        }
        rmc = WindowsHandler.instance.actualSailData.rmc;
        if (!_isValid) {
            isValid = true;
        }
        if (startCoordinate.lat === 0) {
            resetLockedValue();
        }
        _lastTimestamp = WindowsHandler.instance.actualSailData.sailDataTimestamp;
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
        addRemoveFromAlertContainer();
    }

    private function calculateActualValue():void {
        _actualValue = CoordinateSystemUtils.distanceBetweenTwoPointsInNMI(startCoordinate, new Coordinate(rmc.lat, rmc.lon));
        _actualValue = Math.round(_listenerKey.listenerParameter.convertNumber(_actualValue) * 10) / 10
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
        AnchorChange.instance.setEnable(enabled);
        addRemoveFromAlertContainer();
    }


    override public function resetLockedValue():void {
        rmc = WindowsHandler.instance.actualSailData.rmc;
        startCoordinate = new Coordinate(rmc.lat, rmc.lon);
        if(startCoordinate.lat != 0){
            actualValue = 0;
        }else{
            calculateActualValue();
        }
        AnchorChange.instance.reset();
    }
}
}
