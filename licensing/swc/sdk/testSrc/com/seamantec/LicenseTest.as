/**
 * Created by pepusz on 2013.12.08..
 */
package com.seamantec {
import flash.data.EncryptedLocalStore;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;
import org.flexunit.async.Async;

public class LicenseTest {
    public function LicenseTest() {
    }

    private var lm:LicenseManager

    [Before]
    public function setUp():void {
        EncryptedLocalStore.reset();
        lm = new LicenseManager();

    }

    [Test(async, timeout=60000)]
    public function testHashLicense():void {
        asyncWaiter(10000, function (event:Event, passThroughData:Object) {
            var license:License = lm.getLicenseByName("demo.lic");
            license.activate();
            assertTrue(license.isHashValid());

        }, handleTimeout, onTimer);
        lm.getLicenseFromServer("john@gmail.com", "a845d-c7d6a-cbb19-87b31")

    }

    [Test]
    public function testDateValidation():void {
        var localTime:Date = new Date()
        var expAt:Date = new Date(Date.parse("2014-01-05".replace(/-/g, "/")));
        var actAt:Date = new Date(Date.parse("2013-12-05".replace(/-/g, "/")));
        var locAt:Date = new Date(Date.parse("2013-12-08".replace(/-/g, "/")));
        assertTrue(License.validateDate(localTime, actAt, expAt, locAt));

        var localTime:Date = new Date(Date.parse("2013-01-05".replace(/-/g, "/")));
        var expAt:Date = new Date(Date.parse("2014-01-05".replace(/-/g, "/")));
        var actAt:Date = new Date(Date.parse("2013-12-05".replace(/-/g, "/")));
        var locAt:Date = new Date(Date.parse("2013-12-08".replace(/-/g, "/")));
        assertFalse(License.validateDate(localTime, actAt, expAt, locAt));

        var localTime:Date = new Date(Date.parse("2014-01-06".replace(/-/g, "/")));
        var expAt:Date = new Date(Date.parse("2014-01-05".replace(/-/g, "/")));
        var actAt:Date = new Date(Date.parse("2013-12-05".replace(/-/g, "/")));
        var locAt:Date = new Date(Date.parse("2013-12-08".replace(/-/g, "/")));
        assertFalse(License.validateDate(localTime, actAt, expAt, locAt));

        var localTime:Date = new Date(Date.parse("2013-12-07".replace(/-/g, "/")));
        var expAt:Date = new Date(Date.parse("2014-01-05".replace(/-/g, "/")));
        var actAt:Date = new Date(Date.parse("2013-12-05".replace(/-/g, "/")));
        var locAt:Date = new Date(Date.parse("2013-12-08".replace(/-/g, "/")));
        assertFalse(License.validateDate(localTime, actAt, expAt, locAt));
    }


    [Test]
    public function testExpire():void {
        var localTime:Date = new Date(Date.parse("2014-04-22".replace(/-/g, "/")));
        var expAt:Date = new Date(Date.parse("2014-04-21".replace(/-/g, "/")));
        var actAt:Date = new Date(Date.parse("2013-12-05".replace(/-/g, "/")));
        var locAt:Date = new Date(Date.parse("2013-12-05".replace(/-/g, "/")));
        assertFalse(License.validateDate(localTime,actAt,expAt,locAt))
    }

    [Test]
    public function testDistance():void {
        var hwKey:String = "1234-1234-1234-1234"
        assertEquals(0, License.distance(hwKey, hwKey))
        assertEquals(4, License.distance(hwKey, "4321-1234-1234-1234"))
        assertEquals(8, License.distance(hwKey, "4321-jshd-1234-1234"))
    }

    private function asyncWaiter(timeout:int, handleRead:Function, handleTimeout:Function, onTimer:Function):void {
        var timer:Timer = new Timer(100, Math.round(timeout / 100));
        timer.addEventListener(TimerEvent.TIMER, onTimer)
        timer.addEventListener(TimerEvent.TIMER_COMPLETE, Async.asyncHandler(this, handleRead, timeout, timer, handleTimeout), false, 0, true);
        timer.start();
    }

    protected function onTimer(event:TimerEvent):void {
        if (lm.getLicenseByName("demo.lic") != null) {
            (event.currentTarget as Timer).stop();
            (event.currentTarget as Timer).dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
        }
    }


    protected function handleTimeout(passThroughData:Object):void {
        assertTrue("License file not found. Timeout error", false)

    }
}
}
