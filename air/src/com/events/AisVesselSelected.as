/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.05.
 * Time: 13:36
 * To change this template use File | Settings | File Templates.
 */
package com.events {
import flash.events.Event;

public class AisVesselSelected extends Event {
    public static const AIS_VESSEL_SELECTED:String = "aisVesselSelectedMMSI"
    public var mmsi:String;

    public function AisVesselSelected(mmsi:String) {
        this.mmsi = mmsi;
        super(AIS_VESSEL_SELECTED);
    }
}
}
