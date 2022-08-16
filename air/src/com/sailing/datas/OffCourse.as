/**
 * Created by pepusz on 2014.08.02..
 */
package com.sailing.datas {
import com.sailing.units.Direction;

public class OffCourse extends BaseSailData {
   public var offCourse:Direction = new Direction();

    public function OffCourse() {
        super();
        _paramsDisplayName["offCourse"] = { displayName: "Off course", order: 0 };
    }

    public override function get displayName():String {
        return "Off course";
    }
}
}
