/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 02/12/13
 * Time: 10:10
 * To change this template use File | Settings | File Templates.
 */
package com.utils {
import org.flexunit.asserts.assertEquals;

public class SunCalculatorTest {
    public function SunCalculatorTest() {
    }

    [Test]
    public function testGetMoonFraction():void {
        trace(SunCalculator.instance.getMoonFraction(new Date(2013,4,1)));
        trace(SunCalculator.instance.getMoonFraction(new Date(2013,4,2)));
        trace(SunCalculator.instance.getMoonFraction(new Date(2013,4,3)));
        trace(SunCalculator.instance.getMoonFraction(new Date(2013,4,4)));
        trace(SunCalculator.instance.getMoonFraction(new Date(2013,4,5)));
        trace(SunCalculator.instance.getMoonFraction(new Date(2013,4,6)));
        trace(SunCalculator.instance.getMoonFraction(new Date(2013,4,7)));
        trace(SunCalculator.instance.getMoonFraction(new Date(2013,4,8)));
    }

    [Test]
    public function testGetMoonTimes():void {
        var moon:Object = SunCalculator.instance.getMoonTimes(new Date(2013,11,1), 47.4980100, 19.0399100);
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,9), 47.4980100, 19.0399100);
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,10), 47.4980100, 19.0399100);
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,25), 47.4980100, 19.0399100);
        trace(moon.rise + "," + moon.set);/*
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,3), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,4), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,5), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,6), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,7), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,8), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,17), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,19), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,20), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,21), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set);
        moon = SunCalculator.instance.getMoonTimes(new Date(2013,11,22), 45.81491200000000, 15.97851449999996)
        trace(moon.rise + "," + moon.set); */
    }
    /*
    [Test]
    public function testGetSidereal():void {
        trace("Zagreb: ");
        SunCalculator.instance.getSidereal(new Date(2013,11,1), 45.814912000000000000, 15.978514499999960000, -1);
        trace("Budapest: ");
        SunCalculator.instance.getSidereal(new Date(2013,11,1), 47.4980100, 19.0399100, -1);
    }
    */
}
}
