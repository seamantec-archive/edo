package com.sailing.nmeaParser.messages {
import com.adobe.utils.DateUtil;
import com.sailing.datas.Rmc;
import com.sailing.units.Direction;
import com.sailing.units.Unit;

public class NmeaRmcMessage implements NmeaMessage {
    /*
     RMC - Recommended Minimum Navigation Information
     12
     1         2 3       4 5        6 7   8   9    10  11|
     |         | |       | |        | |   |   |    |   | |
     $--RMC,hhmmss.ss,A,llll.ll,a,yyyyy.yy,a,x.x,x.x,xxxx,x.x,a*hh<CR><LF>

     Field Number:
     1) UTC Time
     2) Status, V = Navigation receiver warning
     3) Latitude
     4) N or S
     5) Longitude
     6) E or W
     7) Speed over ground, knots
     8) Track made good, degrees true
     9) Date, ddmmyy
     10) Magnetic Variation, degrees
     11) E or W
     12) Checksum
     */
    private var data:Rmc = new Rmc();

    public function parse(packet:String):void {

        var parts:Array = packet.split(",");

        if (parts[7].length) {
            data.gpsSog.value = Number(parts[7]);
        }

        if (parts[8].length > 0) {
            data.gpsCog.value = Number(parts[8]);

        } else {
            data.gpsCog.value = Unit.INVALID_VALUE
        }
        if (parts[10].length > 0) {

            if (parts[11].length > 0 && parts[11] == "E") {
                data.magneticVariation = new Number(parts[10])*-1;
            } else {
                data.magneticVariation = new Number(parts[10]);
            }
            Direction.variation =  data.magneticVariation;
            Direction.isVariationValid = true;
            if (data.gpsCog.getPureData() != Unit.INVALID_VALUE) {
                data.gpsCog.value = Unit.toInterval(data.gpsCog.getPureData() - Direction.variation);
            }
        }
        var p1:Number;
        var p2:Number;
        // latitude
        if (parts[3].length) {
            var latitude:Number = Number(parts[3]) / 100.0;
            p1 = Math.floor(latitude);
            p2 = 100.0 * (latitude - p1);

            data.lat = p1 + p2 / 60.0;
            if (parts[4] == "S") {
                data.lat = -data.lat;
            }
        }

        // longitude
        if (parts[5].length) {
            var longitude:Number = Number(parts[5]) / 100.0;
            p1 = Math.floor(longitude);
            p2 = 100.0 * (longitude - p1);

            data.lon = p1 + p2 / 60.0;
            if (parts[6] == "W") {
                data.lon = -data.lon;
            }
        }

        var hour:int = parseInt(parts[1].substr(0, 2));
        var minute:int = parseInt(parts[1].substr(2, 2));
        var second:int = parseInt(parts[1].substr(4, 2));
        data.hour = hour;
        data.min = minute;
        data.sec = second;
        //var dateString:String = parts[9]
        var year:int = parseInt(parts[9].substr(4,2))+2000;
        if(year > 2070) year -=100;
        data.utc = new Date(Date.parse(year+"/"+parts[9].substr(2,2)+"/"+parts[9].substr(0,2)+" " +hour+":"+minute+":"+second+" GMT-0000"));
        //	data.gpsSog = parts[7];
        //	data.gpsCog = parts[8];

    }

    public function process():Object {
        return {key: "rmc", data: data};
    }

    public function NmeaRmcMessage() {
    }
}
}