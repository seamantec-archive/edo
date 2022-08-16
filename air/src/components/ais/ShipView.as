/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.11.
 * Time: 13:58
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.layout.LayoutHandler;
import com.sailing.ais.AisContainer;
import com.sailing.ais.Vessel;

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Timer;

public class ShipView extends Sprite {
    private static var _blinker:Timer = new Timer(500);
    private static var _blinkObject:Vector.<Sprite> = new <Sprite>[];
    _blinker.addEventListener(TimerEvent.TIMER, markerBlinker_timerHandler, false, 0, true);
    private static var _markerIsInBlink:Boolean = false;


    private var coordinateSystem:AisCoordinateSystem;
    private var _vessel:Vessel;
//    private var dotRadious:Number = 3;
    private var multiplier:uint = 1
    private var dotAlpha:Number = 1.0
    private var speedAndRot:Sprite;
    private var shipBitmap:Bitmap;
    var selectedRing:Shape;
    private static const MAX_SIZE_OF_ICON:uint = 15;

    public function ShipView(coordinateSystem:AisCoordinateSystem, aisMessage:Vessel) {
        this.coordinateSystem = coordinateSystem;
        this._vessel = aisMessage;
        setDotProperties();
//        this.addEventListener(MouseEvent.CLICK, clickHandler);
    }

    private function setDotProperties():void {
        if (_vessel.shipStatus == Vessel.SHIP_INACTIVE) {
            dotAlpha = 0.5
        }
        cpaVisualAlarmStartStop();
    }

    private function cpaVisualAlarmStartStop():void {
        if (_vessel.closesPointOfApproach > 0 && _vessel.closesPointOfApproach < AisContainer.instance.cpaLimit && _vessel.timeToClosesPointOfApproach < AisContainer.CPTA_LIMIT && _vessel.timeToClosesPointOfApproach > 0) {
            startBlinking()
        } else {
            stopBlinking()
        }
    }

    public function refresh(coordinateSystem:AisCoordinateSystem, aisMessage:Vessel):void {
        this.coordinateSystem = coordinateSystem;
        this._vessel = aisMessage;
        if (_vessel.shipStatus == Vessel.SHIP_INACTIVE) {
            dotAlpha = 0.5
        } else {
            dotAlpha = 1;
        }
        if (originalShipMatrix != null&& shipBitmap != null && shipBitmap.transform != null ) {
            shipBitmap.transform.matrix = originalShipMatrix;
            setBitmapWH();
            saveBitmapMatrix();
        }
        cpaVisualAlarmStartStop();
        drawSpeedAndRotLine();
    }

    public function rotateHeadUpBaseStation():void {
        rotateTo(AisContainer.instance.ownShip.heading)
    }

    private function setBitmapWH():void {
        shipBitmap.width = MAX_SIZE_OF_ICON * multiplier * this.coordinateSystem.parentPerc
        shipBitmap.height = MAX_SIZE_OF_ICON * multiplier * this.coordinateSystem.parentPerc
        if (shipBitmap.width > MAX_SIZE_OF_ICON) {
            shipBitmap.width = MAX_SIZE_OF_ICON;
        }
        if (shipBitmap.height > MAX_SIZE_OF_ICON) {
            shipBitmap.height = MAX_SIZE_OF_ICON;
        }
        shipBitmap.x = -shipBitmap.width / 2;
        shipBitmap.y = -shipBitmap.height / 2;
    }

    var originalShipMatrix:Matrix;
    var originalShipPoint:Point;
    var originalShipHeight:uint = MAX_SIZE_OF_ICON

