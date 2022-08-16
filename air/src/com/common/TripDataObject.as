/**
 * Created by seamantec on 08/04/14.
 */
package com.common {
import com.sailing.units.Distance;
import com.sailing.units.Speed;

public class TripDataObject {

    public var utc:Boolean = false;
    public var i:int = 0;
    public var time:Number = 0;
    public var start:Number = 0;
    public var stand:Number = 0;
    public var go:Number = 0;
    public var avg:Speed = new Speed();
    public var max:Speed = new Speed();
    public var distance:Distance = new Distance();

    public function TripDataObject() {
    }
}
}
