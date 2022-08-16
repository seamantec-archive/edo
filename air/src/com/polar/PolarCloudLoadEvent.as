/**
 * Created by seamantec on 07/07/14.
 */
package com.polar {
import flash.events.Event;

public class PolarCloudLoadEvent extends Event {

    public static const POLAR_CLOUD_LOAD:String = "PolarCloudLoadEvent";

    public static const LOAD_PROCESS:int = 0;
    public static const LOAD_READY:int = 1;

    private var _type:int;
    private var _data:Number;

    public function PolarCloudLoadEvent(type:int, data:Number) {
        super(POLAR_CLOUD_LOAD);
        _type = type;
        _data = data;
    }

    public function getType():int {
        return _type;
    }

    public function getData():Number {
        return _data;
    }
}
}
