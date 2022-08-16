/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.22.
 * Time: 16:01
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.minMax {
import com.events.UnitChangedEvent;
import com.graphs.GraphHandler;
import com.sailing.WindowsHandler;
import com.sailing.datas.BaseSailData;
import com.sailing.instruments.BaseInstrument;
import com.sailing.units.Unit;
import com.sailing.units.UnitHandler;
import com.utils.GeneralUtils;

import flash.events.EventDispatcher;

public class MinMaxHandler extends EventDispatcher {
    private static var _instance:MinMaxHandler;
    private static var _predefKeys:Vector.<String> = new <String>[
        "waterdepth.waterDepth",
        "waterdepth.waterDepthWithOffset",
        "truewindc.windDirection",
        "apparentwind.windDirection",
        "truewindc.windSpeed",
        "apparentwind.windSpeed",
        "mda.windSpeed",
        "mda.barometricPressure",
        "mda.airTemp",
        "mtw.temperature",
        "mwd.windDirection",
        "mwd.windSpeed",
        "rsa.rudderSensorStarboard",
        "vhw.waterSpeed",
        "vmg.waypoint",
        "vmg.wind",
        "vmgwind.wind",
        "vmgwaypoint.waypoint",
        "vwr.windSpeed",
        "vwt.windSpeed",
        "setanddrift.angleset",
        "setanddrift.drift",
        "positionandspeed.sog",
        "performance.polarSpeed"
    ];
    private var _listeners:Object = {};

    public function MinMaxHandler() {
        if (_instance != null) {
            throw new Error("this is a singleton class. use instance");
        } else {
            initListener();
            UnitHandler.instance.addEventListener(UnitChangedEvent.CHANGE, unit_changed_eventHandler, false, 0, true);
        }
    }

    //JUST FOR THE TESTCASES
    public function clear():void {
        _listeners = {};
        initListener();
    }

    private function initListener():void {
        for (var i:int = 0; i < _predefKeys.length; i++) {
            var key:String = _predefKeys[i];
            var s:Array = key.split(".");
            if (_listeners[s[0]] == null) {
                _listeners[s[0]] = {};
            }

            _listeners[s[0]][s[1]] = {global: new MinMax(undefined, undefined, null, GeneralUtils.getClass(WindowsHandler.instance.actualSailData[s[0]][s[1]])), instruments: []};

        }
    }


    public function addListener(control:Object):void {
        if (control.hasOwnProperty("minMaxVars")) {
            var s:Array

            for (var key:String in control.minMaxVars) {
                s = key.split(".");
                if (s.length != 2) {
                    continue;
                }
                if (_listeners[s[0]] != null && _listeners[s[0]][s[1]]) {
                    control.minMaxVars[key].min = _listeners[s[0]][s[1]].global.min;
                    control.minMaxVars[key].max = _listeners[s[0]][s[1]].global.max;
                    control.minMaxVars[key].unitClass = _listeners[s[0]][s[1]].global.unitClass;
                    if (!hasInstrument(_listeners[s[0]][s[1]].instruments, (control as BaseInstrument))) {
                        _listeners[s[0]][s[1]].instruments.push(control)
                    }

                }

            }
        }

    }

    private function hasInstrument(container:Array, control:BaseInstrument):Boolean {

        for (var i:int = 0; i < container.length; i++) {
            if (container[i] == control) {
                return true;
            }

        }
        return false;
    }

    public function removeListener(controll:Object):void {
        if (controll.hasOwnProperty("minMaxVars")) {
            var s:Array

            for (var key:String in controll.minMaxVars) {
                s = key.split(".");
                if (s.length != 2) {
                    continue;
                }
                if (_listeners[s[0]][s[1]] != null && _listeners[s[0]][s[1]].instruments != null) {
                    for (var i:int = 0; i < _listeners[s[0]][s[1]].instruments.length; i++) {
                        if (_listeners[s[0]][s[1]].instruments[i] == controll) {
                            _listeners[s[0]][s[1]].instruments.splice(i, 1)
                        }

                    }
                }
            }
        }

    }

    public function updateMinMax(key:String, data:BaseSailData):void {
        var l:Object = _listeners[key];
        if (l == null) {
            return;
        }

        for (var skey:String in l) {
            (l[skey].global as MinMax).setMinMaxLimit((data[skey] is Unit) ? data[skey].value : data[skey]);
            for (var i:int = 0; i < l[skey].instruments.length; i++) {
                if ((l[skey].instruments[i].minMaxVars[key + "." + skey] as MinMax).setMinMaxLimit((data[skey] is Unit) ? data[skey].value : data[skey])) {
                    try {
                        l[skey].instruments[i].minMaxChanged();
                    } catch (e:Error) {

                    }
                }
            }
        }
    }


    public static function get instance():MinMaxHandler {
        if (_instance == null) {
            _instance = new MinMaxHandler();
        }
        return _instance;
    }

    public function get listeners():Object {
        return _listeners;
    }

    private function unit_changed_eventHandler(event:UnitChangedEvent):void {
        resetAllMinMax(event.typeKlass);
        dispatchEvent(new UnitChangedEvent(event.typeKlass));
    }

    public function datasourceChanged():void {
        resetAllMinMax();
    }

    private function resetAllMinMax(unitClass:Class = null):void {
        for (var key:String in _listeners) {
            for (var skey:String in _listeners[key]) {
                var l:Object = _listeners[key][skey];
                (l.global as MinMax).reset(unitClass);
                for (var i:int = 0; i < l.instruments.length; i++) {
                    (l.instruments[i].minMaxVars[key + "." + skey] as MinMax).reset(unitClass);
                    try {
                        l.instruments[i].minMaxChanged();
                    } catch (e:Error) {

                    }
                }
            }
        }
    }

    public function updateMinMaxesFromLog(datas:Array, key:String):void {
        var x:Array = key.split(".")
        var l:Object = _listeners[x[0]];
        var s:Unit = GraphHandler.emptySailData[x[0]][x[1]] is Unit ? GraphHandler.emptySailData[x[0]][x[1]] : new Unit();
        if (l == null || datas == null) {
            return;
        }

        (l[x[1]].global as MinMax).setMinMaxLimit(s.convertNumber(datas[0].min));
        (l[x[1]].global as MinMax).setMinMaxLimit(s.convertNumber(datas[0].max));
        for (var i:int = 0; i < l[x[1]].instruments.length; i++) {
            (l[x[1]].instruments[i].minMaxVars[key] as MinMax).setMinMaxLimit(s.convertNumber(datas[0].min));
            (l[x[1]].instruments[i].minMaxVars[key] as MinMax).setMinMaxLimit(s.convertNumber(datas[0].max));
            try {
                l[x[1]].instruments[i].minMaxChanged();
            } catch (e:Error) {

            }

        }
    }


    public static function get predefKeys():Vector.<String> {
        return _predefKeys;
    }
}
}
