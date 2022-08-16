/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.04.25.
 * Time: 13:24
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.ais.events {
import flash.events.Event;

public class AisAlertEvent extends Event {
    public var mmsi:String
    public static const AIS_ALERT:String = "aisAlert"
    public function AisAlertEvent(mmsi:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(AIS_ALERT, bubbles, cancelable);
        this.mmsi = mmsi;
    }
}
}
