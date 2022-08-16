/**
 * Created by pepusz on 2013.12.10..
 */
package com.common {
import components.ControlEmbedable;
import components.IInstrument;
import components.ais.AisComponent;
import components.ais.IAisComponent;
import components.graph.custom.GraphInstance;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.getTimer;

public class InstrumentMouseHandler {
    public static const SNAP_GRID_SIZE:uint = 10;
    public static const MIN_WIDTH_SQUARE:int = 50;
    public static const MIN_WIDTH_ROW:int = 150;
    public static const MIN_HEIGHT_COLUMN:int = 150;


    private var cWidth:int = 0;
    private var cHeight:int = 0;
    var diffX:int;
    var diffY:int;
    //private var diagonalSnap:Number = 0;
    private var alphaInRad:Number = 0;
    private var mouseStartX:int;
    private var mouseStartY:int;
    private var mouseFlyX:int;
    private var mouseFlyY:int;
    private var _aspectRatio:Number = 0
    private var instrument:IInstrument
    private var _lastClick:int;
    private var originalC:Number;
    private var mouseLocalX:int;
    private var mouseLocalY:int
    private var _controlOriginalWidth:Number;
    private var _controlOriginalHeight:Number;
    var aPoint:Point;
    var bPoint:Point;

    function InstrumentMouseHandler(instrument:*) {
        this.instrument = instrument;
    }

    public function initControlInitDimensions(controlWidth:int, controlHeight:int):void {
        //diagonalSnap = (Math.sqrt(controlWidth * controlWidth + controlHeight * controlHeight) / controlWidth) * SNAP_GRID_SIZE;
        alphaInRad = Math.atan2(controlHeight, controlWidth);
        _aspectRatio = controlWidth / controlHeight
        _controlOriginalHeight = controlHeight;
        _controlOriginalWidth = controlWidth;
    }

    public function initResizeProperties(width:int, height:int, x:int, y:int, stageX:int, stageY:int, localX:int, localY:int):void {
        mouseStartX = stageX;
        mouseStartY = stageY;
        mouseLocalX = localX;
        mouseLocalY = localY;
        mouseFlyX = mouseStartX;
        mouseFlyY = mouseStartY;
        originalC = Math.sqrt(Math.pow(width, 2) + Math.pow(height, 2));
        aPoint = new Point(4048 * Math.cos(alphaInRad - Math.PI / 2) + mouseStartX, 4048 * Math.sin(alphaInRad - Math.PI / 2) + mouseStartY);
        bPoint = new Point(4048 * Math.cos(alphaInRad + Math.PI / 2) + mouseStartX, 4048 * Math.sin(alphaInRad + Math.PI / 2) + mouseStartY);
        if (instrument.isChart) {
            cWidth = Math.round(width / SNAP_GRID_SIZE) * SNAP_GRID_SIZE;
            cHeight = Math.round(height / SNAP_GRID_SIZE) * SNAP_GRID_SIZE;
        } else {
            cWidth = width;
            cHeight = height;
        }
        //resizeObject(mouseStartX, mouseStartY);
    }

    public function mouseMoveR(event:MouseEvent):void {
        resizeObject(event.stageX, event.stageY);
    }

    public function enterFrameHandler(event:Event):void {

//
        resize(cWidth, cHeight)
        instrument.control.dispatchEvent(new Event("external-resize"));
    }

    public function repositionControls():void {
        instrument.closeBtn.y = 0;

        if (instrument.control is GraphInstance || instrument.control is IAisComponent) {
            instrument.resizeBtn.x = instrument.control.originWidth - instrument.resizeBtn.width;
            instrument.resizeBtn.y = instrument.control.originHeight - instrument.resizeBtn.height;
            instrument.closeBtn.x = instrument.control.originWidth - instrument.closeBtn.width;
//            if (instrument.control is GraphInstance) {
//                instrument.moveButton.y = instrument.control.originHeight - instrument.moveButton.height;
//            }
        } else {
            if (instrument is ControlEmbedable) {
                instrument.resizeBtn.x = instrument.originWidth - instrument.resizeBtn.width;
                instrument.resizeBtn.y = instrument.originHeight - instrument.resizeBtn.height;
                instrument.closeBtn.x = instrument.originWidth - instrument.closeBtn.width;
            } else {
                instrument.resizeBtn.x = instrument.width - instrument.resizeBtn.width;
                instrument.resizeBtn.y = instrument.height - instrument.resizeBtn.height;
                instrument.closeBtn.x = instrument.width - instrument.closeBtn.width;
            }
        }
    }

    public function rescaleControl():void {
        instrument.resizeBtn.scaleX = 1 / instrument.scaleX;
        instrument.resizeBtn.scaleY = 1 / instrument.scaleY;
        instrument.closeBtn.scaleX = 1 / instrument.scaleX;
        instrument.closeBtn.scaleY = 1 / instrument.scaleY;
        repositionControls();
    }

    public function resizeObject(x:int, y:int, needSnap:Boolean = true):void {

        if (instrument.isChart) {
            diffX = (mouseFlyX - x )
            diffY = (mouseFlyY - y )
            if (Math.abs(diffX) >= SNAP_GRID_SIZE || Math.abs(diffY) >= SNAP_GRID_SIZE) {
                mouseFlyX = x;
                mouseFlyY = y;
                diffX = Math.round(diffX / SNAP_GRID_SIZE) * SNAP_GRID_SIZE;
                diffY = Math.round(diffY / SNAP_GRID_SIZE) * SNAP_GRID_SIZE;
                cWidth -= diffX;
                cHeight -= diffY;

                if (cWidth < GraphInstance.MIN_WIDTH) {
                    cWidth = GraphInstance.MIN_WIDTH;
                }
                if (cHeight < GraphInstance.MIN_HEIGHT) {
                    cHeight = GraphInstance.MIN_HEIGHT;
                }
            }
        } else {
            var dist:Number = ((aPoint.y - y) * (bPoint.x - aPoint.x) - (aPoint.x - x) * (bPoint.y - aPoint.y)) / Math.sqrt(Math.pow(bPoint.x - aPoint.x, 2) + Math.pow(bPoint.y - aPoint.y, 2));
            var newC:Number = originalC + dist;
            cWidth = Math.cos(alphaInRad) * newC;
            cHeight = Math.sin(alphaInRad) * newC;
            if (needSnap) {
                if (_aspectRatio >= 1) {
                    cWidth -= cWidth % SNAP_GRID_SIZE;
                    cHeight = cWidth / _aspectRatio;
                } else {
                    cHeight -= cHeight % SNAP_GRID_SIZE;
                    cWidth = cHeight * _aspectRatio;
                }
            }

            if (_aspectRatio === 1 && cWidth < MIN_WIDTH_SQUARE) {
                cWidth = MIN_WIDTH_SQUARE;
                cHeight = cWidth / _aspectRatio;
            } else if (_aspectRatio > 1 && cHeight < 30) {      //cWidth < MIN_WIDTH_ROW
//                cWidth = MIN_WIDTH_ROW;
//                cHeight = cWidth / _aspectRatio;
                cHeight = 30;
                cWidth = cHeight * _aspectRatio;
            } else if (_aspectRatio < 1 && cWidth < 30) {     //cHeight < MIN_HEIGHT_COLUMN
//                cHeight = MIN_HEIGHT_COLUMN;
//                cWidth = cHeight * _aspectRatio;
                cWidth = 30;
                cHeight = cWidth / _aspectRatio;
            }

        }
    }

    public function stopResizeNotify():void {
        if (instrument.control is GraphInstance) {
            instrument.control.stopResize();
        }
    }

    public function startResizeNotify():void {
        if (instrument.control is GraphInstance) {
            instrument.control.startResize();
        }
    }


    public function get aspectRatio():Number {
        return _aspectRatio;
    }

    public function mouseCustomClick(event:MouseEvent):void {
        var time:* = getTimer();
        if (_lastClick + 300 > time) {
            if (event.target.name.match("switch_btn")) {
                event.target.dispatchEvent(new Event("custom-click"));
            } else {
                instrument.control.dispatchEvent(new Event("custom-click"));
            }
        }
    }


    public function set lastClick(value:int):void {
        _lastClick = value;
    }

    public function resize(w:Number, h:Number):void {
        if (instrument.control is GraphInstance || instrument.control is AisComponent) {
            instrument.control.resize(w, h)
            repositionControls();
        } else {
            instrument.originWidth = w;
            instrument.originHeight = h;
            if (_aspectRatio >= 1) {
                instrument.control.scaleX = w / _controlOriginalWidth;
                instrument.control.scaleY = instrument.control.scaleX;
            } else {
                instrument.control.scaleY = h / _controlOriginalHeight
                instrument.control.scaleX = instrument.control.scaleY;
            }
            rescaleControl();
        }
        instrument.drawBg(w, h)


//        if (instrument.control is Digital_c) {
//            trace("import control w, h", instrument.control.width, instrument.control.height)
//            for (var asd:int = 0; asd < instrument.control.digital.numChildren; asd++) {
//                var child = instrument.control.digital.getChildAt(asd);
//                trace(child, child.height, child.y);
//            }
//
//
//        }


    }
}
}
