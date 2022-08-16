/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.07.09.
 * Time: 11:01
 * To change this template use File | Settings | File Templates.
 */
package com.utils {
import com.common.Coordinate;
import com.sailing.split;

import org.flexunit.asserts.assertEquals;

public class CoordinateSystemUtilsTest {
    public function CoordinateSystemUtilsTest() {
    }

    [Test]
    public function testGetAngle():void {
        var o:Coordinate = new Coordinate(0,0);
        var p:Coordinate;
        var d:Number;
        trace("0. teszt");
        p = new Coordinate(0,0);
        d = CoordinateSystemUtils.distanceBetweenTwoPointsInNMI(o, p);
        assertEquals(CoordinateSystemUtils.getAngle(o, p, d), 0);
        trace("1. teszt");
        p = new Coordinate(0,1);
        d = CoordinateSystemUtils.distanceBetweenTwoPointsInNMI(o, p);
        assertEquals(CoordinateSystemUtils.getAngle(o, p, d), 0.5);
        trace("2. teszt");
        p = new Coordinate(1,0);
        d = CoordinateSystemUtils.distanceBetweenTwoPointsInNMI(o, p);
        assertEquals(CoordinateSystemUtils.getAngle(o, p, d), 90.5);
        trace("3. teszt");
        p = new Coordinate(0,-1);
        d = CoordinateSystemUtils.distanceBetweenTwoPointsInNMI(o, p);
        assertEquals(CoordinateSystemUtils.getAngle(o, p, d), 180.5);
        trace("4. teszt");
        p = new Coordinate(-1,0);
        d = CoordinateSystemUtils.distanceBetweenTwoPointsInNMI(o, p);
        assertEquals(CoordinateSystemUtils.getAngle(o, p, d), 270.5);
    }

    [Test]
    public function testLatLonDecToDDMM():void {
        var x:Number = 41.878928;
        var lat:Object = CoordinateSystemUtils.latLonDecToDDMM(x);
        assertEquals(lat.deg, 41);
        assertEquals(lat.min, 52.736);
        var x:Number = 14.65038333333;
        var lat:Object = CoordinateSystemUtils.latLonDecToDDMM(x);
        assertEquals(lat.deg, 14);
        assertEquals(lat.min, 39.0299);


    }

    [Test]
    public function testSplit():void{
//        var string:String = split._b3(38.979999);
//        var string2:String = split._a(38.979999);
//        assertEquals(string, "980");
//        assertEquals(string2, "38");
//        var string:String = split._b3(38.001);
//        var string2:String = split._a(38.001);
//        assertEquals(string, "001");
//        assertEquals(string2, "38");
//        var string:String = split._b3(38.000912);
//        var string2:String = split._a(38.000912);
//        assertEquals(string, "001");
//        assertEquals(string2, "38");
//        var string:String = split._b3(39.023);
//        var string2:String = split._a(39.023);
//        assertEquals(string, "023");
//        assertEquals(string2, "39");
//        var string:String = split._b(12.67);
//        var string2:String = split._a(12.67);
//        assertEquals(string, "7");
//        assertEquals(string2, "12");

    }
}
}
