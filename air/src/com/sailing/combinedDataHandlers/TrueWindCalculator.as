/**
 * Created by pepusz on 2014.07.31..
 */
package com.sailing.combinedDataHandlers {
import com.common.WindCorrection;
import com.sailing.datas.BaseSailData;
import com.sailing.datas.MwvT;
import com.sailing.datas.TrueWindC;
import com.sailing.datas.Vwt;
import com.sailing.units.Unit;

public class TrueWindCalculator extends CombinedData {
    private const TIME_LIMIT:uint = 5000;
    public var data:TrueWindC = new TrueWindC();

    private var _startTime:Number;

    public function TrueWindCalculator() {
        dataKey = "truewindc";
        listenerKeys.push("mwvt")
        listenerKeys.push("vwt")
        _startTime = 0;
    }

    override public function reset():void {
        _startTime = 0;
        data = new TrueWindC();
        lastDatas = new Object();
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        var mwvt:MwvT = lastDatas.mwvt;

        if (mwvt != null) {
            if (key == "mwvt") {
                data.windDirection.value = Unit.toInterval(mwvt.windDirection.getPureData() + WindCorrection.instance.windCorrection);
                setAngle();
                data.windSpeed.value = mwvt.windSpeed.getPureData();
                return data;
            } else {
                return null;
            }
        }
        if (timestamp - _startTime > TIME_LIMIT && _startTime != 0) {
            var vwt:Vwt = lastDatas.vwt;
            if (vwt != null) {
                if (vwt.relativeWindAngleToVessel.getPureData() < 0) {
                    data.windDirection.value = 360 + vwt.relativeWindAngleToVessel.getPureData()
                } else {
                    data.windDirection.value = vwt.relativeWindAngleToVessel.getPureData()
                }
                data.windDirection.value = Unit.toInterval(data.windDirection.value + WindCorrection.instance.windCorrection)
                setAngle();
                data.windSpeed.value = vwt.windSpeed.getPureData();
                return data;
            }
        }
        if (_startTime == 0) {
            _startTime = timestamp;
        }
        return null;

    }

    private function setAngle():void {
        if (data.windDirection.getPureData() > 180) {
            data.windAngle.value = data.windDirection.getPureData() - 360;
        } else {
            data.windAngle.value = data.windDirection.getPureData()
        }
    }
}
}
