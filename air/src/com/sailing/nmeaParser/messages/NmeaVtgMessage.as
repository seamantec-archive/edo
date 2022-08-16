package com.sailing.nmeaParser.messages {

/**
 *
 * VTG - Course Over Ground and Ground Speed
 *
 *
 *         1. 2. 3. 4. 5. 6.7. 8.9.
 *          | |  |  |  |  |  |  | |
 * $--VTG,x.x,T,x.x,M,x.x,N,x.x,K,a*hh<CR><LF>
 *
 *
 * 1.2. Course over ground, degrees True
 * 3.4. Course over ground, degrees Magnetic
 * 5.6. Speed over ground, knots
 * 7.8. Speed over ground, km/hr
 * 9.    Mode Indicator
 *
 * */

import com.sailing.datas.Vtg;
import com.sailing.nmeaParser.utils.NmeaUtil;

public class NmeaVtgMessage implements NmeaMessage {

    private var data:Vtg = new Vtg();

    public function parse(packet:String):void {
        var parts:Array = packet.split(",");
        data.courseOverGround.value = new Number(parts[3]);
//        if (Number(parts[1]) - Number(parts[3]) != Direction.variation) {
//            SystemLogger.Debug("vhw bearing variation ERROR " + (Number(parts[1]) - Number(parts[3])) + " dirvar " + Direction.variation + " " + Number(parts[1]) + " "+ Number(parts[3]))
//        }
        if (parts[5] != "") {
            data.speedOverGround.value = new Number(parts[5]);
        } else {
            data.speedOverGround.value = NmeaUtil.kmhToKnots(parts[7]);
        }

        data.mode = parts[9];


    }

    public function process():Object {
        return {key: "vtg", data: data};
    }
}
}