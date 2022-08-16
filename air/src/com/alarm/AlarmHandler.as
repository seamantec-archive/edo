/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.19.
 * Time: 14:51
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.alarm.soundfx.FxContainer;
import com.alarm.speech.Speech;
import com.alarm.speech.SpeechHandler;
import com.sailing.WindowsHandler;
import com.sailing.datas.BaseSailData;
import com.sailing.units.Angle;
import com.sailing.units.Unit;
import com.store.Statuses;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.media.SoundChannel;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getTimer;

public class AlarmHandler extends EventDispatcher {
    private static const TIMER_DELAY:int = 5000; //TO check system alamrs
    private static const ALERT_TIMER_DELAY:int = 500;
    private static const ALERT_REPEAT_OFFSET:int = 3000;
    private static const INFO_TIMER_DELAY:int = 5000;  //5sec
    private static const INFO_REPEAT_OFFSET:int = 300000; //every 5 min
    private static const NODATA_TIMER_DELAY:int = 10000;  //10sec
    private static var _instance:AlarmHandler;
    private var _listeners:Object;
    private var _alarms:Dictionary;
    private var _alarmsSize:int = 0;
    private var _orderedAlarms:Array = [];
    private var _systemAlarmTimer:Timer;
    private var _alertTimer:Timer;
    private var _infoTimer:Timer;
    private var _validationTimer:Timer;
    private var _systemAlarmKeys:Array = [];
    private var _alarmHistory:Vector.<HistoryAlarm>;
    private var _alertsContainer:Vector.<String> = new <String>[];
    private var _infoContainer:Vector.<String> = new <String>[];
    private var alertSoundChannel:SoundChannel;
    private var _lastSaidTime:int = 0;
    private var _activeAlarmList:Vector.<String> = new <String>[];
    private var _xmlVersion:String;

    public function AlarmHandler() {
        if (_instance != null) {
            throw new Error("This is a singleton. use instance")
        }
        _listeners = new Object();
        _alarms = new Dictionary();
        _alarmHistory = new <HistoryAlarm>[];
        _systemAlarmTimer = new Timer(TIMER_DELAY, 0);
        _systemAlarmTimer.addEventListener(TimerEvent.TIMER, systemAlarmTimer_timerHandler, false, 0, true);
        _systemAlarmTimer.start();

        _alertTimer = new Timer(ALERT_TIMER_DELAY, 0);
        _alertTimer.addEventListener(TimerEvent.TIMER, playAlertBeep, false, 0, true)
        _alertTimer.start();

        _infoTimer = new Timer(INFO_TIMER_DELAY, 0);
        _infoTimer.addEventListener(TimerEvent.TIMER, infoTimer_timerHandler, false, 0, true);
        _infoTimer.start();

        _validationTimer = new Timer(NODATA_TIMER_DELAY, 0);
        _validationTimer.addEventListener(TimerEvent.TIMER, validationTimer_timerHandler, false, 0, true);
        _validationTimer.start();
    }

    public function addActiveAlarm(uuid:String):void {
        for (var i:int = 0; i < _activeAlarmList.length; i++) {
            if (_activeAlarmList[i] === uuid) {
                return;
            }
        }
        _activeAlarmList.push(uuid);
        dispatchEvent(new Event("activeAlarmCounterChanged"));
    }

    public function removeActiveAlarm(uuid:String):void {
        for (var i:int = 0; i < _activeAlarmList.length; i++) {
            if (_activeAlarmList[i] === uuid) {
                _activeAlarmList.splice(i, 1);
                break;
            }
        }
        dispatchEvent(new Event("activeAlarmCounterChanged"));
    }

    public function importAlarms():void {
        var userAlarms:File = File.applicationStorageDirectory;
        userAlarms = userAlarms.resolvePath("configs/alarms.xml");
        var appPredefAlarms:File = File.applicationDirectory;
        appPredefAlarms = appPredefAlarms.resolvePath("configs/alarms.xml")
        var fileStreamUserAlarms:FileStream;
        var fileStreamPredefAlarm:FileStream = new FileStream();
        fileStreamPredefAlarm.open(appPredefAlarms, FileMode.READ);
        fileStreamPredefAlarm.position = 0;
        var predefConfXml:XML = new XML(fileStreamPredefAlarm.readUTFBytes(fileStreamPredefAlarm.bytesAvailable));

        var userxml:XML

        if (userAlarms.exists) {
            fileStreamUserAlarms = new FileStream();
            fileStreamUserAlarms.open(userAlarms, FileMode.READ);
            fileStreamUserAlarms.position = 0;
            userxml = new XML(fileStreamUserAlarms.readUTFBytes(fileStreamUserAlarms.bytesAvailable));

        }
        loadXML(predefConfXml, userxml);

        addEnabledAlarmsToCounter();
    }

