package com.sailing.nmeaParser.messages {
/**
 *
 * VDR - Set and Drift
 *
 *
 *
 *         1. 2. 3. 4. 5. 6.
 *         |  |  |  |  |  |
 * $--VDR,x.x,T,x.x,M,x.x,N*hh<CR><LF>
 *
 * 1.2. Direction, degrees True
 * 3.4. Direction, degrees Magnetic
 * 5.6  Current speed, knots
 *
 *
 *
 * */


import com.loggers.SystemLogger;
import com.sailing.datas.Vdr;
import com.sailing.units.Direction;
import com.sailing.units.Unit;

public class NmeaVdrMessage implements NmeaMessage {

    private var data:Vdr = new Vdr();
    private var isValid:Boolean = true;

    public function parse(packet:String):void {
        isValid = true;

        var parts:Array = packet.split(",");

        if(parts[3].length>0) {
            data.direction.value = Unit.toInterval(new Number(parts[3]));
        } else {
            isValid = false;
        }

        if(parts[5].length>0) {
            data.currentSpeed.value = new Number(parts[5]);
        }

        if (Number(parts[1]) - Number(parts[3]) != Direction.variation) {
            SystemLogger.Debug("vdr bearing variation ERROR" + (Number(parts[1]) - Number(parts[3])) + " dirvar " + Direction.variation)
        }
    }

    public function process():Object {
        return isValid ? {key: "vdr", data: data} : null;
    }
}
}