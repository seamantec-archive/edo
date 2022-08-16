/**
 * Created by pepusz on 2014.08.02..
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.*;

public class OffCourseCalculator extends CombinedData {
    public var data:OffCourse = new OffCourse();

    public function OffCourseCalculator() {
        dataKey = "offcourse";
        listenerKeys.push("positionandspeed");
        listenerKeys.push("bwc");

    }

    override public function reset():void {
        data = new OffCourse();
        lastDatas = new Object();
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        var heading:PositionAndSpeed = lastDatas.positionandspeed;
        var bwc:Bwc = lastDatas.bwc;

        if (heading != null && bwc != null && bwc.waypointId != null && bwc.waypointId != "") {
            if (bwc.waypointBearing.getPureData() - heading.cog.getPureData() <= 180) {
                data.offCourse.value = Math.abs(bwc.waypointBearing.getPureData() - heading.cog.getPureData());
            } else {
                data.offCourse.value = Math.abs((heading.cog.getPureData() + 360) - bwc.waypointBearing.getPureData());
            }
            return data;
        }
        return null;
    }
}
}