    private function addEnabledAlarmsToCounter():void {
        for (var i:int = 0; i < _orderedAlarms.length; i++) {
            if (alarms[_orderedAlarms[i]].enabled) {
                addActiveAlarm(alarms[_orderedAlarms[i]].toString())
            }
        }
        dispatchEvent(new Event("activeAlarmCounterChanged"));
    }

    public function exportAlarms():void {
        var data:XML = new XML("<alarms></alarms>");
        data.appendChild(<version>{_xmlVersion}</version>)
        for (var i:int = 0; i < _alarmsSize; i++) {
            data.appendChild(_alarms[_orderedAlarms[i]].toXML());
        }
        var saveFile:File = File.applicationStorageDirectory;
        saveFile.resolvePath("configs/")
        saveFile = saveFile.resolvePath("configs/alarms.xml");
        var stream:FileStream = new FileStream();
        stream.open(saveFile, FileMode.WRITE);
        stream.writeUTFBytes(data);
        stream.close();

    }


    internal function loadXML(predefXML:XML, userXML:XML = null):void {
        var predefChild:XMLList = predefXML.children();
        var elementsLength:int = predefChild.length();
        for (var i:int = 0; i < elementsLength; i++) {
            var localName:String = predefChild[i].localName() as String;
            var alarm:Alarm;
            var actualXML:XML = predefChild[i];
            var userActualXML:XML = getXMLChildByUUID(actualXML.uuid.text(), userXML);
            if (localName != "version") {
                mergeXml2IntoXml1(actualXML, userActualXML)
            }
            switch (localName) {
                case "LimitAlarm":
                    alarm = LimitAlarm.create(actualXML);
                    break;
//                case "AverageAlarm":
//                    alarm = AverageAlarm.create(children[i]);
//                    break;
                case "SystemAlarm":
                    alarm = SystemAlarm.create(actualXML);
                    break;
                case "AnchorAlarm":
                    alarm = AnchorAlarm.create(actualXML);
                    break;
                case "ShiftAlarm":
                    alarm = ShiftAlarm.create(actualXML);
                    break;
                case "AisAlarm":
                    alarm = AisAlarm.create(actualXML);
                    break;
                case "version":
                    _xmlVersion = predefChild[i].text();
                    break;
            }
            if (alarm != null) {
                addAlarm(alarm);
            }

        }
    }

    internal function mergeXml2IntoXml1(xml1:XML, xml2:XML):void {
        if (xml2 === null) {
            return;
        }
        if (xml1.initAlertLimit != null) {
            xml1.initAlertLimit = xml2.initAlertLimit;
        }
        if (xml1.initInfoLimit != null) {
            xml1.initInfoLimit = xml2.initInfoLimit;
        }
        if (xml1.thresholdLevel != null) {
            xml1.thresholdLevel = xml2.thresholdLevel;
        }

        xml1.enabled = xml2.enabled;
    }

    internal function getXMLChildByUUID(uuid:String, xml:XML):XML {
        if (xml === null) {
            return null;
        }
        var children:XMLList = xml.children();
        for (var i:int = 0; i < children.length(); i++) {
            var xml1:XML = children[i];
            if (xml1.uuid.text() == uuid) {
                return xml1;
            }
        }
        return null;
    }


    public function hasAlarm(labelText:String, listenerKey:String, type:int, klass:Class):Boolean {
        var localAlarms:Array = _listeners[listenerKey];
        if (localAlarms == null) {
            return false;
        }
        var alarmsLength:int = localAlarms.length;
        for (var i:int = 0; i < alarmsLength; i++) {
            if (_alarms[localAlarms[i]].textLabel == labelText) {
                return true;
            } else if (_alarms[localAlarms[i]].alarmType == type && _alarms[localAlarms[i]] is klass) {
                _alarms[localAlarms[i]].textLabel = labelText;
                return true;
            }
        }
        return false;
    }

