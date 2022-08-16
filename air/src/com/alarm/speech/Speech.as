/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.18.
 * Time: 16:11
 * To change this template use File | Settings | File Templates.
 */
package com.alarm.speech {
import com.alarm.Alarm;
import com.alarm.AlarmHandler;
import com.alarm.SystemAlarm;
import com.alarm.soundfx.FxContainer;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.utils.getTimer;

public class Speech extends EventDispatcher {
    public static const NODATA:int = -3;
    public static const ONTIMEINFO:int = -2;
    public static const REINFO:int = -1;
    public static const INFO:int = 0;
    public static const WARNING:int = 1;
    public static const CRITICAL:int = 2;

    private var _sounds:Array = []
    private var beforeText:String;
    private var soundChannel:SoundChannel;
    private var _severity:int;
    private var createdAt:int;
    private var _alarm:Alarm;
    public var _playStartTime:Number;

    public function Speech(alarm:Alarm, severity:int = INFO) {
        this._alarm = alarm;
        createdAt = getTimer();
        this.beforeText = alarm.listenerKey.alarmText;
        this._severity = severity;
    }

    private function addSegmentToSound(sound:Sound):void {
        if (sound != null) {
            _sounds.push(sound)
        }
    }


    public function processNumber(number:String):void {
        if (number.indexOf(".") >= 0) {
            var sNumber:Array = number.split(".");
            var digits:String = sNumber[1];
            if (digits > 2) {
                digits = digits.substr(0, 2);
                if (digits.charAt(1) == "0") {
                    digits = digits.substr(0, 1);
                }
            }

            processNumber(digits);
            processText("point");
            processNumber(sNumber[0]);
            return;
        }
        if (number.length <= 2) {
            processDecimal(number);
            if (number.match("-")) {
                processText("minus");
            }
        } else if (number.length == 3) {
            if (number.charAt(1) != "0" || number.charAt(2) != "0") {
                processDecimal(number.charAt(1) + number.charAt(2));
            }
            addSegmentToSound(SpeechContainer.container[number.charAt(0) + "00"] as Sound);
            if (number.match("-")) {
                processText("minus");
            }
        }

    }

    private function processDecimal(number:String):void {
        var n:Number = new Number(number);
        if (n <= 20 || n % 10 == 0) {
            //TODO refactor ez igy elegge csunya
            addSegmentToSound(SpeechContainer.container[new Number(number) + ""] as Sound);
            return;
        }

        if (number.length == 2) {
            addSegmentToSound(SpeechContainer.container[number.charAt(1)] as Sound);
            addSegmentToSound(SpeechContainer.container[number.charAt(0) + "0"] as Sound);
        }
    }

    private function processText(text:String):void {
        //TODO ha szukseges akkor meg itt is szet tudjuk szedni a stringet es utanna osszerakva ujra megneznihogy
        addSegmentToSound(SpeechContainer.container[text.split(/\s/).join("")] as Sound);

    }

    public function customStart():void {
        play();
    }

    internal function isAlarmValidValue():Boolean {
        return (_severity == REINFO && (alarm.isInAlert() || alarm.isInInfo())) || (_severity == ONTIMEINFO && alarm.isValid) || _alarm.isValidValue() || _severity == NODATA;
    }

    internal function generateSpeechText():void {
        //said less then 2 sec
        if (!_alarm.validateLastSaid()) {
            return;
        }
        var prevAlarmUid:String = SpeechHandler.instance.lastAlarmUID;
        var isSystemAlarm:Boolean = false;
        if (_alarm is SystemAlarm) {
            isSystemAlarm = true;
            (_alarm as SystemAlarm).lastSaidTime = getTimer();
        }

        //generate number for system alarm and nodata alarm doesn't need number
        if (!isSystemAlarm && _severity != NODATA) {
            processText(alarm.listenerKey.unit);
            //nem ismetlesnel a legkozelebbire kerekitunk
            if (_severity != REINFO) {
                if (alarm.isDecrease) {
                    alarm.lastSaidValue = alarm.getRoundedUpValue();
                } else {
                    alarm.lastSaidValue = alarm.getRoundedDownValue();
                }
                processNumber(alarm.lastSaidValue.toString());
            } else {
                if (alarm.lastThreshold > 1) {
                    processNumber(Math.round(alarm.actualValue) + "")
                } else {
                    processNumber(Math.round(alarm.actualValue * 100) / 100 + "");
                }
            }
        }

        if (_severity === NODATA) {
            processText("not valid");

        }

        //generate before text
        if (alarm.isInAlert() || _alarm.validateLastSaidPreText() || prevAlarmUid != alarm.toString() || _severity === NODATA) {
            processText(beforeText);
        }
        if (hasAnySound()) {
            SpeechHandler.instance.lastAlarmUID = alarm.toString();
        }
    }

    private function hasAnySound():Boolean {
        return _sounds.length > 0;
    }

    internal function generateSpeechSfx():void {
        if (!hasAnySound()) {
            return;
        }
        //play beep
        if (_alarm.isInAlert() && _severity != NODATA) {
            if (_alarm.listenerKey.sfx != null) addSegmentToSound(FxContainer.container[_alarm.listenerKey.sfx]);
        } else if (_alarm.isInInfo() && _severity >= REINFO) {
            if (_alarm.isDecrease && _alarm.listenerKey.decFx != "") {
                addSegmentToSound(FxContainer.container[_alarm.listenerKey.decFx])
            } else if (_alarm.listenerKey.incFx != "") {
                addSegmentToSound(FxContainer.container[_alarm.listenerKey.incFx])
            }
        }
    }

    public function startPlay():void {
        if (_alarm === null) {
            dispatchEvent(new Event("speechReady"))
            return;
        }
        _playStartTime = getTimer();
        if (isAlarmValidValue() && _alarm.enabled) {
            generateSpeechText()
            generateSpeechSfx()
            if (hasAnySound()) AlarmHandler.instance.lastSaidTime = getTimer();
            play();

        } else {
            dispatchEvent(new Event("speechReady"));
        }

    }

    public function stop():void {
        try {
            actualSound.close();
        } catch (e:Error) {

        }
        _sounds.length = 0;
    }

//    private function generateSpeeches(alarm:Alarm):Boolean {
//        var prevalarmUid:String = SpeechHandler.instance.lastAlarmUID;
//        var isSystemAlarm:Boolean = false;
//        if (alarm is SystemAlarm) {
//            isSystemAlarm = true;
//            (alarm as SystemAlarm).lastSaidTime = getTimer();
//        }
//        if (alarm.validateLastSaid() && _severity != NODATA) {
//            if (_severity != REINFO) {
//                if (alarm.isDecrease) {
//                    alarm.lastSaidValue = alarm.getRoundedUpValue();
//                } else {
//                    alarm.lastSaidValue = alarm.getRoundedDownValue();
//                }
//            }
//            trace("said ", alarm.listenerKey.key, ".", alarm.listenerKey.parameter, " ", alarm.actualValue, "rouded " + alarm.lastSaidValue)
//            if (!isSystemAlarm && _severity != NODATA) {
//                processText(unit);
//                if (_severity != REINFO) {
//                    processNumber(alarm.lastSaidValue + "");
//                } else {
//                    if (alarm.lastThreshold > 1) {
//                        processNumber(Math.round(alarm.actualValue) + "")
//                    } else {
//                        processNumber(Math.round(alarm.actualValue * 100) / 100 + "");
//                    }
//                }
//            }
//            if ((prevalarmUid != alarm.toString() || alarm.validateLastSaidPreText() || alarm.isInAlert()) && _severity != NODATA) {
//                processText(beforeText);
//            }
//
//            SpeechHandler.instance.lastAlarmUID = alarm.toString();
//            return true;
//        } else if (_severity === NODATA && prevalarmUid != alarm.toString() && alarm.validateLastSaid()) {
//            processText(unit);
//            processText(beforeText);
//            SpeechHandler.instance.lastAlarmUID = alarm.toString();
//            return true;
//        }
//        return false;
//    }

    var actualSound:Sound;

    public function play():void {
        if (_sounds.length == 0) {
            _sounds = [];
            dispatchEvent(new Event("speechReady"))
            return;
        }
        _alarm.updateLastSystemTimestamp();
        actualSound = _sounds.pop();
        if (actualSound == null) {
            play()
            return;
        }
        soundChannel = (actualSound as Sound).play();
        soundChannel.addEventListener(Event.SOUND_COMPLETE, function (event:Event) {
            play()
        }, false, 0, true)
    }


    public function get severity():int {
        return _severity;
    }


    public function get sounds():Array {
        return _sounds;
    }

    public function get alarm():Alarm {
        return _alarm;
    }


}
}
