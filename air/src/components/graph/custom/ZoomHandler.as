/**
 * Created by pepusz on 2014.07.21..
 */
package components.graph.custom {
import com.sailing.WindowsHandler;

import flash.events.TimerEvent;
import flash.utils.Timer;

public class ZoomHandler {
    public static const ONE_MIN_ZLEVEL:int = 0;
    public static const FIVE_MIN_ZLEVEL:int = 1;
    public static const FIFTEEN_MIN_ZLEVEL:int = 2;
    public static const THIRTY_MIN_ZLEVEL:int = 3;
    public static const ONE_HOUR_ZLEVEL:int = 4;
    public static const TWO_HOUR_ZLEVEL:int = 5;
    public static const SIX_HOUR_ZLEVEL:int = 6;
    public static const TWELVE_HOUR_ZLEVEL:int = 7;
    public static const TWENTYFOUR_HOUR_ZLEVEL:int = 8;
    public static const FULL_ZLEVEL:int = -1;
    public static const HOUR:int = 60 * 60 * 1000;
    public static const MIN:int = 60 * 1000;
    public static const MIN_TIMEDIST:int = 15 * MIN;


    protected var _zoomLevel:int = FIFTEEN_MIN_ZLEVEL;
    private var _zoomRatio:Number = 0;
    private var _minTime:Number = 0;
    private var _maxTime:Number = 0;
    private var _graphVisiblePixels:int = 0; //width or height
    protected var _possibleMaxZoomLevel:int = FIFTEEN_MIN_ZLEVEL;
    protected var _graphInstance:GraphInstance;
    private var _canZoomIn:Boolean = false;
    private var _canZoomOut:Boolean = false;
    private var _wasUserInteraction:Boolean = false;
    protected var scaleTimer:Timer = new Timer(300);
    protected var scaleCounter:int = 0;


    public function ZoomHandler(graphInstance:GraphInstance) {
        this._graphInstance = graphInstance;
        scaleTimer.addEventListener(TimerEvent.TIMER, scaleTimer_timerHandler, false, 0, true);

        initTime();
        calculateZoomRation();
    }

    internal function initTime():void {
        _maxTime = new Date().time;
        minTime = _maxTime - 15 * MIN;
    }

    private function calculateZoomRation():void {
        _zoomRatio = getZoomRatioFromZoomLevel();
        setPossibleMaxZoomLevel()
        setCanZoomIn();
        setCanZoomOut();
        _graphInstance.zoomRatioChanged();
    }

    internal function setFullZoom():void {
        _zoomLevel = FULL_ZLEVEL;
        calculateZoomRation();

    }

    internal function setFullZoomIfNoUserInteraction():void {
        if (!_wasUserInteraction) {
            if (WindowsHandler.instance.isSocketDatasource()) {
                _zoomLevel = FIFTEEN_MIN_ZLEVEL;
            } else {
                _zoomLevel = FULL_ZLEVEL;
            }
            calculateZoomRation();
        }
    }


    public function getZoomLabelText():String {
        switch (_zoomLevel) {
            case ZoomHandler.ONE_MIN_ZLEVEL:
                return "1 min";
            case ZoomHandler.FIVE_MIN_ZLEVEL:
                return  "5 min";
            case ZoomHandler.FIFTEEN_MIN_ZLEVEL:
                return  "15 min";
            case ZoomHandler.THIRTY_MIN_ZLEVEL:
                return  "30 min";
            case ZoomHandler.ONE_HOUR_ZLEVEL:
                return  "1 hour";
            case ZoomHandler.TWO_HOUR_ZLEVEL:
                return  "2 hour";
            case ZoomHandler.SIX_HOUR_ZLEVEL:
                return  "6 hour";
            case ZoomHandler.TWELVE_HOUR_ZLEVEL:
                return  "12 hour";
            case ZoomHandler.TWENTYFOUR_HOUR_ZLEVEL:
                return  "24 hour";
            case ZoomHandler.FULL_ZLEVEL:
                return  "Full (" + Math.round(((timeDistance()) / 60000)) + " min)";
        }
        return "";
    }

    protected function setPossibleMaxZoomLevel():void {
        var minmaxDist:Number = timeDistance() / MIN; //in min
        if (minmaxDist >= (24 * 60 )) {
            _possibleMaxZoomLevel = TWENTYFOUR_HOUR_ZLEVEL;
        } else if (minmaxDist >= (12 * 60 )) {
            _possibleMaxZoomLevel = TWELVE_HOUR_ZLEVEL;
        } else if (minmaxDist >= (6 * 60 )) {
            _possibleMaxZoomLevel = SIX_HOUR_ZLEVEL;
        } else if (minmaxDist >= (2 * 60 )) {
            _possibleMaxZoomLevel = TWO_HOUR_ZLEVEL;
        } else if (minmaxDist >= ( 60 )) {
            _possibleMaxZoomLevel = ONE_HOUR_ZLEVEL;
        } else if (minmaxDist >= (30 )) {
            _possibleMaxZoomLevel = THIRTY_MIN_ZLEVEL;
        } else if (minmaxDist >= (15 )) {
            _possibleMaxZoomLevel = FIFTEEN_MIN_ZLEVEL;
        } else if (minmaxDist >= (5 )) {
            _possibleMaxZoomLevel = FIVE_MIN_ZLEVEL;
        } else {
            _possibleMaxZoomLevel = ONE_MIN_ZLEVEL;
        }

//        if (_zoomLevel > _possibleMaxZoomLevel) {
//            _zoomLevel = _possibleMaxZoomLevel;
//            _zoomRatio = getZoomRatioFromZoomLevel();
//        }
    }

    private function getZoomRatioFromZoomLevel():int {
        return getZoomLevelForValue(_zoomLevel);
    }

    public function getZoomLevelForValue(value:int):int {
        switch (value) {
            case ONE_MIN_ZLEVEL:
                return MIN / _graphVisiblePixels;
            case FIVE_MIN_ZLEVEL:
                return( 5 * MIN ) / _graphVisiblePixels;
            case FIFTEEN_MIN_ZLEVEL:
                return (15 * MIN) / _graphVisiblePixels;
            case THIRTY_MIN_ZLEVEL:
                return (30 * MIN) / _graphVisiblePixels;
            case ONE_HOUR_ZLEVEL:
                return (HOUR) / _graphVisiblePixels;
            case TWO_HOUR_ZLEVEL:
                return (2 * HOUR) / _graphVisiblePixels;
            case SIX_HOUR_ZLEVEL:
                return (6 * HOUR) / _graphVisiblePixels;
            case TWELVE_HOUR_ZLEVEL:
                return (12 * HOUR) / _graphVisiblePixels;
            case TWENTYFOUR_HOUR_ZLEVEL:
                return (24 * HOUR) / _graphVisiblePixels;
            case FULL_ZLEVEL:
                return timeDistance() / _graphVisiblePixels
        }
        return 100;
    }

    internal function timeDistance():Number {
        return _maxTime - _minTime
    }

    internal function zoomIn():void {
        if (_canZoomIn) {
            if (_zoomLevel > 0) {
                _zoomLevel--;
            } else if (_zoomLevel === FULL_ZLEVEL) {
                _zoomLevel = _possibleMaxZoomLevel;
            }
            calculateZoomRation()
            resetStartScaleTimerAndScaleGraph();
            _wasUserInteraction = true;
        }
    }


    internal function zoomOut():void {
        if (_canZoomOut) {
            if (_zoomLevel < _possibleMaxZoomLevel) {
                _zoomLevel++;
            } else if (!WindowsHandler.instance.isSocketDatasource()) {
                _zoomLevel = FULL_ZLEVEL;
            }
            calculateZoomRation()
            resetStartScaleTimerAndScaleGraph();
            _wasUserInteraction = true;
        }
    }

    private function setCanZoomIn():void {
        if (_zoomLevel > 0 || (!WindowsHandler.instance.isSocketDatasource() && _zoomLevel == FULL_ZLEVEL)) {
            _canZoomIn = true;
        } else {
            _canZoomIn = false;
        }
    }

    private function setCanZoomOut():void {
        if (WindowsHandler.instance.isSocketDatasource()) {
            if (_zoomLevel < _possibleMaxZoomLevel) {
                _canZoomOut = true;
            } else {
                _canZoomOut = false;
            }
        } else {
            if (_zoomLevel == FULL_ZLEVEL) {
                _canZoomOut = false;
            } else {
                _canZoomOut = true;
            }
        }
    }


    public function setZoomLevelByZoomRatio(ratio:int):void {
        var aRatio:int = 0;
        for (var i:int = 0; i < FULL_ZLEVEL; i++) {
            aRatio = getZoomLevelForValue(i);
            if (aRatio > ratio) {
                _zoomLevel = i - 1;
                break;
            }
        }
//        _graph.zoomRatio = getZoomRatioFromZoomLevel();
    }

    public function reset():void {
        initTime();
        _zoomLevel = FIFTEEN_MIN_ZLEVEL;
        _possibleMaxZoomLevel = FIFTEEN_MIN_ZLEVEL;
        _wasUserInteraction = false;
        calculateZoomRation();
        //TODO
    }

    public function get zoomLevel():int {
        return _zoomLevel;
    }

    public function set zoomLevel(value:int):void {
        _zoomLevel = value;
    }


    public function get graphVisiblePixels():int {
        return _graphVisiblePixels;
    }

    public function set graphVisiblePixels(value:int):void {
        _graphVisiblePixels = value;
        calculateZoomRation();
        //TODO recalculate values
    }


    public function get zoomRatio():Number {
        return _zoomRatio;
    }


    public function get minTime():Number {
        return _minTime;
    }

    public function set minTime(value:Number):void {
        _minTime = value;
        if (_maxTime != 0) {
            calculateZoomRation();
        }
    }

    public function get maxTime():Number {
        return _maxTime;
    }

    public function set maxTime(value:Number):void {
        _maxTime = value;
        if (_minTime != 0) {
            calculateZoomRation()
        }
    }

    public function setMinMaxTime(min:Number, max:Number):void {
        _minTime = min;
        _maxTime = max;
        setMinTimeIfLessThanMinDist();
        calculateZoomRation();
    }

    internal function setMinTimeIfLessThanMinDist():void {
        if (timeDistance() < MIN_TIMEDIST) {
            minTime = _maxTime - MIN_TIMEDIST;
        }
    }


    internal function resetStartScaleTimerAndScaleGraph():void {
        _graphInstance.scaleGraph()
        scaleTimer.reset();
        if (!scaleTimer.running) {
            scaleTimer.start();
        }
        scaleCounter++;
        if (scaleCounter > 20) {
            scaleCounter = 0;
            _graphInstance.finishZoom();
        }
    }

    protected function scaleTimer_timerHandler(event:TimerEvent):void {
        scaleTimer.stop();
        scaleCounter = 0;
        _graphInstance.finishZoom();
    }


    public function get canZoomIn():Boolean {
        return _canZoomIn;
    }

    public function get canZoomOut():Boolean {
        return _canZoomOut;
    }
}
}
