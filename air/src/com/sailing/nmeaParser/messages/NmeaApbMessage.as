/**
 * Created by pepusz on 2014.07.08..
 */
package com.sailing.nmeaParser.messages {
import com.sailing.datas.Apb;

/**
 *          1.2. 3. 4.5.6.7. 8. 9. 10. 11.12.13.14.15
 *          | |  |  | | | |  |  |   |   |  |  |  | |
 *   $--APB,A,A,x.x,a,N,A,A,x.x,a,c--c,x.x,a,x.x,a,a*hh<CR><LF>
 *   15. Mode indicator1, 2
 *   13-14. Heading-to-steer to destination waypoint, Mag or True
 *   11-12. Bearing, Present position to destination, Magnetic or True
 *   10. Destination waypoint ID
 *   8-9. Bearing origin to destination, M/T
 *   7. Status: A = perpendicular passed at waypoint
 *   6. Status: A = arrival circle entered
 *   5. XTE units, nautical miles
 *   4. Direction to steer, L/R
 *   3. Magnitude of XTE (cross-track-error)
 *   2. Status2: A = Data valid or not used, V = Loran-C Cycle Lock warning flag
 *   1. Status2: A = Data valid, V = Loran-C Blink or SNR warning
 *            V = General warning flag for other navigation systems when a reliable fix is not available
 *
 *
 *
 *
 *
 *
 */


public class NmeaApbMessage implements NmeaMessage {
    private var data:Apb = new Apb()
    private var isValid:Boolean = false;
    var parts:Array

    public function parse(packet:String):void {
        isValid = false;
        parts = packet.split(",");
        if (parts[1].length > 0 && parts[2].length > 0 && parts[1] == "A" && parts[2] == "A") {
            data.dataIsValid = true;
            isValid = true;
        } else {
            data.dataIsValid = false;
            return;
        }
        if (parts[3].length > 0) {
            data.crossTrackError.value = Number(parts[3]);
        } else {
            isValid = false;
        }
        if (parts[4].length > 0) {
            data.directionToSteer = parts[4];
        } else {
            data.directionToSteer = "";
        }
        if (parts[8].length > 0) {
            data.bearingToDest.value = Number(parts[8]);
        }
        if (parts[11].length > 0) {
            data.headingToSteer.value = Number(parts[8]);
        }
        if (parts[10].length > 0) {
            data.destWaypointId = parts[10];
        } else {
            data.destWaypointId = "";
        }


    }

    public function process():Object {
        return isValid ? {key: "apb", data: data} : null;
    }
}
}
