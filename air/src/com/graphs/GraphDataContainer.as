/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.07.09.
 * Time: 17:13
 * To change this template use File | Settings | File Templates.
 */
package com.graphs {
import com.sailing.SailData;
import com.sailing.units.Unit;
import com.utils.NBinarySearchForGraphData;

import components.graph.IGraph;

import flash.events.EventDispatcher;

public class GraphDataContainer extends EventDispatcher {
    public static const MAX_TIME:int = 12 * 60 * 60 * 1000; //2 * 60

    private var _key:String;
    private var _defMinMin:Number;
    private var _defMaxMin:Number;
    private var _defMinMax:Number;
    private var _defMaxMax:Number;
    private var _minData:Number = 0;
    private var _maxData:Number = 3;
    private var _quantalStep:int = 1;
    private var _yDataTypeContainer:Unit;
    private var _bSearch:NBinarySearchForGraphData;
    private var _dataProvider:Vector.<GraphData>;

    private var _listeners:Object = {};
    private var _lastTimestamp:Number;

    public function GraphDataContainer(key:String) {
        _dataProvider = new <GraphData>[];
        this._key = key;
        var ydata:Object = YDatas.getByData(_key);
        var splitedYData:Array = _key.split("_");
        if (SailData.actualSailData[splitedYData[0]][splitedYData[1]] is Unit) {
            _yDataTypeContainer = SailData.actualSailData[splitedYData[0]][splitedYData[1]];
        } else {
            _yDataTypeContainer = new Unit();
        }
        if (ydata != null) {
            _defMinMin = ydata.min[0];
            _defMaxMin = ydata.min[1];
            _defMinMax = ydata.max[0];
            _defMaxMax = ydata.max[1];
            _quantalStep = ydata.quantalZoom;
        }
        _bSearch = new NBinarySearchForGraphData(this);
    }

    public const TIME_OFFSET:uint = 60 * 60 * 1000;

    public function addLiveData(data:GraphData):void {
        addData(data, true);
        notifyListenersByDpChanged();
    }

    public function reset():void {
        for (var i:int = _dataProvider.length; i >= 0; i--) {
            _dataProvider[i] = null;
        }
        _dataProvider.length = 0;
        _minData = _defMinMin;
        _maxData = _defMaxMin;
    }

    public function loadDataFromLog(data:Array):void {
        var length:int = data.length;
        _dataProvider = new <GraphData>[];
        for (var i:int = 0; i < length; i++) {
            addData(new GraphData(data[i].sailDataTimestamp, data[i].data))
        }
        setFullZoom();
        notifyListeners();
    }


    private function addData(data:GraphData, isLive:Boolean = false):void {
        if (data.data === Unit.INVALID_VALUE) {
            return;
        }
        _dataProvider.push(data);
        if (isLive && (data.timestamp - _dataProvider[0].timestamp) > MAX_TIME) {  //1 data / second
            _dataProvider.shift();
        }
        if (data.data < _minData) {
            _minData = data.data;
            if (_minData % _quantalStep != 0) {
                if (_minData < 0) {
                    _minData = -1 * Math.ceil(Math.abs(_minData) / _quantalStep) * _quantalStep;
                } else {
                    _minData = Math.ceil(_minData / _quantalStep) * _quantalStep;
                }
            }
        } else if (data.data > _maxData) {
            _maxData = data.data;
            if (_maxData % _quantalStep != 0) {
                _maxData = Math.ceil(_maxData / _quantalStep) * _quantalStep
            }
        }

        if (_minData < _defMinMax) {
            _minData = _defMinMax;
        }

        if (_maxData > _defMaxMax) {
            _maxData = _defMaxMax;
        }


    }


    private function notifyListeners():void {
        var listeners:Array = _listeners[key];
        if (listeners == null) {
            return;
        }
        for (var i:int = 0; i < listeners.length; i++) {
            (listeners[i] as IGraph).updateDp();
        }
    }

    private function setFullZoom():void {
        var listeners:Array = _listeners[key];
        if (listeners == null) {
            return;
        }
        for (var i:int = 0; i < listeners.length; i++) {
            (listeners[i] as IGraph).setFullZoomForLogReplay();
        }
    }

    private function notifyListenersByDpChanged():void {
        var listeners:Array = _listeners[key];
        if (listeners == null) {
            return;
        }
        for (var i:int = 0; i < listeners.length; i++) {
            (listeners[i] as IGraph).gotNewLiveData();
        }
    }


    public function get key():String {
        return _key;
    }

    var tempUnitMin:Number

    public function get minData():Number {
        tempUnitMin = _yDataTypeContainer.convertNumber(_minData)
        if (tempUnitMin < 0) {
            return -1 * Math.ceil(Math.abs(tempUnitMin) / _quantalStep) * _quantalStep;
        } else {
            return Math.ceil(tempUnitMin / _quantalStep) * _quantalStep;
        }
    }

    public function get maxData():Number {
        return Math.ceil(_yDataTypeContainer.convertNumber(_maxData) / _quantalStep) * _quantalStep
    }


    public function get dataProvider():Vector.<GraphData> {
        return _dataProvider;
    }


    public function get yDataTypeContainer():Unit {
        return _yDataTypeContainer;
    }

    public function getDataForTimestamp(timestamp:Number):Number {
        return _bSearch.getSmallClosestValue(timestamp);
    }

    public function getGraphDataForTimestamp(timestamp:Number, from:uint, tolerance:uint):GraphData {
        return _bSearch.getSmallClosestGraphData(timestamp, from, tolerance);
    }


    public function set listeners(value:Object):void {
        _listeners = value;
    }
}
}
