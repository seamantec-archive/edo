/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.08.
 * Time: 17:12
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;
import com.sailing.datas.Mwv;
import com.sailing.datas.MwvR;

public class MwvRHandler extends CombinedData {
    private var data:MwvR = new MwvR()

    public function MwvRHandler() {
        dataKey = "mwvr";
        listenerKeys.push("mwv");
    }

    override public function reset():void {
        data = new MwvR();
        lastDatas = new Object();
    }

    public override function calculate(timestamp:Number, key:String):BaseSailData {
        if (lastDatas.mwv.windDirectionRef == "r" || lastDatas.mwv.windDirectionRef == "R") {
            data.windDirection.value = (lastDatas.mwv as Mwv).windAngle.getPureData();
            if (data.windDirection.getPureData() > 180) {
                data.windAngle.value = data.windDirection.getPureData() - 360;
            } else {
                data.windAngle.value = data.windDirection.getPureData()
            }
            data.windSpeed.value = lastDatas.mwv.windSpeed.getPureData();
            return data;
        }
        return null;
    }
}
}
