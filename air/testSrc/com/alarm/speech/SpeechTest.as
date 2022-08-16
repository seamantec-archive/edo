/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.21.
 * Time: 9:49
 * To change this template use File | Settings | File Templates.
 */
package com.alarm.speech {
import com.alarm.AlarmHandler;
import com.alarm.ListenerKeys;
import com.alarm.MockAlarm;
import com.alarm.soundfx.FxContainer;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class SpeechTest {

    var mockAlarm:MockAlarm
    var mockAlarm2Sog:MockAlarm

    [Before]
    public function setUp():void {
        mockAlarm = new MockAlarm();
        AlarmHandler.instance.lastSaidTime = 0;
        SpeechHandler.instance.lastAlarmUID = "";
        mockAlarm2Sog = new MockAlarm();
        mockAlarm2Sog.listenerKey = ListenerKeys.rmc_gpsSog
    }

    [Test]
    public function testCreateNewSpeechTestTexts():void {
        mockAlarm.actualValue = 50;
        var speech:Speech = new Speech(mockAlarm, mockAlarm.alarmSeverity);
        assertFalse(speech.isAlarmValidValue());
    }

    [Test]
    public function testCreateNewSpeechTestTextsInInfo():void {
        mockAlarm.actualValue = 30;
        mockAlarm._isInInfo = true;
        var speech:Speech = new Speech(mockAlarm, mockAlarm.alarmSeverity);
        speech.generateSpeechText();
        speech.generateSpeechSfx();
        assertEquals(4, speech.sounds.length);
        assertTrue(speech.sounds[0] is SpeechContainer._meter);
        assertTrue(speech.sounds[1] is SpeechContainer._30);
        assertTrue(speech.sounds[2] is SpeechContainer._water_depth_is_);
        assertTrue(speech.sounds[3] is FxContainer.getClass("_submarine"));
    }

    ///NUMBER TESTS-------

    [Test]
    public function testTwenties():void {
        for (var i:int = 1; i < 9; i++) {
            trace("test ", 20 + i);
            AlarmHandler.instance.lastSaidTime = 0;
            SpeechHandler.instance.lastAlarmUID = "";
            mockAlarm.actualValue = 20 + i;
            mockAlarm._isInInfo = true;
            var speech:Speech = new Speech(mockAlarm, Speech.REINFO);
            speech.generateSpeechText();
            speech.generateSpeechSfx();
            assertEquals(5, speech.sounds.length);
            assertTrue(speech.sounds[0] is SpeechContainer._meter);
            assertTrue(speech.sounds[1] is SpeechContainer["_" + i]);
            assertTrue(speech.sounds[2] is SpeechContainer._20);
            assertTrue(speech.sounds[3] is SpeechContainer._water_depth_is_);
            assertTrue(speech.sounds[4] is FxContainer.getClass("_submarine"));
            trace("------------------------------")
        }
    }

    [Test]
    public function testMaradek():void {
        for (var i:int = 1; i < 9; i++) {
            trace("test maradek ", 20 + i);
            AlarmHandler.instance.lastSaidTime = 0;
            SpeechHandler.instance.lastAlarmUID = "";
            mockAlarm2Sog.actualValue = 20 + i + i / 10;
            mockAlarm2Sog._isInInfo = true;
            var speech:Speech = new Speech(mockAlarm2Sog, Speech.REINFO);
            speech.generateSpeechText();
            speech.generateSpeechSfx();
            assertEquals(6, speech.sounds.length);
            assertTrue(speech.sounds[0] is SpeechContainer._knots);
            assertTrue(speech.sounds[1] is SpeechContainer["_" + i]);
            assertTrue(speech.sounds[2] is SpeechContainer._point);
            assertTrue(speech.sounds[3] is SpeechContainer["_" + i]);
            assertTrue(speech.sounds[4] is SpeechContainer._20);
            assertTrue(speech.sounds[5] is SpeechContainer._boat_speed_is_);
            trace("------------------------------")
        }
    }

    [Test]
    public function testHundredAndMaradek():void {
        for (var i:int = 1; i < 9; i++) {
            trace("test hundred maradek ", 120 + 1 * i + (20*i) / 10 + i / 100);
            AlarmHandler.instance.lastSaidTime = 0;
            SpeechHandler.instance.lastAlarmUID = "";
            mockAlarm2Sog.actualValue = 120 + 1 * i + (20+i) / 100;
            mockAlarm2Sog._isInInfo = true;
            var speech:Speech = new Speech(mockAlarm2Sog, Speech.REINFO);
            speech.generateSpeechText();
            speech.generateSpeechSfx();
            assertEquals(8, speech.sounds.length);
            assertTrue(speech.sounds[0] is SpeechContainer._knots);
            assertTrue(speech.sounds[1] is SpeechContainer["_" + i]);
            assertTrue(speech.sounds[2] is SpeechContainer._20);
            assertTrue(speech.sounds[3] is SpeechContainer._point);
            assertTrue(speech.sounds[4] is SpeechContainer["_" + i]);
            assertTrue(speech.sounds[5] is SpeechContainer._20);
            assertTrue(speech.sounds[6] is SpeechContainer._100);
            assertTrue(speech.sounds[7] is SpeechContainer._boat_speed_is_);
            trace("------------------------------")
        }
    }

    //-create new speech, test text segmentation, numbers etc
    //add alarm, change alarm value, check speech
    //add alarm, turn it off
    //add alarm, move actual value to alert
    //add alarm, move actual value to info from alert
    //add alarm, move actual value to not value
    //nodata need to say not valid


}


}
