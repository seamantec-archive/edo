/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.12.
 * Time: 15:11
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.ais.events {
import flash.events.Event;

public class ShipRemovedEvent extends Event {
    public static const SHIP_REMOVED_EVENT:String = "ship-removed"
    public var mmsi:String;

    public function ShipRemovedEvent(mmsi:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(SHIP_REMOVED_EVENT, bubbles, cancelable);
        this.mmsi = mmsi;
    }
}
}
