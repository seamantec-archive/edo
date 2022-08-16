/**
 * Created by pepusz on 2014.08.01..
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;
import com.sailing.datas.Dbt;
import com.sailing.datas.Dpt;
import com.sailing.datas.WaterDepth;

import flash.events.Event;

public class WaterDepthCalculator extends CombinedData {
    private const TIME_LIMIT:uint = 5000;
    public var data:WaterDepth = new WaterDepth();

    private var _startTime:Number;


    public function WaterDepthCalculator() {
        dataKey = "waterdepth";
        listenerKeys.push("dbt")
        listenerKeys.push("dpt")
        _startTime = 0;
    }

    override public function reset():void {
        _startTime = 0;
        data = new WaterDepth();
        lastDatas = new Object();
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        var dpt:Dpt = lastDatas.dpt;
        if (dpt != null) {
            data.waterDepth.value = dpt.waterDepth.getPureData();
            data.offset.value = dpt.offset.getPureData();
            data.waterDepthWithOffset.value = dpt.waterDepthWithOffset.getPureData();
            WaterDepth.eventDispatcher.dispatchEvent(new Event("offsetChanged"));
            return data;
        }
        if (timestamp - _startTime > TIME_LIMIT && _startTime != 0) {
            var dbt:Dbt = lastDatas.dbt;
            if (dbt != null) {
                data.waterDepth.value = dbt.waterDepth.getPureData();
                data.offset.value = 0;
                data.waterDepthWithOffset.value = data.waterDepth.getPureData();
                WaterDepth.eventDispatcher.dispatchEvent(new Event("offsetChanged"));
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
