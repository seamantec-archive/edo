/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.19.
 * Time: 14:52
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.alarm.speech.Speech;
import com.alarm.speech.SpeechHandler;
import com.events.UnitChangedEvent;
import com.laiyonghao.Uuid;
import com.sailing.SailData;
import com.sailing.datas.WaterDepth;
import com.sailing.units.Unit;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.getTimer;

[Event(name="actualValueChanged", type="flash.events.Event")]
[Event(name="infoLimitChangedBySibling", type="flash.events.Event")]
[Event(name="alertLimitChangedBySibling", type="flash.events.Event")]
[Event(name="alert", type="flash.events.Event")]
public class Alarm extends EventDispatcher implements IAlarm {

    public static const DATA_VALIDATION:int = 3;
    public static const AIS:int = 4;
    protected var _alarmType:int;
    protected var _alarmSeverity:int = Speech.INFO;
    protected var _actualInfoLimit:Number;
    protected var _actualAlertLimit:Number;
    protected var _min:Number;
    protected var _max:Number;
    protected var _actualValue:Number = 0;
    private var _alarmUnitValue:Unit = new Unit();
    protected var _steps:Number;
    protected var _listenerKey:ListenerKey;
    protected var _textLabel:String;
    private var _tempTextLabel:String;
    protected var _speechEnabled:Boolean = true;
    protected var _alertEnabled:Boolean = true;
    protected var _enabled:Boolean = true;
    protected var _lastAlertTimeDiff:int = 0; //diff between two alert event (simple time)
    protected var _lastTimestamp:Number = 0; //last nmea timestamp to handle outdated things
//    protected var _lastSaidTimestamp:Number = 0; //register last nmea timestamp to handle repeated speech if necessary
    protected var _lastSystemTimestamp:int = 0; //register last time to calculate diff between two alert
    protected var _lastSaidValue:Number = 0;
    protected var uuid:String;
    protected var xmlUUID:String;
    protected var _isDecrease:Boolean;
    protected var _lastThreshold:Number;
    //egyenlore csak egy testvert lehet megadni ez a limit alarmoknal kell,
    // hogyha huzzuk a listat akkor ne legyen atfedes
    protected var _siblingAlarm:Alarm;
    protected var _roundTo:Number;
    protected var _isValid:Boolean = false;
    protected var _actualThresholdLevel:uint = Threshold.HIGH;


    protected var isPrevInAlert:Boolean;
    protected var isPrevInInfo:Boolean;

    public function Alarm(type:int) {
        super();
        this._alarmType = type;
    }

    public function addAlarmToSpeechAndHistory():void {
        // updateLastAlertTImeDiff();
//        trace("addAlarmToSpeechAndHistory", getQualifiedClassName(this), " value when added " + listenerKey.key, ".", listenerKey.parameter, " ", actualValue)
//        AlarmHandler.instance.addAlarmToHistory(new HistoryAlarm(this._textLabel, this._actualValue, this._lastTimestamp));
        SpeechHandler.instance.addText(this, _alarmSeverity)
        dispatchEvent(new Event("addAlarmToSpeechAndHistory"));
    }


    public function updateLastSystemTimestamp():void {
        _lastSystemTimestamp = getTimer()
    }

    public function validateLastSaid():Boolean {
        return (getTimer() - _lastSystemTimestamp) > 2000
    }

    public function validateLastSaidPreText():Boolean {
        return (getTimer() - _lastSystemTimestamp) > 10000
    }

    /**
     * ezzel figyeljuk hogy szuksegese ismetelni, ha van valaki az alert containerben
     *
     * (lehet rajta optimalizalni, hogy az alert tudja magarol hogy valtozott-e
     * az alert statusza es csak akkor pakolgatja magat
     * */
    public function addRemoveFromAlertContainer():void {
        if (this is SystemAlarm) {
            return;
        }
        if (isInAlert() && _enabled && isValid) {
            AlarmHandler.instance.addAlert(toString());
            dispatchEvent(new Event("startVisualAlert"));
        } else {
            AlarmHandler.instance.removeAlert(toString());
            dispatchEvent(new Event("stopVisualAlert"));
        }

        if (isInInfo() && _enabled && isValid && !(this is AisAlarm)) {
            AlarmHandler.instance.addInfo(toString());
        } else {
            AlarmHandler.instance.removeInfo(toString());
        }
    }

