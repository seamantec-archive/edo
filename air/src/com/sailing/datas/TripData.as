/**
 * Created by seamantec on 02/01/14.
 */
package com.sailing.datas {
import com.common.TripDataObject;

public class TripData extends BaseSailData {

    public var overall:TripDataObject;
    public var user:TripDataObject;
    public var day:TripDataObject;

    public function TripData() {
        overall = new TripDataObject();
        user = new TripDataObject();
        day = new TripDataObject();
    }
}
}
