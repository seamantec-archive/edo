/**
 * Created by seamantec on 09/04/14.
 */
package com.common {
import flash.events.Event;
import flash.events.EventDispatcher;

public class TripDataEventHandler extends EventDispatcher {

    private static var _instance:TripDataEventHandler;

    public function TripDataEventHandler() {
    }

    public static function get instance():TripDataEventHandler {
        if(_instance==null) {
            _instance = new TripDataEventHandler();
        }
        return _instance;
    }

    public function resetUser():void {
        this.dispatchEvent(new Event("resetUser"));
    }

    public function enableTripData():void {
        this.dispatchEvent(new Event("enableTripData"));
    }

    public function disableTripData():void {
        this.dispatchEvent(new Event("disableTripData"));
    }
}
}
