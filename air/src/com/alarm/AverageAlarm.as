/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.26.
 * Time: 22:48
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.sailing.WindowsHandler;
import com.utils.GeneralUtils;

import flash.events.Event;
import flash.utils.getQualifiedClassName;

public class AverageAlarm extends Alarm implements IAlarm {
    private var _lastValues:Array = [];
    private var _actualValueX:Number = 0;
    private var _refreshTime:Number = 0;
    private var _tempValue:Number = 0;
    private var _isInAlert:Boolean = false;
    private var _isInInfo:Boolean = false;
    /*
     *
     * ITT az actaulValue az az atlag
     *
     * */
    public function AverageAlarm() {
        super(0);
    }

    //TODO refaktor, hogy az atlagot hasonlitsuk mint erteket a
    // beallitott limittel es ne az atlag es az uj ertekek azaz a valtozas merteket
    public function checkAlert():void {
        var change:Number = Math.abs(_actualValue - _tempValue);
        if (change > _actualAlertLimit) {
            addAlarmToSpeechAndHistory();
            _isInAlert = true;
        } else {
            _isInAlert = false;
        }
        if (change > _actualInfoLimit) {
            addAlarmToSpeechAndHistory();
            _isInInfo = true;
        } else {
            _isInInfo = false;
        }
    }

    public override function isInAlert(valueToCheck:Number = NaN):Boolean {
        return _isInAlert;
    }

    public override function isInInfo(valueToCheck:Number = NaN):Boolean {
        return _isInInfo;
    }

    public override function toXML():XML {
        var className:String = getQualifiedClassName(this).split("::")[1];
        var sXml:XML = <{className}>
            <listenerKey>{listenerKey.key + "_" + listenerKey.parameter + "_avg"}</listenerKey>
            <threshold>{_actualAlertLimit}</threshold>
            <initInfoLimit>{_actualInfoLimit}</initInfoLimit>
            <refreshTime>{_refreshTime}</refreshTime>
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

    public override function set actualValue(value:Number):void {
        _lastTimestamp = WindowsHandler.instance.actualSailData.sailDataTimestamp;

        if (_lastValues.length != 0) {
            if ((_lastTimestamp - _lastValues[0].timestamp) >= _refreshTime * 60000) {
                _actualValue = calculateAverage();
                _tempValue = value;
                checkAlert()
            } else {
                _isInAlert = false;
                _isInInfo = false;
            }
        } else {
            _isInInfo = false;
        }
        _actualValueX = value;
        _lastValues.push({"value": value, timestamp: _lastTimestamp});
        addRemoveFromAlertContainer();
        dispatchEvent(new Event("actualValueChanged"))

    }

    private function calculateAverage():Number {
        var length:int = _lastValues.length;
        var sum:Number = 0;
        var indexesNeedToDrop:Vector.<int> = new Vector.<int>();
        for (var i:int = 0; i < length; i++) {
            var object:Object = _lastValues[i];
            sum += object.value;
            if ((_lastTimestamp - _lastValues[0].timestamp) >= _refreshTime * 60000) {
                indexesNeedToDrop.push(i);
            }
        }
        for (var j:int = 0; j < indexesNeedToDrop.length; j++) {
            _lastValues.splice(indexesNeedToDrop[j], 1);
        }
        return Math.round(sum / length);
    }

    public override function isValidValue():Boolean {
        if (Math.abs(_actualValue - _actualValue) > _actualAlertLimit) {
            return true;
        }
        return false;
    }

    public override function reset():void {
        _lastValues = [];
        _actualValueX = 0;
        _refreshTime = 0;
        _tempValue = 0;
        _isInAlert = false;
        _isInInfo = false;
    }

    public static function create(props:XML):AverageAlarm {
        var labelText:String = props.textLabel.text().toString();
        var listenerKey:String = props.listenerKey.text().toString();
        if (AlarmHandler.instance.hasAlarm(labelText, listenerKey.split("_")[0])) {
            return null;
        }
        var alarm:AverageAlarm = new AverageAlarm();
        alarm.listenerKey = ListenerKeys[listenerKey] as ListenerKey;
        alarm.actualAlertLimit = new Number(props.threshold.text());
        alarm.actualInfoLimit = new Number(props.initInfoLimit.text());
        alarm.refreshTime = new Number(props.refreshTime.text());
        alarm.textLabel = labelText;
        alarm.min = alarm.listenerKey.possibleMin;
        alarm.max = alarm.listenerKey.possibleMax;
        alarm.alarmSeverity = mapTextToSeverity(props.severity.text());
        alarm.steps = new Number(props.sliderStep.text());
        alarm.enabled = GeneralUtils.stringToBoolean(props.enabled.text().toString());
        alarm.setActualThresholdLevelFromXML(props.thresholdLevel.text())
        //alarm.speechEnabled = GeneralUtils.stringToBoolean(props.speechEnabled.text().toString());
        //alarm.alertEnabled = GeneralUtils.stringToBoolean(props.alertEnabled.text().toString());

        return alarm;
    }


    public function get refreshTime():Number {
        return _refreshTime;
    }

    public function set refreshTime(value:Number):void {
        _refreshTime = value;
    }

    public override function set enabled(value:Boolean):void {
        super.enabled = value;
        reset();
    }


    protected override function setInfoLimitForSibling():void {
        if (_actualInfoLimit < _actualAlertLimit) {
            setInfoLimitFromSibling(_actualAlertLimit)
        }

    }

    protected override function setAlertLimitForSibling():void {
        if (_actualInfoLimit < _actualAlertLimit) {
            setInfoLimitFromSibling(_actualAlertLimit);
        }
    }
}
}
