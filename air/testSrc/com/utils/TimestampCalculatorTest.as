/**
 * Created by pepusz on 2014.01.23..
 */
package com.utils {
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertTrue;

public class TimestampCalculatorTest {
    public function TimestampCalculatorTest() {
    }

    private function loadTestNmea():Array {
        var logFile:File = new File(File.applicationDirectory.nativePath + "/../../../testDatas/dpt_rmc.txt");
        assertTrue(logFile.exists)
        var fileStream:FileStream = new FileStream();
        fileStream.open(logFile, FileMode.READ);
        fileStream.position = 0;
        var fileContent:* = fileStream.readUTFBytes(fileStream.bytesAvailable);
        var packeter:NmeaPacketer = new NmeaPacketer();
        return packeter.newReadPacket(fileContent, true);
    }

    private function loadTestNmeaFROM13():Array {
        var logFile:File = new File(File.applicationDirectory.nativePath + "/../../../testDatas/test_13_jakx.nmea");
        assertTrue(logFile.exists)
        var fileStream:FileStream = new FileStream();
        fileStream.open(logFile, FileMode.READ);
        fileStream.position = 0;
        var fileContent:* = fileStream.readUTFBytes(fileStream.bytesAvailable);
        var packeter:NmeaPacketer = new NmeaPacketer();
        return packeter.newReadPacket(fileContent, true);
    }

    private function loadTestNmeaFROMod0709():Array {
        var logFile:File = new File(File.applicationDirectory.nativePath + "/../../../testDatas/Log 2010-07-09 210914.txt");
        assertTrue(logFile.exists)
        var fileStream:FileStream = new FileStream();
        fileStream.open(logFile, FileMode.READ);
        fileStream.position = 0;
        var fileContent:* = fileStream.readUTFBytes(fileStream.bytesAvailable);
        var packeter:NmeaPacketer = new NmeaPacketer();
        return packeter.newReadPacket(fileContent, true);
    }

    private function loadTestNmeaDemo():Array {
        var logFile:File = new File(File.applicationDirectory.nativePath + "/../../../testDatas/demo.nmea");
        assertTrue(logFile.exists)
        var fileStream:FileStream = new FileStream();
        fileStream.open(logFile, FileMode.READ);
        fileStream.position = 0;
        var fileContent:* = fileStream.readUTFBytes(fileStream.bytesAvailable);
        var packeter:NmeaPacketer = new NmeaPacketer();
        return packeter.newReadPacket(fileContent, true);
    }

    [Test]
    public function testFirstData():void {
        var messages:Array = loadTestNmea();
        var timestampCalc:TimestampCalculator = new TimestampCalculator(messages);
        timestampCalc.removeWrongZdas();
        var timestamp:Number = timestampCalc.getFirstTimestamp();
        assertEquals(1367918289000, timestamp);
    }

    [Test]
    public function testOdysLog():void {
        var messages:Array = loadTestNmeaFROMod0709();
        var timestampCalc:TimestampCalculator = new TimestampCalculator(messages);
        timestampCalc.removeWrongZdas();
        var timestamp:Number = timestampCalc.getFirstTimestamp();
        assertEquals(1278702891000, timestamp);
    }

    [Test]
    public function testFirstZDAFromWronLOG():void {
        var messages:Array = loadTestNmeaFROM13();
        var timestampCalc:TimestampCalculator = new TimestampCalculator(messages);
        timestampCalc.removeWrongZdas();
        var timestamp:Number = timestampCalc.getFirstTimestamp();
        assertEquals("diff " + (timestamp - 1397372927000), 1397372927000, timestamp);
        for (var i:int = 0; i < messages.length; i++) {
            var x:Object = NmeaInterpreter.processWithMessageCode(messages[i]);
            if (x != null) {
                if (x.key.match(TimestampCalculator.regexpForKey)) {
                    if (x.key == "zda") {
                        timestamp = timestampCalc.dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec, x.data.utc);
                    } else {
                        timestamp = timestampCalc.dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec);
                    }

                    if (timestamp != -1) {
                        if (timestamp === 0) {
                            trace("TIMESTAMP 0", messages[i]);
                        }
                        assertEquals(messages[i] + "index:" + i + " timestamp:" + timestamp, 13, new Date(timestamp).dateUTC)
                    } else {
                        timestamp = timestampCalc.actualTimestamp;
                    }

                }
            }
        }

    }

    [Test]
    public function testFirstZDAFromDEMO():void {
        var messages:Array = loadTestNmeaDemo();
        var timestampCalc:TimestampCalculator = new TimestampCalculator(messages);
        timestampCalc.removeWrongZdas();
        var timestamp:Number = timestampCalc.getFirstTimestamp();
        assertEquals(1278427862000, timestamp);
        assertEquals(1278428745000, timestampCalc.lastTimestamp);


    }

    [Test]
    public function test1():void {
        var d1:Date = new Date(2013, 03, 22, 9, 30, 15);
        var timestampCalc:TimestampCalculator = new TimestampCalculator(null, d1);
        assertEquals(Date.UTC(2013, 03, 22, 9, 35, 15), timestampCalc.dateFromNmeaTimestamp(9, 35, 15))
    }

    [Test]
    public function test2():void {
        var d1:Date = new Date(2013, 03, 22, 9, 30, 15);
        var timestampCalc:TimestampCalculator = new TimestampCalculator(null, d1);
        timestampCalc.dateFromNmeaTimestamp(9, 35, 15)
        timestampCalc.dateFromNmeaTimestamp(9, 35, 30)
        timestampCalc.dateFromNmeaTimestamp(9, 35, 40)
        assertEquals(Date.UTC(2013, 03, 22, 9, 35, 50), timestampCalc.dateFromNmeaTimestamp(9, 35, 50))
    }


    [Test]
    public function test3SecondCorrection():void {
        var d1:Date = new Date(2013, 03, 22, 9, 30, 15);
        var timestampCalc:TimestampCalculator = new TimestampCalculator(null, d1);
        timestampCalc.dateFromNmeaTimestamp(9, 35, 15)
        timestampCalc.dateFromNmeaTimestamp(9, 35, 17)
        timestampCalc.dateFromNmeaTimestamp(9, 35, 16)
        assertEquals(Date.UTC(2013, 03, 22, 9, 35, 20), timestampCalc.dateFromNmeaTimestamp(9, 35, 20))
    }

    [Test]
    public function test4HourCorrection():void {
        var d1:Date = new Date(2013, 03, 22, 9, 30, 15);
        var timestampCalc:TimestampCalculator = new TimestampCalculator(null, d1);
        timestampCalc.dateFromNmeaTimestamp(9, 35, 15)
        timestampCalc.dateFromNmeaTimestamp(9, 35, 17)
        timestampCalc.dateFromNmeaTimestamp(7, 35, 18)
        var lasttimestamp:Number = timestampCalc.dateFromNmeaTimestamp(7, 35, 20);
        trace(new Date(Date.UTC(2013, 03, 22, 9, 35, 20)).toUTCString(), new Date(lasttimestamp).toUTCString());
        assertEquals(Date.UTC(2013, 03, 22, 9, 35, 20), lasttimestamp)
    }

    [Test]
    public function test5GotNewDate():void {
        var d1:Date = new Date(2013, 03, 22, 9, 30, 15);
        var d2:Date = new Date(Date.UTC(2013, 03, 23, 0, 30, 15));
        var timestampCalc:TimestampCalculator = new TimestampCalculator(null, d1);
        timestampCalc.dateFromNmeaTimestamp(9, 35, 15)
        timestampCalc.dateFromNmeaTimestamp(9, 35, 17)
        timestampCalc.dateFromNmeaTimestamp(7, 35, 18)
        timestampCalc.dateFromNmeaTimestamp(0, 30, 15, d2);
        timestampCalc.dateFromNmeaTimestamp(0, 31, 15);
        timestampCalc.dateFromNmeaTimestamp(0, 32, 15);
        var lasttimestamp:Number = timestampCalc.dateFromNmeaTimestamp(0, 32, 30);
        assertEquals(Date.UTC(2013, 03, 23, 0, 32, 30), lasttimestamp)
    }

    [Test]
    public function test6GotNewDateButBeforeDaySwitched():void {
        var d1:Date = new Date(2013, 03, 22, 9, 30, 15);
        var d2:Date = new Date(Date.UTC(2013, 03, 23, 0, 30, 15));
        var timestampCalc:TimestampCalculator = new TimestampCalculator(null, d1);
        timestampCalc.dateFromNmeaTimestamp(9, 35, 15)
        timestampCalc.dateFromNmeaTimestamp(9, 35, 17)
        timestampCalc.dateFromNmeaTimestamp(7, 35, 18)
        var t1:Number = timestampCalc.dateFromNmeaTimestamp(0, 30, 15);
        timestampCalc.dateFromNmeaTimestamp(0, 31, 15, d2);
        timestampCalc.dateFromNmeaTimestamp(0, 32, 15);
        var lasttimestamp:Number = timestampCalc.dateFromNmeaTimestamp(0, 32, 30);
        assertEquals(Date.UTC(2013, 03, 23, 0, 32, 30), lasttimestamp)
        assertEquals(Date.UTC(2013, 03, 23, 0, 30, 15), t1)
    }

    [Test]
    public function test7():void {
        var d1:Date = new Date(2013, 03, 22, 9, 30, 15);
        var d2:Date = new Date(Date.UTC(2013, 03, 22, 9, 35, 18));
        var timestampCalc:TimestampCalculator = new TimestampCalculator(null, d1);
        timestampCalc.dateFromNmeaTimestamp(9, 35, 15)
        timestampCalc.dateFromNmeaTimestamp(9, 35, 17)
        var lasttimestamp:Number = timestampCalc.dateFromNmeaTimestamp(7, 35, 18, d2)
        assertEquals(Date.UTC(2013, 03, 22, 9, 35, 18), lasttimestamp)
    }

    [Test]
    public function test8():void {
        var d1:Date = new Date(2013, 03, 22, 23, 59, 58);
        var d2:Date = new Date(Date.UTC(2013, 03, 23, 0, 0, 0));
        var timestampCalc:TimestampCalculator = new TimestampCalculator(null, d1);
        var lasttimestamp:Number = timestampCalc.dateFromNmeaTimestamp(0, 0, 0, d2)
        assertEquals(Date.UTC(2013, 03, 23, 0, 0, 0), lasttimestamp)
    }


}
}
