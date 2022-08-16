package com.sailing.nmeaParser.messages {
import com.sailing.datas.Hvm;
import com.sailing.units.Direction;

public class NmeaHvmMessage implements NmeaMessage {

    private var data:Hvm = new Hvm();

    public function parse(packet:String):void {
        var parts:Array = packet.split(",");


        if (parts[2].length > 0) {
            data.magneticDirection = parts[2];
            if (data.magneticDirection == "E") {
                data.magneticVariation = new Number(parts[1]) * -1;
            } else {
                data.magneticVariation = new Number(parts[1]);
            }
        }
        if (Direction.variation === 0) {
            Direction.variation = data.magneticVariation;
            Direction.isVariationValid = true;
        }
    }

    public function process():Object {
        return {key: "hvm", data: data};
    }
}
}