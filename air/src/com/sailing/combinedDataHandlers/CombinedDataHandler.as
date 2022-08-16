/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.26.
 * Time: 18:20
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.combinedDataHandlers {
import com.events.UpdateNmeaDatasEvent;
import com.sailing.datas.BaseSailData;

import flash.events.EventDispatcher;

public class CombinedDataHandler extends EventDispatcher {
    private static var _instance:CombinedDataHandler;
    private var _listeners:Object = {};

    public function CombinedDataHandler() {
        if (_instance != null) {
            throw new Error("singleton class. Use instance");
        } else {
            addListener(new VmgCalculator());
            addListener(new VmgWindCalculator());
            addListener(new VmgWaypointCalculator());
            addListener(new MwvTHandler());
            addListener(new MwvRHandler());
            addListener(new WindSmoothCaclulator());
            addListener(new WindSmoothAppCaclulator());
            addListener(new SetAndDriftCalculator());
            addListener(new EtaCalculator());
            addListener(new TripDataCalculator());
            addListener(new PositionAndSpeedCalculator());
            addListener(new CrosstrackCalculator());
            addListener(new HeadingCalculator());
            addListener(new TrueWindCalculator());
            addListener(new ApparentWindCalculator());
            addListener(new WaterDepthCalculator());
            addListener(new OffCourseCalculator());
            addListener(new PerformanceCalculator());
        }
    }

    public function addListener(cData:CombinedData):void {
        var key:String;
        for (var i:int = 0; i < cData.listenerKeys.length; i++) {
            key = cData.listenerKeys[i];
            if (!(_listeners[key])) {
                _listeners[key] = [];
            }
            _listeners[key].push(cData);
        }

    }


    public function resetHandlerDatas():void {
        var data:CombinedData;
        for (var key:String in _listeners) {
            for (var j:int = 0; j < _listeners[key].length; j++) {
                data = _listeners[key][j] as CombinedData;
                data.reset();
            }
        }
    }


    public function updateDatas(key:String, data:BaseSailData, timestamp:Number, isLog:Boolean = false):void {
        var l:Array = _listeners[key];
        var cData:CombinedData
        if (l != null) {
            for (var i:int = 0; i < l.length; i++) {
                cData = l[i] as CombinedData;
                if (!(isLog && (cData is TripDataCalculator))) {
                    dispatchEvent(new UpdateNmeaDatasEvent({"key": cData.dataKey, data: cData.dataChanged(key, data, timestamp)}));
                }
            }
        }
    }

    public function getCombindeData(key:String):CombinedData {
        var data:CombinedData;
        for (var i:String in _listeners) {
            for (var j:int = 0; j < _listeners[i].length; j++) {
                data = _listeners[i][j] as CombinedData;
                if (data.dataKey == key) {
                    return data;
                }
            }
        }
        return null;
    }

    public static function get instance():CombinedDataHandler {
        if (_instance == null) {
            _instance = new CombinedDataHandler();
        }
        return _instance;
    }
}
}
