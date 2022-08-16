/**
 * Created by seamantec on 06/02/14.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;
import com.sailing.datas.Bwc;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.VmgWaypoint;
import com.sailing.units.Speed;

public class VmgWaypointCalculator extends CombinedData {

    private var data:VmgWaypoint = new VmgWaypoint();
    private var DTR:Number = Math.PI / 180;

    public function VmgWaypointCalculator() {
        dataKey = "vmgwaypoint";
        listenerKeys.push("positionandspeed");
        listenerKeys.push("bwc");
    }

    override public function reset():void {
        data = new VmgWaypoint();
        lastDatas = new Object();
    }

    public override function calculate(timestamp:Number, key:String):BaseSailData {
        if (lastDatas.positionandspeed == null || lastDatas.bwc == null || (lastDatas.bwc as Bwc).waypointId == null || (lastDatas.bwc as Bwc).waypointId == "") {
            return null;
        }

        data.waypoint = new Speed();
        data.waypoint.value = Math.cos(((lastDatas.bwc as Bwc).waypointBearing.value - (lastDatas.positionandspeed as PositionAndSpeed).sog.value) * DTR) * (lastDatas.positionandspeed as PositionAndSpeed).sog.value;
        if (isNaN(data.waypoint.getPureData())) {
            return null;
        }

        return data;
    }
}
}
