/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.16.
 * Time: 14:32
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;
import com.sailing.datas.Windsmoothapp;

public class WindSmoothAppCaclulator extends CombinedData {
    public static const AVG_COUNTER:uint = 3;
    private var _lastValues:Array = [];
    private var _actualValueX:Number = 0;
    private var _refreshTime:Number = 0.1;
    private var _tempValue:Number = 0;
    private var _actualValue:Number = 0;
    private var data:Windsmoothapp = new Windsmoothapp();
    private var _timestamp:Number = 0;

    public function WindSmoothAppCaclulator() {
        dataKey = "windsmoothapp";
        listenerKeys.push("apparentwind");
    }

    override public function reset():void {
        data = new Windsmoothapp();
        lastDatas = new Object();
        _lastValues = [];
        _timestamp = 0;
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        _timestamp = timestamp;
        _lastValues.push(lastDatas.apparentwind.windDirection.getPureData());
        if (_lastValues.length > AVG_COUNTER) {
            _lastValues.shift();
        }
        data.windDirectionExpAvg.value = calculateExpAverage();
        return data;
    }

    private function calculateAverage():Number {
        var length:int = _lastValues.length;
        if (length == 0) {
            return 0;
        }
        var sum:Number = 0;
        for (var i:int = 0; i < length; i++) {
            sum += _lastValues[i];
        }
        return sum / length;
    }

    private function calculateWeightedAverage():Number {
        var length:int = _lastValues.length;
        if (length == 0) {
            return 0;
        }
        var sum:Number = 0;
        var weightsSum:uint = 0;
        for (var i:int = 0; i < length; i++) {
            sum += _lastValues[i] * (length - i);
            weightsSum += length - i;
        }
        return sum / weightsSum;
    }

    var alpha:uint = 0.18;

    private function calculateExpAverage():Number {
        var length:int = _lastValues.length;
        if (length == 0) {
            return 0;
        }
        var sum:Number = 0;
        var weightsSum:uint = 0;
        for (var i:int = 0; i < length; i++) {
            sum += _lastValues[i] * Math.pow(1 - alpha, length - 1 - i);
            weightsSum += Math.pow(1 - alpha, i);
        }
        return sum / weightsSum;
    }
}
}
