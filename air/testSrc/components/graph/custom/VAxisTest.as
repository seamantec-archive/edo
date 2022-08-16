/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.06.20.
 * Time: 9:47
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import org.flexunit.asserts.assertEquals;

public class VAxisTest {
    private var _graphInstance:GraphInstance

    [Before]
    public function setUp():void {
        _graphInstance = new GraphInstance("mwd.windSpeed", true);
    }

    /**
     * 1. Number of steps test. min: 0, max:100; height: 50;
     * 2. Number of steps test. min: 0, max:100; height: 345;
     * 3. Number of steps test. min: 0, max:8; height: 50;
     * 4. Number of steps test. min: 0, max:8; height: 345;
     * 5. Number of steps test. min: 0, max:13; height: 50;
     * 6. Number of steps test. min: 0, max:13; height: 423;
     * 7. Number of steps test. min: 0, max:23; height: 50;
     * 8. Number of steps test. min: 0, max:23; height: 412;
     * 9. Number of steps test. min: -20, max:20; height: 412;
     * 10. Number of steps test. min: -12, max:23; height: 412;
     * 11. Test Reset;
     * 12. Test minMaxChanged;
     * 13. Number of steps test. min: 0, max:700; height: 50;
     * 14. Number of steps test. min: 0, max:700; height: 345;
     * 15. Number of steps test. min: 0, max:24; height: 50;
     * 16. Number of steps test. min: 0, max:24; height: 345;
     * 17. Number of steps test. min: 0, max:24; height: 1000;
     * 18. Number of steps test. min: 0, max:35; height: 1000;
     *
     * */


        //1. Number of steps test. min: 0, max:100; height: 50;
    [Test]
    public function testNumberOfSteps1():void {
        _graphInstance.resize(300, 50 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = 0;
        _graphInstance.minMax.max = 100;
        var vAxis:VDataAxis = new VDataAxis(0, 100, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 0.5);
        assertEquals(vAxis.stepInPixel, 25);
        assertEquals(vAxis.stepInValue, 50);
        assertEquals(vAxis.numberOfSteps, 2);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,50+ GraphInstance.vAxisWidth);

    }

    //2. Number of steps test. min: 0, max:100; height: 345;
    [Test]
    public function testNumberOfSteps2():void {
        _graphInstance.resize(300, 345 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = 0;
        _graphInstance.minMax.max = 100;
        var vAxis:VDataAxis = new VDataAxis(0, 100, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 3.45);
        assertEquals(vAxis.stepInPixel, 34.5);
        assertEquals(vAxis.stepInValue, 10);
        assertEquals(vAxis.numberOfSteps, 10);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,345+ GraphInstance.vAxisWidth);

    }

    //3. Number of steps test. min: 0, max:8; height: 50;
    [Test]
    public function testNumberOfSteps3():void {
        _graphInstance.resize(300, 50 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = 0;
        _graphInstance.minMax.max = 8;
        var vAxis:VDataAxis = new VDataAxis(0, 8, _graphInstance);
        vAxis.reDraw();

        assertEquals(vAxis.pixelResolution, 6.25);
        assertEquals(vAxis.stepInPixel, 25);
        assertEquals(vAxis.stepInValue, 4);
        assertEquals(vAxis.numberOfSteps, 2);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,50+ GraphInstance.vAxisWidth);

    }

    // 4. Number of steps test. min: 0, max:8; height: 345;
    [Test]
    public function testTestCase4():void {
        _graphInstance.resize(300, 345 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = 0;
        _graphInstance.minMax.max = 8;
        var vAxis:VDataAxis = new VDataAxis(0, 8, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 43.125);
        assertEquals(vAxis.stepInPixel, 43.125);
        assertEquals(vAxis.stepInValue, 1);
        assertEquals(vAxis.numberOfSteps, 8);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,345+ GraphInstance.vAxisWidth);

    }

    //5. Number of steps test. min: 0, max:13; height: 50;
    [Test]
    public function testTestCase5():void {
        _graphInstance.resize(300, 50 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = 0;
        _graphInstance.minMax.max = 13;
        var vAxis:VDataAxis = new VDataAxis(0, 13, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 3.846);
        assertEquals(vAxis.stepInPixel, 26.922);
        assertEquals(vAxis.stepInValue, 7);
        assertEquals(vAxis.numberOfSteps, 1);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,50+ GraphInstance.vAxisWidth);

    }
    //6. Number of steps test. min: 0, max:13; height: 423;
    [Test]
    public function testTestCase6():void {
        _graphInstance.resize(300, 423 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = 0;
        _graphInstance.minMax.max = 13;
        var vAxis:VDataAxis = new VDataAxis(0, 13, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 32.538);
        assertEquals(vAxis.stepInPixel, 32.538);
        assertEquals(vAxis.stepInValue, 1);
        assertEquals(vAxis.numberOfSteps, 13);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,423+ GraphInstance.vAxisWidth);

    }

