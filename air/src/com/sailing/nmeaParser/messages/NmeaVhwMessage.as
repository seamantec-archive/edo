package com.sailing.nmeaParser.messages {
import com.sailing.datas.Vhw;

/*
 VHW - Water speed and heading
 VHW,259.,T,237.,M,05.00,N,09.26,K
 259.,T       Heading 259 deg. True
 237.,M       Heading 237 deg. Magnetic
 05.00,N      Speed 5 knots through the water
 09.26,K      Speed 9.26 KPH
 */

public class NmeaVhwMessage implements NmeaMessage {

    private var data:Vhw = new Vhw();


    public function parse(packet:String):void {

        var parts:Array = packet.split(",");
        if (parts[3].length != 0) {
            data.waterHeading.value = Number(parts[3]);
        }
//        if (Number(parts[1]) - Number(parts[3]) != Direction.variation) {
//            SystemLogger.Debug("vhw bearing variation ERROR " + (Number(parts[1]) - Number(parts[3])) + " dirvar " + Direction.variation + " " + Number(parts[1]) + " "+ Number(parts[3]))
//        }


        if (parts[5].length != 0 || parts[7].length != 0) {
            var speed1:Number = Number(parts[5]);
            var type1:String = parts[6];

            var speed2:Number = Number(parts[7]);
            var type2:String = parts[8];

            // knots
            if (type1 == "n" || type1 == "N") {
                data.waterSpeed.value = speed1;
            }
            else {
                data.waterSpeed.value = speed2;
            }
        }

    }

    public function process():Object {
        return {key: "vhw", data: data}
    }

    public function NmeaVhwMessage() {
    }
}
}