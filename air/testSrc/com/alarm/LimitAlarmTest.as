/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.21.
 * Time: 9:40
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.alarm.speech.Speech;
import com.alarm.speech.SpeechHandler;
import com.sailing.WindowsHandler;
import com.sailing.units.Depth;
import com.sailing.units.UnitHandler;

import flash.utils.getTimer;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class LimitAlarmTest {
    public function LimitAlarmTest() {
    }

    private var alarm:LimitAlarm;

    [Before]
    public function setUp():void {
        var xml:XML = <LimitAlarm>
            <listenerKey>dbt_waterDepth</listenerKey>
            <type>low</type>
            <initAlertLimit>15</initAlertLimit>
            <initInfoLimit>41</initInfoLimit>
            <textLabel>Shallow water</textLabel>
            <severity>warning</severity>
            <sliderStep>2</sliderStep>
            <enabled>false</enabled>
            <speechEnabled>true</speechEnabled>
            <alertEnabled>true</alertEnabled>
        </LimitAlarm>;

        alarm = LimitAlarm.create(xml)
    }


    [Test]
    public function testCreateLimitAlarm():void {
        assertEquals(41, alarm.actualInfoLimit);
        assertEquals(15, alarm.actualAlertLimit);
        assertEquals(Speech.WARNING, alarm.alarmSeverity);

        //assertTrue(alarm.actualValue is Depth)
    }


    [Test]
    public function testAddSiblingAndCheckBinding():void {
        var xml2:XML = <LimitAlarm>
            <listenerKey>dbt_waterDepth</listenerKey>
            <type>high</type>
            <initAlertLimit>60</initAlertLimit>
            <initInfoLimit>42</initInfoLimit>
            <textLabel>Shallow water</textLabel>
            <severity>critical</severity>
            <sliderStep>2</sliderStep>
            <enabled>false</enabled>
            <speechEnabled>true</speechEnabled>
            <alertEnabled>true</alertEnabled>
        </LimitAlarm>;
        var sibling:LimitAlarm = LimitAlarm.create(xml2);
        alarm.siblingAlarm = sibling;
        sibling.siblingAlarm = alarm;

        alarm.actualInfoLimit = 55;
        assertEquals(56, sibling.actualInfoLimit);

        alarm.actualInfoLimit = 70;
        assertEquals(60, sibling.actualInfoLimit);
        assertEquals(59, alarm.actualInfoLimit);

        sibling.actualAlertLimit = 5;
        assertEquals(5, sibling.actualInfoLimit);
        assertEquals(4, alarm.actualInfoLimit);
        assertEquals(4, alarm.actualAlertLimit);

        alarm.actualAlertLimit = 20;
        assertEquals(21, sibling.actualInfoLimit);
        assertEquals(21, sibling.actualAlertLimit);
        assertEquals(20, alarm.actualInfoLimit);
        assertEquals(20, alarm.actualAlertLimit);
    }


    [Test]
    public function testSiblingHighLow():void {
        var xml2:XML = <LimitAlarm>
            <listenerKey>dbt_waterDepth</listenerKey>
            <type>low</type>
            <initAlertLimit>5</initAlertLimit>
            <initInfoLimit>10</initInfoLimit>
            <textLabel>Shallow water</textLabel>
            <severity>critical</severity>
            <sliderStep>2</sliderStep>
            <enabled>false</enabled>
            <speechEnabled>true</speechEnabled>
            <alertEnabled>true</alertEnabled>
        </LimitAlarm>;

        alarm.alarmType = LimitAlarm.HIGH;

        var sibling:LimitAlarm = LimitAlarm.create(xml2);
        alarm.siblingAlarm = sibling;
        sibling.siblingAlarm = alarm;


        alarm.actualAlertLimit = 50;
        alarm.actualInfoLimit = 40;

        sibling.actualAlertLimit = 10;
        sibling.actualInfoLimit = 20;

        assertEquals(50, alarm.actualAlertLimit);
        assertEquals(40, alarm.actualInfoLimit);
        assertEquals(10, sibling.actualAlertLimit);
        assertEquals(20, sibling.actualInfoLimit);


        alarm.actualInfoLimit = 15;
        assertEquals(14, sibling.actualInfoLimit);

        sibling.actualInfoLimit = 45;
        assertEquals(45, sibling.actualInfoLimit);
        assertEquals(46, alarm.actualInfoLimit);

        sibling.actualAlertLimit = 55;
        assertEquals(55, sibling.actualInfoLimit);
        assertEquals(56, alarm.actualInfoLimit);
        assertEquals(56, alarm.actualAlertLimit);

        alarm.actualAlertLimit = 20;
        assertEquals(19, sibling.actualInfoLimit);
        assertEquals(19, sibling.actualAlertLimit);
        assertEquals(20, alarm.actualInfoLimit);
        assertEquals(20, alarm.actualAlertLimit);

    }


    [Test]
    public function testTestActualValue():void {
        //-set actual value, check is in alert, isininfo
        alarm.actualInfoLimit = 50;
        alarm.actualAlertLimit = 20;
        assertFalse(alarm.isInInfo());   //not valid
        assertFalse(alarm.isInAlert());  //not valid
        WindowsHandler.instance.actualSailData.dbt.lastTimestamp = getTimer(); //set value valid
        alarm.actualValue = 30;
        assertTrue(alarm.isInInfo());
        assertFalse(alarm.isInAlert());
        alarm.actualValue = 10;
        assertTrue(alarm.isInInfo());
        assertTrue(alarm.isInAlert());
    }


    [Test]
    public function testTurnOff():void {
        //-turn off, actual value set check is not in container, etc
        alarm.enabled = false;
        alarm.actualInfoLimit = 50;
        alarm.actualAlertLimit = 20;
        WindowsHandler.instance.actualSailData.dbt.lastTimestamp = getTimer(); //set value valid
        alarm.actualValue = 10;
        assertEquals(0, SpeechHandler.instance.speeches.length)
    }


    [Test]
    public function testChangeUnit():void {
        alarm.actualInfoLimit = 50;
        alarm.actualAlertLimit = 21;
        WindowsHandler.instance.actualSailData.dbt.lastTimestamp = getTimer();
        alarm.actualValue = 10;
        alarm.lastSaidValue = 5;

        var depthUnit:Depth = new Depth();

        UnitHandler.instance.depth = Depth.FEET;
        alarm.unitChanged(Depth);
        assertEquals(int(depthUnit.convertNumber(50)), alarm.actualInfoLimit)
        assertEquals(Math.round(depthUnit.convertNumber(21)), alarm.actualAlertLimit)
        assertEquals(Math.round(depthUnit.convertNumber(10) * 1000) / 1000, alarm.actualValue)
        assertEquals(Math.round(depthUnit.convertNumber(5)), alarm.lastSaidValue)
        assertEquals(depthUnit.getThreshold(), alarm.listenerKey.threshold.thresholdString)
        UnitHandler.instance.depth = Depth.METER;
    }

    /**
     * switch (UnitHandler.instance.depth) {
                  case Depth.METER:
                      return "<2:0.1;<10:0.5;<20:1;<40:5;>=40:5"
                      break;
                  case Depth.FEET:
                      return"<2:0.1;<10:0.5;<20:1;<40:5;>=40:10"
                      break;
                  case Depth.FATHOM:
                      return "<2:0.1;<10:0.5;<20:1;<40:5;>=40:10";
                      break;
              }
     *
     * */
    [Test]
    public function testChangeActualValueCheckThreshold():void {
        WindowsHandler.instance.actualSailData.dbt.lastTimestamp = getTimer();
        alarm.enabled = true;
        alarm.actualInfoLimit = 50;
        alarm.actualAlertLimit = 21;
        alarm.actualValue = 60;
        assertEquals(0, SpeechHandler.instance.speeches.length);
        alarm.actualValue = 51;
        assertEquals(0, SpeechHandler.instance.speeches.length);
        alarm.actualValue = 50.5;
        assertEquals(0, SpeechHandler.instance.speeches.length);
        alarm.actualValue = 50;
        assertEquals(1, AlarmHandler.instance.infoContainer.length);
        assertEquals(0, AlarmHandler.instance.alertsContainer.length);
        alarm.actualValue = 49.5;
        assertEquals(1, AlarmHandler.instance.infoContainer.length);
        assertEquals(0, AlarmHandler.instance.alertsContainer.length);
        alarm.actualValue = 47.5;
        assertEquals(1, AlarmHandler.instance.infoContainer.length);
        assertEquals(0, AlarmHandler.instance.alertsContainer.length);

        alarm.actualValue = 60;
        assertEquals(0, AlarmHandler.instance.infoContainer.length);
        assertEquals(0, AlarmHandler.instance.alertsContainer.length);

        alarm.actualValue = 20;
        assertEquals(1, AlarmHandler.instance.infoContainer.length);
        assertEquals(1, AlarmHandler.instance.alertsContainer.length);
    }

//-change unit, do all tests
    //-check thresholds, create changes and check is triggered
    //-change unit and check it again
    //-check minmaxes


}
}
