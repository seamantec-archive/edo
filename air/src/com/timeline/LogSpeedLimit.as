/**
 * Created by seamantec on 09/01/14.
 */
package com.timeline {
public class LogSpeedLimit {

    private var _speed:Number;
    private var _limit:Number;

    public function LogSpeedLimit(speed:Number, limit:Number) {
        _speed = speed;
        _limit = limit;
    }

    public function set speed(speed:Number):void {
        _speed = speed;
    }

    public function get speed():Number {
        return _speed;
    }

    public function set limit(limit:Number):void {
        _limit = limit;
    }

    public function get limit():Number {
        return _limit;
    }

}
}
