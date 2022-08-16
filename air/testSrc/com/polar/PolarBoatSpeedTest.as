/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.28.
 * Time: 17:04
 * To change this template use File | Settings | File Templates.
 */
package com.polar {
import org.flexunit.asserts.assertEquals;

public class PolarBoatSpeedTest {
    public function PolarBoatSpeedTest() {
    }

    [Test]
    public function testSetMax():void {
        var pbs:PolarBoatSpeed = new PolarBoatSpeed(12);
        pbs.setMax(3);
        pbs.setMax(4);
        pbs.setMax(5);
        assertEquals(0, pbs.measured);
        assertEquals(5, pbs.lastThreeMax[0].measured)
        assertEquals(4, pbs.lastThreeMax[1].measured)
        assertEquals(3, pbs.lastThreeMax[2].measured)
    }

    [Test]
    public function testSetMax2():void {
        var pbs:PolarBoatSpeed = new PolarBoatSpeed(12);
        pbs.setMax(3);
        pbs.setMax(4);
        pbs.setMax(4.2);
        pbs.setMax(4.3);
        pbs.setMax(4.2);
        pbs.setMax(4.2);
        pbs.setMax(4.2);
        pbs.setMax(4.1);
        pbs.setMax(5);
        assertEquals(4.3, pbs.measured);
        assertEquals(4.3, pbs.lastThreeMax[1].measured)
        assertEquals(5, pbs.lastThreeMax[0].measured)
        assertEquals(4.2, pbs.lastThreeMax[2].measured)
    }


    [Test]
    public function test3():void {
        var pbs:PolarBoatSpeed = new PolarBoatSpeed(12);
        pbs.setMax(8.1);
        pbs.setMax(4.2);
        pbs.setMax(4.5);
        pbs.setMax(4.4);
        pbs.setMax(5.5);
        pbs.setMax(5.7);
        pbs.setMax(5.9);
        pbs.setMax(6);
        pbs.setMax(6);
        pbs.setMax(6);
        pbs.setMax(6);
        pbs.setMax(5.9);
        pbs.setMax(5.2);
        pbs.setMax(5.2);
        pbs.setMax(5.2);
        pbs.setMax(4.9);
        pbs.setMax(5.2);
        pbs.setMax(5.3);
        pbs.setMax(5.8);
        pbs.setMax(5.9);
        pbs.setMax(5.9);
        pbs.setMax(5.9);
        pbs.setMax(6.2);
        pbs.setMax(5.9);
        pbs.setMax(6);
        pbs.setMax(6.1);
        pbs.setMax(6.3);
        pbs.setMax(6.3);
        pbs.setMax(5.3);
        pbs.setMax(5.4);
        pbs.setMax(5.8);
        pbs.setMax(6.2);
        pbs.setMax(6.2);
        assertEquals(6.3, pbs.measured)
    }
}
}
