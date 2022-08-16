/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.06.
 * Time: 14:41
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.ais {
import com.common.Coordinate;
import com.common.OwnShip;
import com.events.AisVesselSelected;
import com.sailing.ais.events.ShipChangeEvent;
import com.sailing.ais.events.ShipRemovedEvent;
import com.utils.CoordinateSystemUtils;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

[Event(name="ship-changed", type="com.sailing.ais.events.ShipChangeEvent")]
[Event(name="aisAlert", type="com.sailing.ais.events.ShipChangeEvent")]
public class AisContainer extends EventDispatcher {
    public static const CPTA_LIMIT:uint = 30; //in min
    private static var _instance:AisContainer;
    private var _container:Dictionary;
    private var _ownShip:OwnShip;
    private var _shipInOrderedList:Vector.<String> = new <String>[];
    private var _cpaLimit:uint = 2;
    private var _minCpa:Number = 1000;
    private var _selectedShipMMSI:String;

    public function AisContainer() {
        if (_instance != null) {
            throw new Error("this is a singleton class. use instance")
        }
        _container = new Dictionary();
        ownShip = new OwnShip();
        ownShip.addEventListener("heading-changed", ownShipHeadingChangedHandler, false, 0, true);
        ownShip.addEventListener("timestamp-changed", ownShipTimestampChangedHandler, false, 0, true);
        ownShip.addEventListener("coordinate-changed", ownShipCoordinateChangedHandler, false, 0, true);
        ownShip.addEventListener("speed-changed", ownShipSpeedChangedHandler, false, 0, true);
    }

    public function getVessel(mmsi:String, forMessage5:Boolean = false):Vessel {
        if (_container[mmsi] != null) {
            return _container[mmsi] as Vessel
        } else {
            if (!forMessage5) return new Vessel(mmsi);
        }
        return null;
    }

    public function getSarAircraft(mmsi:String, forMessage5:Boolean = false):SarAircraft {
        if (_container[mmsi] != null) {
            return _container[mmsi] as SarAircraft
        } else {
            if (!forMessage5) return new SarAircraft(mmsi);
        }
        return null;
    }

    public function addShip(ship:Vessel):void {
        ship.registrationTimestamp = ownShip.timestamp;
        calculateShipDatas(ship, ownShip.coordinate);
        if (ship.mmsi === null) return;

        if (_container[ship.mmsi] == null) {
            _container[ship.mmsi] = ship;
            _shipInOrderedList.push(ship.mmsi)

        } else {
            updateShipData(ship)
        }
        dispatchEvent(new ShipChangeEvent(_container[ship.mmsi]));
    }

    public function updateShipDetails(mmsi:String):void {
//        var ship:Vessel = _container[mmsi];
        if (_container[mmsi] != null) {
            dispatchEvent(new ShipChangeEvent(_container[mmsi]));
        }
    }

    private function calculateShipDatas(ship:Vessel, origoVessel:Coordinate):void {
        var p2:Coordinate = new Coordinate(ship.lat, ship.lon)
        if(origoVessel == null){
            return;
        }
        ship.distanceFromOwnShip = CoordinateSystemUtils.distanceBetweenTwoPointsInNMI(origoVessel, p2);
        ship.lonDistFromOwnShip = CoordinateSystemUtils.distanceBetweenTwoLonInNMI(origoVessel, p2);
        ship.angleFromOwnShip = CoordinateSystemUtils.getAngle(origoVessel, p2, ship.distanceFromOwnShip);
        closestPointOfApproach(ship);
    }

    private function closestPointOfApproach(ship:Vessel):void {
        var DTR = Math.PI / 180;
        var x, y, xVel, yVel, dot, a, b, cpa;
        var brg:Number = 360 - ship.angleFromOwnShip + 90;
        brg -= Math.floor(brg / 360) * 360;
        x = ship.distanceFromOwnShip * Math.cos(DTR * brg);
        y = ship.distanceFromOwnShip * Math.sin(DTR * brg);
        xVel = ship.speedOverGround * Math.cos(DTR * ship.courseOverGround) - ownShip.speed * Math.cos(DTR * (ownShip.heading));
        yVel = ship.speedOverGround * Math.sin(DTR * ship.courseOverGround) - ownShip.speed * Math.sin(DTR * (ownShip.heading));
        ship.bearing = brg;
        dot = x * xVel + y * yVel;
        a = xVel * xVel + yVel * yVel;
        b = 2 * dot;
        cpa = ship.distanceFromOwnShip * ship.distanceFromOwnShip - ((b * b) / (4 * a));
        if (cpa <= 0.0) {
            ship.closesPointOfApproach = 0;
            ship.timeToClosesPointOfApproach = 60 * (-b / (2 * a));
        }
        cpa = Math.sqrt(cpa);
        ship.closesPointOfApproach = Math.round(cpa * 1000) / 1000;
        ship.timeToClosesPointOfApproach = Math.round(60 * (-b / (2 * a)) * 1000) / 1000;
//        if (ship.closesPointOfApproach >= 0 && ship.closesPointOfApproach < _cpaLimit && ship.timeToClosesPointOfApproach < CPTA_LIMIT && ship.timeToClosesPointOfApproach > 0) {
//            dispatchEvent(new AisAlertEvent(ship.mmsi));
//        }

        if ((ship.closesPointOfApproach < _minCpa &&
                ship.closesPointOfApproach > 0 && !isNaN(ship.closesPointOfApproach) &&
                ship.timeToClosesPointOfApproach < CPTA_LIMIT
                && ship.timeToClosesPointOfApproach > 0)) { //||(ship.timeToClosesPointOfApproach >= CPTA_LIMIT && ship.closesPointOfApproach > _cpaLimit && ship.closesPointOfApproach < _minCpa))
            minCpa = ship.closesPointOfApproach;
        }

    }

    public function recalculateAllDistance():void {
        //TODO implement recalculate all distance, but we need to implement calculate position from our vessel (headup)
        //remove all of vessels where importtimestamp bigger than x
        _minCpa = 1000;
        for each (var object:Vessel in _container) {
            calculateShipDatas(object, ownShip.coordinate);
            dispatchEvent(new ShipChangeEvent(_container[object.mmsi]));

        }
        dispatchEvent(new Event("all-ship-data-changed"));
        dispatchEvent(new Event("minCpaChanged"));
    }

    public function removeShip(mmsi:String):void {
        dispatchEvent(new ShipRemovedEvent(mmsi));
        if (_container[mmsi] != null) {
            delete _container[mmsi]
        }
        for (var i:int = 0; i < _shipInOrderedList.length; i++) {
            if (_shipInOrderedList[i] === mmsi) {
                _shipInOrderedList.splice(i, 1);
            }
        }
    }

    private function updateShipData(ship:Vessel):void {
        //TODO refactor, okositani hogy csak a parametereket frissitsuk
        for (var i:int = 0; i < _shipInOrderedList.length; i++) {
            if (_shipInOrderedList[i] == ship.mmsi) {
                _shipInOrderedList.splice(i, 1);
            }

        }
        _shipInOrderedList.push(ship.mmsi)
        _container[ship.mmsi] = ship;
    }

    //TODO refactor vessel need a specified object
    public function getShip():Object {
        return null;
    }

    //Type 5: Static and Voyage Related Data
    /**
     * Message has a total of 424 bits, occupying two AIVDM sentences.
     # In practice, the information in these fields (especially
     # ETA and destination) is not reliable, as it has to be hand-updated by
     # humans rather than gathered automatically from sensors
     */
    public function updateAdditionalDatasForShip():void {

    }

    private function ownShipHeadingChangedHandler(event:Event):void {
        recalculateAllDistance()
        dispatchEvent(new Event("own-ship-heading-changed"))
    }

    private function ownShipSpeedChangedHandler(event:Event):void {
        recalculateAllDistance();
    }

    public function deleteAllShip():void {
        dispatchEvent(new Event("removeAllShip"))
        _container = new Dictionary();
        _shipInOrderedList = new <String>[];
//        if (LayoutHandler.instance.activeLayout != null) {
//            LayoutHandler.instance.activeLayout.closeAisDetails();
//        }

    }

    private function ownShipTimestampChangedHandler(event:Event):void {
        var object:Vessel;
        var timestampDiff:Number;
        for (var i:int = 0; i < _shipInOrderedList.length; i++) {
            object = _container[_shipInOrderedList[i]];
            if (object === null) {
                continue;
            }
            timestampDiff = ownShip.timestamp - object.registrationTimestamp;
            if (timestampDiff > 90000) {
                object.shipStatus = Vessel.SHIP_OUTDATED;
                dispatchEvent(new ShipChangeEvent(object));
                if (_selectedShipMMSI === object.mmsi) {
                    selectedShipMMSI = null;
                }
                delete _container[object.mmsi]
                _shipInOrderedList.splice(i, 1)
            } else if (timestampDiff > 60000) {
                object.shipStatus = Vessel.SHIP_INACTIVE;
                dispatchEvent(new ShipChangeEvent(object));
            } else {
                //az osszes regi elemen vegig mentunk igy kilephetunk
                return;
            }
        }
    }

    private function ownShipCoordinateChangedHandler(event:Event):void {
        recalculateAllDistance()
    }

    public static function get instance():AisContainer {
        if (_instance == null) {
            _instance = new AisContainer();
        }
        return _instance;
    }

    public function get ownShip():OwnShip {
        return _ownShip;
    }

    public function set ownShip(value:OwnShip):void {
        _ownShip = value;
    }


    public function get container():Dictionary {
        return _container;
    }


    public function get cpaLimit():uint {
        return _cpaLimit;
    }

    public function set cpaLimit(value:uint):void {
        if (_cpaLimit === value) {
            return;
        }
        _cpaLimit = value;

        for (var i:int = 0; i < _shipInOrderedList.length; i++) {
            dispatchEvent(new ShipChangeEvent(_container[_shipInOrderedList[i]]));
        }
        dispatchEvent(new Event("cpaLimitChanged"));
        //nem kell ujraszamolni, csak vegigfutni a listan es ha van amelyiknek valtozott akkor ertesiteni a viewt
        //recalculateAllDistance();
        //TODO draw red circle
    }


    public function get minCpa():Number {
        return _minCpa;
    }

    public function set minCpa(value:Number):void {
        if (value === _minCpa) {
            return;
        }
        _minCpa = value;
    }


    public function get selectedShipMMSI():String {
        return _selectedShipMMSI;
    }

    public function set selectedShipMMSI(value:String):void {
        _selectedShipMMSI = value;
        dispatchEvent(new AisVesselSelected(value));
    }


    public function get shipInOrderedList():Vector.<String> {
        return _shipInOrderedList;
    }

    public function reset():void {
        deleteAllShip();
    }
}
}

