/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.14.
 * Time: 10:46
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import org.flexunit.asserts.assertEquals;

public class DistanceTest {



    //test strings

    //1. set unit handler to nm, and get 100 nm
    [Test]
    public function test1():void {
        UnitHandler.instance.distance = Distance.NM;
        var distance:Distance = new Distance();
        distance.value = 100;
        assertEquals(distance.value, 100);
        assertEquals(distance.getUnitShortString(), "nm");
        assertEquals(distance.getUnitStringForAlarm(), "nauticalmile");
    }


    //2. set unit handler to nm, and get 1 nm
    [Test]
    public function test2():void {
        UnitHandler.instance.distance = Distance.NM;
        var distance:Distance = new Distance();
        distance.value = 1;
        assertEquals(distance.value, 1);
        assertEquals(distance.getUnitShortString(), "nm");
        assertEquals(distance.getUnitStringForAlarm(), "nauticalmile");
    }

    //3. set unit handler to nm, and get 0.1 nm
    [Test]
    public function test3():void {
        UnitHandler.instance.distance = Distance.NM;
        var distance:Distance = new Distance();
        distance.value = 0.1;
        assertEquals(distance.value, 607.61);
        assertEquals(distance.getUnitShortString(), "ft");
        assertEquals(distance.getUnitStringForAlarm(), "feet");
    }

    //4. set unit handler to km, and get 100 km
    [Test]
    public function test4():void {
        UnitHandler.instance.distance = Distance.KM;
        var distance:Distance = new Distance();
        distance.value = 53.99;
        assertEquals(99.99, distance.value);
        assertEquals(distance.getUnitShortString(), "km");
        assertEquals(distance.getUnitStringForAlarm(), "kilometer");
    }

    //5. set unit handler to km, and get 1 km
    [Test]
    public function test5():void {
        UnitHandler.instance.distance = Distance.KM;
        var distance:Distance = new Distance();
        distance.value = 0.539;
        assertEquals(1, distance.value);
        assertEquals(distance.getUnitShortString(), "km");
        assertEquals(distance.getUnitStringForAlarm(), "kilometer");
    }

    //6. set unit handler to km, and get 0.1 km
    [Test]
    public function test6():void {
        UnitHandler.instance.distance = Distance.KM;
        var distance:Distance = new Distance();
        distance.value = 0.054;
        assertEquals(100.01, distance.value);
        assertEquals(distance.getUnitShortString(), "m");
        assertEquals(distance.getUnitStringForAlarm(), "meter");
    }

    //TODO set miletests
}
}
