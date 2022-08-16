/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.11.
 * Time: 13:50
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.events.UnitChangedEvent;
import com.layout.LayoutHandler;
import com.sailing.WindowsHandler;
import com.sailing.ais.AisContainer;
import com.sailing.ais.Vessel;
import com.sailing.ais.events.ShipChangeEvent;
import com.sailing.socket.SocketDispatcher;
import com.sailing.units.Distance;
import com.sailing.units.UnitHandler;
import com.store.Statuses;
import com.utils.FontFactory;

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.TextField;

//TweenPlugin.activate([ShortRotationPlugin, TransformAroundPointPlugin]);

public class AisCoordinateSystem extends Sprite {
    private var shipContainer:Object;
    private var centerPoint:Point;
    private var radious:Number;
    private var sizePercentage:Number;
    private var parentWidth:Number;
    private var parentWidthPer:Number;
    private var _max_distance:int = 30;
    private var _pixelPerNm:Number;
    private var _bgDish:Sprite;
    public static var dishRotation:Boolean = true;
    private var initTrMatrix:Matrix;
    private var aisComponent:IAisComponent;
    private var unit:Distance = new Distance();
    private var statusLabel:TextField = FontFactory.getCustomFont({color: 0xfff200, alpha: 0.6, size: 20, width: 125, height: 20})

    public function AisCoordinateSystem(parent:IAisComponent) {
        this.aisComponent = parent;
        shipContainer = new Object();
        sizePercentage = 0.77;
        AisContainer.instance.addEventListener(ShipChangeEvent.SHIP_CHANGED_EVENT, shipChangedHandler, false, 0, true);
        AisContainer.instance.addEventListener("all-ship-data-changed", allShipChangedHandler, false, 0, true);
        AisContainer.instance.addEventListener("own-ship-heading-changed", ownShipHeadingChangedHandler, false, 0, true);
        AisContainer.instance.addEventListener("removeAllShip", removeAllShipHandler, false, 0, true);
        AisContainer.instance.addEventListener("cpaLimitChanged", cpaLimitChangedHandler, false, 0, true);
        UnitHandler.instance.addEventListener(UnitChangedEvent.CHANGE, unit_changed_eventHandler, false, 0, true);
        this.initTrMatrix = this.transform.matrix;
        this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
        (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).addEventListener("connectDisconnect", connectDisconnectHandler, false, 0, true);
        (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).addEventListener("connectDisconnectDemo", connectDisconnectHandler, false, 0, true);
        addStatusLabel();
        connectDisconnectHandler();
    }

    var bg:Sprite;

    private function addStatusLabel():void {
        statusLabel.text = "Not available";
        statusLabel.visible = !Statuses.instance.socketStatus;
        positionStatusLabel();
        this.addChild(statusLabel);
    }

    private function positionStatusLabel():void {
        if (centerPoint != null) {
            statusLabel.x = Math.abs(centerPoint.x - statusLabel.width / 2);
            statusLabel.y = Math.abs(centerPoint.y - 12);
            setStatusLabelTopChild();
        }
    }

    private function setStatusLabelTopChild():void {
        if (this.contains(statusLabel)) {
            this.setChildIndex(statusLabel, numChildren - 1);
        }
    }

    private function drawGrid():void {
        if (bg == null) {
            bg = new Sprite();
            bg.addEventListener(MouseEvent.CLICK, bg_clickHandler, false, 0, true);
            this.addChild(bg)

        }
        radious = parentWidth * sizePercentage / 2;//this.width / 2;
        _pixelPerNm = radious / _max_distance;
        centerPoint = new Point(parentWidth / 2, parentWidth / 2);
//        centerPoint = new Point(this.width / 2, this.height / 2);
        bg.graphics.clear();
        bg.graphics.beginFill(0xffffff, 0.01);
        bg.graphics.drawCircle(centerPoint.x, centerPoint.y, radious - 3);
        bg.graphics.endFill();


        drawLimitCircle();
    }

