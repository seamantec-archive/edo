/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.07.
 * Time: 13:25
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.ais.events {
import com.sailing.ais.Vessel;

import flash.events.Event;

public class ShipChangeEvent extends Event {
    public static const SHIP_CHANGED_EVENT:String="ship-changed"
    public var vessel:Vessel;
    public function ShipChangeEvent(obj:Vessel, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(SHIP_CHANGED_EVENT, bubbles, cancelable);
        this.vessel = obj;
    }
}
}
