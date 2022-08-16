/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.21.
 * Time: 15:50
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import com.events.UnitChangedEvent;
import com.utils.EdoLocalStore;

import flash.display.Sprite;
import flash.utils.ByteArray;

public class UnitHandler extends Sprite {
    private static var _instance:UnitHandler;

    private var _temperature:Number = Temperature.CELSIUS;
    private var _depth:Number = Depth.METER;
    private var _distance:Number = Distance.NM;
    private var _smallDistance:Number = SmallDistance.METER;
    private var _anchorDistance:Number = AnchorDistance.FEET;
    private var _speed:Number = Speed.KTS;
    private var _windSpeed:Number = WindSpeed.KTS;
    private var _direction:Number = Direction.MAGNETIC;
    private var _prevTemperature:Number = Temperature.CELSIUS;
    private var _prevDepth:Number = Depth.METER;
    private var _prevDistance:Number = Distance.NM;
    private var _prevSmallDistance:Number = SmallDistance.METER;
    private var _prevAnchorDistance:Number = AnchorDistance.FEET;
    private var _prevSpeed:Number = Speed.KTS;
    private var _prevWindSpeed:Number = WindSpeed.KTS;
    private var _prevDirection:Number = Direction.MAGNETIC;


    public function UnitHandler() {

        if (_instance == null) {
            _temperature = Temperature.CELSIUS;
            _depth = Depth.METER;
            _distance = Distance.NM;
            _anchorDistance = AnchorDistance.FEET;
            _speed = Speed.KTS;
            _windSpeed = WindSpeed.KTS;
        }
    }

    public function get temperature():Number {
        return _temperature;
    }

    public function set temperature(value:Number):void {
        _prevTemperature = _temperature
        _temperature = value;
        dispatchEvent(new UnitChangedEvent(Temperature));
    }

    public function get depth():Number {
        return _depth;
    }

    public function set depth(value:Number):void {
        _prevDepth = _depth
        _depth = value;
        dispatchEvent(new UnitChangedEvent(Depth));
    }

    public function get distance():Number {
        return _distance;
    }

    public function set distance(value:Number):void {
        _prevDistance = _distance;
        _distance = value;
        if (_distance === Distance.MILE || _distance === Distance.NM) {
            anchorDistance = AnchorDistance.FEET;
        } else if (_distance === Distance.KM || _distance === Distance.METER) {
            anchorDistance = AnchorDistance.METER;
        }
        dispatchEvent(new UnitChangedEvent(Distance));
        dispatchEvent(new UnitChangedEvent(SmallDistance));
    }


    public function get smallDistance():Number {
        return _smallDistance;
    }

    public function set smallDistance(value:Number):void {
        _prevSmallDistance = _smallDistance;
        _smallDistance = value;
        dispatchEvent(new UnitChangedEvent(SmallDistance));
    }

    public function get anchorDistance():Number {
        return _anchorDistance;
    }

    public function set anchorDistance(value:Number):void {
        _prevAnchorDistance = _anchorDistance
        _anchorDistance = value;
        dispatchEvent(new UnitChangedEvent(AnchorDistance));

    }

    public function get speed():Number {
        return _speed;
    }

    public function set speed(value:Number):void {
        _prevSpeed = _speed;
        _speed = value;
        dispatchEvent(new UnitChangedEvent(Speed));
    }

    public function get windSpeed():Number {
        return _windSpeed;
    }

    public function set windSpeed(value:Number):void {
        _prevWindSpeed = _windSpeed;
        _windSpeed = value;
        dispatchEvent(new UnitChangedEvent(WindSpeed));
    }


    public function saveUnits():void {
        var sObject:Object = {};
        sObject["_temperature"] = _temperature;
        sObject["_depth"] = _depth;
        sObject["_distance"] = _distance;
        sObject["_smallDistance"] = _smallDistance;
        sObject["_anchorDistance"] = _anchorDistance;
        sObject["_speed"] = _speed;
        sObject["_windSpeed"] = _windSpeed;
        sObject["_direction"] = _direction;
//        sObject["_direction"] = _direction;
        var data:ByteArray = new ByteArray();
        data.writeObject(sObject);
        data.position = 0;
        EdoLocalStore.setItem('unitSettings', data);
    }

    public function loadUnits():void {
        var tempInstance = EdoLocalStore.getItem("unitSettings");
        if (tempInstance != null) {
            var sObject:Object = tempInstance.readObject();
            _temperature = Number(sObject["_temperature"]);
            _depth = Number(sObject["_depth"]);
            _distance = Number(sObject["_distance"]);
            _smallDistance = Number(sObject["_smallDistance"]);
            _anchorDistance = Number(sObject["_anchorDistance"]);
            _speed = Number(sObject["_speed"]);
            _windSpeed = Number(sObject["_windSpeed"]);
            _direction = Number(sObject["_direction"]);
            _prevTemperature = Number(sObject["_temperature"]);
            _prevDepth = Number(sObject["_depth"]);
            _prevDistance = Number(sObject["_distance"]);
            _prevSmallDistance = Number(sObject["_smallDistance"]);
            _prevAnchorDistance = Number(sObject["_anchorDistance"]);
            _prevSpeed = Number(sObject["_speed"]);
            _prevWindSpeed = Number(sObject["_windSpeed"]);
            _prevDirection = Number(sObject["_direction"]);
//            _direction = Number(sObject["_direction"]);
        }
    }


    public function get direction():Number {
        return _direction;
    }

    public function set direction(value:Number):void {
        _prevDirection = _direction;
        _direction = value;
        dispatchEvent(new UnitChangedEvent(Direction));
    }

    public static function get instance():UnitHandler {
        if (_instance == null) {
            _instance = new UnitHandler();
        }
        return _instance;
    }


    public function get prevTemperature():Number {
        return _prevTemperature;
    }

    public function get prevDepth():Number {
        return _prevDepth;
    }

    public function get prevDistance():Number {
        return _prevDistance;
    }

    public function get prevSpeed():Number {
        return _prevSpeed;
    }

    public function get prevWindSpeed():Number {
        return _prevWindSpeed;
    }

    public function get prevDirection():Number {
        return _prevDirection;
    }


    public function get prevAnchorDistance():Number {
        return _prevAnchorDistance;
    }


    public function get prevSmallDistance():Number {
        return _prevSmallDistance;
    }
}
}
