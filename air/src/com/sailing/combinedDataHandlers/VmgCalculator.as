/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.26.
 * Time: 18:46
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;
import com.sailing.datas.Bwc;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.TrueWindC;
import com.sailing.datas.Vmg;
import com.sailing.units.Speed;

import flash.utils.getTimer;

public class VmgCalculator extends CombinedData {

    private var data:Vmg = new Vmg();
    private var DTR:Number = Math.PI / 180;

    public function VmgCalculator() {
        dataKey = "vmg";
        listenerKeys.push("bwc");
        listenerKeys.push("positionandspeed");
        listenerKeys.push("truewindc");
    }

    override public function reset():void {
        data = new Vmg();
        lastDatas = new Object();
    }

    public override function calculate(timestamp:Number, key:String):BaseSailData {
        if (lastDatas.positionandspeed == null) {
            return null;
        }
        data.lastTimestamp = getTimer();
        if (lastDatas.truewindc != null) {
            data.wind = new Speed();
            data.wind.value = Math.cos((lastDatas.truewindc as TrueWindC).windDirection.value * DTR) * (lastDatas.positionandspeed as PositionAndSpeed).sog.value;
            if (isNaN(data.wind.getPureData())) {
                data.wind.value = 0
            }
        }
        if (lastDatas.bwc != null && (lastDatas.bwc as Bwc).waypointId != "") {
            data.waypoint = new Speed();
            data.waypoint.value = Math.cos(((lastDatas.bwc as Bwc).waypointBearing.value - (lastDatas.positionandspeed as PositionAndSpeed).sog.value) * DTR) * (lastDatas.positionandspeed as PositionAndSpeed).sog.value;
            if (isNaN(data.waypoint.getPureData())) {
                data.waypoint.value = 0
            }
        }
        return data;
    }

}
}
