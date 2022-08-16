package com.sailing.nmeaParser.messages {
import com.sailing.datas.Htc;
import com.sailing.units.Direction;
import com.sailing.units.Unit;

public class NmeaHtcMessage implements NmeaMessage {

    private var data:Htc = new Htc();
    private var isValid:Boolean = true;

    public function parse(packet:String):void {
        isValid = true;

        var parts:Array = packet.split(",");

        if (parts[1].length) {
            data.commandHeading.value = Unit.toInterval(new Number(parts[1]) - Direction.variation);
        } else {
            isValid = false;
        }
    }

    public function process():Object {
        return isValid ? {key: "htc", data: data} : null;
    }
}
}