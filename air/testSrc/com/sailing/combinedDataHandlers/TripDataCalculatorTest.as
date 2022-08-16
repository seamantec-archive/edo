/**
 * Created by seamantec on 02/01/14.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.Rmc;
import com.sailing.datas.TripData;

public class TripDataCalculatorTest {

    private var _testData:TripDataCalculator;
    private var _data:TripData;

    public function TripDataCalculatorTest() {
        _testData = new TripDataCalculator();
        _data = new TripData();
    }

    [Test]
    public function calculateTest():void {
        _data = _testData.dataChanged("rmc", setRmc(4351.503,1532.134,5.0), 0) as TripData;
        traceData(_data);
        _data = _testData.dataChanged("rmc", setRmc(4351.507,1532.132,5.0), 2000) as TripData;
        traceData(_data);
        _data = _testData.dataChanged("rmc", setRmc(4351.510,1532.132,5.2), 4000) as TripData;
        traceData(_data);
        _data = _testData.dataChanged("rmc", setRmc(4351.515,1532.128,5.4), 7000) as TripData;
        traceData(_data);
        _data = _testData.dataChanged("rmc", setRmc(4351.516,1532.126,5.3), 8000) as TripData;
        traceData(_data);
        _data = _testData.dataChanged("rmc", setRmc(4351.517,1532.123,4.9), 9000) as TripData;
        traceData(_data);
        _data = _testData.dataChanged("rmc", setRmc(4351.517,1532.119,3.8), 11000) as TripData;
        traceData(_data);
        _data = _testData.dataChanged("rmc", setRmc(4351.516,1532.118,3.6), 13000) as TripData;
        traceData(_data);
        _data = _testData.dataChanged("rmc", setRmc(4351.513,1532.113,3.4), 16000) as TripData;
        traceData(_data);
        _data = _testData.dataChanged("rmc", setRmc(4351.512,1532.113,3.2), 17000) as TripData;
        traceData(_data);
    }

    private function traceData(data:TripData):void {
        trace(data.time + " " + data.distance.getPureData() + " " + data.avgSpeed.value);
    }

    private function setRmc(lat:Number, lon:Number, sog:Number):Rmc {
        var rmc:Rmc = new Rmc();

        var latitude:Number = lat/100.0;
        var p1 = Math.floor(latitude);
        var p2 = 100.0 * (latitude - p1);
        rmc.lat = p1 + p2 / 60.0;

        var longitude:Number = lon/100.0;
        p1 = Math.floor(longitude);
        p2 = 100.0 * (longitude - p1);
        rmc.lon = p1 + p2 / 60.0;

        rmc.gpsSog.value = sog;
        return rmc;
    }
}
}
