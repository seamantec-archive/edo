package com.sailing.nmeaParser.messages {
import com.sailing.datas.Hsc;

/*
 HSC - Command heading to steer
 HSC,258.,T,236.,M
 258.,T       258 deg. True
 236.,M       136 deg. Magnetic
 */

public class NmeaHscMessage implements NmeaMessage {

    private var data:Hsc = new Hsc();

    public function NmeaHscMessage() {
    }

    public function parse(packet:String):void {

        var parts:Array = packet.split(",");

        // todo: fix this
        if (parts[1].length != 0 && parts[3].length != 0) {
            var heading1:Number = Number(parts[1]);
            var type1:String = parts[2];

            var heading2:Number = Number(parts[3]);
            var type2:String = parts[4];

            // feet
            if (type1 == "t" || type1 == "T") {
                data.commandHeading.value = heading2;
//                if (heading2 - heading1 != Direction.variation) {
//                    SystemLogger.Debug("HSC heading variation ERROR" + (heading2 - heading1) + " dirvar " + Direction.variation)
//
//                }
            }
        }

    }

    public function process():Object {
        return {key: "hsc", data: data}
    }
}
}