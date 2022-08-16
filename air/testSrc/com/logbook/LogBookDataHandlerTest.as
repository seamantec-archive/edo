/**
 * Created by pepusz on 2014.02.07..
 */
package com.logbook {
import flashx.textLayout.debug.assert;

import org.flexunit.asserts.assertEquals;

public class LogBookDataHandlerTest {
    public function LogBookDataHandlerTest() {
    }

    [Test]
    public function testCalculateDelay():void {
        var zda:Number = Date.UTC(2013, 02, 6, 19, 23, 16);
        var offset:uint = 5 * 60 * 1000;
        var offset2:uint = 60 * 60 * 1000; //1 hour
        var offset3:uint = 12*60 * 60 * 1000; //12 hour
        var offset4:uint = 12*60 * 60 * 1000; //24 hour
        assertEquals(104000, LogBookDataHandler.calculateTimerDelay(zda, offset));
        assertEquals((36*60+44)*1000, LogBookDataHandler.calculateTimerDelay(zda, offset2));
        assertEquals((4*3600+36*60+44)*1000, LogBookDataHandler.calculateTimerDelay(zda, offset3));
        assertEquals((4*3600+36*60+44)*1000, LogBookDataHandler.calculateTimerDelay(zda, offset4));

    }
}
}
