package com.sailing.nmeaParser.messages {
/**
 *
 *ZDA - Time & Date
 *
 *
 *         1.      2.  3. 4.   5. 6.
 *          |       |   |  |    |  |
 * $--ZDA,hhmmss.ss,xx,xx,xxxx,xx,xx*hh<CR><LF>
 *
 * 1. UTC
 * 2. day
 * 3. month
 * 4. year
 * 5. local zone hours 00 to ±13 hrs
 * 6. Local zone minutes, 00 to +59
 *
 *
 * */

import com.sailing.datas.Zda;

public class NmeaZdaMessage implements NmeaMessage {

    public static const INVALIDOFFSET = 14*60;

    private var data:Zda = new Zda();

    public function parse(packet:String):void {
        var parts:Array = packet.split(",");
        data.utc = new Date(Date.UTC(parts[4], new Number(parts[3]) - 1, parts[2], parts[1].substr(0, 2), parts[1].substr(2, 2), parts[1].substr(4, 4)));
        //data.utc.setUTCFullYear(parts[4], new Number(parts[3])-1, parts[2]);
        //data.utc.setUTCHours(parts[1].substr(0,2), parts[1].substr(2,2), parts[1].substr(4,4));
        //TODO local time implementation
        // utc time
        var hour:int = parseInt(parts[1].substr(0, 2));
        var minute:int = parseInt(parts[1].substr(2, 2));
        var second:int = parseInt(parts[1].substr(4, 2));
        data.hour = hour;
        data.min = minute;
        data.sec = second;
        var offsetHour:int = parseInt(parts[5])
        data.offsetInMin = parseInt(parts[6])* ( offsetHour < 0 ? -1 : 1);
        if(isNaN(data.offsetInMin)) {
            data.offsetInMin = INVALIDOFFSET;
        } else {
            data.offsetInMin += offsetHour * 60;
        }

        data.localTime = new Date(data.utc.time + data.offsetInMin * 60 * 1000);

    }

    public function process():Object {
        return {key: "zda", data: data};
    }
}
}