    public function addAlert(alarmUUID:String):void {
        for (var i:int = 0; i < _alertsContainer.length; i++) {
            if (_alertsContainer[i] === alarmUUID) {
                return;
            }
        }
        _alertsContainer.push(alarmUUID);
    }

    public function removeAlert(alarmUUID:String):void {
        var prevLength:int = _alertsContainer.length
        for (var i:int = 0; i < _alertsContainer.length; i++) {
            if (_alertsContainer[i] === alarmUUID) {
                _alertsContainer.splice(i, 1);
                break;
            }
        }
        if (_alertsContainer.length === 0 && prevLength != 0 && WindowsHandler.instance.isSocketDatasource() && Statuses.instance.socketStatus) {
            FxContainer.container["disalert"].play();
        }
    }


    public function addInfo(alarmUUID:String):void {
        for (var i:int = 0; i < _infoContainer.length; i++) {
            if (_infoContainer[i] === alarmUUID) {
                return;
            }
        }
        _infoContainer.push(alarmUUID);
    }

    public function removeInfo(alarmUUID:String):void {
        for (var i:int = 0; i < _infoContainer.length; i++) {
            if (_infoContainer[i] === alarmUUID) {
                _infoContainer.splice(i, 1);
                break;
            }

        }
    }

    private function playAlertBeep(event:TimerEvent):void {
        if (WindowsHandler.instance.isSocketDatasource() && Statuses.instance.socketStatus) {
            var aUUID:String
            var alarmX:Alarm;
            for (var i:int = 0; i < _alertsContainer.length; i++) {
                aUUID = _alertsContainer[i];
                alarmX = _alarms[aUUID];
                if (alarmX.isInAlert() && ( getTimer() - alarmX.lastSystemTimestamp) > ALERT_REPEAT_OFFSET && alarmX.enabled) {
                    SpeechHandler.instance.addText(alarmX, Speech.REINFO);
                }
            }
        }
    }

    public function stopAlertBeep():void {
        if (alertSoundChannel != null) {
            alertSoundChannel.stop();
        }
    }

    public function addAlarm(alarm:Alarm):void {
        if (alarm == null || alarm.listenerKey == null) {
            return;
        }
        if (_listeners[alarm.listenerKey.key] == null) {
            _listeners[alarm.listenerKey.key] = []
        }
        var parent:Array = _listeners[alarm.listenerKey.key];
        var alarmKey:String = alarm.toString();
        _alarms[alarmKey] = alarm;
        for (var i:int = 0; i < parent.length; i++) {
            var aKey:String = parent[i];
            if (_alarms[aKey] is LimitAlarm && alarm is LimitAlarm && _alarms[aKey].listenerKey == alarm.listenerKey) {
                alarm.siblingAlarm = _alarms[aKey];
                _alarms[aKey].siblingAlarm = alarm;
                break;
            }
        }
        parent.push(alarmKey);
        _orderedAlarms.push(alarmKey);
        _alarmsSize++;
        if (alarm is SystemAlarm) {
            _systemAlarmKeys.push(alarmKey)
        }
    }


    public function sailDataChanged(key:String, newData:*):void {
        if (_listeners[key] == null) {
            return;
        }
        var parent:Array = _listeners[key];
        var alarm:Alarm;
        var value:Number;

        for each (var alarmUID:String in parent) {
            alarm = _alarms[alarmUID];
            if (alarm.listenerKey.listenerParameter is Angle) {
                if ((newData[alarm.listenerKey.parameter] as Angle).isValidValue()) {
                    value = Math.abs(newData[alarm.listenerKey.parameter].value)
                } else {
                    return
                }
            } else if (newData[alarm.listenerKey.parameter] is Unit) {
                if ((newData[alarm.listenerKey.parameter] as Unit).isValidValue()) {
                    value = newData[alarm.listenerKey.parameter].value
                    alarm.alarmUnitValue = newData[alarm.listenerKey.parameter]
                } else {
                    return;
                }

            } else {
                value = newData[alarm.listenerKey.parameter]
            }
            alarm.actualValue = value;
        }
    }

    public function resetAlarms():void {
        for (var i:int = 0; i < _orderedAlarms.length; i++) {
            (_alarms[_orderedAlarms[i]] as Alarm).reset();
        }
    }

