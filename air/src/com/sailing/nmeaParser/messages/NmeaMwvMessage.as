package com.sailing.nmeaParser.messages {

import com.common.WindCorrection;
import com.sailing.datas.Mwv;
import com.sailing.units.Unit;
import com.sailing.units.WindSpeed;

/*
 MWV - Wind Speed and Angle

 1   2 3   4 5
 |   | |   | |
 $--MWV,x.x,a,x.x,a*hh<CR><LF>
 $WIMWV,5.6,R,7.4,S,A*3E
 Field Number:
 1) Wind Angle, 0 to 360 degrees
 2) Reference, R = Relative, T = True
 3) Wind Speed
 4) Wind Speed Units, K/M/N
 5) Status, A = Data Valid
 6) Checksum
 */
public class NmeaMwvMessage {
    private var data:Mwv = new Mwv();//Mwv.mwv;
    private var isValid:Boolean = true;

    public function parse(packet:String):void {
        isValid = true;
        var parts:Array = packet.split(",");

        if (parts[2].length) {
            data.windDirectionRef = parts[2];
        }
        if (parts[1].length) {
            data.windAngle.value = Number(parts[1]);
        } else {
            isValid = false;
        }
        if (parts[3].length) {
            var speed:Number = Number(parts[3]);
            if (parts[4] == "N" || parts[4] == "n") {
                data.windSpeed.value = speed;
            }
            else if (parts[4] == "M" || parts[4] == "m") {
                data.windSpeed.value = WindSpeed.knotsFromMeterPerSec(speed);
            }
            else if (parts[4] == "S" || parts[4] == "s") {
                data.windSpeed.value = WindSpeed.knotsFromMile(speed);
            }
            else if (parts[4] == "K" || parts[4] == "k") {
                data.windSpeed.value = WindSpeed.knotsFromKm(speed);
            }
        }


    }

    public function process():Object {
        if(data.windSpeed.getPureData() > 200){
            return null;
        }
        return isValid ? {key: "mwv", data: data} : null;
    }

    public function NmeaMwvMessage() {

    }

}

}