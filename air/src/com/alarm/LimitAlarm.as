/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.26.
 * Time: 19:53
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.events.UnitChangedEvent;
import com.sailing.WindowsHandler;
import com.sailing.units.Angle;
import com.utils.GeneralUtils;

import flash.events.Event;
import flash.utils.getQualifiedClassName;

public class LimitAlarm extends Alarm {
    public static const LOW:int = 0;
    public static const HIGH:int = 1;

    public function LimitAlarm(type:int) {
        super(type);
    }


    public override function isInAlert(valueToCheck:Number = NaN):Boolean {
        if (isNaN(valueToCheck)) {
            valueToCheck = _actualValue;
        }
        if (!_isValid) {
            return false;
        }
        return (_alarmType == LOW && valueToCheck <= actualAlertLimit ||
                _alarmType == HIGH && valueToCheck >= actualAlertLimit);

    }

    public override function isInInfo(valueToCheck:Number = NaN):Boolean {
        if (isNaN(valueToCheck)) {
            valueToCheck = _actualValue;
        }
        if (!_isValid) {
            return false;
        }
        return (_alarmType == LOW && valueToCheck <= actualInfoLimit ||
                _alarmType == HIGH && valueToCheck >= actualInfoLimit);

    }

    public override function isValidValue():Boolean {
        if (enabled && _isValid) {
            _isDecrease = lastSaidValue >= actualValue;
            _lastThreshold = listenerKey.getThreshold(actualValue, _actualThresholdLevel);
            var diffIsBiggerThanTrashold:Boolean = Math.abs(lastSaidValue - actualValue) >= _lastThreshold;
            if ((isInInfo() || isInAlert()) && diffIsBiggerThanTrashold) {
                return true;
            }
        }
        return false;
    }

    public override function set actualValue(value:Number):void {
        if (!_isValid && WindowsHandler.instance.actualSailData[_listenerKey.key].isValid()) {
            isValid = true;
        }
        _lastTimestamp = WindowsHandler.instance.actualSailData.sailDataTimestamp;

        if (_actualValue === value || (_listenerKey.listenerParameter is Angle && (value === 0 || value === 180)) || !isValid) {
            return;
        }
        var needCheck:Boolean = false;
        if (enabled) {
            _lastThreshold = listenerKey.getThreshold(actualValue, _actualThresholdLevel);
            needCheck = (Math.abs(value - lastSaidValue) >= _lastThreshold && (isInInfo(value) || isInAlert(value)))
                    || isNaN(_actualValue);
        }
//        if (_lastThreshold > 1) {
//            value = Math.round(value)
//        } else {
            value = Math.round(value * 10) / 10;
//        }

        _actualValue = value;
//        if (_actualValue > _listenerKey.possibleMax) {
//            _actualValue = _listenerKey.possibleMax + 1;
//        }
        dispatchEvent(new Event("actualValueChanged"))
        if (needCheck && enabled) {
            addAlarmToSpeechAndHistory();
        }
        addRemoveFromAlertContainer();
    }

