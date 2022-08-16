package com.sailing.nmeaParser.messages {
import com.sailing.datas.Gll;

/*
 GLL - Geographic Position - Latitude/Longitude

 1       2 3        4 5         6 7
 |       | |        | |         | |
 $--GLL,llll.ll,a,yyyyy.yy,a,hhmmss.ss,A*hh<CR><LF>

 Field Number:
 1) Latitude
 2) N or S (North or South)
 3) Longitude
 4) E or W (East or West)
 5) Universal Time Coordinated (UTC)
 6) Status A - Data Valid, V - Data Invalid
 7) Checksum
 */
public class NmeaGllMessage implements NmeaMessage {
    private var data:Gll = new Gll();
    private var isValid:Boolean = true;

    public function parse(packet:String):void {
        var parts:Array = packet.split(",");

        var p1:Number;
        var p2:Number;
        // latitude
        if (parts[1].length) {
            var latitude:Number = Number(parts[1]) / 100.0;
            p1 = Math.floor(latitude);
            p2 = 100.0 * (latitude - p1);

            data.lat = p1 + p2 / 60.0;
            if (parts[3] == "S") {
                data.lat = -data.lat;
            }
        }

        // longitude
        if (parts[3].length) {
            var longitude:Number = Number(parts[3]) / 100.0;
            p1 = Math.floor(longitude);
            p2 = 100.0 * (longitude - p1);

            data.lon = p1 + p2 / 60.0;
            if (parts[5] == "W") {
                data.lon = -data.lon;
            }
        }

        // utc time
        var hour:int = parseInt(parts[5].substr(0, 2));
        var minute:int = parseInt(parts[5].substr(2, 2));
        var second:int = parseInt(parts[5].substr(4, 2));
        data.hour = hour;
        data.min = minute;
        data.sec = second;
        data.timeMsUtc = 1000 * (second + 60 * (minute + 60 * hour));
        isValid = true;
        if (parts[5] === "") {
            isValid = false;
        }
    }

    public function process():Object {
        return isValid ? {key: "gll", data: data} : null;
    }

    public function NmeaGllMessage() {

    }

}

}