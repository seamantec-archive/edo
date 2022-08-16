/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.07.
 * Time: 16:49
 * To change this template use File | Settings | File Templates.
 */
package com.common {
public class Coordinate {
    private var _lat:Number;
    private var _lon:Number;

    public function Coordinate(lat:Number, lon:Number) {
        this._lat = lat;
        this._lon = lon;
    }

    public function latInRad():Number {
        return lat * (Math.PI / 180);
    }

    public function lonInRad():Number {
        return lon * (Math.PI / 180);
    }

    public function get lat():Number {
        return _lat;
    }

    public function set lat(value:Number):void {
        _lat = value;
    }

    public function get lon():Number {
        return _lon;
    }

    public function set lon(value:Number):void {
        _lon = value;
    }

    public function toCoString():String {
        return "lat: " + lat + " lon: " + lon;
    }
    public function toCoRadString():String {
        return "lat: " + latInRad() + " lon: " + lonInRad();
    }
}
}
