/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.08.
 * Time: 18:15
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.nmeaParser.messages {
import com.sailing.datas.Rmb;
import com.sailing.nmeaParser.messages.NmeaRmbMessage;

import org.flexunit.asserts.assertEquals;

public class NmeaRmbMessageTest {
    var nmea:Array = [];

    [Before]
    public function setUp():void {
        nmea.push("$IIRMB,A,0.31,R,,1,,,,,0.38,281.0,,V,A*44");
//        nmea.push("$IIRMB,A,0.31,R,,1,,,,,0.38,281.5,,V,A*41");
    }


    [Test]
    public function testRMB():void {
        var n:NmeaRmbMessage = new NmeaRmbMessage()
        for (var i:int = 0; i < nmea.length; i++) {
            n.parse(nmea[i]);
            var data:Rmb = n.process().data as Rmb;
            assertEquals(data.crossTrackError.value, 0.31);
            assertEquals(data.dataStatus, "A");
            assertEquals(data.directionToSteer, "R");
            assertEquals(data.bearingToDest, 281.0);
            assertEquals(data.rangeToDest.value, 0.38);
        }
    }
}
}
