/**
 * Created by pepusz on 2014.07.08..
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.Apb;
import com.sailing.datas.BaseSailData;
import com.sailing.datas.CrossTrack;
import com.sailing.datas.Rmb;
import com.sailing.datas.Xte;

public class CrosstrackCalculator extends CombinedData {
    public var data:CrossTrack = new CrossTrack()
    private var registeredKey:String = "";

    public function CrosstrackCalculator() {
        dataKey = "crosstrack";
        listenerKeys.push("apb");
        listenerKeys.push("rmb");
        listenerKeys.push("xte");
    }

    override public function reset():void {
        data = new CrossTrack();
        lastDatas = new Object();
        registeredKey = "";
    }

    public override function calculate(timestamp:Number, key:String):BaseSailData {
        var apb:Apb = lastDatas.apb;
        var rmb:Rmb = lastDatas.rmb;
        var xte:Xte = lastDatas.xte;
        if (registeredKey == "") {
            if (apb != null && apb.isValid()) {
                registeredKey = "apb";
            } else if (rmb != null && rmb.isValid()) {
                registeredKey = "rmb"
            } else if (xte != null && xte.isValid()) {
                registeredKey = "xte";
            }
        }

        switch (registeredKey) {
            case "apb":
                data.mergeFromApb(apb);
                break;
            case "rmb":
                data.mergeFromRmb(rmb)
                break;
            case "xte":
                data.mergeFromXte(xte)
                break;
        }
        if(registeredKey != ""){
           return data
        }
        return null;

    }
}
}