    public function isInAlert(valueToCheck:Number = NaN):Boolean {
        throw new Error("This is an abstract method. Please override it");
    }

    public function isInInfo(valueToCheck:Number = NaN):Boolean {
        throw new Error("This is an abstract method. Please override it");
    }


    public function isValidValue():Boolean {
        throw new Error("This is an abstract method. Please override it")
    }

    public function get alarmType():int {
        return _alarmType;
    }

    public function set alarmType(value:int):void {
        _alarmType = value;
    }

    public function get min():Number {
        return _min;
    }

    public function set min(value:Number):void {
        _min = value;
    }

    public function get max():Number {
        return _max;
    }

    public function set max(value:Number):void {
        _max = value;
    }


    public function get actualInfoLimit():Number {
        return _actualInfoLimit;
    }

    public function set actualInfoLimit(value:Number):void {
        var prevIsInInfo:Boolean = isInInfo();
        _actualInfoLimit = Math.round(value * 100) / 100;
//        if (isInInfo() && !prevIsInInfo) {
//            sliderMovedIntoAlertOrInfo()
//        }
        setInfoLimitForSibling();
        addRemoveFromAlertContainer();
    }

    public function setInfoLimitFromSibling(value:Number):void {
        var prevIsInInfo:Boolean = isInInfo();
        _actualInfoLimit = Math.round(value * 100) / 100;
//        if (isInInfo() && !prevIsInInfo) {
//            sliderMovedIntoAlertOrInfo()
//        }
        dispatchEvent(new Event("infoLimitChangedBySibling"))
    }

    public function setAlertLimitFromSibling(value:Number):void {
        var needUpdateSibling:Boolean = false;
        if (value < _min) {
            value = _min;
            needUpdateSibling = true;
        }
        if (value > _max) {
            value = _max;
            needUpdateSibling = true;
        }
//        var prevIsInAlert:Boolean = isInAlert();
        _actualAlertLimit = Math.round(value * 100) / 100;
        if (needUpdateSibling) {
            setAlertLimitForSibling();
        }
//        if (isInAlert() && !prevIsInAlert) {
//            sliderMovedIntoAlertOrInfo();
//        }
        addRemoveFromAlertContainer();
        dispatchEvent(new Event("alertLimitChangedBySibling"))
    }


    public function get actualAlertLimit():Number {
        return _actualAlertLimit;
    }

    public function set actualAlertLimit(value:Number):void {
//        var prevIsInAlert:Boolean = isInAlert()
        if (value < _min) {
            value = _min;
        }
        if (value > _max) {
            value = _max;
        }
        _actualAlertLimit = Math.round(value * 100) / 100;
//        if (isInAlert() && !prevIsInAlert) {
//            sliderMovedIntoAlertOrInfo()
//        }
        setAlertLimitForSibling();
        addRemoveFromAlertContainer();

    }

    public function sliderMovedIntoAlertOrInfo():void {
        if (_listenerKey == null) {
            return;
        }
        if (!isPrevInAlert && isInAlert() || !isPrevInInfo && isInInfo()) {
            SpeechHandler.instance.addText(this, Speech.REINFO)
        }
    }

    public function get actualValue():Number {
        return _actualValue;
    }

    public function set actualValue(value:Number):void {
        throw new Error("This is an abstract method. Please override it")
    }


    public function get alarmUnitValue():Unit {
        return _alarmUnitValue;
    }

    public function set alarmUnitValue(value:Unit):void {
        _alarmUnitValue = value;
    }

    public function get steps():Number {
        return _steps;
    }

