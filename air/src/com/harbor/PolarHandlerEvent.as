/**
 * Created by pepusz on 15. 02. 17..
 */
package com.harbor {
import flash.events.Event;

public class PolarHandlerEvent extends Event {

    public static const POLAR_LIST_STATUS_CHANGE:String = "polar-list-status-change";
    public static const POLAR_LIST_READY:String = "polar-list-ready";
    public static const POLAR_ELEMENT_ADDED:String = "polar-element-added";

    public function PolarHandlerEvent(type:String) {
        super(type, false);
    }
}
}