    public static function get instance():AlarmHandler {
        if (_instance == null) {
            _instance = new AlarmHandler();
        }
        return _instance;
    }

    public function addAlarmToHistory(hAlarm:HistoryAlarm):void {
        //_alarmHistory.push(hAlarm);
        //TODO dispatch event
    }

    public function clearAlarmHistory():void {
        _alarmHistory = new <HistoryAlarm>[];
        //TODO dispatch event
    }

    public function get alarms():Dictionary {
        return _alarms;
    }

    public function set alarms(value:Dictionary):void {
        _alarms = value;
    }

    public function get listeners():Object {
        return _listeners;
    }


    public function get alarmsSize():int {
        return _alarmsSize;
    }

    public function get orderedAlarms():Array {
        return _orderedAlarms;
    }

    private function systemAlarmTimer_timerHandler(event:TimerEvent):void {
        for (var i:int = 0; i < _systemAlarmKeys.length; i++) {
            _alarms[_systemAlarmKeys[i]].checkAlert();

        }
    }

    public function get alarmHistory():Vector.<HistoryAlarm> {
        return _alarmHistory;
    }


    public function get lastSaidTime():int {
        return _lastSaidTime;
    }

    public function set lastSaidTime(value:int):void {
        _lastSaidTime = value;
    }

    public function get activeAlarmCounter():int {
        return _activeAlarmList.length;
    }

    public function unitChangedForKey(key:String, typeKlass:Class):void {
        var parent:Array = _listeners[key];
        if (parent === null) {
            return;
        }
        for (var i:int = 0; i < parent.length; i++) {
            (_alarms[parent[i]] as Alarm).unitChanged(typeKlass);
        }
        for (var i:int = 0; i < parent.length; i++) {
            (_alarms[parent[i]] as Alarm).positionSiblingsAfterUnitChange();
        }

    }

    public function get alertsContainer():Vector.<String> {
        return _alertsContainer;
    }


    private function infoTimer_timerHandler(event:TimerEvent):void {
        if (WindowsHandler.instance.isSocketDatasource() && Statuses.instance.socketStatus && _alertsContainer.length === 0) {
            var aUUID:String
            var alarmX:Alarm;
            for (var i:int = 0; i < _infoContainer.length; i++) {
                aUUID = _infoContainer[i];
                alarmX = _alarms[aUUID];
                if (alarmX.isInInfo() && ( getTimer() - alarmX.lastSystemTimestamp) > INFO_REPEAT_OFFSET) {
                    SpeechHandler.instance.addText(alarmX, Speech.REINFO);
                }
            }

//            var saidKeys:Dictionary = new Dictionary();
//            for (var i:int = 0; i < _orderedAlarms.length; i++) {
//                var alarm:Alarm = _alarms[_orderedAlarms[i]];
//                if (alarm.enabled && !alarm.isValid && saidKeys[alarm.listenerKey] == null && alarm is LimitAlarm) {
//                    sayNoData(alarm, saidKeys);
//                }
//            }
        }

    }

    private function sayNoData(alarm:Alarm, saidKeys:Dictionary):void {
        if (alertsContainer.length == 0) {
            alarm.validSaidCounter++;
            SpeechHandler.instance.addText(alarm, Speech.NODATA);
            saidKeys[alarm.listenerKey] = "";
        }
    }

    private function validationTimer_timerHandler(event:TimerEvent):void {
        if (WindowsHandler.instance.isSocketDatasource() && Statuses.instance.socketStatus) {
            var saidKeys:Dictionary = new Dictionary();
            for (var i:int = 0; i < _orderedAlarms.length; i++) {
                var alarm:Alarm = _alarms[_orderedAlarms[i]];
                if (alarm is AisAlarm) {
                    continue;
                }
                if (alarm is LimitAlarm && !(WindowsHandler.instance.actualSailData[alarm.listenerKey.key] as BaseSailData).isValid()) {
                    alarm.isValid = false;
                }
                if (alarm.enabled && !alarm.isValid && saidKeys[alarm.listenerKey] == null && alarm.validSaidCounter < 3) {
                    sayNoData(alarm, saidKeys)
                }
            }
        }
    }


    public function get infoContainer():Vector.<String> {
        return _infoContainer;
    }


    public function get xmlVersion():String {
        return _xmlVersion;
    }
}
}