    public function set steps(value:Number):void {
        _steps = value;
    }

    public function get listenerKey():ListenerKey {
        return _listenerKey;
    }

    public function set listenerKey(value:ListenerKey):void {
        _listenerKey = value;
        if (listenerKey != null && _listenerKey.klass == WaterDepth) {
            WaterDepth.eventDispatcher.addEventListener("offsetChanged", offsetChange);
        }
    }

    private function offsetChange(e:Event):void {

        if (SailData.actualSailData.waterdepth.offset.getPureData() == 0) {
            _tempTextLabel = _textLabel + " below transducer";
        } else if (SailData.actualSailData.waterdepth.offset.getPureData() > 0) {
            _tempTextLabel = _textLabel + " below water-line";
        } else {
            _tempTextLabel = _textLabel + " below keel";
        }
        dispatchEvent(new Event("labelChanged"));

    }

    public override function toString():String {
        if (uuid == null) {
            uuid = new Uuid().toString();
        }
        return uuid
    }


    public function get textLabel():String {
        return _textLabel;
    }

    public function set textLabel(value:String):void {
        _textLabel = value;
    }

    public function get speechEnabled():Boolean {
        return _speechEnabled;
    }

    public function set speechEnabled(value:Boolean):void {
        _speechEnabled = value;
    }

    public function get alertEnabled():Boolean {
        return _alertEnabled;
    }

