/**
 * Created by pepusz on 2014.02.06..
 */
package com.logbook {
import com.sailing.units.Depth;
import com.sailing.units.Speed;
import com.sailing.units.Temperature;
import com.sailing.units.WindSpeed;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertTrue;
import org.flexunit.async.Async;

public class LogBookDbTest {
    static var logBookDb:LogBookDb

    public function LogBookDbTest() {

    }

    [BeforeClass]
    public static function beforeEach() {
        logBookDb = new LogBookDb();
    }


    [After]
    public function tearDown():void {
        try {
//            File.applicationStorageDirectory.deleteDirectory(true);
        } catch (e:Error) {

        }
    }

    [Test(async, timeout=60000)]
    public function initDatabaseTest():void {
        logBookDb = new LogBookDb();
        asyncWaiter(1000, function (event:Event, passThroughData:Object) {
            assertTrue(logBookDb.dbReady);
        }, handleTimeout, onTimer);
    }

    [Test(async, timeout=60000)]
    public function insertNewItemTest():void {
        var sog:Speed = new Speed();
        sog.value = 10;
        var depth:Depth = new Depth();
        depth.value = 30;
        var wtemp:Temperature = new Temperature();
        wtemp.value = 23
        var airtemp:Temperature = new Temperature();
        airtemp.value = 24
        var wSpeed:WindSpeed = new WindSpeed();
        wSpeed.value = 10;
        var date:Date = new Date(Date.UTC(2013, 02, 6, 19, 23, 16));
        var t2:Timer = new Timer(100, 1);
        t2.addEventListener(TimerEvent.TIMER_COMPLETE, function () {
            logBookDb.insertLogEntry(new LogBookEntry(47.1, 18.1, date, sog, 123, depth, wtemp, airtemp, wSpeed, 230))
        })
        t2.start();

        var t3:Timer = new Timer(200, 1);
        var caller:SimpleSelectCaller = new SimpleSelectCaller();
        t3.addEventListener(TimerEvent.TIMER_COMPLETE, function () {
            logBookDb.selectLastEntry(caller);
        })
        t3.start();

        asyncWaiter(400, function () {
        }, function (event:Object) {
            var lastEntry:LogBookEntry = caller.results[0]
            assertEquals(date.time, lastEntry.timestamp.time);
            assertEquals(47.1, lastEntry.lat);
            assertEquals(18.1, lastEntry.lon);
            assertEquals(10, lastEntry.sog.value);
            assertEquals(123, lastEntry.cog);
            assertEquals(30, lastEntry.depth.value);
            assertEquals(23, lastEntry.waterTemp.value);
            assertEquals(24, lastEntry.airTemp.value);
            assertEquals(10, lastEntry.windSpeed.value);
            assertEquals(230, lastEntry.windDir);
        }, onTimer);
    }


    private function asyncWaiter(timeout:int, handleRead:Function, handleTimeout:Function, onTimer:Function):void {
        var timer:Timer = new Timer(100, Math.round(timeout / 100));
        timer.addEventListener(TimerEvent.TIMER, onTimer)
        timer.addEventListener(TimerEvent.TIMER_COMPLETE, Async.asyncHandler(this, handleRead, timeout, timer, handleTimeout), false, 0, true);
        timer.start();
    }

    protected function onTimer(event:TimerEvent):void {
//        var timer:Timer = (event.currentTarget as Timer);
//        if (timer.currentCount == 3) {
//            timer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
//            timer.stop();
//        }
//        if (lm.getLicenseByName("demo.lic") != null) {
//            var timer:Timer = (event.currentTarget as Timer);
//            timer.dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
//            timer.stop();
//        }
    }


    protected function handleTimeout(passThroughData:Object):void {
//        assertTrue("License file not found. Timeout error", false)

    }
}
}