    private function addUpdateShip(ship:Vessel):void {
        if (LayoutHandler.instance.activeLayout == null) {
            return;
        }
        //TODO mikor kirajzolunk egy elemet akkor figyelembe kell venni az egesz muszer meretet
        var distanceFromOwnShipInAUnit:Number = unit.convertNumber(ship.distanceFromOwnShip);
        if (distanceFromOwnShipInAUnit > _max_distance || centerPoint == null) {
            removeShip(ship.mmsi)
            return;
        }
        if (shipContainer[ship.mmsi] == null) {
            shipContainer[ship.mmsi] = new ShipView(this, ship);
            this.addChild(shipContainer[ship.mmsi]);
        }

        var shipAngle:Number = (ship.angleFromOwnShip + (dishRotation ? 0 : AisContainer.instance.ownShip.heading) ) * (Math.PI / 180);  //+ AisContainer.instance.ownShip.heading
        (shipContainer[ship.mmsi] as ShipView).x = centerPoint.x + distanceFromOwnShipInAUnit * _pixelPerNm * Math.cos(shipAngle);
        (shipContainer[ship.mmsi] as ShipView).y = centerPoint.y - distanceFromOwnShipInAUnit * _pixelPerNm * Math.sin(shipAngle);
        (shipContainer[ship.mmsi] as ShipView).refresh(this, ship);
        if (LayoutHandler.instance.activeLayout.aisDetails.isInfoVisible() && AisContainer.instance.selectedShipMMSI == ship.mmsi) {
            updateOpenedShipDetails(ship.mmsi);
        }
    }


    private function shipChangedHandler(event:ShipChangeEvent):void {
        if (event.vessel == null) {
            return;
        }
        if (event.vessel.shipStatus == Vessel.SHIP_OUTDATED) {
            removeShip(event.vessel.mmsi);
            return;
        }
        addUpdateShip(event.vessel)
    }

    private function removeShip(mmsi:String):void {
        if (shipContainer[mmsi] != null) {
            (shipContainer[mmsi] as ShipView).stopBlinking();
            this.removeChild(shipContainer[mmsi]);
            delete shipContainer[mmsi]

        }
    }

    private function allShipChangedHandler(event:Event):void {

    }

    private function ownShipHeadingChangedHandler(event:Event):void {
        if (centerPoint == null) {
            return;
        }
        rotateBg();
    }

    private var tempHeading:Number = 0;

    private function rotateBg():void {
        if (isNaN(AisContainer.instance.ownShip.heading)) {
            return;
        }
        if (dishRotation) {
            rotateDishTo(AisContainer.instance.ownShip.heading);
        } else {
            reAddAllShip();
        }

    }

    private function rotateDishTo(to:Number):void {
        var matrix:Matrix = new Matrix();
        var cachedCenterPoint:Point = centerPoint;
        this.transform.matrix = initTrMatrix;

        matrix.translate(-cachedCenterPoint.x, -cachedCenterPoint.y);
        matrix.rotate((tempHeading - to) * (Math.PI / 180));
        matrix.translate(+cachedCenterPoint.x, +cachedCenterPoint.y);
        matrix.concat(this.transform.matrix);
        this.transform.matrix = matrix;


//        tempHeading = AisContainer.instance.ownShip.heading;
        rotateBaseStationsBack();
    }

    private function rotateBaseStationsBack():void {
        for each (var object:ShipView in shipContainer) {
            if (object.vessel.isBaseStation()) {
                object.rotateHeadUpBaseStation();
            }
        }
    }

    private function reAddAllShip():void {
        for each (var object:Vessel in AisContainer.instance.container) {
            addUpdateShip(object);
        }
    }

    public var parentPerc:Number = 1.0;

    public function resize(parentW:Number):void {
        this.parentWidth = parentW;
        parentWidthPer = parentW / 2;
        if (parentW <= 300) {
            parentPerc = parentW / 300;
        } else {
            parentPerc = parentW / 300 * 0.75;
        }
        if (dishRotation) {
            this.transform.matrix = this.initTrMatrix;
        }
        //this.width = parentWidth * sizePercentage;
//        this.graphics.clear();
//        this.graphics.beginFill(0xffffff, 0.5);
//        this.graphics.drawRect(0, 0, parentWidth * sizePercentage, parentWidth * sizePercentage);
//        this.graphics.endFill();
//        this.graphics.beginFill(0xffffff, 1);
//        this.graphics.drawRect(0, 0, 20,20);
//        this.graphics.endFill();
//        this.x = (parentWidth - (parentWidth * sizePercentage))/2;
//        this.y = (parentWidth - (parentWidth * sizePercentage))/2;
        drawGrid();
        reAddAllShip();
        tempHeading = 0;
        rotateBg();
        positionStatusLabel();
    }

