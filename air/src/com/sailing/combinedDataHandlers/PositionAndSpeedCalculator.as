/**
 * Created by seamantec on 13/05/14.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;
import com.sailing.datas.Gga;
import com.sailing.datas.Gll;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.Rmc;
import com.sailing.datas.Vtg;
import com.sailing.units.Unit;

public class PositionAndSpeedCalculator extends CombinedData {

    private const TIME_LIMIT:uint = 10000;

    public var data:PositionAndSpeed = new PositionAndSpeed();

    private var _time:Number;
    private var _hasRmc:Boolean;

    public function PositionAndSpeedCalculator() {
        dataKey = "positionandspeed";
        listenerKeys.push("gga");
        listenerKeys.push("gll");
        listenerKeys.push("rmc");
        listenerKeys.push("vtg");

        _time = 0;
        _hasRmc = false;
    }

    override public function reset():void {
        data = new PositionAndSpeed();
        lastDatas = new Object();
        _time = 0;
        _hasRmc = false;
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        var gga:Gga = lastDatas.gga;
        var gll:Gll = lastDatas.gll;
        var rmc:Rmc = lastDatas.rmc;
        var vtg:Vtg = lastDatas.vtg;

        if (_hasRmc || _time == 0 || ((timestamp - _time) <= TIME_LIMIT)) {
            if (rmc != null) {
                _hasRmc = true;
                if (data.lat != rmc.lat
                        || data.lon != rmc.lon
                        || data.sog.getPureData() != rmc.gpsSog.getPureData()
                        || data.cog.getPureData() != rmc.gpsCog.getPureData()
                        || data.lastTimestamp != rmc.lastTimestamp) {
                    _time = timestamp;
                    data.lat = rmc.lat;
                    data.lon = rmc.lon;
                    data.sog.value = rmc.gpsSog.getPureData();
                    //if(rmc.gpsCog.value!=Unit.INVALID_VALUE) {
                    data.cog.value = rmc.gpsCog.getPureData();
//                   } else {
//                       data.cog.value = Unit.INVALID_VALUE;
//                   }

                    return data;
                }
            }
        } else {
            if (!_hasRmc || rmc.gpsCog.value == Unit.INVALID_VALUE) {
                if (vtg != null) {
                    data.sog.value = vtg.speedOverGround.getPureData();
                    data.cog.value = vtg.courseOverGround.getPureData();
                }
                if (gga != null) {
                    data.lat = gga.lat;
                    data.lon = gga.lon;

                    return data;
                }
                if (gga == null && gll != null) {
                    data.lat = gll.lat;
                    data.lon = gll.lon;

                    return data;
                }
            }
        }

        return null;
    }

}
}
