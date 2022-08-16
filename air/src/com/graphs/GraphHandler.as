package com.graphs {

import com.events.UnitChangedEvent;
import com.layout.Layout;
import com.layout.LayoutHandler;
import com.sailing.SailData;
import com.sailing.WindowsHandler;
import com.sailing.combinedDataHandlers.CombinedDataHandler;
import com.sailing.datas.BaseSailData;
import com.sailing.units.Unit;
import com.sailing.units.UnitHandler;
import com.utils.GraphDataHandler;

import components.graph.IGraph;
import components.graph.custom.GraphInstance;

//import components.graph.GraphInstanceAs;

public class GraphHandler {
    private static var _instance:GraphHandler;
    private var _listeners:Object = {};
    private var _graphDataHandler:GraphDataHandler;
    private var _hasAnyTimestampCached:Boolean = false;
    private var _containers:Object = {};
    private var _minTimestamp:Number = 0;
    private var _maxTimestamp:Number = 0;
    private var _lastTimestamp:Number = 0;
    public static var emptySailData:SailData = new SailData();


    public function GraphHandler() {
        //testDataForDataContainer();
        if (_instance != null) {
            throw new Error("Singleton can only be accessed through Singleton.instance");
        } else {
            _instance = this;
            graphDataHandler = new GraphDataHandler();
            YDatas.initYDatas()
            var k:String;
            var sk:String
            var ssk:String;
            for (var i:int = 0; i < YDatas.datas.length; i++) {
                k = YDatas.datas[i].dataKey;
                sk = k.split("_")[0];
                ssk = k.split("_")[1];
                createDataContainer(sk, ssk, k);
            }
            UnitHandler.instance.addEventListener(UnitChangedEvent.CHANGE, unit_changed_eventHandler, false, 0, true);
        }
    }

    private function createDataContainer(sk:String, ssk:String, k:String):void {
        if (_containers[sk] == null) {
            _containers[sk] = {}
        }
        _containers[sk][ssk] = new GraphDataContainer(k);
        (_containers[sk][ssk] as GraphDataContainer).listeners = _listeners;
    }

    var key:String;
    var data:BaseSailData
    var _sContainer:Object;
    var hasZda:Boolean = false;

    public function addLiveData(sdata:Object, timestamp:Number):void {

        if (timestamp < _lastTimestamp && Math.abs(_lastTimestamp - timestamp) > 12000) {
            if (Math.abs(_lastTimestamp - timestamp) > 120000) {
                resetAllGraphs();
            }
            return;
        }
        _lastTimestamp = timestamp;
        if (SailData.actualSailData.zda.lastTimestamp > 0 && !hasZda) {
            resetAllGraphs();
            hasZda = true;
        }
        if (_minTimestamp === 0) {
            _minTimestamp = timestamp - 60 * 10 * 1000;
        }

        _maxTimestamp = timestamp;
        if (_maxTimestamp - _minTimestamp > GraphDataContainer.MAX_TIME) {
            _minTimestamp = _maxTimestamp - GraphDataContainer.MAX_TIME;
            notifyListenersMinTimestampChanged();
        }

        var couldContinue:Boolean = false;
        key = sdata.key;
        for (var j:int = 0; j < YDatas.keys.length; j++) {
            if (YDatas.keys[j] == key) {
                couldContinue = true;
                break;
            }
        }
        if (!couldContinue) {
            return;
        }
        data = sdata.data;
        _sContainer = _containers[key];
        for (var sskey:String in _sContainer) {
            (_sContainer[sskey] as GraphDataContainer).addLiveData(new GraphData(timestamp, (data[sskey] is Unit ? data[sskey].getPureData() : data[sskey])));
        }
        notifyEmptyGraphsToUpdateTime(key);
    }

    private function notifyListenersMinTimestampChanged():void {
        for (var key:String in listeners) {
            var charts:Array = listeners[key];
            for each(var chart:GraphInstance in charts) {
                chart.minTimeChange();
            }
        }
    }

    public function notifyAllEmptyGraphsToRefreshTimeline():void {
        notifyEmptyGraphsToUpdateTime("");
    }

    internal function notifyEmptyGraphsToUpdateTime(excludeKey:String):void {
        for (var key:String in listeners) {
            if (key == excludeKey) {
                continue;
            }
            var charts:Array = listeners[key];
            for each(var chart:GraphInstance in charts) {
                chart.updateTimeIfEmpty();
            }
        }
    }

    public function get graphDataHandler():GraphDataHandler {
        return _graphDataHandler;
    }

    public function set graphDataHandler(value:GraphDataHandler):void {
        _graphDataHandler = value;
    }

    public function get listeners():Object {
        return _listeners;
    }

    public function set listeners(value:Object):void {
        _listeners = value;
        var k:String;
        var sk:String
        var ssk:String;
        for (var i:int = 0; i < YDatas.datas.length; i++) {
            k = YDatas.datas[i].dataKey;
            sk = k.split("_")[0];
            ssk = k.split("_")[1];
            (_containers[sk][ssk] as GraphDataContainer).listeners = _listeners;
        }

    }

    public function addListener(key:String, chartObject:IGraph) {

        if (listeners[key] == null) {
            listeners[key] = [];
        }
        var hasChart:Boolean = false
        for (var i:int = 0; i < listeners[key].length; i++) {
            if (listeners[key][i] === chartObject) {
                hasChart = true;
                break;
            }
        }
        if (!hasChart) {
            listeners[key].push(chartObject);
        }

        chartObject.updateDp();
        if (WindowsHandler.instance.isSocketDatasource()) {
            chartObject.setMarkerLabelAndScrollToEndInLiveMode();
        } else {
            var sKey:Array = key.split("_")
            var value:Number = (_containers[sKey[0]][sKey[1]] as GraphDataContainer).getDataForTimestamp(timeLineMarkerTime)//
            chartObject.setMarkerTimeFromTimeline(timeLineMarkerTime, value);
        }
    }


    public var timeLineMarkerTime:Number = 0;

    public function updateAllMarker(timelineMarkerTime:Number):void {
        this.timeLineMarkerTime = timelineMarkerTime;
        for (var key:String in listeners) {
            var charts:Array = listeners[key];
            var sKey:Array = key.split("_")
            var value:Number = (_containers[sKey[0]][sKey[1]] as GraphDataContainer).getDataForTimestamp(timelineMarkerTime)//
            //var value2:Number = _graphDataHandler.getMarkerData(key, this.timeLineMarkerTime);
//            trace("bsearch key: ", value, " sqlkey", value2);

            for each(var chart:IGraph in charts) {
                chart.setMarkerTimeFromTimeline(timelineMarkerTime, value);
            }
        }
    }


    public function removeListener(key:String, chartObject:*):void {
        var lListeners:Array = listeners[key];
        if (lListeners) {
            for (var i:int = 0; i < lListeners.length; i++) {
                var current = lListeners[i];
                if (current === chartObject) {
                    lListeners.splice(i, 1);
                    break;
                }
            }
        }
    }


    /**
     *
     *   this method called from when graphdatahandler log file changed,
     *     that file change when the user load new log, or change datasource
     *
     **/
    public function resetAllGraphs():void {
        hasAnyTimestampCached = false;
        resetContainer();
        CombinedDataHandler.instance.resetHandlerDatas(); //TImestamp valtas miatt kell ide is
        timeLineMarkerTime = 0;
        hasZda = false;
        _lastTimestamp = 0;
        _minTimestamp = 0;
        for each(var layout:Layout in LayoutHandler.instance.layoutContainer) {
            for (var key:String in layout.graphListeners) {
                var charts:Array = layout.graphListeners[key];
                for each(var chart:IGraph in charts) {
                    chart.resetGraph();
                }
            }
        }
        graphDataHandler.resetGraphDataContainers()

    }

    public function updateAllGraphsAfterLayoutActivate():void {
        var charts:Array
        for (var key:String in listeners) {
            charts = listeners[key];
            for each(var chart:IGraph in charts) {
                chart.activateAfterLayoutChange();
            }
        }
        if (!WindowsHandler.instance.isSocketDatasource()) {
            updateAllMarker(timeLineMarkerTime);
        }
    }

    private function resetContainer():void {
        var k:String;
        var sk:String
        var ssk:String;
        for (var i:int = 0; i < YDatas.datas.length; i++) {
            k = YDatas.datas[i].dataKey;
            sk = k.split("_")[0];
            ssk = k.split("_")[1];

            _containers[sk][ssk].reset();
        }

        _minTimestamp = 0;
        _maxTimestamp = 0;
    }

    public function removeAllListeners():void {
        listeners = {};
    }

    public static function get instance():GraphHandler {
        if (_instance == null)  _instance = new GraphHandler();

        return _instance;
    }


    public function set hasAnyTimestampCached(value:Boolean):void {
        _hasAnyTimestampCached = value;
    }

    public function get containers():Object {
        return _containers;
    }


    public function get minTimestamp():Number {
        return _minTimestamp;
    }

    public function get maxTimestamp():Number {
        return _maxTimestamp;
    }


    public function set minTimestamp(value:Number):void {
        _minTimestamp = value;
    }

    public function set maxTimestamp(value:Number):void {
        _maxTimestamp = value;
    }

    private function unit_changed_eventHandler(event:UnitChangedEvent):void {
        for (var key:String in listeners) {
            var charts:Array = listeners[key];
            for each(var chart:IGraph in charts) {
                chart.unitChanged();
            }
        }
    }
}
}