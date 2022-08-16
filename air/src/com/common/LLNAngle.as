package com.common {
import com.utils.EdoLocalStore;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

public class LLNAngle extends EventDispatcher {

    public static const LLN_UP_MIN_LIMIT:int = 20;
    public static const LLN_DOWN_MIN_LIMIT:int = 0;
    public static const LLN_MAX_LIMIT:int = 80;
    public static const LLN_DEFAULT_ANGLE:int = 40;
    public static const LLN_MANUAL:int = 0;
    public static const LLN_AUTO:int = 1;

    private static var _instance:LLNAngle;
    private var _llnUpAngle:Number = LLN_DEFAULT_ANGLE;
    private var _llnDownAngle:Number = LLN_DEFAULT_ANGLE;
    private var _llnType:int;

    function LLNAngle() {
        load();
    }

    public static function get instance():LLNAngle {
        if(_instance==null) {
            _instance = new LLNAngle();
        }
        return _instance;
    }

    public function set llnUpAngle(value:Number):void {
        if(value<LLN_UP_MIN_LIMIT) {
            _llnUpAngle = LLN_UP_MIN_LIMIT;
        } else if(value>LLN_MAX_LIMIT) {
            _llnUpAngle = LLN_MAX_LIMIT;
        } else {
            _llnUpAngle = value;
        }
        save();
        this.dispatchEvent(new Event("llnUpAngleChange"));
    }

    public function get llnUpAngle():Number {
        return _llnUpAngle;
    }

    public function set llnDownAngle(value:Number):void {
        if(value<LLN_DOWN_MIN_LIMIT) {
            _llnDownAngle = LLN_DOWN_MIN_LIMIT;
        } else if(value>LLN_MAX_LIMIT) {
            _llnDownAngle = LLN_MAX_LIMIT;
        } else {
            _llnDownAngle = value;
        }
        save();
        this.dispatchEvent(new Event("llnDownAngleChange"));
    }

    public function get llnDownAngle():Number {
        return _llnDownAngle;
    }

    public function get llnType():int {
        return _llnType;
    }

    public function set llnType(value:int):void {
        _llnType = value;
        save();
        this.dispatchEvent(new Event("llnTypeChange"));
    }

    public function save():void {
        var data:ByteArray = new ByteArray();
        data.writeDouble(_llnUpAngle);
        EdoLocalStore.setItem('llnUpAngle', data);
        data = new ByteArray();
        data.writeDouble(_llnDownAngle);
        EdoLocalStore.setItem('llnDownAngle', data);
        data = new ByteArray();
        data.writeInt(_llnType);
        EdoLocalStore.setItem('llnType', data);
    }

    public function load():void {
        var data:ByteArray = EdoLocalStore.getItem("llnUpAngle");
        if(data!=null) {
            _llnUpAngle = data.readDouble();
        } else {
            _llnUpAngle = LLN_DEFAULT_ANGLE;
        }
        data = EdoLocalStore.getItem("llnDownAngle");
        if(data!=null) {
            _llnDownAngle = data.readDouble();
        } else {
            _llnDownAngle = LLN_DEFAULT_ANGLE;
        }
        data = EdoLocalStore.getItem("llnType");
        if(data!=null) {
            _llnType = data.readInt();
        } else {
            _llnType = LLN_MANUAL;
        }
    }
}
}
