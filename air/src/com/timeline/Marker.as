package com.timeline {
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;

public class Marker extends Sprite {

    private var _minTime:Number;
    private var _maxTime:Number;
    private var _minX:Number;
    private var _maxX:Number;
    private var _actualTime:Number;
    private var _actualMarkerX:Number;
    private var _maxDistance:Number;
    private var _pixelDensity:Number;
    private var _lineWidth:Number;
    private var vertical:Boolean;

    private var _markerHeight:Number;

    private var lineColor:uint;
    private var marker:Shape

    public function Marker(minX:Number, markerHeight:Number, lineColor:uint = 0xFFFF00, lineWidth:Number = 4, vertical:Boolean = false) {
        super();
        this.lineColor = lineColor;
        this.markerHeight = markerHeight;
        this._lineWidth = lineWidth;
        this.minX = minX;
        this.vertical = vertical;
        marker = new Shape();
        marker.x = -lineWidth / 2;
        marker.y = 0;
        actualMarkerX = minX;
        actualTime = 0;
        drawMarker();
        this.addChild(marker)

//        this.depth = 1000;
        if (vertical) {
            this.y = minX
        } else {
            this.x = minX;
        }
    }

    private function drawMarker():void {
        marker.graphics.clear();
        marker.graphics.lineStyle(_lineWidth, lineColor);
        if (!vertical) {
            marker.graphics.moveTo(0, 0);
            marker.graphics.lineTo(0, _markerHeight);
        } else {
            marker.graphics.moveTo(0, 0);
            marker.graphics.lineTo(_markerHeight, 0);
        }
    }

    public function get markerHeight():Number {
        return _markerHeight;
    }

    public function set markerHeight(value:Number):void {
        _markerHeight = value;
    }

    public function redrawMarker():void {
        drawMarker()
    }

    public function calculateActulateX():void {
        actualMarkerX = (actualTime - minTime) / pixelDensity + minX;
    }

    public function calculateActualTime():void {
        actualTime = (actualMarkerX - minX) * pixelDensity + minTime; //+this.lineWidth/2 correciot kivettem mivel igy soha nem ment a 0 poziciora
    }

    public function getTimeFromPixel(pixel:int):Number{
        return pixel *_pixelDensity+minTime;
    }
    public function getPixelFromTime(time:Number):int{
        return (time-_minTime)/_pixelDensity+_minX;
    }

    private function calculatePixelDensity():void {
        pixelDensity = (maxTime - minTime) / maxDistance;
    }

    private function calculateMaxDistance():void {
        maxDistance = maxX - minX;
    }

    public function get actualMarkerX():Number {
        return _actualMarkerX;
    }

    public function putMarkerIntoCenter():void {
        actualMarkerX = maxDistance / 2 + minX - _lineWidth / 2;

    }

    public function putMarkerIntoEnd():void {
        actualMarkerX = maxX;
        calculateActualTime();
    }

    public function putMarkerIntoBeginning():void {
        actualMarkerX = minX;
        calculateActualTime();
    }

    public function set actualMarkerX(value:Number):void {
        if (minX < value && value <= maxX) {
            _actualMarkerX = value;
            if (vertical) {
                this.y = actualMarkerX;
            } else {
                this.x = actualMarkerX;
            }
        } else if (value > maxX) {
            _actualMarkerX = maxX;
            if (vertical) {
                this.y = maxX;
            } else {
                this.x = maxX;
            }
        } else {
            _actualMarkerX = minX;
            if (vertical) {
                this.y = minX;
            } else {
                this.x = minX;
            }
        }
    }


    public function get pixelDensity():Number {
        return _pixelDensity;
    }

    public function set pixelDensity(value:Number):void {
        _pixelDensity = value;
    }

    public function get maxDistance():Number {
        return _maxDistance;
    }

    public function set maxDistance(value:Number):void {
        _maxDistance = value;
        calculatePixelDensity()
    }

    public function get actualTime():Number {
        return _actualTime;
    }

    public function set actualTime(value:Number):void {
        _actualTime = value;
        dispatchEvent(new Event("actualeTimeChanged"));
    }

    public function get maxX():Number {
        return _maxX;
    }

    public function set maxX(value:Number):void {
        _maxX = value;
        calculateMaxDistance();
    }

    public function get minX():Number {
        return _minX;
    }

    public function set minX(value:Number):void {
        _minX = value;
        calculateMaxDistance();
    }

    public function get maxTime():Number {
        return _maxTime;
    }

    public function set maxTime(value:Number):void {
        _maxTime = value;
        calculatePixelDensity();
    }

    public function get minTime():Number {
        return _minTime;
    }

    public function set minTime(value:Number):void {
        _minTime = value;
        calculatePixelDensity();
    }

    public function get lineWidth():Number {
        return _lineWidth;
    }
}
}