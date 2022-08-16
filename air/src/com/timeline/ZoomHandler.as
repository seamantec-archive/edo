package com.timeline {

import com.graphs.GraphHandler;
import com.loggers.LogEntry;
import com.loggers.LogRegister;

import flash.display.Sprite;
import flash.events.Event;

public class ZoomHandler extends Sprite {
    private var _zoomLevel:Number = 1; //1-100 in percent
    private var _minTime:Number; //possible minTime
    private var _maxTime:Number; //possible max time
    private var _actualSegment:Segment;
    private var _actualMin:Number;
    private var _actualMax:Number;
    private var _actualDistance:Number;
    private var _segments:Vector.<Segment>;
    private var _marker:Marker;
    private var _maxLoadedTime:Number;
    private var _zoomResolution:Number;
    private var _pixelResolution:Number;
    private var _tickSpaceId:Number; //a feliratok tavolsaganak a meghatarozasara szolgal. 0: 12 oras, 1: 6 oras, 2: 3h, 3:1,5 4:30min, 5: 15min,


    public static var MIN_ZOOM_DISTANCE:Number = 10 * 60 * 1000;//10min
    private var _statusBarX:int;
    private var _statusBarWidth:Number;
    private var _statusBarMarkerX:Number;

    private var timelineLenght:Number;
    private var _zoomPlusEnabled:Boolean;
    private var _zoomMinusEnabled:Boolean;


    public function ZoomHandler(marker:Marker, timelineLenght:Number) {
        super();
        this.timelineLenght = timelineLenght;
        this.zoomLevel = 1;
        this.marker = marker;
        this.segments = new Vector.<Segment>();
        _statusBarWidth = 0;
    }



    public function refreshFullSegmentList(logEntry:LogEntry):void {
        if (logEntry == null) {

        }
        segments = new Vector.<Segment>();
        var filename:String = logEntry.name;
        var segmentsNumber:Number = logEntry.maxNumberOfSegments;
        var loadedSegments:Vector.<Segment> = LogRegister.instance.getSegments(logEntry.id);
        segmentsNumber -= loadedSegments.length;

        minTime = logEntry.firstTimestamp;
        for (var i:int = 0; i < loadedSegments.length; i++) {
            var segment:Segment = loadedSegments[i];
            if (segment.maxTime != 0) {
                segment.inited = true;
                segments.push(segment);
            } else {
                segmentsNumber += loadedSegments.length - i;
                break;
            }
        }
        if (segmentsNumber == 0 && segments.length > 0) {
            maxTime = segments[segments.length - 1].maxTime;
        }
        for (var i:int = 0; i < segmentsNumber; i++) {
            var fName:String = Segment.getSegmentNameFromLogNameAndIndex(filename, i);
            var segment:Segment = new Segment(i + loadedSegments.length, fName);
            segment.minTime = -1
            segment.maxTime = -1
            segment.inited = false;
            segments.push(segment);
        }
        actualMax = maxTime;
        actualMin = minTime;
        maxTimeForLastInitedSegmentMaxTime();
        refreshZoomBtnEnabled();
        dispatchEvent(new Event("actual-distance-changed"));
    }

    public function setActualSegmantAt(position:Number):void {
        actualSegment = getSegmentAt(position);
    }

    private function getSegmentAt(position:Number):Segment {
        for (var i:int = 0; i < segments.length; i++) {
            var segment:Segment = segments[i];
            if (position == segment.index) {
                return segment;
            }
        }
        return null;
    }

    private function setSegmentAt(position:Number, newSegment:Segment):void {
        for (var i:int = 0; i < segments.length; i++) {
            if (position == segments[i].index) {
                segments[i] = newSegment;
                break;
            }
        }
    }

    private function calculateDistance():void {
        actualDistance = actualMax - actualMin;
        var calculatedZoomResolution:Object = setupZoomResolution(actualDistance);
        _zoomResolution = calculatedZoomResolution.zResolution;
        tickSpaceId = calculatedZoomResolution.tickSpaceId;
        calculateStatusBarPositions();

    }

    private function calculateStatusBarPositions():void {
        var minMaxPixelRatio:Number = (maxTime - minTime) / timelineLenght;
        statusBarX = (actualMin - minTime) / minMaxPixelRatio;
        statusBarWidthRatio = actualDistance / minMaxPixelRatio;
        stastusBarMarkerX = (marker.actualTime - minTime) / minMaxPixelRatio;
    }

    public static function setupZoomResolution(actualDistance:Number):Object {
        var returnObject:Object = {}
        returnObject.zResolution = 0;
        returnObject.tickSpaceId = 0;

        if (actualDistance >= 24 * 60 * 60 * 1000) {
            returnObject.zResolution = 12 * 60 * 60 * 1000 //12h
            returnObject.tickSpaceId = 0;
        } else if (actualDistance < 24 * 60 * 60 * 1000 && actualDistance >= 12 * 60 * 60 * 1000) {
            returnObject.zResolution = 6 * 60 * 60 * 1000 //6h
            returnObject.tickSpaceId = 1;
        } else if (actualDistance < 12 * 60 * 60 * 1000 && actualDistance >= 6 * 60 * 60 * 1000) {
            returnObject.zResolution = 3 * 60 * 60 * 1000 //3h
            returnObject.tickSpaceId = 2;
        } else if (actualDistance < 6 * 60 * 60 * 1000 && actualDistance >= 3 * 60 * 60 * 1000) {
            returnObject.zResolution = 90 * 60 * 1000 //1,5h
            returnObject.tickSpaceId = 3;
        } else if (actualDistance < 3 * 60 * 60 * 1000 && actualDistance >= 1 * 60 * 60 * 1000) {
            returnObject.zResolution = 30 * 60 * 1000 //30min
            returnObject.tickSpaceId = 4;

        } else if (actualDistance < 1 * 60 * 60 * 1000 && actualDistance >= 30 * 60 * 1000) {
            returnObject.zResolution = 15 * 60 * 1000 //15min
            returnObject.tickSpaceId = 5;

        } else if (actualDistance < 30 * 60 * 1000 && actualDistance >= 10 * 60 * 1000) {
            returnObject.zResolution = 10 * 60 * 1000 //5min
            returnObject.tickSpaceId = 6;

        } else if (actualDistance < 10 * 60 * 1000 && actualDistance >= 5 * 60 * 1000) {
            returnObject.zResolution = 5 * 60 * 1000 //2.5min
            returnObject.tickSpaceId = 7;

        } else if (actualDistance < 5 * 60 * 1000 && actualDistance >= 60 * 1000) {
            returnObject.zResolution = 60 * 1000 //0,5min
            returnObject.tickSpaceId = 8;

        } else {
            returnObject.zResolution = 30 * 1000 //30sec
            returnObject.tickSpaceId = 9;
        }
        return returnObject;

    }

    public function updateSegmentStatus(index:Number, logFileId:Number):void {
        var segmentDao:Segment = LogRegister.instance.getSegment(logFileId, index);
        if (segmentDao != null) {
            segmentDao.inited = true;
            setSegmentAt(index, segmentDao);
        }
        maxTimeForLastInitedSegmentMaxTime();
    }

    private function maxTimeForLastInitedSegmentMaxTime():void {
        var prevSegment:Segment = null;
        for (var i:int = 0; i < segments.length; i++) {
            var segment:Segment = segments[i];
            if (prevSegment == null) {
                prevSegment = segment;
            }
            if (!segment.inited) {
                maxLoadedTime = prevSegment.maxTime;
                return;
            }
            prevSegment = segment;
        }
        if (prevSegment != null) {
            maxLoadedTime = prevSegment.maxTime;
        }
    }


    public function isMarkerInActualSegment():Boolean {
        return isTimeInActualSegment(marker.actualTime);
    }

    public function isTimeInActualSegment(time:Number):Boolean {
        if (_actualSegment == null) {
            return false;
        }
        if (time <= actualSegment.maxTime && time >= actualSegment.minTime) {
            return true;
        } else {
            return false;
        }
    }

    public function getSegmentForTime(time:Number):Segment {
        if (isTimeInActualSegment(time)) {
            return actualSegment;
        } else {
            for each(var segment:Segment in segments) {
                if (segment.inited && time <= segment.maxTime && time >= segment.minTime) {
                    actualSegment = segment;
                    return segment;
                }
            }
        }
        return null;
    }

    public function getSegmentForMarkerActualTime():Segment {
        return getSegmentForTime(marker.actualTime);
    }


    public function get zoomLevel():Number {
        return _zoomLevel;
    }

    public function set zoomLevel(value:Number):void {
        _zoomLevel = value;
    }

    public function increaseZoom():void {
        if (actualDistance - _zoomResolution >= 120000) {
            //noveljuk a zoom levelet azaz csokkentjuk a actualMinMaxot
            zoomChangehandler("inc");
        }
    }

    public function decreaseZoom():void {

        if (actualDistance <= (maxTime - minTime)) {
            zoomChangehandler("dec");
        }
    }

    public function isLoading():Boolean {
        if (this._maxLoadedTime < this._maxTime) {
            return true;
        } else {
            return false;
        }
    }

    private function refreshZoomBtnEnabled():void {

        if (actualDistance - _zoomResolution >= 120000 && !isLoading()) {
            zoomPlusEnabled = true;
        } else {
            zoomPlusEnabled = false;
        }
        if (actualDistance < (maxTime - minTime) && !isLoading()) {
            zoomMinusEnabled = true;
        } else {
            zoomMinusEnabled = false;
        }

    }

    private function zoomChangehandler(type:String):void {
        var timeFromMin:Number = marker.actualTime - minTime;
        var timeFromActualMin:Number = marker.actualTime - actualMin;
        var timeFromMax:Number = maxTime - marker.actualTime;
        var diffDistance:Number;

        if (type == "dec") {
            diffDistance = -2 * _zoomResolution;
        } else {
            diffDistance = 1 * _zoomResolution;

        }
        var minMaxRate:Number = timeFromMin / (maxTime - minTime);
        var actualMinMaxRate:Number = timeFromActualMin / actualDistance;
        var distToMin:Number = diffDistance * actualMinMaxRate;
        var distToMax:Number = diffDistance - distToMin;


        var newMin:Number = actualMin + distToMin;
        var newMax:Number = actualMax - distToMax;
        var newDiffFromMin:Number = minTime - newMin;
        var newDiffFromMax:Number = newMax - maxTime;


        if (newMax > maxTime) {
            newMax = maxTime;
            newMin -= newDiffFromMax;
        }

        if (newMin < minTime) {
            newMin = minTime;
            newMax += newDiffFromMin
            if (newMax > maxTime) {
                newMax = maxTime;
            }
        }

        actualMin = newMin;
        actualMax = newMax;
        if (marker.actualTime <= actualMax && marker.actualTime >= actualMin) {
            marker.calculateActulateX();
        } else {
            marker.calculateActualTime();
        }
        refreshZoomBtnEnabled();
        trace("tickSpaceId " + tickSpaceId);
        dispatchEvent(new Event("actual-distance-changed"));

    }

    public function resetActualDistance():void {
        actualMax = maxTime;
        actualMin = minTime;
        refreshZoomBtnEnabled();
        dispatchEvent(new Event("actual-distance-changed"));
    }

    public function goToBegeningOfTimelineWithoutZoomReset():void {
        var tempDist:Number = actualDistance;
        actualMin = minTime;
        actualMax = actualMin + tempDist;
        refreshZoomBtnEnabled();
        dispatchEvent(new Event("actual-distance-changed"));
    }

    public function get minTime():Number {
        return _minTime;
    }

    public function set minTime(value:Number):void {
        _minTime = value;
        GraphHandler.instance.minTimestamp = value;
    }

    public function get maxTime():Number {
        return _maxTime;
    }

    public function set maxTime(value:Number):void {
        _maxTime = value;
        GraphHandler.instance.maxTimestamp = value;
    }

    public function get actualDistance():Number {
        return _actualDistance;
    }

    public function set actualDistance(value:Number):void {
        _actualDistance = value;
    }

    public function get segments():Vector.<Segment> {
        return _segments;
    }

    public function set segments(value:Vector.<Segment>):void {
        _segments = value;
    }

    public function get marker():Marker {
        return _marker;
    }

    public function set marker(value:Marker):void {
        _marker = value;
    }

    public function get actualSegment():Segment {
        return _actualSegment;
    }

    public function set actualSegment(value:Segment):void {
        _actualSegment = value;
    }

    public function get actualMin():Number {
        return _actualMin;
    }

    public function set actualMin(value:Number):void {
        _actualMin = value;
        marker.minTime = _actualMin;
        calculateDistance()
    }

    public function get actualMax():Number {
        return _actualMax;
    }

    public function set actualMax(value:Number):void {
        _actualMax = value;
        marker.maxTime = _actualMax
        calculateDistance()
    }


    public function get maxLoadedTime():Number {
        return _maxLoadedTime;
    }

    public function set maxLoadedTime(value:Number):void {
        _maxLoadedTime = value;
        dispatchEvent(new Event("max-loaded-time-changed"));
    }

    public function get tickSpaceId():Number {
        return _tickSpaceId;
    }

    public function set tickSpaceId(value:Number):void {
        _tickSpaceId = value;
    }

    public function get statusBarX():int {
        return _statusBarX;
    }

    public function set statusBarX(value:int):void {
        _statusBarX = value;
    }

    public function get statusBarWidthRatio():Number {
        return _statusBarWidth;
    }

    public function set statusBarWidthRatio(value:Number):void {
        _statusBarWidth = value;
    }

    public function get stastusBarMarkerX():Number {
        return _statusBarMarkerX;
    }

    public function set stastusBarMarkerX(value:Number):void {
        _statusBarMarkerX = value;
    }

    public function get zoomPlusEnabled():Boolean {
        return _zoomPlusEnabled;
    }

    public function set zoomPlusEnabled(value:Boolean):void {
        _zoomPlusEnabled = value;
    }

    public function get zoomMinusEnabled():Boolean {
        return _zoomMinusEnabled;
    }

    public function set zoomMinusEnabled(value:Boolean):void {
        _zoomMinusEnabled = value;
    }


    public function get pixelResolution():Number {
        return _pixelResolution;
    }

    public function set pixelResolution(value:Number):void {
        _pixelResolution = value;
    }
}
}