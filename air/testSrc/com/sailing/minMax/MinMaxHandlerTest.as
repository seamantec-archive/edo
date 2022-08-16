/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.22.
 * Time: 16:20
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.minMax {
import com.events.UpdateNmeaDatasEvent;
import com.sailing.combinedDataHandlers.CombinedDataHandler;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import org.flexunit.asserts.assertEquals;

import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertTrue;

public class MinMaxHandlerTest {
    var messages:Array;
    /*
     * FIRST 50 DATAS
     * DBT min:5.46 max:8.14
     *
     * */
    [Before]
    public function setUp():void {
        var logFile:File = new File(File.applicationDirectory.nativePath + "/../../../testDatas/minmaxtest.nmea");
        assertTrue(logFile.exists)
        var fileStream:FileStream = new FileStream();
        fileStream.open(logFile, FileMode.READ);
        fileStream.position = 0;
        var fileContent:* = fileStream.readUTFBytes(fileStream.bytesAvailable);
        var packeter:NmeaPacketer = new NmeaPacketer();
        messages = packeter.newReadPacket(fileContent, true);
        MinMaxHandler.instance.clear();
        CombinedDataHandler.instance.addEventListener(UpdateNmeaDatasEvent.UPDATE_NMEA_DATAS, updateNmeaDatasHandler);
    }

    private function loadMessages(to:int = 50) {

        for (var i:int = 0; i < to; i++) {
            var x:Object = NmeaInterpreter.processWithMessageCode(messages[i]);
            MinMaxHandler.instance.updateMinMax(x.key, x.data);
            CombinedDataHandler.instance.updateDatas(x.key, x.data, 1000);

        }
    }

    [Test]
    public function testListenerStructure():void {
        var l:Object = MinMaxHandler.instance.listeners;
        assertNotNull(l["dbt"]);
        assertNotNull(l["dbt"]["waterDepth"]);
        assertNotNull(l["dbt"]["waterDepth"].global);
        assertTrue(l["dbt"]["waterDepth"].global is MinMax);
        assertNotNull(l["dbt"]["waterDepth"].instruments);
        assertNotNull(l["mwvr"]["windDirection"].global);
        assertNotNull(l["mwvr"]["windSpeed"].global);
        assertNotNull(l["mwvt"]["windSpeed"].global);
    }


    [Test]
    public function testGlobalVariables():void {
        var l:Object = MinMaxHandler.instance.listeners;
        loadMessages();
        assertEquals(l["dbt"]["waterDepth"].global.min, 5.46)
        assertEquals(l["dbt"]["waterDepth"].global.max, 8.14)
        assertEquals(l["mwvr"]["windDirection"].global.min, 0)
        assertEquals(l["mwvr"]["windDirection"].global.max, 359)
        assertEquals(l["mwvr"]["windSpeed"].global.min, 6.1)
        assertEquals(l["mwvr"]["windSpeed"].global.max, 6.7)
        assertEquals(l["mwvt"]["windSpeed"].global.min, 1.7)
        assertEquals(l["mwvt"]["windSpeed"].global.max, 2.7)
        assertEquals(l["mwvt"]["windDirection"].global.min, 160)
        assertEquals(l["mwvt"]["windDirection"].global.max, 183.5)
    }


    [Test]
    public function testMockControl():void {
        //TODO when created instruments base class update this test (and others below)
        loadMessages();
        var controll1:Object = {};
        controll1["minMaxVars"] = {};
        controll1["minMaxVars"]["dbt.waterDepth"] = new MinMax();
        controll1["minMaxVars"]["mwvt.windDirection"] = new MinMax();
        var x:MinMaxHandler = MinMaxHandler.instance;
        MinMaxHandler.instance.addListener(controll1);
        assertEquals(controll1["minMaxVars"]["dbt.waterDepth"].min, 5.46);
        assertEquals(controll1["minMaxVars"]["dbt.waterDepth"].max, 8.14);
        assertEquals(controll1["minMaxVars"]["mwvt.windDirection"].min, 160);
        assertEquals(controll1["minMaxVars"]["mwvt.windDirection"].max, 183.5);
    }

    [Test]
    public function testMockControlAfterReset():void {
        loadMessages();
        var controll1:Object = {};
        controll1["minMaxVars"] = {};
        controll1["minMaxVars"]["dbt.waterDepth"] = new MinMax();
        MinMaxHandler.instance.addListener(controll1);
        controll1["minMaxVars"]["dbt.waterDepth"].reset();
        assertTrue(controll1["minMaxVars"]["dbt.waterDepth"].reseted);
        assertTrue(isNaN(controll1["minMaxVars"]["dbt.waterDepth"].min));
        loadMessages(10);
        assertEquals(controll1["minMaxVars"]["dbt.waterDepth"].min, 5.46);
        assertEquals(controll1["minMaxVars"]["dbt.waterDepth"].max, 5.88);

        var l:Object = MinMaxHandler.instance.listeners;
        assertEquals(l["dbt"]["waterDepth"].global.min, 5.46)
        assertEquals(l["dbt"]["waterDepth"].global.max, 8.14)

    }


    [Test]
    public function testAddOldControlToListener():void {
        var controll1:Object = {};
        MinMaxHandler.instance.addListener(controll1);
        //no assert just check is not throw exception
    }

    [Test]
    public function testAddWronKeyControlToListener():void {
        var controll1:Object = {};
        controll1["minMaxVars"] = {};
        controll1["minMaxVars"]["xyz.waterDepth"] = new MinMax();
        MinMaxHandler.instance.addListener(controll1);
        //no assert just check is not throw exception
    }


    [Test]
    public function testRemoveListener():void {

        var controll1:Object = {};
        controll1["minMaxVars"] = {};
        controll1["minMaxVars"]["dbt.waterDepth"] = new MinMax();
        controll1["minMaxVars"]["mwvt.windDirection"] = new MinMax();
        MinMaxHandler.instance.addListener(controll1);
        var controll2:Object = {};
        controll2["minMaxVars"] = {};
        controll2["minMaxVars"]["dbt.waterDepth"] = new MinMax();
        controll2["minMaxVars"]["mwvt.windDirection"] = new MinMax();
        MinMaxHandler.instance.addListener(controll2);

        var l:Object = MinMaxHandler.instance.listeners;
        assertEquals(l["dbt"]["waterDepth"].instruments.length, 2)
        assertEquals(l["mwvt"]["windDirection"].instruments.length, 2)

        MinMaxHandler.instance.removeListener(controll1);
        assertEquals(l["dbt"]["waterDepth"].instruments.length, 1)
        assertEquals(l["mwvt"]["windDirection"].instruments.length, 1)
        assertEquals(l["dbt"]["waterDepth"].instruments[0]["minMaxVars"]["dbt.waterDepth"], controll2["minMaxVars"]["dbt.waterDepth"])
        assertEquals(l["mwvt"]["windDirection"].instruments[0]["minMaxVars"]["mwv.windDirection"], controll2["minMaxVars"]["mwv.windDirection"])

    }

    [Test]
    public function testLoadOnlyOneData():void {
        var l:Object = MinMaxHandler.instance.listeners;

        loadMessages(1);
        assertEquals(l["dbt"]["waterDepth"].global.min, 5.46)
        assertEquals(l["dbt"]["waterDepth"].global.max, 5.46)

    }

    private function updateNmeaDatasHandler(event:UpdateNmeaDatasEvent):void {
        if(event.data.data == null){
            return;
        }
        MinMaxHandler.instance.updateMinMax(event.data.key, event.data.data);
    }
}
}
