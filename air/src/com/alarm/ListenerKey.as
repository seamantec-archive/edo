/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.19.
 * Time: 15:08
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.events.UnitChangedEvent;
import com.sailing.units.Unit;
import com.sailing.units.UnitHandler;

public class ListenerKey {

    public var key:String;
    public var unit:String;
    public var alarmText:String;
    public var parameter:String;
    public var possibleMin:int;
//    private var _thresholdString:String;
    public var possibleMax:int;
    private var _threshold:Threshold;

    public var incFx:String;
    public var decFx:String;
    public var sfx:String;
    private var _klass:Class;
    private var _listenerParameter:Unit;
    private var _isShift:Boolean = false;
    private var _explicitThreshold:ThresholdString;
    //hogy kikeruljuk a duplikalt feliratkozasokat, pl mtw-t ketszer feliratkoztajuk akkor rossz erteket kapunk
    private var foundOtherKey:Boolean = false;
    public static var unitChangedListeners:Vector.<String>

    public function ListenerKey(options) {
        if (unitChangedListeners == null) {
            unitChangedListeners = new <String>[];
        }
        _threshold = new Threshold();
        if (options["klass"] is Class) {
            this._klass = options["klass"];
            this.key = (this._klass as Class).toString().replace(/(class\s)|(\[)|(\])/g, "").toLowerCase()
        } else {
            this.key = options["klass"];
        }
        this.parameter = options["parameter"];
        this.alarmText = options["alarmText"];
        if (this._klass != null && options["unit"] == null) {
            var tempListener:* = new _klass()[this.parameter];
            _listenerParameter = (tempListener is Unit ? tempListener : new Unit());
        } else if (options["unit"] != null) {
            _listenerParameter = options["unit"];
        } else {
            _listenerParameter = new Unit();
        }
        this.incFx = options["incFx"];
        this.decFx = options["decFx"];
        this.sfx = options["sfx"];
        this._isShift = options["shift"] != null ? options["shift"] : false;
        this._explicitThreshold = options["explicitThreshold"] != null ? new ThresholdString(options["explicitThreshold"]) : null;
        setParametersFromUnit();
        for (var i:int = 0; i < unitChangedListeners.length; i++) {
            if (key + parameter === unitChangedListeners[i]) {
                foundOtherKey = true;
                break;
            }
        }
        if (!foundOtherKey) {
            unitChangedListeners.push(key + parameter);
        }
        UnitHandler.instance.addEventListener(UnitChangedEvent.CHANGE, unitChangeEvent, false, 0, true)


    }

    private function setParametersFromUnit():void {
        this.unit = _listenerParameter.getUnitStringForAlarm();
        if (!_isShift) {
            this._threshold.thresholdString = _listenerParameter.getThreshold();
            this.possibleMax = (("getAlarmMax" + this.key) in _listenerParameter ? _listenerParameter["getAlarmMax" + this.key]() : _listenerParameter.getAlarmMax());
            this.possibleMin = (("getAlarmMin" + this.key) in _listenerParameter ? _listenerParameter["getAlarmMin" + this.key]() : _listenerParameter.getAlarmMin());
        } else {
            this._threshold.thresholdString = _listenerParameter.getThreshold();
            this.possibleMax = (("getAlarmMax" + this.key + "_shift") in _listenerParameter ? _listenerParameter["getAlarmMax" + this.key + "_shift"]() : _listenerParameter.getAlarmMax());
            this.possibleMin = (("getAlarmMin" + this.key + "_shift") in _listenerParameter ? _listenerParameter["getAlarmMin" + this.key + "_shift"]() : _listenerParameter.getAlarmMin());
        }
        if (_explicitThreshold != null) {
            this._threshold.thresholdString= _explicitThreshold;
        }
        _threshold.parseThresholdStrings();
    }

    public function getThreshold(actualValue:Number, level:uint):Number {
         return _threshold.getThreshold(actualValue, level);
    }

    private function unitChangeEvent(event:UnitChangedEvent):void {
        setParametersFromUnit();
        if (listenerParameter is event.typeKlass && !foundOtherKey) {
            AlarmHandler.instance.unitChangedForKey(key, event.typeKlass);
        }
    }


    public function get listenerParameter():Unit {
        return _listenerParameter;
    }

    public function get klass():Class {
        if (_klass != null) {
            return _klass;
        } else {
            return Unit;
        }
    }


    public function get threshold():Threshold {
        return _threshold;
    }
}
}
