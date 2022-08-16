/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.08.
 * Time: 15:24
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.nmeaParser.messages {
import com.common.WindCorrection;

public class NmeaMwvMessageTest {
    var nmea:Array = [];

    [Before]
    public function setUp():void {
        nmea.push("$IIMWV,006.0,R,7.0,N,A*3C");
        nmea.push("$IIMWV,154.0,T,1.6,N,A*3C");
        nmea.push("$IIMWV,74.5,T,1.6,N,A*3C");
        nmea.push("$IIMWV,155.5,T,1.6,N,A*3C");
    }


    [Test]
    public function testMwv():void {
        WindCorrection.instance.windCorrection = 2;
        var n:NmeaMwvMessage = new NmeaMwvMessage();
        for (var i:int = 0; i < nmea.length; i++) {
            n.parse(nmea[i]);
            trace(n.process().data.windAngle.getPureData());
        }
    }
}
}
