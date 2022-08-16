package com.sailing.nmeaParser.messages {
import com.sailing.datas.Hdg;
import com.sailing.units.Direction;
import com.sailing.units.Unit;

/*
 HDG - Heading - Deviation & Variation

 1   2   3 4   5 6
 |   |   | |   | |
 $--HDG,x.x,x.x,a,x.x,a*hh<CR><LF>

 Field Number:
 1) Magnetic Sensor heading in degrees
 2) Magnetic Deviation, degrees
 3) Magnetic Deviation direction, E = Easterly, W = Westerly
 4) Magnetic Variation degrees
 5) Magnetic Variation direction, E = Easterly, W = Westerly
 6) Checksum
 */
public class NmeaHdgMessage implements NmeaMessage {
    private var data:Hdg = new Hdg();
    private var isValid:Boolean = true;

    public function parse(packet:String):void {
        isValid = true;

        var parts:Array = packet.split(",");

        if (parts[1].length) {
            data.sensorHeading.value = Unit.toInterval(Number(parts[1]) - (parts[4].length > 0 ? data.magneticVariation : 0));
        } else {
            isValid = false;
        }

        if (parts[2].length) {
            data.magneticDeviation = Number(parts[2]);
        }


        if (parts[3].length) {
            data.magneticDeviationDirection = parts[3];
        }


        if (parts[5].length) {
            data.magneticVariationDirection = parts[5];
        }
        if (parts[4].length) {
            data.magneticVariation = Number(parts[4]);
            if (data.magneticVariationDirection == "E") {
                data.magneticVariation = Number(parts[4]) * -1;
            }
            Direction.variation = data.magneticVariation;
            Direction.isVariationValid = true;
        }

    }

    public function process():Object {
        return isValid ? {key: "hdg", data: data} : null;
    }

    public function NmeaHdgMessage() {

    }

}

}