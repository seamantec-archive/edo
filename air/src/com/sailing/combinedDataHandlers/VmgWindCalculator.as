/**
 * Created by seamantec on 06/02/14.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.TrueWindC;
import com.sailing.datas.VmgWind;
import com.sailing.units.Speed;

import flash.utils.getTimer;

public class VmgWindCalculator extends CombinedData {

    private var data:VmgWind = new VmgWind();
    var DTR:Number = Math.PI / 180;

    public function VmgWindCalculator() {
        dataKey = "vmgwind";
        listenerKeys.push("positionandspeed");
        listenerKeys.push("truewindc");
    }

    override public function reset():void {
        data = new VmgWind();
        lastDatas = new Object();
    }

    public override function calculate(timestamp:Number, key:String):BaseSailData {
        if (lastDatas.positionandspeed == null || lastDatas.truewindc == null) {
            return null;
        }
        data.lastTimestamp = getTimer();
        data.wind = new Speed();
        data.wind.value = Math.cos((lastDatas.truewindc as TrueWindC).windDirection.value * DTR) * (lastDatas.positionandspeed as PositionAndSpeed).sog.value;
        if (isNaN(data.wind.getPureData())) {
            return null;
        }

        return data;
    }
}
}
