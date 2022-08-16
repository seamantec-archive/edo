/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.08.
 * Time: 16:49
 * To change this template use File | Settings | File Templates.
 */
package com.common {
import flash.display.Sprite;
import flash.events.Event;

public class OwnShip extends Sprite{
    private var _coordinate:Coordinate;
    private var _timestamp:Number;
    private var _heading:Number;
    private var _speed:Number;

    public function get speed():Number {
        return _speed;
    }

    public function set speed(value:Number):void {
        if(_speed == value){
            return;
        }
        _speed = value;
        dispatchEvent(new Event("speed-changed"))

    }

    public function get timestamp():Number {
        return _timestamp;
    }
    //TODO refactor az eventeket kivenni kulon osztalyba
    public function set timestamp(value:Number):void {
        if(value === _timestamp){
            return;
        }
        _timestamp = value;
        dispatchEvent(new Event("timestamp-changed"))
    }

    public function get heading():Number {
        return _heading;
    }

    public function set heading(value:Number):void {
        if(value === _heading && Math.abs(value-_heading) > 0.5){
            return;
        }
        _heading = value;
        dispatchEvent(new Event("heading-changed"))
    }

    public function get coordinate():Coordinate {
        return _coordinate;
    }

    public function set coordinate(value:Coordinate):void {
        if(_coordinate != null && value != null && value.lat === _coordinate.lat && value.lon == _coordinate.lon){
            return;
        }
        _coordinate = value;
        dispatchEvent(new Event("coordinate-changed"))

    }

    public function OwnShip() {
    }
}
}
