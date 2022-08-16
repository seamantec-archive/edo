/**
 * Created by seamantec on 26/03/14.
 */
package com.polar {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

public class PolarForceDot extends Sprite {

    public static const SIZE:Number = 5;
    private const RAD90:Number = Math.PI / 2;
    private const RAD360:Number = 2 * Math.PI;

    private var _windDirection:int;
    private var _windAngle:Number;
    private var _instrument:Sprite;

    private var _layer:PolarDotLayer;

    private var _dragPoint:Point = new Point(0, 0);
    private var _boatSpeed:Number;

    private var _mouseOver:Boolean = false;

    public function PolarForceDot(windDirection:Number, instrument:Sprite) {
        super();

        this.visible = false;

        _windDirection = windDirection;
        _windAngle = (windDirection - 90) * (Math.PI / 180);

        _instrument = instrument;
        if (windDirection <= 180) {
            this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
            this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true);
            this.graphics.beginFill(0xff0000, 1);
        } else {
            this.graphics.beginFill(0xff0000, 0.5);
        }

        this.graphics.drawCircle(SIZE, SIZE, SIZE * 2);

    }

    var aPoint:Point;
    var bPoint:Point;
    var mouseStartX:Number;
    var mouseStartY:Number;
    var mouseFlyX:Number;
    var mouseFlyY:Number;
    var startBoatSpeed:Number;
    var onDrag:Boolean = false;

    private function mouseOverHandler(event:MouseEvent):void {
        this.graphics.clear();
        this.graphics.beginFill(0x0000ff);
        this.graphics.drawCircle(SIZE, SIZE, SIZE * 2);
        this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
        _mouseOver = true;
    }

    private function mouseOutHandler(event:MouseEvent):void {
        _mouseOver = false;
        if(!onDrag) {
            this.graphics.clear();
            this.graphics.beginFill(0xff0000);
            this.graphics.drawCircle(SIZE, SIZE, SIZE * 2);
            this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        }
    }

    private function mouseDownHandler(event:MouseEvent):void {
        this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
        this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
        _dragPoint = new Point(this.x, this.y);
        startBoatSpeed = _boatSpeed
        mouseStartX = event.stageX;
        mouseStartY = event.stageY;
        initDrag();
        onDrag = true;
    }

    private function initDrag():void {
        var alphaInRad:Number = (_windDirection - 90) * Math.PI / 180;
        aPoint = new Point(4048 * Math.cos(alphaInRad - Math.PI / 2) + mouseStartX, 4048 * Math.sin(alphaInRad - Math.PI / 2) + mouseStartY);
        bPoint = new Point(4048 * Math.cos(alphaInRad + Math.PI / 2) + mouseStartX, 4048 * Math.sin(alphaInRad + Math.PI / 2) + mouseStartY);
    }

    private function mouseMoveHandler(event:MouseEvent):void {
        mouseFlyX = event.stageX;
        mouseFlyY = event.stageY;
        try {
            var dist:Number = ((aPoint.y - event.stageY) * (bPoint.x - aPoint.x) - (aPoint.x - event.stageX) * (bPoint.y - aPoint.y)) / Math.sqrt(Math.pow(bPoint.x - aPoint.x, 2) + Math.pow(bPoint.y - aPoint.y, 2));
//        trace(dist, mouseStartX - event.stageX);
            var tempSpeed:Number = startBoatSpeed + dist / ( _layer.pixelPerSpeed / (800 / _layer.parent.parent.parent.width))
            if (tempSpeed >= 0 && (tempSpeed) <= _layer.maxSpeedForWind && tempSpeed>=PolarDotLayer.SPEED_MIN && tempSpeed <= PolarDotLayer.SPEED_MAX) {
                setSpeed(tempSpeed);
                _layer.resetTimer();
            }
        } catch (e:Error) {
            trace(e.getStackTrace());
        }

    }

    private function mouseUpHandler(event:MouseEvent):void {
        this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        _layer.setBoatSpeedForActualLayer(_boatSpeed, _windDirection);
        onDrag = false;
        if(this.hasEventListener(MouseEvent.MOUSE_OUT) && !_mouseOver) {
            this.graphics.clear();
            this.graphics.beginFill(0xff0000);
            this.graphics.drawCircle(SIZE, SIZE, SIZE * 2);
            this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        }
    }

    public function mouseOver(mx:Number, my:Number):Boolean {
        return (mx>=this.x) && (mx<=(this.x+SIZE*2)) && (my>=this.y) && (my<=(this.y+SIZE*2));
    }

    public function setSpeed(speed:Number, layer:PolarDotLayer = null):void {
        _boatSpeed = speed;
        if (layer != null) _layer = layer;
        this.visible = true;
        this.x = _boatSpeed * _layer.pixelPerSpeed * Math.cos(_windAngle) + PolarLayer.DIAMETER - SIZE;
        this.y = _boatSpeed * _layer.pixelPerSpeed * Math.sin(_windAngle) + PolarLayer.DIAMETER - SIZE;
    }

    private function addForceDot(pbs:PolarBoatSpeed, direction:Number):void {
//        direction = (direction- 90)*RAD;
//        //vertical pink
//        if (pbs.verticalInterpolated != 0) {
//            _dot.graphics.beginFill(0xed145b, PolarTable.vInterpolatedWeight/PolarTable.MAX_INTERPOLATIONW);
//            _dot.graphics.drawCircle(pbs.verticalInterpolated * _pixelPerSpeed*Math.cos(direction) + PolarLayer.DIAMETER, pbs.verticalInterpolated*_pixelPerSpeed*Math.sin(direction) + PolarLayer.DIAMETER, 6);
//        }
//        //horizontal orange
//        if (pbs.horizontalInterpolated != 0) {
//            _dot.graphics.beginFill(0xff9c00, PolarTable.hInterpolatedWeight/PolarTable.MAX_INTERPOLATIONW);
//            _dot.graphics.drawCircle(pbs.horizontalInterpolated * _pixelPerSpeed*Math.cos(direction) + PolarLayer.DIAMETER, pbs.horizontalInterpolated*_pixelPerSpeed*Math.sin(direction) + PolarLayer.DIAMETER, 5);
//        }
//        //combinedMeasured cian
//        if (pbs.combinedMeasured != 0) {
//            _dot.graphics.beginFill(0x0DFFEC);
//            _dot.graphics.drawCircle(pbs.combinedMeasured * _pixelPerSpeed*Math.cos(direction) + PolarLayer.DIAMETER, pbs.combinedMeasured*_pixelPerSpeed*Math.sin(direction) + PolarLayer.DIAMETER, 4);
//        }
//        //measured white
//        if (pbs.measured != 0) {
//            _dot.graphics.beginFill(0xffffff);
//            _dot.graphics.drawCircle(pbs.measured*_pixelPerSpeed*Math.cos(direction) + PolarLayer.DIAMETER, pbs.measured*_pixelPerSpeed*Math.sin(direction) + PolarLayer.DIAMETER, 3);
//        }
    }


}
}
