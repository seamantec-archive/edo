/**
 * Created by seamantec on 21/01/14.
 */
package com.sailing.combinedDataHandlers {

import com.sailing.datas.BaseSailData;
import com.sailing.datas.Bwc;
import com.sailing.datas.Eta;
import com.sailing.datas.VmgWaypoint;

public class EtaCalculator extends CombinedData {

    private var _data:Eta = new Eta();
    private var _n:int;
    private const VMG_MIN:Number = 0.5;

    private var _lastBwc:Number;
    private var _lastVmg:Number;

    public function EtaCalculator() {
        dataKey = "eta";
        listenerKeys.push("bwc");
        listenerKeys.push("vmgwaypoint");

        _n = 0;
    }

    override public function reset():void {
        _data = new Eta();
        lastDatas = new Object();
        _n = 0;
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        var bwc:Bwc = lastDatas.bwc;
        var vmg:VmgWaypoint = lastDatas.vmgwaypoint;

        if(bwc!=null && bwc.isValid() && vmg!=null && vmg.isValid()) {
            var bwcDistance:Number = bwc.waypointDistance.getPureData();
            var vmgWaypoint:Number = vmg.waypoint.getPureData();
            //var bwcDistance:Number = bwc.waypointDistance.getPureData();

            if(_n==0 || bwcDistance!=_lastBwc || vmgWaypoint!=_lastVmg) {
                if(bwcDistance==0 || vmgWaypoint<VMG_MIN) {
                    return null;
                }

                _n++;

                var eta:Number = bwcDistance/vmgWaypoint;
                eta *= 3600;

                if(_n>1) {
                    _data.eta = (sum(_n-1)*_data.eta + _n*eta)/sum(_n);
                } else {
                    _data.eta = eta;
                }

                _lastBwc = bwcDistance;
                _lastVmg = vmgWaypoint;
            }

            return _data;
        }

        return null;
    }

    private function sum(n:int):Number {
        return (n*(n+1))/2;
    }
}
}