    public function set alertEnabled(value:Boolean):void {
        _alertEnabled = value;
        addRemoveFromAlertContainer();
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(value:Boolean):void {
        _enabled = value;

        if (_enabled) {
            AlarmHandler.instance.addActiveAlarm(toString());
        } else {
            AlarmHandler.instance.removeActiveAlarm(toString());
        }
        dispatchEvent(new Event("alarmEnableChanged"))

        addRemoveFromAlertContainer();
    }

    public function get alarmSeverity():int {
        return _alarmSeverity;
    }

    public function set alarmSeverity(value:int):void {
        _alarmSeverity = value;
    }

    public function toXML():XML {
        throw new Error("This is an abstract method. Please override it")
    }


    public function get lastAlertTimeDiff():int {
        return _lastAlertTimeDiff;
    }


    public function get lastSaidValue():Number {
        return _lastSaidValue;
    }

    public function set lastSaidValue(value:Number):void {
        _lastSaidValue = value;
    }

    public static function mapTextToSeverity(severityText:String):int {
        var severity:int = Speech.INFO;
        switch (severityText) {
            case "info":
                severity = Speech.INFO;
                break;
            case "warning":
                severity = Speech.WARNING;
                break;
            case "critical":
                severity = Speech.CRITICAL;
                break;
        }
        return severity;
    }

    protected function mapSeverityToXML():String {
        switch (_alarmSeverity) {
            case Speech.INFO:
                return "info"
                break;
            case Speech.WARNING:
                return "warning"
                break;
            case Speech.CRITICAL:
                return "critical";
                break;
        }
        return "";
    }

    protected function mapThresholdLevelToXML():String {
        switch (_actualThresholdLevel) {
            case Threshold.LOW:
                return "low"
                break;
            case Threshold.MEDIUM:
                return "medium"
                break;
            case Threshold.HIGH:
                return "high";
                break;
        }
        return "";
    }

    public function get isDecrease():Boolean {
        return _isDecrease;
    }

    public function set isDecrease(value:Boolean):void {
        _isDecrease = value;
    }

    public function get lastTimestamp():int {
        return _lastTimestamp;
    }

    public function set lastTimestamp(value:int):void {
        _lastTimestamp = value;
    }


    public function get siblingAlarm():Alarm {
        return _siblingAlarm;
    }

    public function set siblingAlarm(value:Alarm):void {
        _siblingAlarm = value;
    }

    protected function setInfoLimitForSibling():void {


    }

    protected function setAlertLimitForSibling():void {

    }


    public function getPossibleInfoLimit(value:Number):Number {
        return 0;
    }

    public function get lastSystemTimestamp():int {
        return _lastSystemTimestamp;
    }


    public function set lastAlertTimeDiff(value:int):void {
        _lastAlertTimeDiff = value;
    }


    public function get lastThreshold():Number {
        if (isNaN(_lastThreshold)) {
            _lastThreshold = listenerKey.getThreshold(actualValue, _actualThresholdLevel);
        }
        return _lastThreshold;
    }

    public function getRoundedDownValue():Number {
        if (isNaN(_lastThreshold)) {
            _lastThreshold = listenerKey.getThreshold(actualValue, _actualThresholdLevel);
        }
        trace("round down with THRESHOL:", _lastThreshold, "for alarm:", _textLabel, "actual value:", _actualValue, "rounded value:", Math.floor(_actualValue / _lastThreshold) * _lastThreshold)

        return Math.floor(_actualValue / _lastThreshold) * _lastThreshold
    }

    public function getRoundedUpValue():Number {
        if (isNaN(_lastThreshold)) {
            _lastThreshold = listenerKey.getThreshold(actualValue, _actualThresholdLevel);
        }
        trace("round up with THRESHOL:", _lastThreshold, "for alarm", _textLabel, "actual value:", _actualValue, "rounded value:", Math.ceil(_actualValue / _lastThreshold) * _lastThreshold)
        return Math.ceil(_actualValue / _lastThreshold) * _lastThreshold
    }

    public function unitChanged(typeKlass:Class):void {
        if (!(_listenerKey.listenerParameter is typeKlass)) {
            return;
        }
        _min = _listenerKey.possibleMin;
        _max = _listenerKey.possibleMax;
        setRoundTo();
        _actualAlertLimit = Math.round(_listenerKey.listenerParameter.convertFromOldToNew(_actualAlertLimit));
        _actualValue = Math.round(_listenerKey.listenerParameter.convertFromOldToNew(_actualValue));
        _actualInfoLimit = Math.round(_listenerKey.listenerParameter.convertFromOldToNew(_actualInfoLimit));
        dispatchEvent(new UnitChangedEvent(listenerKey.klass));
        trace(_listenerKey.klass);
    }

    public function positionSiblingsAfterUnitChange():void {

    }


    protected function setRoundTo():void {
        _roundTo = 1;
        if (_max - _min < 4) {
            _roundTo = 0.1;
        }
    }

    public function reset():void {
        isValid = false;
        _actualValue = 0;
        _lastSaidValue = 0;
        if (!(this is SystemAlarm)) {
            dispatchEvent(new Event("actualValueChanged"));
        }
    }


    public function get roundTo():Number {
        return _roundTo;
    }


    public function get isValid():Boolean {
        return _isValid;
    }

    public var validSaidCounter:uint = 0;

    public function set isValid(value:Boolean):void {
        _isValid = value;
        if (_isValid) {
            validSaidCounter = 0;
        }
        if (!(this is SystemAlarm)) {
            dispatchEvent(new Event("isValidChanged"));
        }
    }

    public function resetLockedValue():void {

    }


    public function alertLimitChangeStarted():void {
        isPrevInAlert = isInAlert()
    }

    public function infoLimitChangeStarted():void {
        isPrevInInfo = isInInfo();
    }


    public function get tempTextLabel():String {
        return _tempTextLabel;
    }


    public function setActualThresholdLevelFromXML(level:String):void {
        switch (level) {
            case "low":
                _actualThresholdLevel = Threshold.LOW;
                break;
            case "medium":
                _actualThresholdLevel = Threshold.MEDIUM;
                break;
            case "high":
                _actualThresholdLevel = Threshold.HIGH;
                break;
        }
    }

    public function setActualThresholdLevelByIndex(index:int):void {

        _actualThresholdLevel = index;
    }

    public function get actualThresholdLevel():uint {
        return _actualThresholdLevel;
    }

    public function set actualThresholdLevel(value:uint):void {
        _actualThresholdLevel = value;
    }
}


}
