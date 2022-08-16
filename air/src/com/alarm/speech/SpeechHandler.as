/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.18.
 * Time: 18:29
 * To change this template use File | Settings | File Templates.
 */
package com.alarm.speech {
import com.alarm.Alarm;
import com.alarm.AlarmHandler;
import com.common.AppProperties;

import flash.events.Event;
import flash.media.SoundMixer;
import flash.utils.getTimer;

public class SpeechHandler {
    private static var _instance:SpeechHandler;

    private var _speeches:Vector.<Speech>;
    private var criticalSpeeches:Array;
    private var _nowPlaying:Boolean = false;
    private var _lastAlarmUID:String;
    private var _actualPlay:Speech;

    public function SpeechHandler() {
        if (_instance == null) {
            _instance = this;
            _speeches = new <Speech>[];
            criticalSpeeches = [];
        } else {
            throw new Error("This is a singleton. Use instance")
        }
    }

    public function addText(alarm:Alarm, severity:int = 0):void {
        addSpeech(new Speech(alarm, severity));
    }


    var aAlarm:Alarm;

    public function addSpeech(speech:Speech):void {
        trace("speeches length", _speeches.length, "critical speeches length", criticalSpeeches.length)
        aAlarm = speech.alarm;
        if (aAlarm == null || (AlarmHandler.instance.alertsContainer.length > 0 && !aAlarm.isInAlert() && aAlarm.isInInfo() && speech.severity != Speech.ONTIMEINFO)) {
            return;
        }
        if (_actualPlay != null && (getTimer() - _actualPlay._playStartTime) > 5000) {
            _actualPlay.stop();
            SoundMixer.stopAll();
            _nowPlaying = false;
        }
        //csak akkor adjuk hozza ujra ha nem reinfo es nem nodata
        if (speech.severity === Speech.NODATA || speech.severity === Speech.REINFO || AlarmHandler.instance.alertsContainer.length > 0) {
            for (var i:int = 0; i < _speeches.length; i++) {
                if (_speeches[i].alarm === speech.alarm) {
                    if (_speeches.length > 0) {
                        playSpeeches()
                    }
                    return;
                }
            }
        }
        if (((aAlarm.isInAlert() && aAlarm.isValid) || speech.severity === Speech.NODATA) && aAlarm.enabled) {
            openAlarmWindows();
        }

        speech.addEventListener("speechReady", speechPlayReady, false, 0, true)
        if (speech.severity == Speech.CRITICAL && speech.alarm.isValidValue()) {
            if (_actualPlay != null && _actualPlay.severity != Speech.CRITICAL) {
                _actualPlay.stop();
                SoundMixer.stopAll();
                _nowPlaying = false;
            } else
                var hasSameCritical:Boolean = false;
            for (var i:int = 0; i < criticalSpeeches.length; i++) {
                if (criticalSpeeches[i].alarm === speech.alarm) {
                    hasSameCritical = true;
                    break;
                }
            }
            if (!hasSameCritical) {
                criticalSpeeches.push(speech)
            }
            playCriticalSpeech();
            return;
        } else if (speech.severity == Speech.WARNING) {
            _speeches.unshift(speech);
        } else {
            _speeches.push(speech);
        }
        playSpeeches();
    }

    private function playCriticalSpeech():void {
        if (!_nowPlaying) {
            _nowPlaying = true;
            _actualPlay = (criticalSpeeches.shift() as Speech);
            _actualPlay.startPlay();
        }
    }

    private function playSpeeches():void {
        if (!_nowPlaying && criticalSpeeches.length === 0) {
            _actualPlay = (_speeches.shift() as Speech)
            if (_actualPlay != null) {
                _nowPlaying = true;
                _actualPlay.startPlay();
            }
        } else if (criticalSpeeches.length > 0) {
            playCriticalSpeech();
        }
    }

    private function speechPlayReady(e:Event):void {
        _nowPlaying = false;
        playSpeeches();
    }


    public static function get instance():SpeechHandler {
        if (_instance == null) {
            _instance = new SpeechHandler();
        }
        return _instance;
    }


    public function get lastAlarmUID():String {
        return _lastAlarmUID;
    }

    public function set lastAlarmUID(value:String):void {
        _lastAlarmUID = value;
    }

    public function stopAll():void {
        _speeches = new <Speech>[];
        SoundMixer.stopAll();
    }

    public function get nowPlaying():Boolean {
        return _nowPlaying;
    }

    public function set nowPlaying(value:Boolean):void {
        if (value) {
            AlarmHandler.instance.stopAlertBeep()
        }
        _nowPlaying = value;
    }

    private function openAlarmWindows():void {
        try {
            if (getTimer() > 5000 && (AppProperties.alarmWindow == null || AppProperties.alarmWindow.closed)) {
                AppProperties.openAlarmWindow();
                AppProperties.alarmWindow.selectActiveAlarms()
            }
        } catch (e:Error) {

        }
    }


    public function get speeches():Vector.<Speech> {
        return _speeches;
    }
}
}
