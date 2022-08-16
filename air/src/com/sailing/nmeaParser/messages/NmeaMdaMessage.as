package com.sailing.nmeaParser.messages {
/**
 *
 * MDA - Meteorological Composite
 *
 *
 *        1. 2. 3. 4. 5. 6. 7. 8. 9. 10.  11 12 13 14 15 16 17 18 19 20
 *         |  |  |  |  |  |  |  |  |   |   |  |  |  |  |  |  |  |  |  |
 * $--MDA,x.x,I,x.x,B,x.x,C,x.x,C,x.x,x.x,x.x,C,x.x,T,x.x,M,x.x,N,x.x,M*hh<CR><LF>
 *
 * 1.2. Barometric pressure, inches of mercury
 * 3.4 Barometric pressure, bars
 * 5.6. Air temperature, degrees C
 * 7.8 Water temperature, degrees C
 * 9.Relative humidity, percent
 * 10.  Absolute humidity, percent
 * 11.12.Dew point, degrees C
 * 13.14. Wind direction, degrees True
 * 15.16 Wind direction, degrees Magnetic
 * 17.18 Wind speed, knots
 * 19.20 Wind speed, meters/second
 *
 *
 *
 *
 * */

import com.sailing.datas.Mda;
import com.sailing.nmeaParser.utils.NmeaUtil;
import com.sailing.units.Unit;

public class NmeaMdaMessage implements NmeaMessage {
    private var data:Mda = new Mda();

    public function parse(packet:String):void {
        var parts:Array = packet.split(",");

        data.barometricPressure.value = (parts[3].length > 0) ? Math.round(Number(parts[3]) * 1000) : Unit.INVALID_VALUE;
        data.airTemp.value = (parts[5].length > 0) ? Number(parts[5]) : Unit.INVALID_VALUE;
        data.waterTemp.value = (parts[7].length > 0) ? Number(parts[7]) : Unit.INVALID_VALUE;
        data.relativeHumidity.value = (parts[9].length > 0) ? Number(parts[9]) : Unit.INVALID_VALUE;
        data.absoluteHumidity.value = (parts[10].length > 0) ? Number(parts[10]) : Unit.INVALID_VALUE;
        data.dewPoint.value = (parts[11].length > 0) ? Number(parts[11]) : Unit.INVALID_VALUE;
        data.windDirection.value = (parts[15].length > 0) ? Number(parts[15]) : Unit.INVALID_VALUE;
        if (parts[17] != "") {
            data.windSpeed.value = (parts[17].length > 0) ? Number(parts[17]) : Unit.INVALID_VALUE;
        } else {
            data.windSpeed.value = (parts[19].length > 0) ? NmeaUtil.meterSecToKnots(parts[19]) : Unit.INVALID_VALUE;
        }


    }

    public function process():Object {
        return {key: "mda", data: data};
    }
}
}