    public override function toXML():XML {
        var className:String = getQualifiedClassName(this).split("::")[1];
        var sXml:XML = <{className}>
            <uuid>{xmlUUID}</uuid>
            <listenerKey>{listenerKey.key + "_" + listenerKey.parameter}</listenerKey>
            <type>{_alarmType == LOW ? "low" : "high"}</type>
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


    public static function create(props:XML):LimitAlarm {
        var type:int = mapAlarmType(props.type.text());
        var labelText:String = props.textLabel.text().toString();
        var listenerKey:String = props.listenerKey.text().toString();
        if (AlarmHandler.instance.hasAlarm(labelText, listenerKey.split("_")[0], type, LimitAlarm)) {
            return null;
        }

        var alarm:LimitAlarm = new LimitAlarm(type);
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
        alarm.setInfoLimit();
        alarm.setAlertLimit();
        alarm.xmlUUID = props.uuid.text();
        alarm.setActualThresholdLevelFromXML(props.thresholdLevel.text())
        return alarm;
    }

    public static function mapAlarmType(type:String):int {
        return type == "low" ? LimitAlarm.LOW : LimitAlarm.HIGH
    }

    public override function set siblingAlarm(value:Alarm):void {
        _siblingAlarm = value;
        setInfoLimit();
        setAlertLimit();

    }

    private function setInfoLimitStandalone():void {
        if ((_alarmType === LOW && _actualInfoLimit < _actualAlertLimit) || (_alarmType === HIGH && _actualInfoLimit > _actualAlertLimit)) {
            setInfoLimitFromSibling(_actualAlertLimit)
        }
    }

    protected override function setInfoLimitForSibling():void {
        setInfoLimitStandalone();
        setInfoLimitForSiblingByValue(_actualInfoLimit);
    }

    private function setInfoLimitForSiblingByValue(value:Number):void {
        if (_siblingAlarm == null) {
            return;
        }
        if (_alarmType === LOW && _siblingAlarm.alarmType === HIGH) {
            if (value >= _siblingAlarm.actualInfoLimit) {
                _siblingAlarm.setInfoLimitFromSibling(value + _roundTo);
            }
            if (value > _siblingAlarm.actualAlertLimit) {
                _siblingAlarm.setInfoLimitFromSibling(_siblingAlarm.actualAlertLimit);
                setInfoLimitFromSibling(_siblingAlarm.actualAlertLimit - _roundTo);
            }
        } else if (_alarmType === HIGH && _siblingAlarm.alarmType === LOW) {
            if (value <= _siblingAlarm.actualInfoLimit) {
                _siblingAlarm.setInfoLimitFromSibling(value - _roundTo);
            } else if (value < _siblingAlarm.actualAlertLimit) {
                _siblingAlarm.setInfoLimitFromSibling(_siblingAlarm.actualAlertLimit);
                setInfoLimitFromSibling(_siblingAlarm.actualAlertLimit + _roundTo);
            }
        }

    }

    public override function setInfoLimitFromSibling(value:Number):void {
//        var prevIsInInfo:Boolean = isInInfo();
        if (_alarmType === LOW && value >= _actualAlertLimit || _alarmType === HIGH && value <= _actualAlertLimit) {
            _actualInfoLimit = Math.round(value * 100) / 100;
        } else {
            _actualInfoLimit = _actualAlertLimit;
        }
//        if (isInInfo() && !prevIsInInfo) {
//            sliderMovedIntoAlertOrInfo()
//        }
        dispatchEvent(new Event("infoLimitChangedBySibling"))
    }


    override public function getPossibleInfoLimit(value:Number):Number {
        var rValue:Number = value;
        if (_siblingAlarm != null) {
            if (_alarmType === LOW && _siblingAlarm.alarmType === HIGH) {
                if (value >= _siblingAlarm.actualInfoLimit) {
                    setInfoLimitForSiblingByValue(value);
                    rValue = _siblingAlarm.actualInfoLimit - _roundTo
                }
            } else if (_alarmType === HIGH && _siblingAlarm.alarmType === LOW) {
                if (value <= _siblingAlarm.actualInfoLimit) {
                    setInfoLimitForSiblingByValue(value);
                    rValue = _siblingAlarm.actualInfoLimit + _roundTo
                }
            }
        }
        if (rValue < _min) {
            rValue = _min;
        }
        if (rValue > _max) {
            rValue = _max
        }
        return rValue;
    }


    protected override function setAlertLimitForSibling():void {
        setAlertLimitStandalone();
        if (_siblingAlarm == null) {

            return;
        }
        if (_alarmType === LOW && _siblingAlarm.alarmType === HIGH) {
            if (_actualAlertLimit >= _siblingAlarm.actualAlertLimit) {
                _siblingAlarm.setAlertLimitFromSibling(_actualAlertLimit + _roundTo);
                _siblingAlarm.setInfoLimitFromSibling(_actualAlertLimit + _roundTo);
            }
        } else if (_alarmType === HIGH && _siblingAlarm.alarmType === LOW) {
            if (_actualAlertLimit <= _siblingAlarm.actualAlertLimit) {
                _siblingAlarm.setAlertLimitFromSibling(_actualAlertLimit - _roundTo);
                _siblingAlarm.setInfoLimitFromSibling(_actualAlertLimit - _roundTo);
            }
        }

        setInfoLimitForSibling()


    }

    private function setAlertLimitStandalone():void {
        if ((_alarmType === LOW && _actualInfoLimit < _actualAlertLimit) || (_alarmType === HIGH && _actualInfoLimit > _actualAlertLimit)) {
            setInfoLimitFromSibling(_actualAlertLimit);
        }
    }

    private function setInfoLimit():void {
        if (_siblingAlarm != null) {
            if (_alarmType === LOW && _siblingAlarm.alarmType === HIGH) {
                if (_actualInfoLimit >= _siblingAlarm.actualInfoLimit || _actualInfoLimit >= _siblingAlarm.actualAlertLimit) {   // && _actualInfoLimit < _siblingAlarm.actualAlertLimit
                    _actualInfoLimit = _siblingAlarm.actualAlertLimit - _roundTo;
                    if (_actualInfoLimit < _min) {
                        _actualInfoLimit = _min;
                        _siblingAlarm.setInfoLimitFromSibling(_min + _roundTo);
                    }
                }
            } else if (_alarmType === HIGH && _siblingAlarm.alarmType === LOW) {
                if (_actualInfoLimit <= _siblingAlarm.actualInfoLimit || _actualInfoLimit <= _siblingAlarm.actualAlertLimit) {  // && _actualInfoLimit > _siblingAlarm.actualAlertLimit
                    _actualInfoLimit = _siblingAlarm.actualInfoLimit + _roundTo;
                    if (_actualInfoLimit > _max) {
                        _actualInfoLimit = _max;
                        _siblingAlarm.setInfoLimitFromSibling(_max - _roundTo);
                    }
                }
            }
        } else {
            if (_actualInfoLimit < _min) {
                _actualInfoLimit = _min;
            } else if (_actualInfoLimit > _max) {
                _actualInfoLimit = _max;
            }
        }

    }


    //run at init (set values from sibling if necessary
    private function setAlertLimit():void {
        if (_siblingAlarm != null) {
            if (_alarmType === LOW && _siblingAlarm.alarmType === HIGH) {
                if (_actualAlertLimit >= _siblingAlarm.actualAlertLimit) {
                    _actualAlertLimit = _siblingAlarm.actualAlertLimit - _roundTo;
                    if (_actualAlertLimit < _min) {
                        _actualAlertLimit = _min;
                        _siblingAlarm.setAlertLimitFromSibling(_min + _roundTo);
                    }
                }
                if (_actualAlertLimit >= _actualInfoLimit) {
                    _actualInfoLimit = _actualAlertLimit;
                }
            } else if (_alarmType === HIGH && _siblingAlarm.alarmType === LOW) {
                if (_actualAlertLimit <= _siblingAlarm.actualAlertLimit) {
                    _actualAlertLimit = _siblingAlarm.actualAlertLimit + _roundTo;
                    if (_actualAlertLimit > _max) {
                        _actualAlertLimit = _max;
                        _siblingAlarm.setAlertLimitFromSibling(_max - _roundTo);
                    }
                }
                if (_actualAlertLimit <= _actualInfoLimit) {
                    _actualInfoLimit = _actualAlertLimit;
                }
            }
        } else {

            if (_actualAlertLimit < _min) {
                _actualAlertLimit = _min;
            } else if (_actualAlertLimit > _max) {
                _actualAlertLimit = _max;
            }
        }


    }

    public override function unitChanged(typeKlass:Class):void {
        if (!(_listenerKey.listenerParameter is typeKlass)) {
            return;
        }
//        trace("unitmin", alarmUnitValue.getAlarmMax(), _listenerKey.possibleMax, alarmUnitValue.getUnitShortString(), listenerKey.listenerParameter.getUnitShortString(), listenerKey.unit);
        _min = _listenerKey.possibleMin;
        _max = _listenerKey.possibleMax;
        setRoundTo();
        _actualAlertLimit = Math.round(_listenerKey.listenerParameter.convertFromOldToNew(_actualAlertLimit));
        _actualValue = Math.round(_listenerKey.listenerParameter.convertFromOldToNew(_actualValue) * 1000) / 1000;
        _actualInfoLimit = Math.round(_listenerKey.listenerParameter.convertFromOldToNew(_actualInfoLimit));
        _lastSaidValue = Math.round(_listenerKey.listenerParameter.convertFromOldToNew(_lastSaidValue));
        if (_actualAlertLimit > _max) {
            _actualAlertLimit = _max;
        }
        if (_actualAlertLimit < _min) {
            _actualAlertLimit = _min;
        }
        if (_actualInfoLimit > _max) {
            _actualInfoLimit = _max;
        }
        if (_actualInfoLimit < _min) {
            _actualInfoLimit = _min;
        }
        dispatchEvent(new UnitChangedEvent(listenerKey.klass));
    }


    public override function positionSiblingsAfterUnitChange():void {
        setInfoLimit();
        setAlertLimit();
        dispatchEvent(new UnitChangedEvent(listenerKey.klass));
    }


}
}
