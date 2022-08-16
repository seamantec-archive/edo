/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.17.
 * Time: 13:47
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.ais {
import com.sailing.units.Distance;
import com.sailing.units.Speed;
import com.utils.GeneralUtils;

import flash.display.Bitmap;

public class Vessel {
    [Embed(source="../../../../assets/images/ais/basestation.png")]
    public static var baseStationPng:Class;
    [Embed(source="../../../../assets/images/ais/cargo_stop.png")]
    public static var cargoStopPng:Class;
    [Embed(source="../../../../assets/images/ais/cargo_vessel.png")]
    public static var cargoVesselPng:Class;
    [Embed(source="../../../../assets/images/ais/sail_stop.png")]
    public static var sailStopPng:Class;
    [Embed(source="../../../../assets/images/ais/sail_vessel.png")]
    public static var sailVesselPng:Class;
    [Embed(source="../../../../assets/images/ais/passenger_stop.png")]
    public static var passengerStopPng:Class;
    [Embed(source="../../../../assets/images/ais/passenger_vessel.png")]
    public static var passengerVesselPng:Class;
    [Embed(source="../../../../assets/images/ais/unknown_stop.png")]
    public static var unknownStopPng:Class;
    [Embed(source="../../../../assets/images/ais/unknown_vessel.png")]
    public static var unknownVesselPng:Class;
    [Embed(source="../../../../assets/images/ais/aircraft.png")]
    public static var aircraftPng:Class;

    public static const BASESTATION_CODE:int = 1000;

    public static const SHIP_ACTIVE:int = 0;
    public static const SHIP_INACTIVE:int = 1;
    public static const SHIP_OUTDATED:int = 2;

    public static const SHIP_CARGO:int = 0;
    public static const SHIP_PASSENGER:int = 1;
    public static const SHIP_SAIL:int = 2;
    public static const SHIP_UNKNOWN:int = 3;
    public static const SHIP_SAR:int = 4;
    public static const BASESTATION:int = 5;

    public static const UNKNOWN_COLOR:uint = 0xffffff;
    public static const CARGO_COLOR:uint = 0x1fa300;
    public static const BASESTATION_COLOR:uint = 0xffffff;
    public static const SAIL_COLOR:uint = 0xfb00ff;
    public static const PASSENGER_COLOR:uint = 0x1e75f7;
    public static const SAR_COLOR:uint = 0x1e75f7;

    protected var _registrationTimestamp:Number;
    protected var _distanceFromOwnShip:Number;
    protected var _angleFromOwnShip:Number;
    protected var _lonDistFromOwnShip:Number;
    protected var _shipStatus:Number = SHIP_ACTIVE;
    protected var _closesPointOfApproach:Number;
    protected var _timeToClosesPointOfApproach:Number;
    protected var _bearing:Number;
    protected var _mmsi:String;
    protected var _shipMainType:uint = SHIP_UNKNOWN;
    /// what is the vessel doing
    // 0: under way using engine
    // 1: at anchor
    // 2: not under command
    // 3: restricted maneuverability
    // 4: constrained by her draught
    // 5: moored
    // 6: aground
    // 7: engaged in fishing
    // 8: under way sailing
    // 9-14: reserved for future use (hazmat)
    // 15: not defined = default
    protected var _navStatus:Number;

    protected var _rateOfTurnOverRange:Boolean;

    /// rate of turning
    // positive: right
    // negative: left
    protected var _rateOfTurn:Number;

    // accuracy of positioning fixes
    // 0: low (greater than 10 m)
    // 1: high (less than 10 m)
    protected var _positionAccuracy:Number;

    // longitude and latitude
    protected var _lon:Number;
    protected var _lat:Number;

    protected var _courseOverGround:Number;

    // true heading (relative to true North)
    protected var _trueHeading:Number;

    // speed over ground in knots (102.2: 102.2 knots or higher)
    protected var _speedOverGround:Number;

    // vessel identification number (different than mmsi)
    public var imoNumber:Number;

    private var _callsign:String;
    private var _name:String;

    /// Type of ship and cargo type:
    // 20: Wing in ground (WIG), all ships of this type
    // 21: Wing in ground (WIG), Hazardous catagory A
    // 22: Wing in ground (WIG), Hazardous catagory B
    // 23: Wing in ground (WIG), Hazardous catagory C
    // 24: Wing in ground (WIG), Hazardous catagory D
    // 25: Wing in ground (WIG), Reserved for future use
    // 26: Wing in ground (WIG), Reserved for future use
    // 27: Wing in ground (WIG), Reserved for future use
    // 28: Wing in ground (WIG), Reserved for future use
    // 29: Wing in ground (WIG), No additional information
    // 30: fishing
    // 31: towing
    // 32: towing length exceeds 200m or breadth exceeds 25m
    // 33: dredging or underwater ops
    // 34: diving ops
    // 35: military ops
    // 36: sailing
    // 37: pleasure craft
    // 38: reserved
    // 39: reserved
    // 40: High speed craft (HSC), all ships of this type
    // 41: High speed craft (HSC), Hazardous catagory A
    // 42: High speed craft (HSC), Hazardous catagory B
    // 43: High speed craft (HSC), Hazardous catagory C
    // 44: High speed craft (HSC), Hazardous catagory D
    // 45: High speed craft (HSC), Reserved for future use
    // 46: High speed craft (HSC), Reserved for future use
    // 47: High speed craft (HSC), Reserved for future use
    // 48: High speed craft (HSC), Reserved for future use
    // 49: High speed craft (HSC), No additional information
    // 50: pilot vessel
    // 51: search and rescue vessel
    // 52: tug
    // 53: port tender
    // 54: anti-polution equipment
    // 55: law enforcement
    // 56: spare - local vessel
    // 57: spare - local vessel
    // 58: medical transport
    // 59: ship according to RR Resolution No. 18
    // 60: passenger, all ships of this type
    // 61: passenger, Hazardous catagory A
    // 62: passenger, Hazardous catagory B
    // 63: passenger, Hazardous catagory C
    // 64: passenger, Hazardous catagory D
    // 65: passenger, Reserved for future use
    // 66: passenger, Reserved for future use
    // 67: passenger, Reserved for future use
    // 68: passenger, Reserved for future use
    // 69: passenger, No additional information
    // 70: cargo, all ships of this type
    // 71: cargo, Hazardous catagory A
    // 72: cargo, Hazardous catagory B
    // 73: cargo, Hazardous catagory C
    // 74: cargo, Hazardous catagory D
    // 75: cargo, Reserved for future use
    // 76: cargo, Reserved for future use
    // 77: cargo, Reserved for future use
    // 78: cargo, Reserved for future use
    // 79: cargo, No additional information
    // 80: tanker, all ships of this type
    // 81: tanker, Hazardous catagory A
    // 82: tanker, Hazardous catagory B
    // 83: tanker, Hazardous catagory C
    // 84: tanker, Hazardous catagory D
    // 85: tanker, Reserved for future use
    // 86: tanker, Reserved for future use
    // 87: tanker, Reserved for future use
    // 88: tanker, Reserved for future use
    // 89: tanker, No additional information
    // 90: other type, all ships of this type
    // 91: other type, Hazardous catagory A
    // 92: other type, Hazardous catagory B
    // 93: other type, Hazardous catagory C
    // 94: other type, Hazardous catagory D
    // 95: other type, Reserved for future use
    // 96: other type, Reserved for future use
    // 97: other type, Reserved for future use
    // 98: other type, Reserved for future use
    // 99: other type, No additional information
    protected var _shipType:Number;

    public var length:uint;

    public function get shipType():Number {
        return _shipType;
    }

    public function set shipType(value:Number):void {
        _shipType = value;
        switch (true) {
            case value >= 20 && value < 30:
                _shipMainType = SHIP_UNKNOWN;
                break; // Wing in ground (aeroplan)
            case value >= 60 && value < 70:
                _shipMainType = SHIP_PASSENGER;
                vesselColor = PASSENGER_COLOR;
                break;
            case value >= 60 && value < 70:
                _shipMainType = SHIP_PASSENGER;
                break;
            case value >= 70 && value < 89:
                _shipMainType = SHIP_CARGO;
                vesselColor = CARGO_COLOR;
                break;
            case value == 36:
                _shipMainType = SHIP_SAIL;
                vesselColor = SAIL_COLOR
                break;
        }
    }

// distance from bow to reference position (meters)
    private var _dimensionToBow:Number;

    // distance from reference position to stern (meters)
    private var _dimensionToStern:Number;

    // distance from port side to reference position (meters) (63: 63 m or greater)
    private var _dimensionToPort:Number;

    // Distance from reference position to starboard side (meters) (63: 63 m or greater)
    private var _dimensionToStarboard:Number;

    // Maximum present static draught (25.5: 25.5 m or greater)
    private var _draught:Number;

    private var _destination:String;

    public function Vessel(mmsi:String) {
        this._mmsi = mmsi;
    }

    /// what is the vessel doing
    // 0: under way using engine
    // 1: at anchor
    // 2: not under command
    // 3: restricted maneuverability
    // 4: constrained by her draught
    // 5: moored
    // 6: aground
    // 7: engaged in fishing
    // 8: under way sailing
    // 9-14: reserved for future use (hazmat)
    // 15: not defined = default
    public var vesselColor:uint = UNKNOWN_COLOR

    public function getShipBitmap():Bitmap {
        var isUnderWayV:Boolean = isUnderWay();
        switch (_shipMainType) {
            case SHIP_CARGO:
                if (isUnderWayV) {
                    return new cargoVesselPng();
                } else {
                    return new cargoStopPng();
                }
                ;
            case SHIP_PASSENGER:
                if (isUnderWayV) {
                    return new passengerVesselPng();
                } else {
                    return new passengerStopPng();
                }
                ;
            case SHIP_SAIL:
                if (isUnderWayV) {
                    return new sailVesselPng();
                } else {
                    return new sailStopPng();
                }
            case SHIP_SAR:
                return new aircraftPng();

            case SHIP_UNKNOWN:
                vesselColor = UNKNOWN_COLOR;
                if (isUnderWayV) {
                    return new unknownVesselPng();
                } else {
                    return  new unknownStopPng();
                }
            case BASESTATION:
                vesselColor = BASESTATION_COLOR;
                return new baseStationPng()
        }
        if (isUnderWayV) {
            return new unknownVesselPng();
        } else {
            return  new unknownStopPng();
        }
    }

    public function isUnderWay():Boolean {
        var isUnderWay:Boolean = true;
        if (_shipType === BASESTATION_CODE) {     //BASE station
            return false;
        }
        switch (_navStatus) {
            case 0:
                isUnderWay = true;
                break;
            case 1:
                isUnderWay = false;
                break;

            case 2:
            case 3:
            case 4:
                isUnderWay = true;
                break;
            case 5:
            case 6:
                isUnderWay = false;
                break;
            case 7:
            case 8:
                isUnderWay = true;
                break;
            case 9:
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
                if (speedOverGround > 0.2) {
                    isUnderWay = true;
                } else {
                    isUnderWay = false;
                }
                break;
        }
        if (speedOverGround > 0.5) {
            isUnderWay = true;
        }
        return isUnderWay;
    }

    public function get registrationTimestamp():Number {
        return _registrationTimestamp;
    }

    public function set registrationTimestamp(value:Number):void {
        _registrationTimestamp = value;
    }

    public function get distanceFromOwnShip():Number {
        return _distanceFromOwnShip;
    }

    public function set distanceFromOwnShip(value:Number):void {
        _distanceFromOwnShip = value;
    }

    public function get angleFromOwnShip():Number {
        return _angleFromOwnShip;
    }

    public function set angleFromOwnShip(value:Number):void {
        _angleFromOwnShip = value;
    }

    public function get lonDistFromOwnShip():Number {
        return _lonDistFromOwnShip;
    }

    public function set lonDistFromOwnShip(value:Number):void {
        _lonDistFromOwnShip = value;
    }

    public function get shipStatus():Number {
        return _shipStatus;
    }

    public function set shipStatus(value:Number):void {
        _shipStatus = value;
    }

    public function get closesPointOfApproach():Number {
        return _closesPointOfApproach;
    }

    public function set closesPointOfApproach(value:Number):void {
        _closesPointOfApproach = value;
    }

    public function get timeToClosesPointOfApproach():Number {
        return _timeToClosesPointOfApproach;
    }

    public function set timeToClosesPointOfApproach(value:Number):void {
        _timeToClosesPointOfApproach = value;
    }

    public function get bearing():Number {
        return _bearing;
    }

    public function set bearing(value:Number):void {
        _bearing = value;
    }


    public function get mmsi():String {
        return _mmsi;
    }

    public function set mmsi(value:String):void {
        _mmsi = value;
    }

    public function get navStatus():Number {
        return _navStatus;
    }

    public function set navStatus(value:Number):void {
        _navStatus = value;
    }

    public function get rateOfTurnOverRange():Boolean {
        return _rateOfTurnOverRange;
    }

    public function set rateOfTurnOverRange(value:Boolean):void {
        _rateOfTurnOverRange = value;
    }

    public function get rateOfTurn():Number {
        return _rateOfTurn;
    }

    public function set rateOfTurn(value:Number):void {
        _rateOfTurn = value;
    }

    public function get positionAccuracy():Number {
        return _positionAccuracy;
    }

    public function set positionAccuracy(value:Number):void {
        _positionAccuracy = value;
    }

    public function get lon():Number {
        return _lon;
    }

    public function set lon(value:Number):void {
        _lon = value;
    }

    public function get lat():Number {
        return _lat;
    }

    public function set lat(value:Number):void {
        _lat = value;
    }

    public function get courseOverGround():Number {
        return _courseOverGround;
    }

    public function set courseOverGround(value:Number):void {
        _courseOverGround = value;
    }

    public function get trueHeading():Number {
        return _trueHeading;
    }

    public function set trueHeading(value:Number):void {
        _trueHeading = value;
    }

    public function get speedOverGround():Number {
        return _speedOverGround;
    }

    public function set speedOverGround(value:Number):void {
        _speedOverGround = value;
    }

    public function get shipMainType():uint {
        return _shipMainType;
    }

    public function set shipMainType(value:uint):void {
        _shipMainType = value;
    }


    public function isBaseStation():Boolean {
        return _shipType === BASESTATION_CODE;
    }

    public function getStatusString():String {
        var s:String = "---";
        switch (_navStatus) {
            case 0:
                s = "under way using engine";
                break;
            case 1:
                s = "at anchor";
                break;
            case 2:
                s = "not under command";
                break;
            case 3:
                s = "restricted maneuverability";
                break;
            case 4:
                s = "constrained by her draught";
                break;
            case 5:
                s = "moored";
                break;
            case 6:
                s = "aground";
                break;
            case 7:
                s = "engaged in fishing";
                break;
            case 8:
                s = "under way sailing";
                break;
            case 9:
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
                s = "reserved for future use";
                break;
            case 15:
                s = "not defined "
                break;
        }
        return GeneralUtils.breakTextAt(s, 16);
    }

    public function getTypeString():String {
        var s:String = "---";
        switch (_shipType) {
            case 20:
                s = "Wing in ground (WIG)";
                break;
            case 21:
                s = "Wing in ground (WIG)";
                break;
            case 22:
                s = "Wing in ground (WIG)";
                break;
            case 23:
                s = "Wing in ground (WIG)";
                break;
            case 24:
                s = "Wing in ground (WIG)";
                break;
            case 25:
                s = "Wing in ground (WIG)";
                break;
            case 26:
                s = "Wing in ground (WIG)";
                break;
            case 27:
                s = "Wing in ground (WIG)";
                break;
            case 28:
                s = "Wing in ground (WIG)";
                break;
            case 29:
                s = "Wing in ground (WIG)";
                break;
            case 30:
                s = "fishing";
                break;
            case 31:
                s = "towing";
                break;
            case 32:
                s = "towing length exceeds 200m or breadth exceeds 25m";
                break;
            case 33:
                s = "dredging or underwater ops";
                break;
            case 34:
                s = "diving ops";
                break;
            case 35:
                s = "military ops";
                break;
            case 36:
                s = "sailing";
                break;
            case 37:
                s = "pleasure craft";
                break;
            case 38:
                s = "reserved";
                break;
            case 39:
                s = "reserved";
                break;
            case 40:
                s = "High speed craft (HSC)";
                break;
            case 41:
                s = "High speed craft (HSC)";
                break;
            case 42:
                s = "High speed craft (HSC)";
                break;
            case 43:
                s = "High speed craft (HSC)";
                break;
            case 44:
                s = "High speed craft (HSC)";
                break;
            case 45:
                s = "High speed craft (HSC)";
                break;
            case 46:
                s = "High speed craft (HSC)";
                break;
            case 47:
                s = "High speed craft (HSC)";
                break;
            case 48:
                s = "High speed craft (HSC)";
                break;
            case 49:
                s = "High speed craft (HSC)";
                break;
            case 50:
                s = "pilot vessel";
                break;
            case 51:
                s = "search and rescue vessel";
                break;
            case 52:
                s = "tug";
                break;
            case 53:
                s = "port tender";
                break;
            case 54:
                s = "anti-polution equipment";
                break;
            case 55:
                s = "law enforcement";
                break;
            case 56:
                s = "spare - local vessel";
                break;
            case 57:
                s = "spare - local vessel";
                break;
            case 58:
                s = "medical transport";
                break;
            case 59:
                s = "ship according to RR Resolution No. 18";
                break;
            case 60:
                s = "passenger";
                break;
            case 61:
                s = "passenger";
                break;
            case 62:
                s = "passenger";
                break;
            case 63:
                s = "passenger";
                break;
            case 64:
                s = "passenger";
                break;
            case 65:
                s = "passenger";
                break;
            case 66:
                s = "passenger";
                break;
            case 67:
                s = "passenger";
                break;
            case 68:
                s = "passenger";
                break;
            case 69:
                s = "passenger";
                break;
            case 70:
                s = "cargo";
                break;
            case 71:
                s = "cargo";
                break;
            case 72:
                s = "cargo";
                break;
            case 73:
                s = "cargo";
                break;
            case 74:
                s = "cargo";
                break;
            case 75:
                s = "cargo";
                break;
            case 76:
                s = "cargo";
                break;
            case 77:
                s = "cargo";
                break;
            case 78:
                s = "cargo";
                break;
            case 79:
                s = "cargo";
                break;
            case 80:
                s = "tanker";
                break;
            case 81:
                s = "tanker";
                break;
            case 82:
                s = "tanker";
                break;
            case 83:
                s = "tanker";
                break;
            case 84:
                s = "tanker";
                break;
            case 85:
                s = "tanker";
                break;
            case 86:
                s = "tanker";
                break;
            case 87:
                s = "tanker";
                break;
            case 88:
                s = "tanker";
                break;
            case 89:
                s = "tanker";
                break;
            case 90:
                s = "other type";
                break;
            case 91:
                s = "other type";
                break;
            case 92:
                s = "other type";
                break;
            case 93:
                s = "other type";
                break;
            case 94:
                s = "other type";
                break;
            case 95:
                s = "other type";
                break;
            case 96:
                s = "other type";
                break;
            case 97:
                s = "other type";
                break;
            case 98:
                s = "other type";
                break;
            case 99:
                s = "other type, No additional information";
                break;
        }
        switch (_shipMainType) {
            case BASESTATION:
                s = "Base station";
                break;
            case SHIP_SAR:
                s = "SAR Aircraft";
                break;
        }
        return GeneralUtils.breakTextAt(s, 16);
    }

    public function getShipClass():String {
        return "A"
    }


    public function get callsign():String {
        if (_callsign === null) {
            return "---"
        }
        return _callsign;
    }

    public function get name():String {
        if (_name === null) {
            return "Unknown"
        }
        return _name;
    }

    public function get dimensionToBow():Number {
        return _dimensionToBow;
    }

    public function get dimensionToStern():Number {
        return _dimensionToStern;
    }

    public function get dimensionToPort():Number {
        return _dimensionToPort;
    }

    public function get dimensionToStarboard():Number {
        return _dimensionToStarboard;
    }

    public function get draught():Number {
        return _draught;
    }

    public function get destination():String {
        if (_destination === null) {
            return "---";
        }
        return GeneralUtils.breakTextAt(_destination, 16);
    }

    public function set callsign(value:String):void {
        _callsign = value;
    }

    public function set name(value:String):void {
        _name = value;
    }

    public function set dimensionToBow(value:Number):void {
        _dimensionToBow = value;
    }

    public function set dimensionToStern(value:Number):void {
        _dimensionToStern = value;
    }

    public function set dimensionToPort(value:Number):void {
        _dimensionToPort = value;
    }

    public function set dimensionToStarboard(value:Number):void {
        _dimensionToStarboard = value;
    }

    public function set draught(value:Number):void {
        _draught = value;
    }

    public function set destination(value:String):void {
        _destination = value;
    }

    public function getBearingValue():String {
        return isNaN(_bearing) ? "---" : Math.round(_bearing) + "°";
    }

    public function getDistanceValue():String {
        var unit:Distance = new Distance();
        return isNaN(_distanceFromOwnShip) ? "---" : formatNumber(unit.convertNumber(_distanceFromOwnShip)) + unit.getUnitShortString();
        return "----"
    }

    public function getCOGValue():String {
        return isNaN(_courseOverGround) ? "---" : Math.round(_courseOverGround) + "°";
    }

    public function getSOGValue():String {
        var unit:Speed = new Speed();
        return isNaN(_speedOverGround) ? "---" : formatNumber(unit.convertNumber(_speedOverGround)) + unit.getUnitShortString();
    }

    public function getCPAValue():String {
        var unit:Distance = new Distance();
        return isNaN(_closesPointOfApproach) ? "---" : formatNumber(unit.convertNumber(_closesPointOfApproach), 5, 0) + unit.getUnitShortString();
    }

    public function getTCPAValue():String {
        if (_timeToClosesPointOfApproach < 0) {
            return "Passed"
        }
        if (isNaN(_timeToClosesPointOfApproach)) {
            return "---"
        }
        var tcpaMinFloor:int = Math.floor(_timeToClosesPointOfApproach);
        var tcpaMin:int = Math.round(60 * (_timeToClosesPointOfApproach - tcpaMinFloor));

        return (tcpaMinFloor < 10 ? "0" + tcpaMinFloor : tcpaMinFloor) + ":" + (tcpaMin < 10 ? "0" + tcpaMin : tcpaMin.toString());
    }

    public static function formatNumber(value:Number, digit:uint=6, exp:uint=1):String {
        var s:String = value.toString();
        if(s.length>digit) {
            var p:Array = value.toExponential(exp).split("e");
            if(p[1].charAt(0)=="+") {
                p[1] = p[1].substr(1);
            }
            s = p[0] + "*10^" + p[1];
        }
        return s;
    }

}
}