    private function drawSpeedAndRotLine():void {
        if (speedAndRot == null) {
            speedAndRot = new Sprite();
        } else {
            speedAndRot.graphics.clear();
            this.graphics.clear();
        }
        if (shipBitmap == null || (shipBitmap is Vessel.unknownVesselPng && vessel.shipMainType != Vessel.SHIP_UNKNOWN)
                || (shipBitmap is Vessel.unknownStopPng && vessel.shipMainType != Vessel.SHIP_UNKNOWN)) {
            if (shipBitmap != null) {
                speedAndRot.removeChild(shipBitmap);
            }
            shipBitmap = _vessel.getShipBitmap();
            shipBitmap.smoothing = true;
            setBitmapWH()
            saveBitmapMatrix();
            speedAndRot.addChild(shipBitmap)
        }
        if (vessel.isUnderWay() && !vessel.isBaseStation()) {
            rotateTo(vessel.trueHeading === 511 ? vessel.courseOverGround : vessel.trueHeading);
        } else {
            rotateHeadUpBaseStation();
        }
        shipBitmap.alpha = dotAlpha;

        if (vessel.isUnderWay()) {
            var cog:Number = vessel.courseOverGround - 90 - (AisCoordinateSystem.dishRotation ? 0 : AisContainer.instance.ownShip.heading);
            cog -= Math.floor(cog / 360) * 360
            var cogInRad:Number = (cog) * (Math.PI / 180);

            var distanceInOneHour:Number = vessel.speedOverGround < 102 ? vessel.speedOverGround : 0;
            var distanceInTenMinutes:Number = distanceInOneHour * (10 / 60);

            var distInPixel:Number = distanceInTenMinutes * coordinateSystem.pixelPerNm + originalShipHeight / 2;
            if (distanceInTenMinutes === 0) {
                distInPixel = 0;
            }
            var x:Number = (distInPixel) * Math.cos(cogInRad);
            var y:Number = (distInPixel) * Math.sin(cogInRad);
            var x2:Number = x + (((vessel.rateOfTurn * -1) / multiplier * coordinateSystem.parentPerc) * 0.4 ) * Math.cos(-1.57079633 + cogInRad);
            var y2:Number = y + (((vessel.rateOfTurn * -1) / multiplier * coordinateSystem.parentPerc) * 0.4 ) * Math.sin(-1.57079633 + cogInRad);

            speedAndRot.graphics.lineStyle(1, vessel.vesselColor, dotAlpha);
            speedAndRot.graphics.moveTo(0, 0);
            speedAndRot.graphics.lineTo(x, y);
            if (!vessel.rateOfTurnOverRange) {
                speedAndRot.graphics.lineStyle(1, vessel.vesselColor);
                speedAndRot.graphics.lineTo(x2, y2);
            }
        }
        this.addChild(speedAndRot)
    }

    private function saveBitmapMatrix():void {
        originalShipMatrix = shipBitmap.transform.matrix;
        originalShipPoint = new Point(shipBitmap.x + shipBitmap.width / 2, shipBitmap.y + shipBitmap.height / 2);
        originalShipHeight = shipBitmap.height;
    }

    private function rotateTo(rotation:int) {
        shipBitmap.transform.matrix = originalShipMatrix;
        var matrix:Matrix = shipBitmap.transform.matrix;
        matrix.translate(-originalShipPoint.x, -originalShipPoint.y);
        matrix.rotate((rotation) * (Math.PI / 180));
        matrix.translate(+originalShipPoint.x, +originalShipPoint.y);
        shipBitmap.transform.matrix = matrix;

    }

    public function get vessel():Vessel {
        return _vessel;
    }

    private function clickHandler(event:MouseEvent):void {
        if (LayoutHandler.instance.editMode) {
            return;
        }
        this.parent.setChildIndex(this, this.parent.numChildren-1);
        AisContainer.instance.selectedShipMMSI = this.vessel.mmsi;
    }

    public function stopBlinking():void {
        for (var i:int = 0; i < _blinkObject.length; i++) {
            if (_blinkObject[i] == this) {
                this.alpha = 1;
                _blinkObject.splice(i, 1);
                break;
            }
        }
        if (_blinkObject.length === 0) {
            _blinker.stop();
            _markerIsInBlink = false;
        }
    }

    public function startBlinking():void {
        var needTopush:Boolean = true;
        for (var i:int = 0; i < _blinkObject.length; i++) {
            if (_blinkObject[i] == this) {
                needTopush = false;
                break;
            }
        }
        if (needTopush) {
            _blinkObject.push(this);
        }
        if (!_blinker.running) {
            _blinker.start();
        }
    }

    private static function markerBlinker_timerHandler(event:TimerEvent):void {
        for (var i:int = 0; i < _blinkObject.length; i++) {
            if (_markerIsInBlink) {
                _blinkObject[i].alpha = 1
            } else {
                _blinkObject[i].alpha = 0.1
            }
        }
        _markerIsInBlink = !_markerIsInBlink;

    }


    public function setSelected():void {
        if (selectedRing === null) {
            selectedRing = new Shape();
            this.addChild(selectedRing);
        }

        selectedRing.graphics.clear();
        selectedRing.graphics.lineStyle(1, 0xffffff);
        selectedRing.graphics.drawCircle(0, 0, shipBitmap.height / 2 + 3);
    }

    public function deSelect():void {
        if (selectedRing !== null) {
            selectedRing.graphics.clear();
        }
    }


}
}
