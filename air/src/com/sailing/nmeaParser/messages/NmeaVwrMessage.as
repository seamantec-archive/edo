package com.sailing.nmeaParser.messages {
import com.common.WindCorrection;
import com.sailing.datas.Vwr;
import com.sailing.units.WindSpeed;

/*
 VWR - Relative wind direction and speed
 VWR,148.,L,02.4,N,01.2,M,04.4,K
 148.,L       Wind from 148 deg Left of bow
 02.4,N       Speed 2.4 Knots
 01.2,M       1.2 Metres/Sec
 04.4,K       Speed 4.4 Kilometers/Hr
 */
public class NmeaVwrMessage implements NmeaMessage {
    private var data:Vwr = new Vwr();
    private var isValid:Boolean = true;

    public function parse(packet:String):void {
        isValid = true;
        var parts:Array = packet.split(",");

        if (parts[1].length) {
//            var angle:Number = Number(parts[1]);
//            if (angle >= -180 && angle <= 180) {
//                angle -= WindCorrection.instance.windCorrection;
//                if (angle < -180) {
//                    angle += 360;
//                } else if (angle > 180) {
//                    angle -= 360;
//                }
                data.windDirection.value = Number(parts[1]);
                isValid = true;
//            } else {
//                isValid = false;
//            }
        } else {
            isValid = false;
        }

        if (data != null) {
            data.windDirectionSide = parts[2];
            if (data.windDirectionSide == "L" || data.windDirectionSide == "left") {
                data.windDirection.value = data.windDirection.getPureData() * -1;
            }
            for (var i:int = 3; i < 9; i += 2) {
                if (parts[i].length) {
                    var speedValue:Number = Number(parts[i]);
                    var speedType:String = parts[i + 1];

                    if (speedType == "N" || speedType == "n") {
                        data.windSpeed.value = speedValue;
                        break;
                    }
                    else if (speedType == "M" || speedType == "m") {
                        data.windSpeed.value = WindSpeed.knotsFromMile(speedValue);
                        break;
                    }
                    else if (speedType == "K" || speedType == "k") {
                        data.windSpeed.value = WindSpeed.knotsFromKm(speedValue);
                        break;
                    }
                }
            }
        }
    }

    public function process():Object {
        return isValid ? {key: "vwr", data: data} : null;
    }


}

}