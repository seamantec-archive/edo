/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.21.
 * Time: 17:08
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.units {
import org.flexunit.asserts.assertEquals;

public class UnitHandlerTest {


    [Test]
    public function testTemperature():void {
        UnitHandler.instance.temperature = Temperature.CELSIUS;
        var n:Temperature = new Temperature();
        n.value = 24;
        assertEquals(n.value, 24);
        UnitHandler.instance.temperature = Temperature.FAHRENHEIT;
        assertEquals(n.value, 75.2);
        UnitHandler.instance.temperature = Temperature.KELVIN;
        assertEquals(n.value, 297.15);
    }

    [Test]
    public function testDepth():void {
        UnitHandler.instance.depth = Depth.METER;
        var n:Depth = new Depth();
        n.value = 24;
        assertEquals(n.value, 24);
        UnitHandler.instance.depth = Depth.FATHOM;
        assertEquals(Math.round(n.value * 1000) / 1000, 13.123);
        UnitHandler.instance.depth = Depth.FEET;
        assertEquals(Math.round(n.value * 1000) / 1000, 78.740);
    }

    [Test]
    public function testDistance():void {
        UnitHandler.instance.distance = Distance.NM;
        var n:Distance = new Distance();
        n.value = 123;
        assertEquals(n.value, 123);
        UnitHandler.instance.distance = Distance.MILE;
        assertEquals(Math.round(n.value * 1000) / 1000, 141.546);
        UnitHandler.instance.distance = Distance.KM;
        assertEquals(Math.round(n.value * 1000) / 1000, 227.796);
        UnitHandler.instance.distance = Distance.METER;
        assertEquals(Math.round(n.value * 1000) / 1000, 227796);
        UnitHandler.instance.distance = Distance.YARD;
        assertEquals(Math.round(n.value * 1000) / 1000, 249120.756);
        UnitHandler.instance.distance = Distance.FEET;
        assertEquals(Math.round(n.value * 1000) / 1000, 747362.207);
    }

    [Test]
    public function testSpeed():void {
        UnitHandler.instance.speed = Speed.KTS;
        var n:Speed = new Speed();
        n.value = 35;
        assertEquals(n.value, 35);
        UnitHandler.instance.speed = Speed.KMH;
        assertEquals(Math.round(n.value * 1000) / 1000, 64.82);
        UnitHandler.instance.speed = Speed.MS;
        assertEquals(Math.round(n.value * 1000) / 1000, 18.006);
        UnitHandler.instance.speed = Speed.MPH;
        assertEquals(Math.round(n.value * 1000) / 1000, 40.277);
        UnitHandler.instance.speed = Speed.FTS;
        assertEquals(Math.round(n.value * 1000) / 1000, 59.073);

    }

    [Test]
    public function testWindSpeed():void {
        UnitHandler.instance.windSpeed = WindSpeed.KTS;
        var n:WindSpeed = new WindSpeed();
        n.value = 35;
        assertEquals(n.value, 35);
        UnitHandler.instance.windSpeed = WindSpeed.KMH;
        assertEquals(Math.round(n.value * 1000) / 1000, 64.82);
        UnitHandler.instance.windSpeed = WindSpeed.MS;
        assertEquals(Math.round(n.value * 1000) / 1000, 18.006);
        UnitHandler.instance.windSpeed = WindSpeed.MPH;
        assertEquals(Math.round(n.value * 1000) / 1000, 40.277);
        UnitHandler.instance.windSpeed = WindSpeed.FTS;
        assertEquals(Math.round(n.value * 1000) / 1000, 59.073);
        UnitHandler.instance.windSpeed = WindSpeed.FTS;
        assertEquals(Math.round(n.value * 1000) / 1000, 59.073);
        UnitHandler.instance.windSpeed = WindSpeed.BF;
        n.value = 0.5;
        assertEquals(n.value, 0);
        n.value = 3;
        assertEquals(n.value, 1);
        n.value = 6;
        assertEquals(n.value, 2);
        n.value = 8.5;
        assertEquals(n.value, 3);
        n.value = 15;
        assertEquals(n.value, 4);
        n.value = 17;
        assertEquals(n.value, 5);
        n.value = 27;
        assertEquals(n.value, 6);
        n.value = 30;
        assertEquals(n.value, 7);
        n.value = 36;
        assertEquals(n.value, 8);
        n.value = 47;
        assertEquals(n.value, 9);
        n.value = 54;
        assertEquals(n.value, 10);
        n.value = 57;
        assertEquals(n.value, 11);
        n.value = 100;
        assertEquals(n.value, 12);

    }


    [Test]
    public function testSaveLoad():void {
        UnitHandler.instance.temperature = Temperature.FAHRENHEIT;
        UnitHandler.instance.depth = Depth.FEET;
        UnitHandler.instance.distance = Distance.FEET;
        UnitHandler.instance.speed = Speed.MS;
        UnitHandler.instance.windSpeed = WindSpeed.BF;

        UnitHandler.instance.saveUnits();

        UnitHandler.instance.temperature = Temperature.CELSIUS;
        UnitHandler.instance.depth = Depth.METER;
        UnitHandler.instance.distance = Distance.NM;
        UnitHandler.instance.speed = Speed.KMH;
        UnitHandler.instance.windSpeed = WindSpeed.KMH;

        UnitHandler.instance.loadUnits();

        assertEquals(UnitHandler.instance.temperature, Temperature.FAHRENHEIT)
        assertEquals(UnitHandler.instance.depth, Depth.FEET)
        assertEquals(UnitHandler.instance.distance, Distance.FEET)
        assertEquals(UnitHandler.instance.speed, Speed.MS)
        assertEquals(UnitHandler.instance.windSpeed, WindSpeed.BF)


    }
}
}
