/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 15/11/13
 * Time: 16:37
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.events.AnchorChangeEvent;

import flash.events.EventDispatcher;

public class AnchorChange extends EventDispatcher {

    private static var _instance;
    private var _max:Number;
    private var _enable:Boolean;

    private static var _isLogReplay:Boolean;

    public function AnchorChange() {
    }

    public static function get instance():AnchorChange {
        if(_instance==null) {
            _instance = new AnchorChange();
        }
        return _instance;
    }

    public function maxChange(max:Number):void {
        _max = max;
        dispatchEvent(new AnchorChangeEvent(max, false, _enable));
    }

    public function setEnable(enable:Boolean):void {
        _enable = enable;
        dispatchEvent(new AnchorChangeEvent(_max, false, enable));
    }

    public function reset():void {
        dispatchEvent(new AnchorChangeEvent(_max, true, _enable));
    }

    public function set max(max:Number):void {
        _max = max;
    }

    public function get max():Number {
        return _max;
    }

    public function set logReplay(value:Boolean):void {
        _isLogReplay = value;
    }

    public function get logReplay():Boolean {
        return _isLogReplay;
    }

    public function set enable(enable:Boolean):void {
        _enable = enable;
    }

    public function get enable():Boolean {
        return _enable;
    }
}
}
