/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 9/12/13
 * Time: 1:36 PM
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import org.flexunit.asserts.assertEquals;

public class WindSpeedTest {
    public function WindSpeedTest() {
        UnitHandler.instance.windSpeed = WindSpeed.BF;
    }

    [Test]
    public function testConvertNumber():void {
        var unit:WindSpeed = new WindSpeed();
        assertEquals("0.9", 0,unit.convertNumber(0.9));
        assertEquals("0.1", 0,unit.convertNumber(0.1));
        assertEquals("1.2", 1,unit.convertNumber(1.2));
        assertEquals("2", 1,unit.convertNumber(2));
        assertEquals("3", 1,unit.convertNumber(3));
        assertEquals("6", 2,unit.convertNumber(6));
        assertEquals("7", 3,unit.convertNumber(7));
        assertEquals("10", 3,unit.convertNumber(10));
        assertEquals("10.3", 3,unit.convertNumber(10.3));
        assertEquals("11", 4,unit.convertNumber(11));

    }
}
}
