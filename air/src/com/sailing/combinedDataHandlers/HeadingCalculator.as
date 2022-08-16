/**
 * Created by pepusz on 2014.07.31..
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;
import com.sailing.datas.Hdg;
import com.sailing.datas.Hdm;
import com.sailing.datas.Hdt;
import com.sailing.datas.Heading;
import com.sailing.datas.Vhw;

public class HeadingCalculator extends CombinedData {
    private const TIME_LIMIT:uint = 5000;
    public var data:Heading = new Heading();

    private var _startTime:Number;


    public function HeadingCalculator() {
        dataKey = "heading";
        listenerKeys.push("hdg");
        listenerKeys.push("hdm");
        listenerKeys.push("hdt");
        listenerKeys.push("vhw");
        _startTime = 0;
    }


    override public function reset():void {
        _startTime = 0;
        data = new Heading();
        lastDatas = new Object();
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        var hdg:Hdg = lastDatas.hdg;

        if (hdg != null) {
            if (key == "hdg") {
                data.heading = hdg.sensorHeading;
                return data;
            } else {
                return null;
            }
        }
        if (timestamp - _startTime > TIME_LIMIT && _startTime != 0) {
            var hdm:Hdm = lastDatas.hdm;
            if (hdm != null) {
                data.heading = hdm.heading;
                return data
            }
            var hdt:Hdt = lastDatas.hdt;
            if (hdt != null) {
                data.heading = hdt.heading;
                return data;
            }

            var vhw:Vhw = lastDatas.vhw
            if (vhw != null) {
                data.heading = vhw.waterHeading;
                return data;
            }
        }
        if (_startTime == 0) {
            _startTime = timestamp;
        }
        return null;

    }
}
}
