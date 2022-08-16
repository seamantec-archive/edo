/**
 * Created by seamantec on 29/04/14.
 */
package com.sailing.ais {
import org.flexunit.asserts.assertEquals;

public class VesselTest {
    public function VesselTest() {
    }

    [Test]
    public function testFormatNumber():void {
        assertEquals(Vessel.formatNumber(123456.7894564), "1.23*10^5");
        assertEquals(Vessel.formatNumber(12345), "12345");
        assertEquals(Vessel.formatNumber(1187.1), "1.18*10^3");
        assertEquals(Vessel.formatNumber(0.07), "0.07");
        assertEquals(Vessel.formatNumber(0.00000764452), "7.64*10^-6");
        assertEquals(Vessel.formatNumber(-0.00000764452), "-7.64*10^-6");
        assertEquals(Vessel.formatNumber(-123456.7894564), "-1.23*10^5");
    }
}
}
