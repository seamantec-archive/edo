/**
 * Created by pepusz on 2014.07.31..
 */
package com.sailing.combinedDataHandlers {
import com.common.WindCorrection;
import com.sailing.datas.ApparentWind;
import com.sailing.datas.BaseSailData;
import com.sailing.datas.MwvR;
import com.sailing.datas.Vwr;
import com.sailing.units.Unit;

public class ApparentWindCalculator extends CombinedData {
    private const TIME_LIMIT:uint = 5000;
    public var data:ApparentWind = new ApparentWind();
    private var _startTime:Number;

    public function ApparentWindCalculator() {
            dataKey = "apparentwind";
            listenerKeys.push("mwvr")
            listenerKeys.push("vwr")
            _startTime = 0;
        }

        override public function reset():void {
            _startTime = 0;
            data = new ApparentWind();
            lastDatas = new Object();
        }

        override public function calculate(timestamp:Number, key:String):BaseSailData {
            var mwvr:MwvR= lastDatas.mwvr;

            if (mwvr != null) {
                if (key == "mwvr") {
                    data.windDirection.value = Unit.toInterval(mwvr.windDirection.getPureData() + WindCorrection.instance.windCorrection);
                    setAngle();
                    data.windSpeed.value = mwvr.windSpeed.getPureData();
                    return data;
                } else {
                    return null;
                }
            }
            if (timestamp - _startTime > TIME_LIMIT && _startTime != 0) {
                var vwr:Vwr = lastDatas.vwr;
                if (vwr != null) {
                    if (vwr.windDirection.getPureData() < 0) {
                        data.windDirection.value = 360 + vwr.windDirection.getPureData()
                    } else {
                        data.windDirection.value = vwr.windDirection.getPureData()
                    }
                    data.windDirection.value = Unit.toInterval(data.windDirection.value + WindCorrection.instance.windCorrection)
                    setAngle();
                    data.windSpeed.value = vwr.windSpeed.getPureData();
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
