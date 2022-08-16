/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.28.
 * Time: 10:36
 * To change this template use File | Settings | File Templates.
 */
package com.polar {
import flash.geom.Point;

import org.flexunit.asserts.assertEquals;

public class PolarTableTest {

    var datas:Vector.<PolarData> = new <PolarData>[];
    var polarTable:PolarTable;


    [Test]
    public function testFilterWind():void {
        assertEquals(155, datas.length);
        assertEquals(70, polarTable.table.length);
        assertEquals(360, polarTable.table[0].length);
        assertEquals(360, polarTable.table[69].length);
    }


    [Test]
    public function testAddData():void {
        for (var i:int = 0; i < datas.length; i++) {
            polarTable.addData(datas[i]);
        }
        trace("finish")
        assertEquals(0, polarTable.table[12][47].measured);
    }


    [Test]
    public function testCalculateAvgDistances():void {
        buildUpCustomTable();
        polarTable.polarLoadReady();
    }


    [Test]
    public function testGetCustomWeightedAvg():void {
        var v:Vector.<Number> = new <Number>[6.1, 6.1, 6.2, 6.2, 6.3, 6.4, 6.5, 6.6, 7.3];
        assertEquals(6.56, Math.round(polarTable.getCustomWeightedAvg(v) * 100) / 100);
    }

    [Test]
    public function testInterpolateBetweenPoints():void {
        var point1:Point = new Point(0.5, 1);
        var point2:Point = new Point(2.5, 2);
        polarTable.interpolateBetweenPoints(point1, point2, 1, "cardinalHardCalculated");

        assertEquals(1.25, polarTable.table[1][1].calculated);
        assertEquals(1.75, polarTable.table[1][2].calculated);
        assertEquals(null, polarTable.table[1][3]);

        var point1:Point = new Point(0.5, 1);
        var point2:Point = new Point(1.2, 2);
        polarTable.interpolateBetweenPoints(point1, point2, 1, "cardinalHardCalculated");

        var point1:Point = new Point(1, 1);
        var point2:Point = new Point(2, 2);
        polarTable.interpolateBetweenPoints(point1, point2, 1, "cardinalHardCalculated");

        assertEquals(1, Math.round(polarTable.table[1][1].calculated * 1000) / 1000);
        assertEquals(2, Math.round(polarTable.table[1][2].calculated * 1000) / 1000);


    }


    [Test]
    public function testAvgMeasuerd():void {
        var table:Vector.<Vector.<PolarBoatSpeed>> = new Vector.<Vector.<PolarBoatSpeed>>(PolarTable.MAX_WINDSPEED)
        //       8    9.59   43.78   10.99   75.00   11.19  115.00    9.01  138.43    4.95     180
        table[8] = new Vector.<PolarBoatSpeed>(360, true);
        table[8][43] = new MockPolarBoatSpeed(8);
        (table[8][43] as MockPolarBoatSpeed)._measured = 9.59;   //0.8
        table[8][75] = new MockPolarBoatSpeed(8);
        (table[8][75] as MockPolarBoatSpeed)._measured = 10.99;   //0.8
        table[8][115] = new MockPolarBoatSpeed(8);
        (table[8][115] as MockPolarBoatSpeed)._measured = 11.19;   //0.8
        table[8][138] = new MockPolarBoatSpeed(8);
        (table[8][138] as MockPolarBoatSpeed)._measured = 9.01;   //0.8
        table[8][180] = new MockPolarBoatSpeed(8);
        (table[8][180] as MockPolarBoatSpeed)._measured = 4.95;   //0.8

        polarTable.table = table;
        assertEquals(9.59, polarTable.getAvgMeasuerd(40, 8))
        assertEquals(10.99, polarTable.getAvgMeasuerd(70, 8))
        assertEquals(11.19, polarTable.getAvgMeasuerd(110, 8))
        assertEquals(9.01, polarTable.getAvgMeasuerd(140, 8))
        assertEquals(4.95, polarTable.getAvgMeasuerd(180, 8))

    }

//    [Test]
//    public function testCalculateDistst():void {
//        var table:Vector.<Vector.<PolarBoatSpeed>> = new Vector.<Vector.<PolarBoatSpeed>>(PolarTable.MAX_WINDSPEED)
//        table[1] = new Vector.<PolarBoatSpeed>(360, true);
//        table[1][0] = new MockPolarBoatSpeed(1);
//        (table[1][0] as MockPolarBoatSpeed)._measured = 0.8;   //0.8
//        table[1][0].setMax(0);
//
//        table[1][1] = new MockPolarBoatSpeed(1);
//        (table[1][1] as MockPolarBoatSpeed)._measured = 0.9;   //0.8
//        table[1][1].setMax(0);
//
//        table[1][2] = new MockPolarBoatSpeed(1);
//        (table[1][2] as MockPolarBoatSpeed)._measured = 0.9;   //0.8
//        table[1][2].setMax(0);
//
//        table[2] = new Vector.<PolarBoatSpeed>(360, true);
//        table[2][0] = new MockPolarBoatSpeed(2);
//        (table[2][0] as MockPolarBoatSpeed)._measured = 1.2;        //0.6
//        table[2][0].setMax(0);
//
//        table[2][1] = new MockPolarBoatSpeed(2);
//        (table[2][1] as MockPolarBoatSpeed)._measured = 1.2;        //0.6
//        table[2][1].setMax(0);
//
//        table[2][2] = new MockPolarBoatSpeed(2);
//        (table[2][2] as MockPolarBoatSpeed)._measured = 1.2;        //0.6
//        table[2][2].setMax(0);
//
//
//        table[3] = new Vector.<PolarBoatSpeed>(360, true);
//        table[3][0] = new MockPolarBoatSpeed(3);
//        (table[3][0] as MockPolarBoatSpeed)._measured = 0;               //0
//        table[3][0].setMax(0);
//
//
//        table[4] = new Vector.<PolarBoatSpeed>(360, true);
//        table[4][0] = new MockPolarBoatSpeed(4);
//        (table[4][0] as MockPolarBoatSpeed)._measured = 0;     //0
//        table[4][0].setMax(0);
//
//        table[5] = new Vector.<PolarBoatSpeed>(360, true);
//        table[5][0] = new MockPolarBoatSpeed(5);
//        (table[5][0] as MockPolarBoatSpeed)._measured = 3;  //0.6
//        table[5][0].setMax(0);
//
//
//        table[6] = new Vector.<PolarBoatSpeed>(360, true);
//        table[6][0] = new MockPolarBoatSpeed(6);
//        (table[6][0] as MockPolarBoatSpeed)._measured = 4.2;  //0.7
//        table[6][0].setMax(0);
//
//
//        table[7] = new Vector.<PolarBoatSpeed>(360, true);
//        table[7][0] = new MockPolarBoatSpeed(7);
//        (table[7][0] as MockPolarBoatSpeed)._measured = 0; //0
//        table[7][0].setMax(0);
//
//
//        table[8] = new Vector.<PolarBoatSpeed>(360, true);
//        table[8][0] = new MockPolarBoatSpeed(8);
//        (table[8][0] as MockPolarBoatSpeed)._measured = 5.6;  //0.7
//        table[8][0].setMax(0);
//        polarTable.table = table;
//
//        var dists:Vector.<Number> = polarTable.calculateRatioDistForAngle(0);
//        assertEquals(0, dists[0]);
//        assertEquals(0.2, Math.round(dists[1] * 10) / 10);
//        assertEquals(0, Math.round(dists[2] * 10) / 10);
//        assertEquals(0, Math.round(dists[3] * 10) / 10);
//        assertEquals(0, Math.round(dists[4] * 10) / 10);
//        assertEquals(-0.1, Math.round(dists[5] * 10) / 10);
//        assertEquals(0, Math.round(dists[6] * 10) / 10);
//        assertEquals(0, Math.round(dists[7] * 10) / 10);
//        assertEquals(0, Math.round(dists[8] * 10) / 10);
//        assertEquals(0, Math.round(dists[9] * 10) / 10);
//    }


//    [Test]
//    public function testAvgDist():void {
//        var table:Vector.<Vector.<PolarBoatSpeed>> = new Vector.<Vector.<PolarBoatSpeed>>(PolarTable.MAX_WINDSPEED)
//        table[1] = new Vector.<PolarBoatSpeed>(360, true);
//        table[1][0] = new MockPolarBoatSpeed(1);
//        (table[1][0] as MockPolarBoatSpeed)._measured = 0.8;   //0.8
//        table[1][0].setMax(0);
//
//        table[1][1] = new MockPolarBoatSpeed(1);
//        (table[1][1] as MockPolarBoatSpeed)._measured = 0.9;   //0.8
//        table[1][1].setMax(0);
//
//        table[1][2] = new MockPolarBoatSpeed(1);
//        (table[1][2] as MockPolarBoatSpeed)._measured = 0.9;   //0.8
//        table[1][2].setMax(0);
//
//        table[2] = new Vector.<PolarBoatSpeed>(360, true);
//        table[2][0] = new MockPolarBoatSpeed(2);
//        (table[2][0] as MockPolarBoatSpeed)._measured = 1.2;        //0.6
//        table[2][0].setMax(0);
//
//        table[2][1] = new MockPolarBoatSpeed(2);
//        (table[2][1] as MockPolarBoatSpeed)._measured = 1.2;        //0.6
//        table[2][1].setMax(0);
//
//        table[2][2] = new MockPolarBoatSpeed(2);
//        (table[2][2] as MockPolarBoatSpeed)._measured = 1.2;        //0.6
//        table[2][2].setMax(0);
//
//
//        table[3] = new Vector.<PolarBoatSpeed>(360, true);
//        table[3][0] = new MockPolarBoatSpeed(3);
//        (table[3][0] as MockPolarBoatSpeed)._measured = 0;               //0
//        table[3][0].setMax(0);
//
//
//        table[4] = new Vector.<PolarBoatSpeed>(360, true);
//        table[4][0] = new MockPolarBoatSpeed(4);
//        (table[4][0] as MockPolarBoatSpeed)._measured = 0;     //0
//        table[4][0].setMax(0);
//
//        table[5] = new Vector.<PolarBoatSpeed>(360, true);
//        table[5][0] = new MockPolarBoatSpeed(5);
//        (table[5][0] as MockPolarBoatSpeed)._measured = 3;  //0.6
//        table[5][0].setMax(0);
//
//
//        table[6] = new Vector.<PolarBoatSpeed>(360, true);
//        table[6][0] = new MockPolarBoatSpeed(6);
//        (table[6][0] as MockPolarBoatSpeed)._measured = 4.2;  //0.7
//        table[6][0].setMax(0);
//
//
//        table[7] = new Vector.<PolarBoatSpeed>(360, true);
//        table[7][0] = new MockPolarBoatSpeed(7);
//        (table[7][0] as MockPolarBoatSpeed)._measured = 0; //0
//        table[7][0].setMax(0);
//
//
//        table[8] = new Vector.<PolarBoatSpeed>(360, true);
//        table[8][0] = new MockPolarBoatSpeed(8);
//        (table[8][0] as MockPolarBoatSpeed)._measured = 5.6;  //0.7
//        table[8][0].setMax(0);
//        polarTable.table = table;
//
//        var a:Array = polarTable.calculateAverageDists();
//        assertEquals(0.275, a[0][1])
//        assertEquals(0, a[1][1])
//        assertEquals(0, a[2][1])
//        assertEquals(0, a[3][1])
//        trace(a.toString())
//    }

    private function buildUpCustomTable():void {
        var table:Vector.<Vector.<PolarBoatSpeed>> = new Vector.<Vector.<PolarBoatSpeed>>(16)
        var c:int = 1;
        for (var i:int = 0; i < PolarTable.MAX_WINDSPEED; i++) {

            var innerPolar:Vector.<PolarBoatSpeed> = new Vector.<PolarBoatSpeed>(360, true);
//            trace(i, ((c ) * 30), "-", ((c) * 30 + 30), ";", 360 - (c) * 30 * 2, "-", 360 - (c) * 30);
            if (i >= 6 && i < 16) {
                for (var j:int = 0; j < 360; j++) {
                    var pbs:MockPolarBoatSpeed = new MockPolarBoatSpeed(i);
                    if (j > 28 && j < 335 && ((j > ((c) * 30) && j < (c ) * 30 + 30) || (j > 360 - (c ) * 30 * 2 && j < 360 - (c) * 30 ))) {
                        pbs._measured = i * Math.sqrt(i * 1.98 / ((j > 180 ? Math.abs(360 - j) : j) * 0.43));
                        pbs.setMax(0);

                    } else {
                        pbs._measured = 0;
                        pbs.setMax(0);
                    }
                    innerPolar[j] = pbs;
                }
                c++;
            }
            table[i] = innerPolar;

        }

        for (var i:int = 0; i < table.length; i++) {
            var inner:Vector.<PolarBoatSpeed> = table[i];
            if (inner === null) {
                continue;
            }
            for (var j:int = 0; j < inner.length; j++) {
                var polarBoatSpeed:PolarBoatSpeed = inner[j];
            }

        }

        polarTable.table = table;
    }


//    [Test]
//    public function testGetActualRatio():void {
//        var a:Vector.<Number> = new <Number>[0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 30]
//        var b:Vector.<Number> = new <Number>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
//        var c:Vector.<Number> = new <Number>[0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 0]
//
//        var ratioContainer:Array = [];
//
//        ratioContainer.push(a)
//        ratioContainer.push(b)
//        ratioContainer.push(c)
//
//        assertEquals(0, polarTable.getActualRatio(ratioContainer, PolarTable.RES + 1, 0));
//        assertEquals(12, polarTable.getActualRatio(ratioContainer, PolarTable.RES + 1, 9));
//        assertEquals(28, polarTable.getActualRatio(ratioContainer, PolarTable.RES + 1, 27));
//
//    }

    [Test]
    public function testReady():void {
        for (var i:int = 0; i < datas.length; i++) {
            polarTable.addData(datas[i]);
        }
        polarTable.polarLoadReady();
    }


//    [Test]
//    public function testInterpolateDists():void {
//        var container:Array = [];
//        container.push([0, 2, 0, 1, 2, 3]) //0
//        container.push([0, 0, 0, 1, 2, 3]) //1
//        container.push([0, 0, 0, 1, 2, 3]) //2
//        container.push([0, 0, 0, 1, 2, 3]) //3
//        container.push([0, 0, 0, 1, 2, 3]) //4
//        container.push([0, 0, 0, 1, 2, 3]) //5
//        container.push([0, 0, 0, 1, 2, 3]) //6
//        container.push([0, 0, 0, 1, 2, 3]) //7
//        container.push([0, 3, 0, 1, 2, 3]) //8
//        container.push([0, 3, 0, 0, 2, 3]) //9
//
//        var newContainer:Array = polarTable.interpolateDists(container);
//        assertEquals(2, newContainer[0][1]);
//        assertEquals(2, newContainer[1][1]);
//        assertEquals(3, newContainer[7][1]);
//    }


//    [Test]
//    public function testVerticalScan():void {
//        var ratios:Vector.<Number> = new Vector.<Number>(16);
//        ratios[0] = 0;
//        ratios[1] = 0;
//        ratios[2] = 1;
//        ratios[3] = 2;
//        ratios[4] = 3;
//        ratios[5] = 0;
//        ratios[6] = 0;
//        ratios[7] = 4;
//        ratios[8] = 5;
//        ratios[9] = 38;
//        ratios[10] = 33;
//        ratios[11] = 25;
//        ratios[12] = 22;
//        ratios[13] = 19;
//        ratios[14] = 15;
//        ratios[15] = 8;
//
//        assertEquals(0, polarTable.scanVerticalInSpeedDists(ratios, 0))
//        assertEquals(3.33, Math.round(polarTable.scanVerticalInSpeedDists(ratios, 6) * 100) / 100)
//        assertEquals(0, polarTable.scanVerticalInSpeedDists(ratios, 1))
//        assertEquals(49, polarTable.scanVerticalInSpeedDists(ratios, 3))
//
//
//    }

    [Before]
    public function setUp():void {
        datas.length = 0
        polarTable = new PolarTable();
        //timestamp, windspeed, boatspeed, windangle
        datas.push(new PolarData(-1, 12, 7.3, 86));
        datas.push(new PolarData(-1, 12, 7.4, 83));
        datas.push(new PolarData(-1, 12, 7.4, 83));
        datas.push(new PolarData(-1, 12, 7.4, 88));
        datas.push(new PolarData(-1, 12, 7.4, 87));
        datas.push(new PolarData(-1, 12, 7.4, 84));
        datas.push(new PolarData(-1, 12, 7.4, 85));
        datas.push(new PolarData(-1, 12, 7.4, 83));
        datas.push(new PolarData(-1, 12, 7.4, 87));
        datas.push(new PolarData(-1, 12, 7.5, 87));
        datas.push(new PolarData(-1, 12, 7.5, 87));
        datas.push(new PolarData(-1, 12, 7.5, 87));
        datas.push(new PolarData(-1, 12, 7.5, 85));
        datas.push(new PolarData(-1, 12, 7.5, 83));
        datas.push(new PolarData(-1, 12, 7.5, 85));
        datas.push(new PolarData(-1, 12, 7.5, 84));
        datas.push(new PolarData(-1, 12, 7.5, 86));
        datas.push(new PolarData(-1, 12, 7.5, 83));
        datas.push(new PolarData(-1, 12, 7.5, 84));
        datas.push(new PolarData(-1, 12, 7.5, 82));
        datas.push(new PolarData(-1, 12, 7.5, 82));
        datas.push(new PolarData(-1, 12, 7.5, 82));
        datas.push(new PolarData(-1, 12, 7.6, 81));
        datas.push(new PolarData(-1, 12, 7.6, 83));
        datas.push(new PolarData(-1, 12, 7.6, 83));
        datas.push(new PolarData(-1, 12, 7.7, 84));
        datas.push(new PolarData(-1, 12, 7.7, 79));
        datas.push(new PolarData(-1, 12, 7.7, 83));
        datas.push(new PolarData(-1, 12, 7.7, 80));
        datas.push(new PolarData(-1, 12, 7.7, 80));
        datas.push(new PolarData(-1, 12, 7.7, 82));
        datas.push(new PolarData(-1, 12, 7.7, 81));
        datas.push(new PolarData(-1, 12, 7.7, 80));
        datas.push(new PolarData(-1, 12, 7.7, 83));
        datas.push(new PolarData(-1, 12, 7.7, 85));
        datas.push(new PolarData(-1, 12, 7.7, 85));
        datas.push(new PolarData(-1, 12, 7.7, 81));
        datas.push(new PolarData(-1, 12, 7.7, 83));
        datas.push(new PolarData(-1, 12, 7.7, 82));
        datas.push(new PolarData(-1, 12, 7.8, 83));
        datas.push(new PolarData(-1, 12, 7.9, 85));
        datas.push(new PolarData(-1, 12, 7.9, 80));
        datas.push(new PolarData(-1, 12, 7.9, 83));
        datas.push(new PolarData(-1, 12, 8, 84));
        datas.push(new PolarData(-1, 12, 8, 84));
        datas.push(new PolarData(-1, 12, 8, 84));
        datas.push(new PolarData(-1, 12, 8, 83));
        datas.push(new PolarData(-1, 12, 8, 85));
        datas.push(new PolarData(-1, 12, 8, 82));
        datas.push(new PolarData(-1, 12, 7.9, 87));
        datas.push(new PolarData(-1, 12, 7.9, 88));
        datas.push(new PolarData(-1, 12, 7.9, 90));
        datas.push(new PolarData(-1, 12, 7.9, 88));
        datas.push(new PolarData(-1, 12, 7.8, 88));
        datas.push(new PolarData(-1, 12, 7.7, 88));
        datas.push(new PolarData(-1, 12, 7.7, 89));
        datas.push(new PolarData(-1, 12, 7.7, 88));
        datas.push(new PolarData(-1, 12, 7.7, 87));
        datas.push(new PolarData(-1, 12, 7.7, 86));
        datas.push(new PolarData(-1, 12, 7.7, 86));
        datas.push(new PolarData(-1, 12, 7.7, 85));
        datas.push(new PolarData(-1, 12, 7.7, 85));
        datas.push(new PolarData(-1, 12, 7.7, 84));
        datas.push(new PolarData(-1, 12, 7.7, 89));
        datas.push(new PolarData(-1, 12, 7.7, 86));
        datas.push(new PolarData(-1, 12, 7.7, 88));
        datas.push(new PolarData(-1, 12, 7.6, 87));
        datas.push(new PolarData(-1, 12, 7.6, 89));
        datas.push(new PolarData(-1, 12, 7.6, 87));
        datas.push(new PolarData(-1, 12, 7.6, 84));
        datas.push(new PolarData(-1, 12, 7.3, 82));
        datas.push(new PolarData(-1, 12, 7.4, 87));
        datas.push(new PolarData(-1, 12, 7.5, 88));
        datas.push(new PolarData(-1, 12, 7.6, 83));
        datas.push(new PolarData(-1, 12, 7.6, 88));
        datas.push(new PolarData(-1, 12, 7.7, 87));
        datas.push(new PolarData(-1, 12, 7.7, 85));
        datas.push(new PolarData(-1, 12, 7.8, 87));
        datas.push(new PolarData(-1, 12, 7.8, 85));
        datas.push(new PolarData(-1, 12, 7.8, 86));
        datas.push(new PolarData(-1, 12, 7.8, 82));
        datas.push(new PolarData(-1, 12, 7.8, 85));
        datas.push(new PolarData(-1, 12, 7.8, 89));
        datas.push(new PolarData(-1, 12, 7.8, 90));
        datas.push(new PolarData(-1, 12, 7.8, 90));
        datas.push(new PolarData(-1, 12, 7.8, 88));
        datas.push(new PolarData(-1, 12, 7.7, 89));
        datas.push(new PolarData(-1, 12, 7.7, 90));
        datas.push(new PolarData(-1, 12, 7.7, 86));
        datas.push(new PolarData(-1, 12, 7.6, 84));
        datas.push(new PolarData(-1, 12, 7.6, 87));
        datas.push(new PolarData(-1, 12, 7.6, 89));
        datas.push(new PolarData(-1, 12, 7.6, 88));
        datas.push(new PolarData(-1, 12, 7.6, 92));
        datas.push(new PolarData(-1, 12, 7.6, 90));
        datas.push(new PolarData(-1, 12, 7.6, 89));
        datas.push(new PolarData(-1, 12, 7.6, 86));
        datas.push(new PolarData(-1, 12, 7.5, 94));
        datas.push(new PolarData(-1, 12, 7.5, 88));
        datas.push(new PolarData(-1, 12, 7.4, 90));
        datas.push(new PolarData(-1, 12, 7.3, 93));
        datas.push(new PolarData(-1, 12, 6.6, 42));
        datas.push(new PolarData(-1, 12, 6.5, 35));
        datas.push(new PolarData(-1, 12, 6.3, 8));
        datas.push(new PolarData(-1, 12, 5.6, 87));
        datas.push(new PolarData(-1, 12, 5.6, 94));
        datas.push(new PolarData(-1, 12, 5.7, 88));
        datas.push(new PolarData(-1, 12, 5.8, 93));
        datas.push(new PolarData(-1, 12, 5.9, 82));
        datas.push(new PolarData(-1, 12, 5.9, 90));
        datas.push(new PolarData(-1, 12, 5.9, 91));
        datas.push(new PolarData(-1, 12, 6.6, 85));
        datas.push(new PolarData(-1, 12, 8, 90));
        datas.push(new PolarData(-1, 12, 8, 88));
        datas.push(new PolarData(-1, 12, 7.9, 93));
        datas.push(new PolarData(-1, 12, 7.8, 91));
        datas.push(new PolarData(-1, 12, 7.8, 94));
        datas.push(new PolarData(-1, 12, 7.8, 94));
        datas.push(new PolarData(-1, 12, 7.8, 88));
        datas.push(new PolarData(-1, 12, 7.7, 93));
        datas.push(new PolarData(-1, 12, 7.7, 91));
        datas.push(new PolarData(-1, 12, 7.7, 94));
        datas.push(new PolarData(-1, 12, 7.6, 92));
        datas.push(new PolarData(-1, 12, 7.6, 89));
        datas.push(new PolarData(-1, 12, 7.6, 89));
        datas.push(new PolarData(-1, 12, 7.6, 93));
        datas.push(new PolarData(-1, 12, 7.6, 94));
        datas.push(new PolarData(-1, 12, 7.5, 88));
        datas.push(new PolarData(-1, 12, 7.5, 92));
        datas.push(new PolarData(-1, 12, 7.5, 96));
        datas.push(new PolarData(-1, 12, 7.5, 97));
        datas.push(new PolarData(-1, 12, 7.5, 94));
        datas.push(new PolarData(-1, 12, 7.5, 96));
        datas.push(new PolarData(-1, 12, 7.5, 96));
        datas.push(new PolarData(-1, 12, 7.5, 97));
        datas.push(new PolarData(-1, 12, 7.4, 92));
        datas.push(new PolarData(-1, 12, 7.4, 100));
        datas.push(new PolarData(-1, 12, 7.4, 92));
        datas.push(new PolarData(-1, 12, 7.4, 97));
        datas.push(new PolarData(-1, 12, 7.4, 98));
        datas.push(new PolarData(-1, 12, 7.4, 93));
        datas.push(new PolarData(-1, 12, 7.4, 96));
        datas.push(new PolarData(-1, 12, 7.4, 98));
        datas.push(new PolarData(-1, 12, 7.4, 97));
        datas.push(new PolarData(-1, 12, 7.4, 98));
        datas.push(new PolarData(-1, 12, 7.7, 95));
        datas.push(new PolarData(-1, 12, 7.8, 95));
        datas.push(new PolarData(-1, 12, 7.9, 96));
        datas.push(new PolarData(-1, 12, 7.9, 94));
        datas.push(new PolarData(-1, 12, 7.9, 96));
        datas.push(new PolarData(-1, 12, 7.9, 98));
        datas.push(new PolarData(-1, 12, 7.8, 94));
        datas.push(new PolarData(-1, 12, 7.8, 94));
        datas.push(new PolarData(-1, 12, 7.8, 97));
        datas.push(new PolarData(-1, 12, 7.8, 95));
        datas.push(new PolarData(-1, 12, 7.8, 96));
        datas.push(new PolarData(-1, 12, 7.8, 98));
        datas.push(new PolarData(-1, 12, 7.8, 95));
        datas.push(new PolarData(-1, 12, 7.8, 96));
        datas.push(new PolarData(-1, 12, 7.8, 91));
        datas.push(new PolarData(-1, 12, 7.8, 94));
        datas.push(new PolarData(-1, 12, 7.8, 96));
        datas.push(new PolarData(-1, 12, 7.8, 97));
        datas.push(new PolarData(-1, 12, 7.8, 95));
        datas.push(new PolarData(-1, 12, 7.8, 98));
        datas.push(new PolarData(-1, 12, 7.8, 94));
        datas.push(new PolarData(-1, 12, 7.8, 96));
        datas.push(new PolarData(-1, 12, 7.8, 96));
        datas.push(new PolarData(-1, 12, 7.8, 98));
        datas.push(new PolarData(-1, 12, 7.8, 96));
        datas.push(new PolarData(-1, 12, 7.8, 96));
        datas.push(new PolarData(-1, 12, 7.8, 95));
        datas.push(new PolarData(-1, 12, 7.8, 100));
        datas.push(new PolarData(-1, 12, 7.8, 95));
        datas.push(new PolarData(-1, 12, 7.8, 100));
        datas.push(new PolarData(-1, 12, 7.8, 98));
        datas.push(new PolarData(-1, 12, 7.7, 93));
        datas.push(new PolarData(-1, 12, 7.7, 97));
        datas.push(new PolarData(-1, 12, 7.7, 98));
        datas.push(new PolarData(-1, 12, 7.7, 95));
        datas.push(new PolarData(-1, 12, 7.7, 97));
        datas.push(new PolarData(-1, 12, 7.6, 91));
        datas.push(new PolarData(-1, 12, 7.7, 98));
        datas.push(new PolarData(-1, 12, 7.6, 99));
        datas.push(new PolarData(-1, 12, 7.6, 102));
        datas.push(new PolarData(-1, 12, 7.5, 100));
        datas.push(new PolarData(-1, 12, 7.2, 98));
        datas.push(new PolarData(-1, 12, 7.2, 98));
        datas.push(new PolarData(-1, 12, 7.2, 102));
        datas.push(new PolarData(-1, 12, 7.2, 96));
        datas.push(new PolarData(-1, 12, 7.2, 101));
        datas.push(new PolarData(-1, 12, 7.1, 103));
        datas.push(new PolarData(-1, 12, 7.1, 100));
        datas.push(new PolarData(-1, 12, 7.1, 99));
        datas.push(new PolarData(-1, 12, 7.1, 96));
        datas.push(new PolarData(-1, 12, 7.1, 94));
        datas.push(new PolarData(-1, 12, 7.1, 96));
        datas.push(new PolarData(-1, 12, 7.1, 94));
        datas.push(new PolarData(-1, 12, 7.1, 97));
        datas.push(new PolarData(-1, 12, 7.1, 97));
        datas.push(new PolarData(-1, 12, 7, 86));
        datas.push(new PolarData(-1, 12, 7, 79));
        datas.push(new PolarData(-1, 12, 6.3, 32));
        datas.push(new PolarData(-1, 12, 5.9, 20));
        datas.push(new PolarData(-1, 12, 4.7, 63));
        datas.push(new PolarData(-1, 12, 8.1, 91));
        datas.push(new PolarData(-1, 12, 8, 90));
        datas.push(new PolarData(-1, 12, 8, 89));
        datas.push(new PolarData(-1, 12, 7.9, 88));
        datas.push(new PolarData(-1, 12, 7.9, 90));
        datas.push(new PolarData(-1, 12, 7.8, 83));
        datas.push(new PolarData(-1, 12, 7.8, 87));
        datas.push(new PolarData(-1, 12, 7.8, 87));
        datas.push(new PolarData(-1, 12, 7.7, 89));
        datas.push(new PolarData(-1, 12, 7.6, 89));
        datas.push(new PolarData(-1, 12, 7.7, 90));
        datas.push(new PolarData(-1, 12, 7.8, 88));
        datas.push(new PolarData(-1, 12, 7.9, 83));
        datas.push(new PolarData(-1, 12, 8.2, 92));
        datas.push(new PolarData(-1, 12, 8.1, 92));
        datas.push(new PolarData(-1, 12, 8, 91));
        datas.push(new PolarData(-1, 12, 8, 94));
        datas.push(new PolarData(-1, 12, 7.8, 97));
        datas.push(new PolarData(-1, 12, 7.8, 96));
        datas.push(new PolarData(-1, 12, 7.7, 98));
        datas.push(new PolarData(-1, 12, 7.5, 96));
        datas.push(new PolarData(-1, 12, 7.4, 95));
        datas.push(new PolarData(-1, 12, 7.3, 90));
        datas.push(new PolarData(-1, 12, 8.1, 82));
        datas.push(new PolarData(-1, 12, 8, 81));
        datas.push(new PolarData(-1, 12, 8, 85));
        datas.push(new PolarData(-1, 12, 8, 85));
        datas.push(new PolarData(-1, 12, 8, 88));
        datas.push(new PolarData(-1, 12, 8, 87));
        datas.push(new PolarData(-1, 12, 8.1, 86));
        datas.push(new PolarData(-1, 12, 7.9, 77));
        datas.push(new PolarData(-1, 12, 7.8, 84));
        datas.push(new PolarData(-1, 12, 7.8, 85));
        datas.push(new PolarData(-1, 12, 7.8, 81));
        datas.push(new PolarData(-1, 12, 7.7, 81));
        datas.push(new PolarData(-1, 12, 8.2, 83));
        datas.push(new PolarData(-1, 12, 8.2, 83));
        datas.push(new PolarData(-1, 12, 8.2, 85));
        datas.push(new PolarData(-1, 12, 8.3, 85));
        datas.push(new PolarData(-1, 12, 8.3, 83));
        datas.push(new PolarData(-1, 12, 8.3, 83));
        datas.push(new PolarData(-1, 12, 8.2, 83));
        datas.push(new PolarData(-1, 12, 8.2, 86));
        datas.push(new PolarData(-1, 12, 8.2, 85));
        datas.push(new PolarData(-1, 12, 8.2, 87));
        datas.push(new PolarData(-1, 12, 8.2, 86));
        datas.push(new PolarData(-1, 12, 8.2, 86));
        datas.push(new PolarData(-1, 12, 8.2, 83));
        datas.push(new PolarData(-1, 12, 8.2, 83));
        datas.push(new PolarData(-1, 12, 8.2, 82));
        datas.push(new PolarData(-1, 12, 8.2, 82));
        datas.push(new PolarData(-1, 12, 8.1, 85));
        datas.push(new PolarData(-1, 12, 8.1, 85));
        datas.push(new PolarData(-1, 12, 8.1, 85));
        datas.push(new PolarData(-1, 12, 8.2, 80));
        datas.push(new PolarData(-1, 12, 8.1, 83));
        datas.push(new PolarData(-1, 12, 8.1, 82));
        datas.push(new PolarData(-1, 12, 8.1, 86));
        datas.push(new PolarData(-1, 12, 8.2, 88));
        datas.push(new PolarData(-1, 12, 8.2, 86));
        datas.push(new PolarData(-1, 12, 8.2, 84));
        datas.push(new PolarData(-1, 12, 8.1, 87));
        datas.push(new PolarData(-1, 12, 8.2, 89));
        datas.push(new PolarData(-1, 12, 8.2, 88));
        datas.push(new PolarData(-1, 12, 8.2, 86));
        datas.push(new PolarData(-1, 12, 8.2, 87));
        datas.push(new PolarData(-1, 12, 8.2, 90));
        datas.push(new PolarData(-1, 12, 8.2, 90));
        datas.push(new PolarData(-1, 12, 8.2, 88));
        datas.push(new PolarData(-1, 12, 8.2, 91));
        datas.push(new PolarData(-1, 12, 8.2, 92));
        datas.push(new PolarData(-1, 12, 8.2, 90));
        datas.push(new PolarData(-1, 12, 8.2, 87));
        datas.push(new PolarData(-1, 12, 8.2, 88));
        datas.push(new PolarData(-1, 12, 8.2, 88));
        datas.push(new PolarData(-1, 12, 8.1, 89));
        datas.push(new PolarData(-1, 12, 8.1, 89));
        datas.push(new PolarData(-1, 12, 8.1, 90));
        datas.push(new PolarData(-1, 12, 8.1, 92));
        datas.push(new PolarData(-1, 12, 8.1, 91));
        datas.push(new PolarData(-1, 12, 8.1, 91));
        datas.push(new PolarData(-1, 12, 8, 89));
        datas.push(new PolarData(-1, 12, 8, 94));
        datas.push(new PolarData(-1, 12, 8, 92));
        datas.push(new PolarData(-1, 12, 8, 94));
        datas.push(new PolarData(-1, 12, 7.9, 93));
        datas.push(new PolarData(-1, 12, 7.8, 88));
        datas.push(new PolarData(-1, 12, 7.7, 93));
        datas.push(new PolarData(-1, 12, 7.7, 96));
        datas.push(new PolarData(-1, 12, 6.8, 44));
        datas.push(new PolarData(-1, 12, 5.8, 12));
        datas.push(new PolarData(-1, 12, 5.1, 40));
        datas.push(new PolarData(-1, 12, 4.7, 56));
        datas.push(new PolarData(-1, 12, 5, 70));
        datas.push(new PolarData(-1, 12, 8.3, 91));
        datas.push(new PolarData(-1, 12, 8.3, 89));
        datas.push(new PolarData(-1, 12, 8.2, 88));
        datas.push(new PolarData(-1, 12, 8.2, 89));
        datas.push(new PolarData(-1, 12, 8.2, 94));
        datas.push(new PolarData(-1, 12, 8.2, 94));
        datas.push(new PolarData(-1, 12, 8.2, 92));
        datas.push(new PolarData(-1, 12, 8.1, 93));
        datas.push(new PolarData(-1, 12, 8.1, 90));
        datas.push(new PolarData(-1, 12, 8.1, 90));
        datas.push(new PolarData(-1, 12, 8.1, 92));
        datas.push(new PolarData(-1, 12, 8.1, 90));
        datas.push(new PolarData(-1, 12, 8.1, 88));
        datas.push(new PolarData(-1, 12, 8.1, 89));
        datas.push(new PolarData(-1, 12, 8.1, 89));
        datas.push(new PolarData(-1, 12, 8.1, 91));
        datas.push(new PolarData(-1, 12, 8.1, 89));
        datas.push(new PolarData(-1, 12, 8.1, 92));
        datas.push(new PolarData(-1, 12, 8.1, 90));
        datas.push(new PolarData(-1, 12, 8.1, 94));
        datas.push(new PolarData(-1, 12, 8.1, 89));
        datas.push(new PolarData(-1, 12, 8.2, 87));
        datas.push(new PolarData(-1, 12, 8.2, 93));
        datas.push(new PolarData(-1, 12, 8.2, 94));
        datas.push(new PolarData(-1, 12, 8.2, 93));
        datas.push(new PolarData(-1, 12, 8.2, 92));
        datas.push(new PolarData(-1, 12, 8.1, 92));
        datas.push(new PolarData(-1, 12, 8.1, 86));
        datas.push(new PolarData(-1, 12, 8.1, 87));
        datas.push(new PolarData(-1, 12, 8.1, 84));
        datas.push(new PolarData(-1, 12, 8.1, 85));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 7.9, 77));
        datas.push(new PolarData(-1, 12, 7.8, 74));
        datas.push(new PolarData(-1, 12, 7.8, 71));
        datas.push(new PolarData(-1, 12, 7.7, 59));
        datas.push(new PolarData(-1, 12, 7.6, 63));
        datas.push(new PolarData(-1, 12, 5.7, 4));
        datas.push(new PolarData(-1, 12, 7.8, 74));
        datas.push(new PolarData(-1, 12, 7.8, 71));
        datas.push(new PolarData(-1, 12, 8, 74));
        datas.push(new PolarData(-1, 12, 7.8, 63));
        datas.push(new PolarData(-1, 12, 8.4, 85));
        datas.push(new PolarData(-1, 12, 8.3, 83));
        datas.push(new PolarData(-1, 12, 8.3, 81));
        datas.push(new PolarData(-1, 12, 8.3, 79));
        datas.push(new PolarData(-1, 12, 8.2, 83));
        datas.push(new PolarData(-1, 12, 8.1, 80));
        datas.push(new PolarData(-1, 12, 8.1, 82));
        datas.push(new PolarData(-1, 12, 8.1, 81));
        datas.push(new PolarData(-1, 12, 8.1, 80));
        datas.push(new PolarData(-1, 12, 8, 83));
        datas.push(new PolarData(-1, 12, 8, 82));
        datas.push(new PolarData(-1, 12, 8, 81));
        datas.push(new PolarData(-1, 12, 8, 81));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 8, 83));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 7.9, 82));
        datas.push(new PolarData(-1, 12, 8, 77));
        datas.push(new PolarData(-1, 12, 8, 76));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 7.9, 83));
        datas.push(new PolarData(-1, 12, 7.9, 84));
        datas.push(new PolarData(-1, 12, 7.9, 82));
        datas.push(new PolarData(-1, 12, 7.9, 80));
        datas.push(new PolarData(-1, 12, 7.9, 82));
        datas.push(new PolarData(-1, 12, 7.9, 82));
        datas.push(new PolarData(-1, 12, 7.9, 86));
        datas.push(new PolarData(-1, 12, 7.9, 82));
        datas.push(new PolarData(-1, 12, 7.8, 83));
        datas.push(new PolarData(-1, 12, 7.8, 82));
        datas.push(new PolarData(-1, 12, 7.7, 84));
        datas.push(new PolarData(-1, 12, 7.7, 81));
        datas.push(new PolarData(-1, 12, 7.7, 79));
        datas.push(new PolarData(-1, 12, 7.6, 79));
        datas.push(new PolarData(-1, 12, 7.6, 83));
        datas.push(new PolarData(-1, 12, 7.7, 81));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 8, 80));
        datas.push(new PolarData(-1, 12, 8, 78));
        datas.push(new PolarData(-1, 12, 8, 82));
        datas.push(new PolarData(-1, 12, 8, 82));
        datas.push(new PolarData(-1, 12, 8.1, 81));
        datas.push(new PolarData(-1, 12, 8.1, 83));
        datas.push(new PolarData(-1, 12, 8.1, 81));
        datas.push(new PolarData(-1, 12, 8.1, 81));
        datas.push(new PolarData(-1, 12, 8.1, 83));
        datas.push(new PolarData(-1, 12, 8.1, 85));
        datas.push(new PolarData(-1, 12, 8.1, 82));
        datas.push(new PolarData(-1, 12, 8.1, 81));
        datas.push(new PolarData(-1, 12, 8.1, 86));
        datas.push(new PolarData(-1, 12, 8.1, 82));
        datas.push(new PolarData(-1, 12, 8.1, 82));
        datas.push(new PolarData(-1, 12, 8, 84));
        datas.push(new PolarData(-1, 12, 8, 83));
        datas.push(new PolarData(-1, 12, 8, 86));
        datas.push(new PolarData(-1, 12, 8, 87));
        datas.push(new PolarData(-1, 12, 8, 87));
        datas.push(new PolarData(-1, 12, 7.9, 86));
        datas.push(new PolarData(-1, 12, 4.3, 19));
        datas.push(new PolarData(-1, 12, 3.9, 25));
        datas.push(new PolarData(-1, 12, 3.7, 34));
        datas.push(new PolarData(-1, 12, 4.5, 56));
        datas.push(new PolarData(-1, 12, 4.5, 57));
        datas.push(new PolarData(-1, 12, 4.6, 59));
        datas.push(new PolarData(-1, 12, 4.7, 62));
        datas.push(new PolarData(-1, 12, 4.9, 59));
        datas.push(new PolarData(-1, 12, 5.1, 57));
        datas.push(new PolarData(-1, 12, 5.2, 61));
        datas.push(new PolarData(-1, 12, 5.3, 59));
        datas.push(new PolarData(-1, 12, 6.2, 63));
        datas.push(new PolarData(-1, 12, 6.9, 62));
        datas.push(new PolarData(-1, 12, 6.9, 63));
        datas.push(new PolarData(-1, 12, 6.9, 66));
        datas.push(new PolarData(-1, 12, 7, 62));
        datas.push(new PolarData(-1, 12, 7, 60));
        datas.push(new PolarData(-1, 12, 7.1, 60));
        datas.push(new PolarData(-1, 12, 7.5, 62));
        datas.push(new PolarData(-1, 12, 7.6, 67));
        datas.push(new PolarData(-1, 12, 8.3, 79));
        datas.push(new PolarData(-1, 12, 8.3, 77));
        datas.push(new PolarData(-1, 12, 8.2, 73));
        datas.push(new PolarData(-1, 12, 8.1, 75));
        datas.push(new PolarData(-1, 12, 8.1, 76));
        datas.push(new PolarData(-1, 12, 8.1, 78));
        datas.push(new PolarData(-1, 12, 8.1, 73));
        datas.push(new PolarData(-1, 12, 8.1, 78));
        datas.push(new PolarData(-1, 12, 8.1, 77));
        datas.push(new PolarData(-1, 12, 8.1, 81));
        datas.push(new PolarData(-1, 12, 8.1, 74));
        datas.push(new PolarData(-1, 12, 8.2, 70));
        datas.push(new PolarData(-1, 12, 8.2, 71));
        datas.push(new PolarData(-1, 12, 8.2, 79));
        datas.push(new PolarData(-1, 12, 8.2, 79));
        datas.push(new PolarData(-1, 12, 8.2, 83));
        datas.push(new PolarData(-1, 12, 8.2, 85));
        datas.push(new PolarData(-1, 12, 8.2, 79));
        datas.push(new PolarData(-1, 12, 8.2, 77));
        datas.push(new PolarData(-1, 12, 8.2, 76));
        datas.push(new PolarData(-1, 12, 8.2, 78));
        datas.push(new PolarData(-1, 12, 8.1, 83));
        datas.push(new PolarData(-1, 12, 8.1, 76));
        datas.push(new PolarData(-1, 12, 8.1, 81));
        datas.push(new PolarData(-1, 12, 8.1, 78));
        datas.push(new PolarData(-1, 12, 8.1, 74));
        datas.push(new PolarData(-1, 12, 8, 81));
        datas.push(new PolarData(-1, 12, 8, 76));
        datas.push(new PolarData(-1, 12, 8, 76));
        datas.push(new PolarData(-1, 12, 7.6, 80));
        datas.push(new PolarData(-1, 12, 7, 45));
        datas.push(new PolarData(-1, 12, 6.8, 25));
        datas.push(new PolarData(-1, 12, 4.9, 80));
        datas.push(new PolarData(-1, 12, 5.7, 68));
        datas.push(new PolarData(-1, 12, 5.7, 70));
        datas.push(new PolarData(-1, 12, 6.2, 70));
        datas.push(new PolarData(-1, 12, 6.6, 61));
        datas.push(new PolarData(-1, 12, 6.8, 63));
        datas.push(new PolarData(-1, 12, 6.9, 66));
        datas.push(new PolarData(-1, 12, 7, 63));
        datas.push(new PolarData(-1, 12, 7.4, 64));
        datas.push(new PolarData(-1, 12, 7.7, 59));
        datas.push(new PolarData(-1, 12, 7.5, 64));
        datas.push(new PolarData(-1, 12, 7.4, 64));
        datas.push(new PolarData(-1, 12, 7.4, 60));
        datas.push(new PolarData(-1, 12, 7.4, 65));
        datas.push(new PolarData(-1, 12, 7.5, 63));
        datas.push(new PolarData(-1, 12, 7.5, 64));
        datas.push(new PolarData(-1, 12, 7.9, 65));
        datas.push(new PolarData(-1, 12, 7.9, 64));
        datas.push(new PolarData(-1, 12, 7.9, 69));
        datas.push(new PolarData(-1, 12, 8, 70));
        datas.push(new PolarData(-1, 12, 7.9, 65));
        datas.push(new PolarData(-1, 12, 8, 81));
        datas.push(new PolarData(-1, 12, 8, 84));
        datas.push(new PolarData(-1, 12, 7.9, 81));
        datas.push(new PolarData(-1, 12, 7.9, 75));
        datas.push(new PolarData(-1, 12, 7.9, 82));
        datas.push(new PolarData(-1, 12, 7.9, 78));
        datas.push(new PolarData(-1, 12, 7.9, 72));
        datas.push(new PolarData(-1, 12, 7.9, 76));
        datas.push(new PolarData(-1, 12, 7.6, 76));
        datas.push(new PolarData(-1, 12, 7.5, 68));
        datas.push(new PolarData(-1, 12, 7.5, 71));
        datas.push(new PolarData(-1, 12, 7.5, 73));
        datas.push(new PolarData(-1, 12, 7.5, 74));
        datas.push(new PolarData(-1, 12, 7.5, 70));
        datas.push(new PolarData(-1, 12, 7.4, 70));
        datas.push(new PolarData(-1, 12, 7.4, 71));
        datas.push(new PolarData(-1, 12, 7.4, 70));
        datas.push(new PolarData(-1, 12, 7.3, 69));
        datas.push(new PolarData(-1, 12, 7.3, 67));
        datas.push(new PolarData(-1, 12, 7.3, 69));
        datas.push(new PolarData(-1, 12, 7.3, 74));
        datas.push(new PolarData(-1, 12, 7.3, 70));
        datas.push(new PolarData(-1, 12, 7.3, 73));
        datas.push(new PolarData(-1, 12, 7.4, 74));
        datas.push(new PolarData(-1, 12, 7.4, 74));
        datas.push(new PolarData(-1, 12, 7.4, 71));
        datas.push(new PolarData(-1, 12, 7.4, 68));
        datas.push(new PolarData(-1, 12, 7.4, 69));
        datas.push(new PolarData(-1, 12, 7.5, 73));
        datas.push(new PolarData(-1, 12, 7.5, 76));
        datas.push(new PolarData(-1, 12, 7.5, 76));
        datas.push(new PolarData(-1, 12, 7.5, 74));
        datas.push(new PolarData(-1, 12, 7.5, 74));
        datas.push(new PolarData(-1, 12, 7.4, 74));
        datas.push(new PolarData(-1, 12, 7.4, 75));
        datas.push(new PolarData(-1, 12, 7.4, 75));
        datas.push(new PolarData(-1, 12, 7.4, 74));
        datas.push(new PolarData(-1, 12, 6.7, 42));
        datas.push(new PolarData(-1, 12, 6.3, 26));
        datas.push(new PolarData(-1, 12, 8.3, 90));
        datas.push(new PolarData(-1, 12, 8.4, 75));
        datas.push(new PolarData(-1, 12, 8.4, 73));
        datas.push(new PolarData(-1, 12, 8.4, 73));
        datas.push(new PolarData(-1, 12, 8.3, 76));
        datas.push(new PolarData(-1, 12, 8.2, 69));
        datas.push(new PolarData(-1, 12, 8, 70));
        datas.push(new PolarData(-1, 12, 7.9, 74));
        datas.push(new PolarData(-1, 12, 8, 71));
        datas.push(new PolarData(-1, 12, 8.4, 83));
        datas.push(new PolarData(-1, 12, 8.3, 81));
        datas.push(new PolarData(-1, 12, 8.6, 84));
        datas.push(new PolarData(-1, 12, 8.6, 88));
        datas.push(new PolarData(-1, 12, 8.6, 86));
        datas.push(new PolarData(-1, 12, 8.6, 90));
        datas.push(new PolarData(-1, 12, 8.5, 94));
        datas.push(new PolarData(-1, 12, 8.5, 95));
        datas.push(new PolarData(-1, 12, 8.5, 92));
        datas.push(new PolarData(-1, 12, 8.4, 86));
        datas.push(new PolarData(-1, 12, 8.3, 78));
        datas.push(new PolarData(-1, 12, 8.2, 73));
        datas.push(new PolarData(-1, 12, 8.2, 63));
        datas.push(new PolarData(-1, 12, 8.2, 64));
        datas.push(new PolarData(-1, 12, 7.8, 77));
        datas.push(new PolarData(-1, 12, 7.8, 75));
        datas.push(new PolarData(-1, 12, 7.8, 67));
        datas.push(new PolarData(-1, 12, 7.8, 67));
        datas.push(new PolarData(-1, 12, 7.8, 75));
        datas.push(new PolarData(-1, 12, 7.8, 61));
        datas.push(new PolarData(-1, 12, 8, 62));
        datas.push(new PolarData(-1, 12, 8, 53));
        datas.push(new PolarData(-1, 12, 7.4, 70));
        datas.push(new PolarData(-1, 12, 7.4, 70));
        datas.push(new PolarData(-1, 12, 7.3, 59));
        datas.push(new PolarData(-1, 12, 7.3, 51));
        datas.push(new PolarData(-1, 12, 7, 53));
        datas.push(new PolarData(-1, 12, 6.9, 61));
        datas.push(new PolarData(-1, 12, 7, 62));
        datas.push(new PolarData(-1, 12, 6.9, 79));
        datas.push(new PolarData(-1, 12, 6.8, 75));
        datas.push(new PolarData(-1, 12, 6.7, 58));
        datas.push(new PolarData(-1, 12, 6.8, 74));
        datas.push(new PolarData(-1, 12, 6.9, 63));
        datas.push(new PolarData(-1, 12, 7.1, 71));
        datas.push(new PolarData(-1, 12, 7.4, 72));
        datas.push(new PolarData(-1, 12, 7.9, 70));
        datas.push(new PolarData(-1, 12, 8.3, 57));
        datas.push(new PolarData(-1, 12, 8.2, 53));
        datas.push(new PolarData(-1, 12, 8.2, 58));
        datas.push(new PolarData(-1, 12, 8.1, 62));
        datas.push(new PolarData(-1, 12, 8.1, 47));
        datas.push(new PolarData(-1, 12, 8.7, 77));
        datas.push(new PolarData(-1, 12, 8.7, 70));
        datas.push(new PolarData(-1, 12, 8.6, 67));
        datas.push(new PolarData(-1, 12, 8.7, 74));
        datas.push(new PolarData(-1, 12, 8.7, 73));
        datas.push(new PolarData(-1, 12, 8.6, 80));
        datas.push(new PolarData(-1, 12, 8.5, 74));
        datas.push(new PolarData(-1, 12, 8.4, 71));
        datas.push(new PolarData(-1, 12, 8.4, 74));
        datas.push(new PolarData(-1, 12, 8.5, 77));
        datas.push(new PolarData(-1, 12, 8.5, 78));
        datas.push(new PolarData(-1, 12, 8.4, 78));
        datas.push(new PolarData(-1, 12, 8.4, 74));
        datas.push(new PolarData(-1, 12, 8.4, 80));
        datas.push(new PolarData(-1, 12, 8.4, 76));
        datas.push(new PolarData(-1, 12, 8.4, 78));
        datas.push(new PolarData(-1, 12, 7.6, 72));
        datas.push(new PolarData(-1, 12, 7.6, 70));
        datas.push(new PolarData(-1, 12, 7.1, 64));
        datas.push(new PolarData(-1, 12, 7.1, 63));
        datas.push(new PolarData(-1, 12, 7.1, 63));
        datas.push(new PolarData(-1, 12, 7.2, 65));
        datas.push(new PolarData(-1, 12, 7.2, 67));
        datas.push(new PolarData(-1, 12, 7.2, 68));
        datas.push(new PolarData(-1, 12, 7.2, 67));
        datas.push(new PolarData(-1, 12, 7.3, 62));
        datas.push(new PolarData(-1, 12, 7.3, 66));
        datas.push(new PolarData(-1, 12, 7.3, 72));
        datas.push(new PolarData(-1, 12, 7.3, 66));
        datas.push(new PolarData(-1, 12, 7.3, 66));
        datas.push(new PolarData(-1, 12, 7.3, 64));
        datas.push(new PolarData(-1, 12, 7.3, 63));
        datas.push(new PolarData(-1, 12, 7.3, 67));
        datas.push(new PolarData(-1, 12, 7.4, 65));
        datas.push(new PolarData(-1, 12, 7.4, 65));
        datas.push(new PolarData(-1, 12, 7.4, 71));
        datas.push(new PolarData(-1, 12, 7.4, 65));
        datas.push(new PolarData(-1, 12, 7.3, 65));
        datas.push(new PolarData(-1, 12, 7.3, 65));
        datas.push(new PolarData(-1, 12, 7.3, 69));
        datas.push(new PolarData(-1, 12, 7.3, 66));
        datas.push(new PolarData(-1, 12, 7.2, 68));
        datas.push(new PolarData(-1, 12, 7.2, 68));
        datas.push(new PolarData(-1, 12, 7.2, 70));
        datas.push(new PolarData(-1, 12, 7.2, 64));
        datas.push(new PolarData(-1, 12, 7.2, 63));
        datas.push(new PolarData(-1, 12, 7.3, 66));
        datas.push(new PolarData(-1, 12, 7.3, 63));
        datas.push(new PolarData(-1, 12, 7.3, 62));
        datas.push(new PolarData(-1, 12, 7.3, 61));
        datas.push(new PolarData(-1, 12, 7.3, 60));
        datas.push(new PolarData(-1, 12, 7.3, 64));
        datas.push(new PolarData(-1, 12, 7.3, 66));
        datas.push(new PolarData(-1, 12, 7.3, 64));
        datas.push(new PolarData(-1, 12, 7.3, 66));
        datas.push(new PolarData(-1, 12, 7.3, 63));
        datas.push(new PolarData(-1, 12, 7.3, 63));
        datas.push(new PolarData(-1, 12, 7.3, 64));
        datas.push(new PolarData(-1, 12, 7.3, 65));
        datas.push(new PolarData(-1, 12, 7.4, 61));
        datas.push(new PolarData(-1, 12, 7.4, 66));
        datas.push(new PolarData(-1, 12, 7.4, 67));
        datas.push(new PolarData(-1, 12, 7.4, 65));
        datas.push(new PolarData(-1, 12, 7.4, 67));
        datas.push(new PolarData(-1, 12, 7.5, 64));
        datas.push(new PolarData(-1, 12, 7.5, 64));
        datas.push(new PolarData(-1, 12, 7.6, 63));
        datas.push(new PolarData(-1, 12, 7.6, 65));
        datas.push(new PolarData(-1, 12, 7.6, 69));
        datas.push(new PolarData(-1, 12, 7.6, 66));
        datas.push(new PolarData(-1, 12, 7.6, 68));
        datas.push(new PolarData(-1, 12, 7.7, 65));
        datas.push(new PolarData(-1, 12, 7.7, 65));
        datas.push(new PolarData(-1, 12, 7.7, 67));
        datas.push(new PolarData(-1, 12, 7.7, 68));
        datas.push(new PolarData(-1, 12, 7.7, 69));
        datas.push(new PolarData(-1, 12, 7.7, 69));
        datas.push(new PolarData(-1, 12, 7.7, 72));
        datas.push(new PolarData(-1, 12, 7.7, 69));
        datas.push(new PolarData(-1, 12, 7.7, 69));
        datas.push(new PolarData(-1, 12, 7.7, 67));
        datas.push(new PolarData(-1, 12, 7.8, 68));
        datas.push(new PolarData(-1, 12, 7.8, 68));
        datas.push(new PolarData(-1, 12, 7.8, 74));
        datas.push(new PolarData(-1, 12, 7.8, 69));
        datas.push(new PolarData(-1, 12, 7.9, 73));
        datas.push(new PolarData(-1, 12, 7.9, 71));
        datas.push(new PolarData(-1, 12, 7.9, 70));
        datas.push(new PolarData(-1, 12, 7.9, 70));
        datas.push(new PolarData(-1, 12, 7.9, 71));
        datas.push(new PolarData(-1, 12, 7.9, 72));
        datas.push(new PolarData(-1, 12, 8, 73));
        datas.push(new PolarData(-1, 12, 8.1, 71));
        datas.push(new PolarData(-1, 12, 8, 72));
        datas.push(new PolarData(-1, 12, 7.9, 71));
        datas.push(new PolarData(-1, 12, 8.1, 75));
        datas.push(new PolarData(-1, 12, 8.1, 74));
        datas.push(new PolarData(-1, 12, 8.2, 72));
        datas.push(new PolarData(-1, 12, 8.2, 75));
        datas.push(new PolarData(-1, 12, 8.1, 72));
        datas.push(new PolarData(-1, 12, 8.1, 75));
        datas.push(new PolarData(-1, 12, 8.1, 76));
        datas.push(new PolarData(-1, 12, 8.1, 78));
        datas.push(new PolarData(-1, 12, 8.1, 76));
        datas.push(new PolarData(-1, 12, 8.1, 75));
        datas.push(new PolarData(-1, 12, 8.1, 75));
        datas.push(new PolarData(-1, 12, 8.1, 77));
        datas.push(new PolarData(-1, 12, 8.1, 82));
        datas.push(new PolarData(-1, 12, 8.1, 78));
        datas.push(new PolarData(-1, 12, 8, 80));
        datas.push(new PolarData(-1, 12, 8, 80));
        datas.push(new PolarData(-1, 12, 8, 82));
        datas.push(new PolarData(-1, 12, 8, 81));
        datas.push(new PolarData(-1, 12, 7.9, 78));
        datas.push(new PolarData(-1, 12, 7.8, 74));
        datas.push(new PolarData(-1, 12, 7.8, 73));
        datas.push(new PolarData(-1, 12, 7.8, 73));
        datas.push(new PolarData(-1, 12, 7.9, 76));
        datas.push(new PolarData(-1, 12, 7.9, 79));
        datas.push(new PolarData(-1, 12, 7.8, 73));
        datas.push(new PolarData(-1, 12, 7.8, 74));
        datas.push(new PolarData(-1, 12, 7.8, 81));
        datas.push(new PolarData(-1, 12, 7.9, 80));
        datas.push(new PolarData(-1, 12, 7.9, 76));
        datas.push(new PolarData(-1, 12, 7.9, 77));
        datas.push(new PolarData(-1, 12, 8, 77));
        datas.push(new PolarData(-1, 12, 8, 78));
        datas.push(new PolarData(-1, 12, 7.9, 74));
        datas.push(new PolarData(-1, 12, 8, 74));
        datas.push(new PolarData(-1, 12, 8, 75));
        datas.push(new PolarData(-1, 12, 8.1, 78));
        datas.push(new PolarData(-1, 12, 8.1, 79));
        datas.push(new PolarData(-1, 12, 8.2, 79));
        datas.push(new PolarData(-1, 12, 8.2, 81));
        datas.push(new PolarData(-1, 12, 8.2, 75));
        datas.push(new PolarData(-1, 12, 8.2, 80));
        datas.push(new PolarData(-1, 12, 8.2, 79));
        datas.push(new PolarData(-1, 12, 8.2, 76));
        datas.push(new PolarData(-1, 12, 8.1, 78));
        datas.push(new PolarData(-1, 12, 8.1, 80));
        datas.push(new PolarData(-1, 12, 8.2, 79));
        datas.push(new PolarData(-1, 12, 8.2, 73));
        datas.push(new PolarData(-1, 12, 8.2, 68));
        datas.push(new PolarData(-1, 12, 8.2, 70));
        datas.push(new PolarData(-1, 12, 8.1, 74));
        datas.push(new PolarData(-1, 12, 8.1, 73));
        datas.push(new PolarData(-1, 12, 8.1, 73));
        datas.push(new PolarData(-1, 12, 8.1, 73));
        datas.push(new PolarData(-1, 12, 7.9, 69));
        datas.push(new PolarData(-1, 12, 7.9, 73));
        datas.push(new PolarData(-1, 12, 7.9, 67));
        datas.push(new PolarData(-1, 12, 7.9, 68));
        datas.push(new PolarData(-1, 12, 7.9, 65));
        datas.push(new PolarData(-1, 12, 7.8, 61));
        datas.push(new PolarData(-1, 12, 7.9, 64));
        datas.push(new PolarData(-1, 12, 8, 65));
        datas.push(new PolarData(-1, 12, 8.1, 69));
        datas.push(new PolarData(-1, 12, 8.1, 65));
        datas.push(new PolarData(-1, 12, 8.1, 71));
        datas.push(new PolarData(-1, 12, 8.1, 70));
        datas.push(new PolarData(-1, 12, 8.1, 67));
        datas.push(new PolarData(-1, 12, 8.1, 62));
        datas.push(new PolarData(-1, 12, 8.1, 72));
        datas.push(new PolarData(-1, 12, 8.1, 78));
        datas.push(new PolarData(-1, 12, 8, 69));
        datas.push(new PolarData(-1, 12, 8, 75));
        datas.push(new PolarData(-1, 12, 8, 72));
        datas.push(new PolarData(-1, 12, 8, 66));
        datas.push(new PolarData(-1, 12, 8, 62));
        datas.push(new PolarData(-1, 12, 7.9, 69));
        datas.push(new PolarData(-1, 12, 7.9, 62));
        datas.push(new PolarData(-1, 12, 8, 68));
        datas.push(new PolarData(-1, 12, 8.2, 68));
        datas.push(new PolarData(-1, 12, 8.1, 74));
        datas.push(new PolarData(-1, 12, 8.1, 75));
        datas.push(new PolarData(-1, 12, 8.1, 77));
        datas.push(new PolarData(-1, 12, 8.1, 71));
        datas.push(new PolarData(-1, 12, 8, 73));
        datas.push(new PolarData(-1, 12, 8, 77));
        datas.push(new PolarData(-1, 12, 8, 72));
        datas.push(new PolarData(-1, 12, 8, 70));
        datas.push(new PolarData(-1, 12, 7.9, 69));
        datas.push(new PolarData(-1, 12, 7.9, 70));
        datas.push(new PolarData(-1, 12, 7.9, 73));
        datas.push(new PolarData(-1, 12, 8, 68));
        datas.push(new PolarData(-1, 12, 8, 76));
        datas.push(new PolarData(-1, 12, 8, 76));
        datas.push(new PolarData(-1, 12, 8, 74));
        datas.push(new PolarData(-1, 12, 7.9, 74));
        datas.push(new PolarData(-1, 12, 7.9, 74));
        datas.push(new PolarData(-1, 12, 7.8, 77));
        datas.push(new PolarData(-1, 12, 7.8, 74));
        datas.push(new PolarData(-1, 12, 7.8, 74));
        datas.push(new PolarData(-1, 12, 7.8, 68));
        datas.push(new PolarData(-1, 12, 7.8, 72));
        datas.push(new PolarData(-1, 12, 7.8, 73));
        datas.push(new PolarData(-1, 12, 7.8, 77));
        datas.push(new PolarData(-1, 12, 7.7, 73));
        datas.push(new PolarData(-1, 12, 7.7, 72));
        datas.push(new PolarData(-1, 12, 7.7, 73));
        datas.push(new PolarData(-1, 12, 7.7, 73));
        datas.push(new PolarData(-1, 12, 7.6, 74));
        datas.push(new PolarData(-1, 12, 7.6, 71));
        datas.push(new PolarData(-1, 12, 7.6, 74));
        datas.push(new PolarData(-1, 12, 7.6, 79));
        datas.push(new PolarData(-1, 12, 7.6, 69));
        datas.push(new PolarData(-1, 12, 7.6, 72));
        datas.push(new PolarData(-1, 12, 7.6, 76));
        datas.push(new PolarData(-1, 12, 8, 73));
        datas.push(new PolarData(-1, 12, 8, 78));
        datas.push(new PolarData(-1, 12, 8, 81));
        datas.push(new PolarData(-1, 12, 8, 79));
        datas.push(new PolarData(-1, 12, 8, 73));
        datas.push(new PolarData(-1, 12, 7.9, 77));
        datas.push(new PolarData(-1, 12, 7.9, 71));
        datas.push(new PolarData(-1, 12, 7.9, 78));
        datas.push(new PolarData(-1, 12, 7.9, 79));
        datas.push(new PolarData(-1, 12, 8, 77));
        datas.push(new PolarData(-1, 12, 7.9, 78));
        datas.push(new PolarData(-1, 12, 7.9, 77));
        datas.push(new PolarData(-1, 12, 7.9, 76));
        datas.push(new PolarData(-1, 12, 7.9, 72));
        datas.push(new PolarData(-1, 12, 7.9, 74));
        datas.push(new PolarData(-1, 12, 7.9, 78));
        datas.push(new PolarData(-1, 12, 7.9, 78));
        datas.push(new PolarData(-1, 12, 8, 75));
        datas.push(new PolarData(-1, 12, 8, 62));
        datas.push(new PolarData(-1, 12, 7.9, 73));
        datas.push(new PolarData(-1, 12, 7.9, 88));
        datas.push(new PolarData(-1, 12, 8, 78));
        datas.push(new PolarData(-1, 12, 7.9, 83));
        datas.push(new PolarData(-1, 12, 7.9, 74));
        datas.push(new PolarData(-1, 12, 8, 68));
        datas.push(new PolarData(-1, 12, 8, 81));
        datas.push(new PolarData(-1, 12, 7.7, 80));
        datas.push(new PolarData(-1, 12, 7.6, 74));
        datas.push(new PolarData(-1, 12, 7.7, 78));
        datas.push(new PolarData(-1, 12, 7.8, 76));
        datas.push(new PolarData(-1, 12, 7.9, 79));
        datas.push(new PolarData(-1, 12, 7.9, 79));
        datas.push(new PolarData(-1, 12, 7.9, 80));
        datas.push(new PolarData(-1, 12, 7.9, 77));
        datas.push(new PolarData(-1, 12, 7.8, 78));
        datas.push(new PolarData(-1, 12, 7.8, 80));
        datas.push(new PolarData(-1, 12, 7.8, 76));
        datas.push(new PolarData(-1, 12, 7.9, 78));
        datas.push(new PolarData(-1, 12, 7.9, 79));
        datas.push(new PolarData(-1, 12, 7.9, 80));
        datas.push(new PolarData(-1, 12, 8, 80));
        datas.push(new PolarData(-1, 12, 7.9, 86));
        datas.push(new PolarData(-1, 12, 7.9, 79));
        datas.push(new PolarData(-1, 12, 7.9, 77));
        datas.push(new PolarData(-1, 12, 7.8, 86));
        datas.push(new PolarData(-1, 12, 7.8, 80));
        datas.push(new PolarData(-1, 12, 7.8, 83));
        datas.push(new PolarData(-1, 12, 7.8, 77));
        datas.push(new PolarData(-1, 12, 7.8, 81));
        datas.push(new PolarData(-1, 12, 7.8, 78));
        datas.push(new PolarData(-1, 12, 7.7, 79));
        datas.push(new PolarData(-1, 12, 7.7, 77));
        datas.push(new PolarData(-1, 12, 7.7, 79));
        datas.push(new PolarData(-1, 12, 7.7, 81));
        datas.push(new PolarData(-1, 12, 7.7, 77));
        datas.push(new PolarData(-1, 12, 7.7, 82));
        datas.push(new PolarData(-1, 12, 7.7, 79));
        datas.push(new PolarData(-1, 12, 7.7, 75));
        datas.push(new PolarData(-1, 12, 7.6, 78));
        datas.push(new PolarData(-1, 12, 7.6, 75));
        datas.push(new PolarData(-1, 12, 7.5, 84));
        datas.push(new PolarData(-1, 12, 7.5, 78));
        datas.push(new PolarData(-1, 12, 7.4, 73));
        datas.push(new PolarData(-1, 12, 7.1, 49));
        datas.push(new PolarData(-1, 12, 5.5, 2));
        datas.push(new PolarData(-1, 12, 5.5, 31));
        datas.push(new PolarData(-1, 12, 3.9, 42));
        datas.push(new PolarData(-1, 12, 4.1, 43));
        datas.push(new PolarData(-1, 12, 4.1, 43));
        datas.push(new PolarData(-1, 12, 4.2, 43));
        datas.push(new PolarData(-1, 12, 4.2, 41));
        datas.push(new PolarData(-1, 12, 4.2, 47));
        datas.push(new PolarData(-1, 12, 4.2, 42));
        datas.push(new PolarData(-1, 12, 4.2, 44));
        datas.push(new PolarData(-1, 12, 4.5, 47));
        datas.push(new PolarData(-1, 12, 4.7, 55));
        datas.push(new PolarData(-1, 12, 4.8, 55));
        datas.push(new PolarData(-1, 12, 5.1, 53));
        datas.push(new PolarData(-1, 12, 5.2, 51));
        datas.push(new PolarData(-1, 12, 5.6, 52));
        datas.push(new PolarData(-1, 12, 6.6, 53));
        datas.push(new PolarData(-1, 12, 4.6, 35));
        datas.push(new PolarData(-1, 12, 4, 36));
        datas.push(new PolarData(-1, 12, 3.9, 37));
        datas.push(new PolarData(-1, 12, 3.9, 32));
        datas.push(new PolarData(-1, 12, 3.9, 33));
        datas.push(new PolarData(-1, 12, 3.8, 37));
        datas.push(new PolarData(-1, 12, 3.8, 35));
        datas.push(new PolarData(-1, 12, 3.8, 38));
        datas.push(new PolarData(-1, 12, 3.7, 40));
        datas.push(new PolarData(-1, 12, 3.7, 38));
        datas.push(new PolarData(-1, 12, 3.7, 40));
        datas.push(new PolarData(-1, 12, 3.7, 36));
        datas.push(new PolarData(-1, 12, 3.7, 41));
        datas.push(new PolarData(-1, 12, 3.9, 41));
        datas.push(new PolarData(-1, 12, 4, 42));
        datas.push(new PolarData(-1, 12, 4.4, 44));
        datas.push(new PolarData(-1, 12, 4.4, 47));
        datas.push(new PolarData(-1, 12, 4.4, 38));
        datas.push(new PolarData(-1, 12, 4.6, 41));
        datas.push(new PolarData(-1, 12, 4.8, 46));
        datas.push(new PolarData(-1, 12, 4.9, 40));
        datas.push(new PolarData(-1, 12, 4.9, 41));
        datas.push(new PolarData(-1, 12, 5, 40));
        datas.push(new PolarData(-1, 12, 5, 40));
        datas.push(new PolarData(-1, 12, 5, 44));
        datas.push(new PolarData(-1, 12, 5, 38));
        datas.push(new PolarData(-1, 12, 5, 40));
        datas.push(new PolarData(-1, 12, 5.1, 42));
        datas.push(new PolarData(-1, 12, 5.1, 40));
        datas.push(new PolarData(-1, 12, 5.1, 41));
        datas.push(new PolarData(-1, 12, 5.1, 39));
        datas.push(new PolarData(-1, 12, 5.1, 40));
        datas.push(new PolarData(-1, 12, 5.1, 43));
        datas.push(new PolarData(-1, 12, 5.2, 44));
        datas.push(new PolarData(-1, 12, 5.2, 40));
        datas.push(new PolarData(-1, 12, 5.2, 43));
        datas.push(new PolarData(-1, 12, 5.2, 44));
        datas.push(new PolarData(-1, 12, 5.3, 42));
        datas.push(new PolarData(-1, 12, 5.4, 45));
        datas.push(new PolarData(-1, 12, 5.5, 41));
        datas.push(new PolarData(-1, 12, 5.5, 43));
        datas.push(new PolarData(-1, 12, 5.5, 43));
        datas.push(new PolarData(-1, 12, 5.5, 47));
        datas.push(new PolarData(-1, 12, 5.5, 44));
        datas.push(new PolarData(-1, 12, 5.5, 44));
        datas.push(new PolarData(-1, 12, 5.5, 46));
        datas.push(new PolarData(-1, 12, 5.5, 44));
        datas.push(new PolarData(-1, 12, 5.6, 45));
        datas.push(new PolarData(-1, 12, 5.6, 44));
        datas.push(new PolarData(-1, 12, 5.6, 45));
        datas.push(new PolarData(-1, 12, 5.6, 46));
        datas.push(new PolarData(-1, 12, 5.6, 41));
        datas.push(new PolarData(-1, 12, 5.3, 40));
        datas.push(new PolarData(-1, 12, 5.5, 41));
        datas.push(new PolarData(-1, 12, 5.4, 42));
        datas.push(new PolarData(-1, 12, 5.4, 44));
        datas.push(new PolarData(-1, 12, 5.4, 48));
        datas.push(new PolarData(-1, 12, 5.4, 44));
        datas.push(new PolarData(-1, 12, 5.4, 43));
        datas.push(new PolarData(-1, 12, 5.4, 43));
        datas.push(new PolarData(-1, 12, 5.4, 45));
        datas.push(new PolarData(-1, 12, 5.5, 45));
        datas.push(new PolarData(-1, 12, 5.5, 42));
        datas.push(new PolarData(-1, 12, 5.5, 43));
        datas.push(new PolarData(-1, 12, 5.5, 2));
        datas.push(new PolarData(-1, 12, 5.3, 20));
        datas.push(new PolarData(-1, 12, 4.4, 39));
        datas.push(new PolarData(-1, 12, 4.5, 38));
        datas.push(new PolarData(-1, 12, 4.5, 38));
        datas.push(new PolarData(-1, 12, 4.6, 37));
        datas.push(new PolarData(-1, 12, 4.9, 44));
        datas.push(new PolarData(-1, 12, 5, 45));
        datas.push(new PolarData(-1, 12, 5.1, 43));
        datas.push(new PolarData(-1, 12, 5.1, 45));
        datas.push(new PolarData(-1, 12, 5.2, 43));
        datas.push(new PolarData(-1, 12, 5.4, 45));
        datas.push(new PolarData(-1, 12, 5.4, 45));
        datas.push(new PolarData(-1, 12, 5.4, 45));
        datas.push(new PolarData(-1, 12, 5.5, 45));
        datas.push(new PolarData(-1, 12, 5.6, 43));
        datas.push(new PolarData(-1, 12, 5.7, 47));
        datas.push(new PolarData(-1, 12, 5.7, 42));
        datas.push(new PolarData(-1, 12, 5.8, 44));
        datas.push(new PolarData(-1, 12, 5.8, 44));
        datas.push(new PolarData(-1, 12, 5.9, 47));
        datas.push(new PolarData(-1, 12, 5.9, 43));
        datas.push(new PolarData(-1, 12, 5.9, 45));
        datas.push(new PolarData(-1, 12, 5.9, 44));
        datas.push(new PolarData(-1, 12, 6, 47));
        datas.push(new PolarData(-1, 12, 6, 44));
        datas.push(new PolarData(-1, 12, 6.1, 45));
        datas.push(new PolarData(-1, 12, 6.1, 44));
        datas.push(new PolarData(-1, 12, 6.1, 45));
        datas.push(new PolarData(-1, 12, 6.1, 43));
        datas.push(new PolarData(-1, 12, 6.1, 45));
        datas.push(new PolarData(-1, 12, 6.1, 44));
        datas.push(new PolarData(-1, 12, 6.1, 45));
        datas.push(new PolarData(-1, 12, 6.1, 48));
        datas.push(new PolarData(-1, 12, 6.1, 50));
        datas.push(new PolarData(-1, 12, 6.1, 49));
        datas.push(new PolarData(-1, 12, 6, 45));
        datas.push(new PolarData(-1, 12, 6, 47));
        datas.push(new PolarData(-1, 12, 6, 49));
        datas.push(new PolarData(-1, 12, 6, 46));
        datas.push(new PolarData(-1, 12, 6, 47));
        datas.push(new PolarData(-1, 12, 6, 45));
        datas.push(new PolarData(-1, 12, 6, 47));
        datas.push(new PolarData(-1, 12, 6, 50));
        datas.push(new PolarData(-1, 12, 6, 45));
        datas.push(new PolarData(-1, 12, 5.9, 45));
        datas.push(new PolarData(-1, 12, 5.9, 48));
        datas.push(new PolarData(-1, 12, 5.9, 44));
        datas.push(new PolarData(-1, 12, 5.9, 48));
        datas.push(new PolarData(-1, 12, 5.9, 46));
        datas.push(new PolarData(-1, 12, 5.8, 48));
        datas.push(new PolarData(-1, 12, 5.8, 50));
        datas.push(new PolarData(-1, 12, 5.8, 49));
        datas.push(new PolarData(-1, 12, 5.8, 48));
        datas.push(new PolarData(-1, 12, 5.9, 49));
        datas.push(new PolarData(-1, 12, 5.9, 53));
        datas.push(new PolarData(-1, 12, 5.9, 49));
        datas.push(new PolarData(-1, 12, 5.9, 49));
        datas.push(new PolarData(-1, 12, 5.9, 51));
        datas.push(new PolarData(-1, 12, 5.9, 47));
        datas.push(new PolarData(-1, 12, 5.9, 49));
        datas.push(new PolarData(-1, 12, 5.9, 54));
        datas.push(new PolarData(-1, 12, 5.9, 57));
        datas.push(new PolarData(-1, 12, 5.9, 55));
        datas.push(new PolarData(-1, 12, 6, 60));
        datas.push(new PolarData(-1, 12, 6, 60));
        datas.push(new PolarData(-1, 12, 6, 59));
        datas.push(new PolarData(-1, 12, 6.1, 57));
        datas.push(new PolarData(-1, 12, 6.1, 60));
        datas.push(new PolarData(-1, 12, 6.2, 60));
        datas.push(new PolarData(-1, 12, 6.2, 62));
        datas.push(new PolarData(-1, 12, 6.3, 63));
        datas.push(new PolarData(-1, 12, 6.3, 59));
        datas.push(new PolarData(-1, 12, 6.4, 58));
        datas.push(new PolarData(-1, 12, 6.4, 62));
        datas.push(new PolarData(-1, 12, 6.4, 62));
        datas.push(new PolarData(-1, 12, 6.5, 60));
        datas.push(new PolarData(-1, 12, 6.5, 61));
        datas.push(new PolarData(-1, 12, 6.5, 63));
        datas.push(new PolarData(-1, 12, 6.6, 64));
        datas.push(new PolarData(-1, 12, 6.6, 66));
        datas.push(new PolarData(-1, 12, 6.6, 67));
        datas.push(new PolarData(-1, 12, 6.7, 65));
        datas.push(new PolarData(-1, 12, 6.7, 64));
        datas.push(new PolarData(-1, 12, 6.8, 65));
        datas.push(new PolarData(-1, 12, 6.8, 68));
        datas.push(new PolarData(-1, 12, 6.8, 69));
        datas.push(new PolarData(-1, 12, 6.8, 70));
        datas.push(new PolarData(-1, 12, 6.9, 71));
        datas.push(new PolarData(-1, 12, 7, 75));
        datas.push(new PolarData(-1, 12, 7, 75));
        datas.push(new PolarData(-1, 12, 7, 76));
        datas.push(new PolarData(-1, 12, 7, 79));
        datas.push(new PolarData(-1, 12, 7, 79));
        datas.push(new PolarData(-1, 12, 7.1, 84));
        datas.push(new PolarData(-1, 12, 7.1, 85));
        datas.push(new PolarData(-1, 12, 5.4, 60));
        datas.push(new PolarData(-1, 12, 5.6, 55));
        datas.push(new PolarData(-1, 12, 5.5, 55));
        datas.push(new PolarData(-1, 12, 5.5, 53));
        datas.push(new PolarData(-1, 12, 5.5, 52));
        datas.push(new PolarData(-1, 12, 5.5, 52));
        datas.push(new PolarData(-1, 12, 5.5, 52));
        datas.push(new PolarData(-1, 12, 5, 44));
        datas.push(new PolarData(-1, 12, 5, 49));
        datas.push(new PolarData(-1, 12, 5.1, 48));
        datas.push(new PolarData(-1, 12, 5.2, 47));
        datas.push(new PolarData(-1, 12, 5.2, 47));
        datas.push(new PolarData(-1, 12, 5.2, 45));
        datas.push(new PolarData(-1, 12, 5.2, 48));
        datas.push(new PolarData(-1, 12, 5.2, 47));
        datas.push(new PolarData(-1, 12, 5.7, 61));
        datas.push(new PolarData(-1, 12, 6.2, 62));
        datas.push(new PolarData(-1, 12, 6.3, 60));
        datas.push(new PolarData(-1, 12, 6.4, 60));
        datas.push(new PolarData(-1, 12, 6.4, 60));
        datas.push(new PolarData(-1, 12, 6.4, 60));
        datas.push(new PolarData(-1, 12, 6.4, 60));
        datas.push(new PolarData(-1, 12, 6.5, 61));
        datas.push(new PolarData(-1, 12, 6.5, 60));
        datas.push(new PolarData(-1, 12, 6.6, 60));
        datas.push(new PolarData(-1, 12, 6.6, 60));
        datas.push(new PolarData(-1, 12, 6.7, 59));
        datas.push(new PolarData(-1, 12, 6.7, 59));
        datas.push(new PolarData(-1, 12, 6.8, 62));
        datas.push(new PolarData(-1, 12, 6.8, 62));
        datas.push(new PolarData(-1, 12, 4, 38));
        datas.push(new PolarData(-1, 12, 4.1, 39));
        datas.push(new PolarData(-1, 12, 4.2, 41));
        datas.push(new PolarData(-1, 12, 4.2, 42));
        datas.push(new PolarData(-1, 12, 4.3, 39));
        datas.push(new PolarData(-1, 12, 4.4, 39));
        datas.push(new PolarData(-1, 12, 4.5, 41));
        datas.push(new PolarData(-1, 12, 4.6, 38));
        datas.push(new PolarData(-1, 12, 4.6, 37));
        datas.push(new PolarData(-1, 12, 4.7, 40));
        datas.push(new PolarData(-1, 12, 4.7, 41));
        datas.push(new PolarData(-1, 12, 4.8, 45));
        datas.push(new PolarData(-1, 12, 4.8, 48));
        datas.push(new PolarData(-1, 12, 4.9, 47));
        datas.push(new PolarData(-1, 12, 4.9, 48));
        datas.push(new PolarData(-1, 12, 5, 43));
        datas.push(new PolarData(-1, 12, 5.1, 45));
        datas.push(new PolarData(-1, 12, 5.2, 48));
        datas.push(new PolarData(-1, 12, 5.2, 47));
        datas.push(new PolarData(-1, 12, 5.3, 46));
        datas.push(new PolarData(-1, 12, 5.3, 47));
        datas.push(new PolarData(-1, 12, 5.4, 46));
        datas.push(new PolarData(-1, 12, 5.4, 48));
        datas.push(new PolarData(-1, 12, 5.5, 46));
        datas.push(new PolarData(-1, 12, 5.5, 43));
        datas.push(new PolarData(-1, 12, 5.5, 48));
        datas.push(new PolarData(-1, 12, 5.5, 50));
        datas.push(new PolarData(-1, 12, 5.6, 49));
        datas.push(new PolarData(-1, 12, 5.6, 50));
        datas.push(new PolarData(-1, 12, 5.7, 51));
        datas.push(new PolarData(-1, 12, 5.7, 50));
        datas.push(new PolarData(-1, 12, 5.7, 49));
        datas.push(new PolarData(-1, 12, 5.7, 52));
        datas.push(new PolarData(-1, 12, 5.7, 48));
        datas.push(new PolarData(-1, 12, 5.7, 51));
        datas.push(new PolarData(-1, 12, 5.8, 49));
        datas.push(new PolarData(-1, 12, 5.8, 49));
        datas.push(new PolarData(-1, 12, 5.8, 49));
        datas.push(new PolarData(-1, 12, 5.8, 49));
        datas.push(new PolarData(-1, 12, 5.8, 47));
        datas.push(new PolarData(-1, 12, 5.9, 47));
        datas.push(new PolarData(-1, 12, 5.9, 48));
        datas.push(new PolarData(-1, 12, 5.9, 47));
        datas.push(new PolarData(-1, 12, 5.9, 47));
        datas.push(new PolarData(-1, 12, 6, 48));
        datas.push(new PolarData(-1, 12, 6, 48));
        datas.push(new PolarData(-1, 12, 6, 48));
        datas.push(new PolarData(-1, 12, 6, 48));
        datas.push(new PolarData(-1, 12, 6.1, 46));
        datas.push(new PolarData(-1, 12, 6.1, 49));
        datas.push(new PolarData(-1, 12, 6.1, 45));
        datas.push(new PolarData(-1, 12, 6.2, 46));
        datas.push(new PolarData(-1, 12, 6.2, 48));
        datas.push(new PolarData(-1, 12, 6.2, 47));
        datas.push(new PolarData(-1, 12, 6.1, 46));
        datas.push(new PolarData(-1, 12, 6.1, 46));
        datas.push(new PolarData(-1, 12, 6.1, 44));
        datas.push(new PolarData(-1, 12, 6.1, 45));
        datas.push(new PolarData(-1, 12, 6.1, 45));
        datas.push(new PolarData(-1, 12, 6, 45));
        datas.push(new PolarData(-1, 12, 6, 45));
        datas.push(new PolarData(-1, 12, 6, 44));
        datas.push(new PolarData(-1, 12, 6, 44));
        datas.push(new PolarData(-1, 12, 6, 44));
        datas.push(new PolarData(-1, 12, 5.9, 45));
        datas.push(new PolarData(-1, 12, 5.9, 47));
        datas.push(new PolarData(-1, 12, 5.9, 44));
        datas.push(new PolarData(-1, 12, 5.9, 44));
        datas.push(new PolarData(-1, 12, 5.9, 43));
        datas.push(new PolarData(-1, 12, 5.9, 43));
        datas.push(new PolarData(-1, 12, 5.9, 45));
        datas.push(new PolarData(-1, 12, 5.9, 44));
        datas.push(new PolarData(-1, 12, 5.9, 44));
        datas.push(new PolarData(-1, 12, 5.8, 46));
        datas.push(new PolarData(-1, 12, 5.8, 45));
        datas.push(new PolarData(-1, 12, 5.8, 46));
        datas.push(new PolarData(-1, 12, 5.8, 44));
        datas.push(new PolarData(-1, 12, 5.8, 45));
        datas.push(new PolarData(-1, 12, 5.8, 46));
        datas.push(new PolarData(-1, 12, 5.8, 44));
        datas.push(new PolarData(-1, 12, 5.9, 46));
        datas.push(new PolarData(-1, 12, 5.9, 43));
        datas.push(new PolarData(-1, 12, 5.9, 46));
        datas.push(new PolarData(-1, 12, 5.9, 46));
        datas.push(new PolarData(-1, 12, 5.9, 49));
        datas.push(new PolarData(-1, 12, 6, 50));
        datas.push(new PolarData(-1, 12, 6, 47));
        datas.push(new PolarData(-1, 12, 6, 46));
        datas.push(new PolarData(-1, 12, 6.1, 48));
        datas.push(new PolarData(-1, 12, 6.1, 47));
        datas.push(new PolarData(-1, 12, 6.1, 45));
        datas.push(new PolarData(-1, 12, 6.2, 48));
        datas.push(new PolarData(-1, 12, 6.2, 46));
        datas.push(new PolarData(-1, 12, 6.2, 43));
        datas.push(new PolarData(-1, 12, 6.3, 45));
        datas.push(new PolarData(-1, 12, 6.3, 47));
        datas.push(new PolarData(-1, 12, 6.3, 45));
        datas.push(new PolarData(-1, 12, 6.3, 47));
        datas.push(new PolarData(-1, 12, 6.3, 49));
        datas.push(new PolarData(-1, 12, 6.2, 34));
        datas.push(new PolarData(-1, 12, 6, 22));
        datas.push(new PolarData(-1, 12, 5.8, 32));
        datas.push(new PolarData(-1, 12, 5.3, 41));
        datas.push(new PolarData(-1, 12, 3, 49));
        datas.push(new PolarData(-1, 12, 3.6, 51));
        datas.push(new PolarData(-1, 12, 3.9, 49));
        datas.push(new PolarData(-1, 12, 3.9, 52));
        datas.push(new PolarData(-1, 12, 5.2, 48));
        datas.push(new PolarData(-1, 12, 5.2, 53));
        datas.push(new PolarData(-1, 12, 5.3, 55));
        datas.push(new PolarData(-1, 12, 5.7, 52));
        datas.push(new PolarData(-1, 12, 6.6, 52));
        datas.push(new PolarData(-1, 12, 6.6, 57));
        datas.push(new PolarData(-1, 12, 6.7, 57));
        datas.push(new PolarData(-1, 12, 6.7, 51));
        datas.push(new PolarData(-1, 12, 6.6, 55));
        datas.push(new PolarData(-1, 12, 6.6, 56));
        datas.push(new PolarData(-1, 12, 6.6, 57));
        datas.push(new PolarData(-1, 12, 6.6, 57));
        datas.push(new PolarData(-1, 12, 6.6, 62));
        datas.push(new PolarData(-1, 12, 6.6, 57));
        datas.push(new PolarData(-1, 12, 6.6, 57));
        datas.push(new PolarData(-1, 12, 6.6, 56));
        datas.push(new PolarData(-1, 12, 6.6, 56));
        datas.push(new PolarData(-1, 12, 6.6, 62));
        datas.push(new PolarData(-1, 12, 6.6, 56));
        datas.push(new PolarData(-1, 12, 6.7, 55));
        datas.push(new PolarData(-1, 12, 6.7, 56));
        datas.push(new PolarData(-1, 12, 6.6, 61));
        datas.push(new PolarData(-1, 12, 6.7, 43));
        datas.push(new PolarData(-1, 12, 6.7, 53));
        datas.push(new PolarData(-1, 12, 6.7, 41));
        datas.push(new PolarData(-1, 12, 6.6, 40));
        datas.push(new PolarData(-1, 12, 6.6, 39));
        datas.push(new PolarData(-1, 12, 6.4, 42));
        datas.push(new PolarData(-1, 12, 6.4, 40));
        datas.push(new PolarData(-1, 12, 6.3, 38));
        datas.push(new PolarData(-1, 12, 6.3, 39));
        datas.push(new PolarData(-1, 12, 6, 35));
        datas.push(new PolarData(-1, 12, 5.9, 39));
        datas.push(new PolarData(-1, 12, 5.8, 42));
        datas.push(new PolarData(-1, 12, 5.7, 42));
        datas.push(new PolarData(-1, 12, 5.5, 45));
        datas.push(new PolarData(-1, 12, 5.5, 44));
        datas.push(new PolarData(-1, 12, 5.5, 46));
        datas.push(new PolarData(-1, 12, 5.5, 48));
        datas.push(new PolarData(-1, 12, 5.7, 53));
        datas.push(new PolarData(-1, 12, 5.7, 49));
        datas.push(new PolarData(-1, 12, 5.8, 50));
        datas.push(new PolarData(-1, 12, 5.9, 55));
        datas.push(new PolarData(-1, 12, 6, 57));
        datas.push(new PolarData(-1, 12, 6.2, 48));
        datas.push(new PolarData(-1, 12, 6.5, 52));
        datas.push(new PolarData(-1, 12, 6.6, 61));
        datas.push(new PolarData(-1, 12, 6.7, 62));
        datas.push(new PolarData(-1, 12, 6.7, 56));
        datas.push(new PolarData(-1, 12, 6.7, 58));
        datas.push(new PolarData(-1, 12, 6.7, 55));
        datas.push(new PolarData(-1, 12, 6.7, 53));
        datas.push(new PolarData(-1, 12, 6.7, 53));
        datas.push(new PolarData(-1, 12, 6.7, 55));
        datas.push(new PolarData(-1, 12, 6.7, 58));
        datas.push(new PolarData(-1, 12, 6.7, 53));
        datas.push(new PolarData(-1, 12, 6.6, 52));
        datas.push(new PolarData(-1, 12, 6.6, 55));
        datas.push(new PolarData(-1, 12, 6.5, 57));
        datas.push(new PolarData(-1, 12, 6.5, 53));
        datas.push(new PolarData(-1, 12, 6.5, 55));
        datas.push(new PolarData(-1, 12, 6.5, 55));
        datas.push(new PolarData(-1, 12, 6.5, 57));
        datas.push(new PolarData(-1, 12, 6.5, 54));
        datas.push(new PolarData(-1, 12, 6.5, 53));
        datas.push(new PolarData(-1, 12, 6.5, 54));
        datas.push(new PolarData(-1, 12, 6.5, 51));
        datas.push(new PolarData(-1, 12, 6.4, 51));
        datas.push(new PolarData(-1, 12, 6.4, 49));
        datas.push(new PolarData(-1, 12, 6.7, 55));
        datas.push(new PolarData(-1, 12, 6.6, 57));
        datas.push(new PolarData(-1, 12, 6.6, 53));
        datas.push(new PolarData(-1, 12, 6.6, 55));
        datas.push(new PolarData(-1, 12, 6.6, 53));
        datas.push(new PolarData(-1, 12, 6.6, 55));
        datas.push(new PolarData(-1, 12, 6.6, 52));
        datas.push(new PolarData(-1, 12, 6.6, 54));
        datas.push(new PolarData(-1, 12, 6.6, 52));
        datas.push(new PolarData(-1, 12, 6.6, 53));
        datas.push(new PolarData(-1, 12, 6.6, 52));
        datas.push(new PolarData(-1, 12, 6.6, 54));
        datas.push(new PolarData(-1, 12, 6.6, 55));
        datas.push(new PolarData(-1, 12, 6.5, 52));
        datas.push(new PolarData(-1, 12, 6.5, 54));
        datas.push(new PolarData(-1, 12, 6.5, 52));
        datas.push(new PolarData(-1, 12, 6.5, 55));
        datas.push(new PolarData(-1, 12, 6.5, 53));
        datas.push(new PolarData(-1, 12, 6.5, 55));
        datas.push(new PolarData(-1, 12, 6.5, 51));
        datas.push(new PolarData(-1, 12, 6.4, 53));
        datas.push(new PolarData(-1, 12, 6.4, 52));
        datas.push(new PolarData(-1, 12, 6.4, 51));
        datas.push(new PolarData(-1, 12, 6.3, 52));
        datas.push(new PolarData(-1, 12, 6.2, 53));
        datas.push(new PolarData(-1, 12, 6, 54));
        datas.push(new PolarData(-1, 12, 6, 56));
        datas.push(new PolarData(-1, 12, 5.9, 53));
        datas.push(new PolarData(-1, 12, 5.9, 55));
        datas.push(new PolarData(-1, 12, 5.9, 50));
        datas.push(new PolarData(-1, 12, 5.9, 55));
        datas.push(new PolarData(-1, 12, 5.9, 57));
        datas.push(new PolarData(-1, 12, 5.9, 55));
        datas.push(new PolarData(-1, 12, 5.9, 58));
        datas.push(new PolarData(-1, 12, 5.9, 57));
        datas.push(new PolarData(-1, 12, 5.9, 59));
        datas.push(new PolarData(-1, 12, 5.9, 56));
        datas.push(new PolarData(-1, 12, 5.9, 59));
        datas.push(new PolarData(-1, 12, 5.9, 58));
        datas.push(new PolarData(-1, 12, 6, 57));
        datas.push(new PolarData(-1, 12, 6, 58));
        datas.push(new PolarData(-1, 12, 6, 56));
        datas.push(new PolarData(-1, 12, 6, 57));
        datas.push(new PolarData(-1, 12, 6, 57));
        datas.push(new PolarData(-1, 12, 6, 52));
        datas.push(new PolarData(-1, 12, 6, 56));
        datas.push(new PolarData(-1, 12, 6, 54));
        datas.push(new PolarData(-1, 12, 6, 55));
        datas.push(new PolarData(-1, 12, 6, 54));
        datas.push(new PolarData(-1, 12, 6, 52));
        datas.push(new PolarData(-1, 12, 6, 55));
        datas.push(new PolarData(-1, 12, 6, 58));
        datas.push(new PolarData(-1, 12, 6, 58));
        datas.push(new PolarData(-1, 12, 6, 55));
        datas.push(new PolarData(-1, 12, 6.3, 17));
        datas.push(new PolarData(-1, 12, 5.3, 28));
        datas.push(new PolarData(-1, 12, 4.2, 40));
        datas.push(new PolarData(-1, 12, 4.2, 36));
        datas.push(new PolarData(-1, 12, 4.2, 38));
        datas.push(new PolarData(-1, 12, 4.2, 36));
        datas.push(new PolarData(-1, 12, 4.2, 39));
        datas.push(new PolarData(-1, 12, 4.2, 48));
        datas.push(new PolarData(-1, 12, 4.3, 48));
        datas.push(new PolarData(-1, 12, 4.7, 53));
        datas.push(new PolarData(-1, 12, 4.9, 52));
        datas.push(new PolarData(-1, 12, 5, 51));
        datas.push(new PolarData(-1, 12, 5.3, 47));
        datas.push(new PolarData(-1, 12, 5.3, 50));
        datas.push(new PolarData(-1, 12, 5.4, 47));
        datas.push(new PolarData(-1, 12, 5.5, 51));
        datas.push(new PolarData(-1, 12, 5.6, 48));
        datas.push(new PolarData(-1, 12, 5.8, 50));
        datas.push(new PolarData(-1, 12, 5.8, 47));
        datas.push(new PolarData(-1, 12, 5.9, 48));
        datas.push(new PolarData(-1, 12, 5.9, 46));
        datas.push(new PolarData(-1, 12, 6, 48));
        datas.push(new PolarData(-1, 12, 6.1, 48));
        datas.push(new PolarData(-1, 12, 6.1, 48));
        datas.push(new PolarData(-1, 12, 6.2, 47));
        datas.push(new PolarData(-1, 12, 6.2, 46));
        datas.push(new PolarData(-1, 12, 6.2, 48));
        datas.push(new PolarData(-1, 12, 6.2, 47));
        datas.push(new PolarData(-1, 12, 6.3, 49));
        datas.push(new PolarData(-1, 12, 6.3, 49));
        datas.push(new PolarData(-1, 12, 6.3, 49));
        datas.push(new PolarData(-1, 12, 6.3, 46));
        datas.push(new PolarData(-1, 12, 6.3, 49));
        datas.push(new PolarData(-1, 12, 6.3, 51));
        datas.push(new PolarData(-1, 12, 6.3, 50));
        datas.push(new PolarData(-1, 12, 6.3, 53));
        datas.push(new PolarData(-1, 12, 6.3, 51));
        datas.push(new PolarData(-1, 12, 6.3, 51));
        datas.push(new PolarData(-1, 12, 6.3, 51));
        datas.push(new PolarData(-1, 12, 6.3, 52));
        datas.push(new PolarData(-1, 12, 6.3, 52));
        datas.push(new PolarData(-1, 12, 6.3, 51));
        datas.push(new PolarData(-1, 12, 6.3, 54));
        datas.push(new PolarData(-1, 12, 6.3, 52));
        datas.push(new PolarData(-1, 12, 6.3, 51));
        datas.push(new PolarData(-1, 12, 6.3, 63));
        datas.push(new PolarData(-1, 12, 6.3, 55));
        datas.push(new PolarData(-1, 12, 6.3, 54));
        datas.push(new PolarData(-1, 12, 6.3, 55));
        datas.push(new PolarData(-1, 12, 6.3, 56));
        datas.push(new PolarData(-1, 12, 6.3, 52));
        datas.push(new PolarData(-1, 12, 6.3, 56));
        datas.push(new PolarData(-1, 12, 6.3, 54));
        datas.push(new PolarData(-1, 12, 6.3, 55));
        datas.push(new PolarData(-1, 12, 6.3, 55));
        datas.push(new PolarData(-1, 12, 6.3, 53));
        datas.push(new PolarData(-1, 12, 7.3, 57));
        datas.push(new PolarData(-1, 12, 7.3, 56));
        datas.push(new PolarData(-1, 12, 7.3, 55));
        datas.push(new PolarData(-1, 12, 7.3, 57));
        datas.push(new PolarData(-1, 12, 7.3, 62));
        datas.push(new PolarData(-1, 12, 7.2, 56));
        datas.push(new PolarData(-1, 12, 7.2, 58));
        datas.push(new PolarData(-1, 12, 7.1, 55));
        datas.push(new PolarData(-1, 12, 7.1, 58));
        datas.push(new PolarData(-1, 12, 7.1, 56));
        datas.push(new PolarData(-1, 12, 7.1, 59));
        datas.push(new PolarData(-1, 12, 7, 58));
        datas.push(new PolarData(-1, 12, 7, 56));
        datas.push(new PolarData(-1, 12, 7, 57));
        datas.push(new PolarData(-1, 12, 6.9, 59));
        datas.push(new PolarData(-1, 12, 6.9, 63));
        datas.push(new PolarData(-1, 12, 6.9, 57));
        datas.push(new PolarData(-1, 12, 6.9, 59));
        datas.push(new PolarData(-1, 12, 6.9, 54));
        datas.push(new PolarData(-1, 12, 6.9, 57));
        datas.push(new PolarData(-1, 12, 6.4, 63));
        datas.push(new PolarData(-1, 12, 6.3, 61));
        datas.push(new PolarData(-1, 12, 6.3, 59));
        datas.push(new PolarData(-1, 12, 6.4, 56));
        datas.push(new PolarData(-1, 12, 6.8, 59));
        datas.push(new PolarData(-1, 12, 6.8, 58));
        datas.push(new PolarData(-1, 12, 6.8, 58));
        datas.push(new PolarData(-1, 12, 6.8, 57));
        datas.push(new PolarData(-1, 12, 6.8, 59));
        datas.push(new PolarData(-1, 12, 6.8, 57));
        datas.push(new PolarData(-1, 12, 6.8, 58));
        datas.push(new PolarData(-1, 12, 6.8, 55));
        datas.push(new PolarData(-1, 12, 7.1, 55));
        datas.push(new PolarData(-1, 12, 7.1, 56));
        datas.push(new PolarData(-1, 12, 7.1, 62));
        datas.push(new PolarData(-1, 12, 7.1, 56));
        datas.push(new PolarData(-1, 12, 7.1, 55));
        datas.push(new PolarData(-1, 12, 7.1, 57));
        datas.push(new PolarData(-1, 12, 7.1, 60));
        datas.push(new PolarData(-1, 12, 7.1, 58));
        datas.push(new PolarData(-1, 12, 7.1, 59));
        datas.push(new PolarData(-1, 12, 7.1, 53));
        datas.push(new PolarData(-1, 12, 7.2, 59));
        datas.push(new PolarData(-1, 12, 7.2, 59));
        datas.push(new PolarData(-1, 12, 7.2, 57));
        datas.push(new PolarData(-1, 12, 7.1, 58));
        datas.push(new PolarData(-1, 12, 7, 55));
        datas.push(new PolarData(-1, 12, 7, 57));
        datas.push(new PolarData(-1, 12, 7, 58));
        datas.push(new PolarData(-1, 12, 6.9, 58));
        datas.push(new PolarData(-1, 12, 6.9, 56));
        datas.push(new PolarData(-1, 12, 6.9, 61));
        datas.push(new PolarData(-1, 12, 6.9, 60));
        datas.push(new PolarData(-1, 12, 6.9, 60));
        datas.push(new PolarData(-1, 12, 7, 57));
    }
}
}