    //7. Number of steps test. min: 0, max:23; height: 50;
    [Test]
    public function testTestCase7():void {
        _graphInstance.resize(300, 50 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = 0;
        _graphInstance.minMax.max = 23;
        var vAxis:VDataAxis = new VDataAxis(0, 13, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 2.174);
        assertEquals(vAxis.stepInPixel, 26.088);
        assertEquals(vAxis.stepInValue, 12);
        assertEquals(vAxis.numberOfSteps, 1);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,50+ GraphInstance.vAxisWidth);

    }

    //8. Number of steps test. min: 0, max:23; height: 412;
    [Test]
    public function testTestCase8():void {
        _graphInstance.resize(300, 412 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = 0;
        _graphInstance.minMax.max = 23;
        var vAxis:VDataAxis = new VDataAxis(0, 23, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 17.913);
        assertEquals(vAxis.stepInPixel, 35.826);
        assertEquals(vAxis.stepInValue, 2);
        assertEquals(vAxis.numberOfSteps, 11);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,412+ GraphInstance.vAxisWidth);

    }
    //9. Number of steps test. min: -20, max:20; height: 412;
    [Test]
    public function testTestCase9():void {
        _graphInstance.resize(300, 412 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = -20;
        _graphInstance.minMax.max = 20;
        var vAxis:VDataAxis = new VDataAxis(-20, 20, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 10.3);
        assertEquals(vAxis.stepInPixel, 103);
        assertEquals(vAxis.stepInValue, 10);
        assertEquals(vAxis.numberOfSteps, 4);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,412+ GraphInstance.vAxisWidth);

    }
    //10. Number of steps test. min: -12, max:23; height: 412;
    [Test]
    public function testTestCase10():void {
        _graphInstance.resize(300, 412 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = -12;
        _graphInstance.minMax.max = 23;
        var vAxis:VDataAxis = new VDataAxis(-12, 23, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 9.581);
        assertEquals(vAxis.stepInPixel, 95.81);
        assertEquals(vAxis.stepInValue, 10);
        assertEquals(vAxis.numberOfSteps, 4);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,412+ GraphInstance.vAxisWidth);

    }



    // Number of steps test. min: 0, max:10; height: 550;
    [Test]
    public function testTestCase0_10_550():void {
        _graphInstance.resize(300, 550 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = 0;
        _graphInstance.minMax.max = 10;
        var vAxis:VDataAxis = new VDataAxis(0, 10, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 55);
        assertEquals(vAxis.stepInPixel, 55);
        assertEquals(vAxis.stepInValue, 1);
        assertEquals(vAxis.numberOfSteps, 10);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,550+ GraphInstance.vAxisWidth);

    }

    // Number of steps test. min: -34, max:34; height: 570;
    [Test]
    public function testTestCase_34_34_570():void {
        _graphInstance.resize(300, 570 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = -34;
        _graphInstance.minMax.max = 43;
        var vAxis:VDataAxis = new VDataAxis(-34, 34, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 6.867);
        assertEquals(vAxis.stepInPixel, 68.67);
        assertEquals(vAxis.stepInValue, 10);
        assertEquals(vAxis.numberOfSteps, 8);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,570+ GraphInstance.vAxisWidth);

    }

    // Number of steps test. min: -34, max:34; height: 390;
    [Test]
    public function testTestCase_34_34_390():void {
        _graphInstance.resize(300, 390 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = -34;
        _graphInstance.minMax.max = 43;
        var vAxis:VDataAxis = new VDataAxis(-34, 34, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 4.699);
        assertEquals(vAxis.stepInPixel, 46.989999999999995);
        assertEquals(vAxis.stepInValue, 10);
        assertEquals(vAxis.numberOfSteps, 8);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,390+ GraphInstance.vAxisWidth);

    }// Number of steps test. min: -34, max:34; height: 130;

    [Test]
    public function testTestCase_34_34_130():void {
        _graphInstance.resize(300, 130 + GraphInstance.vAxisWidth);
        _graphInstance.minMax.min = -34;
        _graphInstance.minMax.max = 43;
        var vAxis:VDataAxis = new VDataAxis(-34, 34, _graphInstance);
        vAxis.reDraw();
        assertEquals(vAxis.pixelResolution, 1.566);
        assertEquals(vAxis.stepInPixel, 31.32);
        assertEquals(vAxis.stepInValue, 20);
        assertEquals(vAxis.numberOfSteps, 4);
        assertEquals(vAxis.yOffset, 0);
        assertEquals(vAxis.height,130+ GraphInstance.vAxisWidth);

    }
}
}
