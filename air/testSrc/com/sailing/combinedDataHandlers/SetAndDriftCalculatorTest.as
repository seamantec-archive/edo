/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 10/11/13
 * Time: 10:42 AM
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.Rmc;
import com.sailing.datas.Setanddrift;
import com.sailing.datas.Vhw;

import flash.utils.getTimer;

import org.flexunit.asserts.assertEquals;

public class SetAndDriftCalculatorTest {
    var testData:SetAndDriftCalculator;
    var data:Setanddrift;

    public function SetAndDriftCalculatorTest() {
        testData = new SetAndDriftCalculator();
        data = new Setanddrift();
    }


    public function setUp():void {
        var vhw = new Vhw();
        vhw.waterHeading.value = 60;
        vhw.waterSpeed.value = 15;
        var rmc = new Rmc();
        rmc.gpsCog.value = 45;
        rmc.gpsSog.value = 10;
        for(var i=0; i<100; i++) {
            vhw.lastTimestamp = (new Date()).getMilliseconds();
            rmc.lastTimestamp = (new Date()).getMilliseconds();
            data = (testData.dataChanged("vhw", vhw,  (new Date()).getMilliseconds()) as Setanddrift);
            data = (testData.dataChanged("rmc", rmc,  (new Date()).getMilliseconds()) as Setanddrift);
            sleep(3);
        }
    }

    [Test]
    public function dataTest():void {
        data = changeVhw(30, 0);
        data = changeRmc(60, 1);
        trace(data.angleset.value);

        data = changeVhw(60, 1);
        data = changeRmc(30, 1);
        trace(data.angleset.value);

        data = changeVhw(45, 1);
        data = changeRmc(45, 1);
        trace(data.angleset.value);

        data = changeVhw(30, 1);
        data = changeRmc(60, 2);
        trace(data.angleset.value);

        data = changeVhw(60, 2);
        data = changeRmc(30, 1);
        trace(data.angleset.value);
    }

    [Test]
    public function immutableDataTest():void {
        assertEquals(data.angleset.value, 15);
        assertEquals(data.drift.value,  5);
    }

    [Test]
    public function mutableDataTest():void {
        //changeVhw(65, 12);
        //changeRmc(52, 11);

        //changeVhw(344, 19);
        //changeRmc(50, 18);

        //changeVhw(72, 21);
        //changeRmc(55, 9);

        //changeVhw(65, 12);
        //changeRmc(52, 11);

        data = changeVhw(60, 5);
        data = changeRmc(30, 10);
        trace(data.angleset.value + " : " + 126.206);
        trace(data.drift.value + " : " + 6.1965);

        data = changeVhw(195, 1.1);
        data = changeRmc(265, 3.6);
        trace(data.angleset.value + " : " + 92.22);
        trace(data.drift.value + " : " + 3.3854);

        data = changeVhw(289, 2.2);
        data = changeRmc(291, 4);
        trace(data.angleset.value + " : " + 162.4698);
        trace(data.drift.value + " : " + 1.8469);

        data = changeVhw(31, 2.7);
        data = changeRmc(22, 5);
        trace(data.angleset.value + " : " + 160.7476);
        trace(data.drift.value + " : " + 2.3711);

        data = changeVhw(270, 0);
        data = changeRmc(32, 0);
        trace(data.angleset.value + " : " + 0);
        trace(data.drift.value + " : " + 0);

        data = changeVhw(302, 9);
        data = changeRmc(301, 7.9);
        trace(data.angleset.value + " : " + 7.1361);
        trace(data.drift.value + " : " + 1.1098);
    }

    private function changeVhw(heading:Number, speed:Number):Setanddrift {
        sleep(3);
        var vhw = new Vhw();
        vhw.waterHeading.value = heading;
        vhw.waterSpeed.value = speed;
        vhw.lastTimestamp = (new Date()).getMilliseconds();
        return testData.dataChanged("vhw", vhw, vhw.lastTimestamp) as Setanddrift;
    }

    private function changeRmc(cog:Number, sog:Number):Setanddrift {
        var rmc = new Rmc();
        rmc.gpsCog.value = cog;
        rmc.gpsSog.value = sog;
        rmc.lastTimestamp = (new Date()).getMilliseconds();
        return testData.dataChanged("rmc", rmc, rmc.lastTimestamp) as Setanddrift;
    }

    private function sleep(ms:int):void {
        var init:int = (new Date()).getMilliseconds();
        while(true) {
            if(((new Date()).getMilliseconds()-init)>=ms) {
                break;
            }
        }
    }

}
}