    private function removeAllShipHandler(event:Event):void {
        removeAllShip()
    }

    private function removeAllShip():void {
        for each (var object:Object in shipContainer) {
            this.removeChild(object as ShipView);
        }
        shipContainer = new Object();
        prevSelectedMMSI = null;
        if (LayoutHandler.instance.activeLayout != null) {
            LayoutHandler.instance.activeLayout.deselectVessel();
        }
        //rotateDishTo(0);
    }

    public function get pixelPerNm():Number {
        return _pixelPerNm;
    }

    private var shipInfo:TextField;


    public function updateOpenedShipDetails(mmsi:String):void {
        if (LayoutHandler.instance.activeLayout == null) {
            return;
        }
        LayoutHandler.instance.activeLayout.aisDetails.ship = AisContainer.instance.container[mmsi] as Vessel;
        LayoutHandler.instance.activeLayout.aisDetails.updateShipDatas();
    }


    private function bg_clickHandler(event:MouseEvent):void {
        if (LayoutHandler.instance.activeLayout == null) {
            return;
        }
        LayoutHandler.instance.activeLayout.deselectVessel();
    }

    public function get max_distance():int {
        return _max_distance;
    }

    public function set max_distance(value:int):void {
        if (value == _max_distance) {
            return;
        }
        removeAllShip();
        _max_distance = value;
        _pixelPerNm = radious / _max_distance;
        drawLimitCircle();
        reAddAllShip();
    }


    private var circle:Shape;

    private function cpaLimitChangedHandler(event:Event):void {
        drawLimitCircle();
    }

    private function drawLimitCircle():void {
        if (circle === null) {
            circle = new Shape();
            this.addChild(circle);
        }
        circle.graphics.clear();
        circle.graphics.lineStyle(2, 0x700000, 0.8);
        var cpaLimit:Number = unit.convertNumber(AisContainer.instance.cpaLimit) < _max_distance ? unit.convertNumber(AisContainer.instance.cpaLimit) : _max_distance
        //TODO convert cpalimit to current unit
        circle.graphics.drawCircle(centerPoint.x, centerPoint.y, cpaLimit * _pixelPerNm)
    }

    private var prevSelectedMMSI:String;

    public function setShipSelected(mmsi:String):Boolean {
        if (prevSelectedMMSI != null && shipContainer[prevSelectedMMSI] != null) {
            (shipContainer[prevSelectedMMSI] as ShipView).deSelect();
        }
        if (shipContainer[mmsi] == null) {
            return false;
        }
        if (mmsi != null) {
            (shipContainer[mmsi] as ShipView).setSelected();
        }
        prevSelectedMMSI = mmsi;
        return true;
    }

    private function unit_changed_eventHandler(event:UnitChangedEvent):void {
        if (event.typeKlass == Distance) {
            drawLimitCircle();
            var length:uint = AisContainer.instance.shipInOrderedList.length;
            var vessel:Vessel;
            for (var i:int = 0; i < length; i++) {
                vessel = AisContainer.instance.container[AisContainer.instance.shipInOrderedList[i]];
                if (vessel === null) {
                    continue;
                }
                addUpdateShip(vessel);
            }
        }
    }

    private var lastPoint:Point;
    private var lastClickedIndex:int = 0;

    private function clickHandler(event:MouseEvent):void {
        if (LayoutHandler.instance.editMode) {
            return;
        }
        var point:Point = new Point(mouseX, mouseY);
        var point = localToGlobal(point);
        var objects:Array = stage.getObjectsUnderPoint(point);
        for (var i:int = 0; i < objects.length; i++) {
            if (objects[i].parent != null && objects[i].parent.parent != null && objects[i].parent.parent is ShipView) {
                var ship:ShipView = objects[i].parent.parent;
                if (lastPoint === point && i === lastClickedIndex + 1) {
                    this.setChildIndex(ship, numChildren - 1);
                    AisContainer.instance.selectedShipMMSI = ship.vessel.mmsi;
                    lastClickedIndex = i;
                    break;
                } else {
                    this.setChildIndex(ship, numChildren - 1);
                    AisContainer.instance.selectedShipMMSI = ship.vessel.mmsi;
                    lastClickedIndex = i;
                    break;
                }
            }

        }
        lastPoint = point;
    }


    private function connectDisconnectHandler(event:Event = null):void {
        statusLabel.visible = !Statuses.instance.socketStatus;
    }
}
}
