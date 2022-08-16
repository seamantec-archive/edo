/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.24.
 * Time: 13:29
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.ais {
public class SarAircraft extends Vessel {
    public var altitude:uint;
    public var radioStatus:uint;
    public function SarAircraft(mmsi:String) {
        super(mmsi);
    }
}
}
