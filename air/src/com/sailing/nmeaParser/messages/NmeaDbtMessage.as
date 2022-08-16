package com.sailing.nmeaParser.messages {
import com.sailing.datas.Dbt;
import com.sailing.units.Depth;

/*
 DBT - Depth below transducer
 DBT,0017.6,f,0005.4,M
 0017.6,f     17.6 feet
 0005.4,M     5.4 Metres
 */
public class NmeaDbtMessage implements NmeaMessage {

    private var data:Dbt = new Dbt();
    private var isValid:Boolean = true;

    public function parse(packet:String):void {
        var parts:Array = packet.split(",");
        if (parts[3].length > 0) {
            data.waterDepth.value = new Number(parts[3]);
            isValid = true;
        } else if (parts[1].length > 0) {
            data.waterDepth.value = Depth.convertFromFeet(new Number(parts[1]));
            isValid = true;
        } else {
            isValid = false;
        }
    }

    public function process():Object {
        return isValid ? {key: "dbt", data: data} : null;
    }

    public function NmeaDbtMessage() {
    }

}
}