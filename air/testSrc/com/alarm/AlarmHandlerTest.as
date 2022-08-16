/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.15.
 * Time: 17:35
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import com.sailing.WindowsHandler;
import com.sailing.datas.Dbt;

import flash.filesystem.File;
import flash.utils.getTimer;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertNull;

public class AlarmHandlerTest {
    var dbt:Dbt = new Dbt();

    public function AlarmHandlerTest() {
    }

    [Before]
    public function setUp():void {
        AlarmHandler.instance.importAlarms();
    }

    [After]
    public function tearDown():void {
        File.applicationStorageDirectory.deleteDirectory(true);
    }

    [Test]
    public function testSailDataChanged():void {
        dbt.waterDepth.value = 10;
        AlarmHandler.instance.sailDataChanged("dbt", dbt);
    }


    [Test]
    public function testDisableAll():void {
        for (var i:int = 0; i < AlarmHandler.instance.orderedAlarms.length; i++) {
            var alarm:Alarm = AlarmHandler.instance.alarms[AlarmHandler.instance.orderedAlarms[i]];
            alarm.enabled = false;
        }
        assertEquals(0, AlarmHandler.instance.activeAlarmCounter);
        assertEquals(0, AlarmHandler.instance.alertsContainer.length)
        assertEquals(0, AlarmHandler.instance.infoContainer.length)
    }


    [Test]
    public function testEnableOne():void {
        for (var i:int = 0; i < AlarmHandler.instance.orderedAlarms.length; i++) {
            var alarm:Alarm = AlarmHandler.instance.alarms[AlarmHandler.instance.orderedAlarms[i]];
            alarm.enabled = false;
        }
        var alarm:Alarm = AlarmHandler.instance.alarms[AlarmHandler.instance.orderedAlarms[0]];
        alarm.enabled = true;
        assertEquals(1, AlarmHandler.instance.activeAlarmCounter);
        assertEquals(0, AlarmHandler.instance.alertsContainer.length)
        assertEquals(0, AlarmHandler.instance.infoContainer.length)
    }

    [Test]
    public function testEnableOneLimitAlarm():void {
        for (var i:int = 0; i < AlarmHandler.instance.orderedAlarms.length; i++) {
            var alarm:Alarm = AlarmHandler.instance.alarms[AlarmHandler.instance.orderedAlarms[i]];
            alarm.enabled = false;
        }

        var alarm:Alarm
        for (var i:int = 0; i < AlarmHandler.instance.orderedAlarms.length; i++) {
            alarm = AlarmHandler.instance.alarms[AlarmHandler.instance.orderedAlarms[i]];
            if (alarm is LimitAlarm && alarm.alarmType === LimitAlarm.LOW) {
                break;
            }
        }
        WindowsHandler.instance.actualSailData[alarm.listenerKey.key].lastTimestamp = getTimer(); //set value valid
        alarm.actualValue = alarm.actualAlertLimit - 5;
        alarm.enabled = true;
        assertEquals(1, AlarmHandler.instance.activeAlarmCounter);
        assertEquals(1, AlarmHandler.instance.alertsContainer.length);
        assertEquals(1, AlarmHandler.instance.infoContainer.length);
        alarm.actualInfoLimit = alarm.actualAlertLimit + 5;
        alarm.actualValue = alarm.actualAlertLimit + 1;
        assertEquals(1, AlarmHandler.instance.activeAlarmCounter);
        assertEquals(0, AlarmHandler.instance.alertsContainer.length);
        assertEquals(1, AlarmHandler.instance.infoContainer.length);

        alarm.actualValue = alarm.actualInfoLimit + 1;
        assertEquals(1, AlarmHandler.instance.activeAlarmCounter);
        assertEquals(0, AlarmHandler.instance.alertsContainer.length);
        assertEquals(0, AlarmHandler.instance.infoContainer.length);
    }


    [Test]
    public function testAlertCounterAddRemove():void {
        for (var i:int = 0; i < AlarmHandler.instance.orderedAlarms.length; i++) {
            var alarm:Alarm = AlarmHandler.instance.alarms[AlarmHandler.instance.orderedAlarms[i]];
            alarm.enabled = false;
        }

        var alarm:Alarm;
        for (var i:int = 0; i < AlarmHandler.instance.orderedAlarms.length; i++) {
            if (i === 8) {
                break;
            }
            alarm = AlarmHandler.instance.alarms[AlarmHandler.instance.orderedAlarms[i]];
            WindowsHandler.instance.actualSailData[alarm.listenerKey.key].lastTimestamp = getTimer()
            alarm.enabled = true;
            if (alarm.alarmType === LimitAlarm.LOW) {
                alarm.actualAlertLimit = 10
                alarm.actualValue = 8;
            } else {
                alarm.actualAlertLimit = 20
                alarm.actualValue = 30;
            }

        }

        assertEquals(8, AlarmHandler.instance.alertsContainer.length);

        for (var i:int = 0; i < AlarmHandler.instance.orderedAlarms.length; i++) {
            alarm = AlarmHandler.instance.alarms[AlarmHandler.instance.orderedAlarms[i]];
            if (alarm.enabled) {
                if (alarm.alarmType === LimitAlarm.LOW) {
                    alarm.actualValue = 12
                } else {
                    alarm.actualValue = 18
                }
            }
        }
        assertEquals(0, AlarmHandler.instance.alertsContainer.length);

    }

//    [Test]
//    public function testOverrideXmlElement():void {
//        var xml1:XML = <alarms>
//            <LimitAlarm>
//                <listenerKey>dbt_waterDepth</listenerKey>
//                <type>low</type>
//                <initAlertLimit>15</initAlertLimit>
//                <initInfoLimit>39</initInfoLimit>
//                <textLabel>Not deep water</textLabel>
//                <severity>critical</severity>
//                <sliderStep>2</sliderStep>
//                <enabled>false</enabled>
//                <speechEnabled>true</speechEnabled>
//                <alertEnabled>true</alertEnabled>
//            </LimitAlarm>
//        </alarms>
//        var alarmHandler:AlarmHandler = AlarmHandler.instance;
//        assertEquals(14, alarmHandler.orderedAlarms.length);
//        assertEquals("Shallow water", alarmHandler.alarms[alarmHandler.orderedAlarms[0]].textLabel);
//
//        alarmHandler.loadXML(xml1);
//
//        assertEquals(14, alarmHandler.orderedAlarms.length);
//        assertEquals("Not deep water", alarmHandler.alarms[alarmHandler.orderedAlarms[0]].textLabel);
//
//    }
//    [Test]
//    public function testOverrideAnchorElement():void {
//        var xml1:XML = <alarms>
//            <AnchorAlarm>
//               <listenerKey>anchor</listenerKey>
//               <type>high</type>
//               <initAlertLimit>150</initAlertLimit>
//               <initInfoLimit>150</initInfoLimit>
//               <textLabel>new Anchor</textLabel>
//               <severity>info</severity>
//               <sliderStep>1</sliderStep>
//               <enabled>false</enabled>
//               <speechEnabled>true</speechEnabled>
//               <alertEnabled>true</alertEnabled>
//             </AnchorAlarm>
//        </alarms>
//        var alarmHandler:AlarmHandler = AlarmHandler.instance;
//        assertEquals(15, alarmHandler.orderedAlarms.length);
//        assertEquals("Anchor", alarmHandler.alarms[alarmHandler.orderedAlarms[12]].textLabel);
//
//        alarmHandler.loadXML(xml1);
//
//        assertEquals(15, alarmHandler.orderedAlarms.length);
//        assertEquals("new Anchor", alarmHandler.alarms[alarmHandler.orderedAlarms[12]].textLabel);
//
//    }
//    [Test]
//    public function testTryToOverrideSameNameAndTypeButDifferentClassElement():void {
//        var xml1:XML = <alarms>
//            <LimitAlarm>
//               <listenerKey>rmc.gpsSog</listenerKey>
//               <type>high</type>
//               <initAlertLimit>150</initAlertLimit>
//               <initInfoLimit>150</initInfoLimit>
//               <textLabel>Gpssog</textLabel>
//               <severity>info</severity>
//               <sliderStep>1</sliderStep>
//               <enabled>false</enabled>
//               <speechEnabled>true</speechEnabled>
//               <alertEnabled>true</alertEnabled>
//             </AnchorAlarm>
//        </alarms>
//        var alarmHandler:AlarmHandler = AlarmHandler.instance;
//        assertEquals(15, alarmHandler.orderedAlarms.length);
//        assertEquals("Anchor", alarmHandler.alarms[alarmHandler.orderedAlarms[12]].textLabel);
//
//        alarmHandler.loadXML(xml1);
//
//        assertEquals(16, alarmHandler.orderedAlarms.length);
//        assertEquals("Anchor", alarmHandler.alarms[alarmHandler.orderedAlarms[12]].textLabel);
//        assertEquals("Gpssog", alarmHandler.alarms[alarmHandler.orderedAlarms[15]].textLabel);
//
//    }
//     //TODO test add new name same key but different alarm class
//    [Test]
//    public function testAddsameElementXml():void {
//        var xml1:XML = <alarms>
//            <LimitAlarm>
//                <listenerKey>dbt_waterDepth</listenerKey>
//                <type>low</type>
//                <initAlertLimit>15</initAlertLimit>
//                <initInfoLimit>39</initInfoLimit>
//                <textLabel>Shallow water</textLabel>
//                <severity>critical</severity>
//                <sliderStep>2</sliderStep>
//                <enabled>false</enabled>
//                <speechEnabled>true</speechEnabled>
//                <alertEnabled>true</alertEnabled>
//            </LimitAlarm>
//        </alarms>
//        var alarmHandler:AlarmHandler = AlarmHandler.instance;
//        assertEquals(14, alarmHandler.orderedAlarms.length);
//        assertEquals("Shallow water", alarmHandler.alarms[alarmHandler.orderedAlarms[0]].textLabel);
//
//        alarmHandler.loadXML(xml1);
//
//        assertEquals(14, alarmHandler.orderedAlarms.length);
//        assertEquals("Shallow water", alarmHandler.alarms[alarmHandler.orderedAlarms[0]].textLabel);
//    }
//
//    [Test]
//    public function testAddNewElementXml():void {
//        var xml1:XML = <alarms>
//            <LimitAlarm>
//                <listenerKey>dbt_waterDepth</listenerKey>
//                <type>high</type>
//                <initAlertLimit>40</initAlertLimit>
//                <initInfoLimit>40</initInfoLimit>
//                <textLabel>Deep water</textLabel>
//                <severity>info</severity>
//                <sliderStep>2</sliderStep>
//                <enabled>false</enabled>
//                <speechEnabled>true</speechEnabled>
//                <alertEnabled>true</alertEnabled>
//            </LimitAlarm>
//        </alarms>
//        var alarmHandler:AlarmHandler = AlarmHandler.instance;
//        assertEquals(14, alarmHandler.orderedAlarms.length);
//        assertEquals("Ais", alarmHandler.alarms[alarmHandler.orderedAlarms[13]].textLabel);
//
//        alarmHandler.loadXML(xml1);
//
//        assertEquals(15, alarmHandler.orderedAlarms.length);
//        assertEquals("Deep water", alarmHandler.alarms[alarmHandler.orderedAlarms[14]].textLabel);
//    }

    [Test]
    public function testLoadConfigAlarmNoSavedAlarms():void {
        var alarmHandler:AlarmHandler = AlarmHandler.instance;
        assertEquals(15, alarmHandler.orderedAlarms.length);
        assertEquals("1", alarmHandler.xmlVersion);
    }

    [Test]
    public function testAddedNewElementToPredef():void {
        var xml1:XML = <alarms>
            <version>1</version>
            <LimitAlarm>
                <uuid>uuid1</uuid>
                <listenerKey>dbt_waterDepth</listenerKey>
                <type>high</type>
                <initAlertLimit>40</initAlertLimit>
                <initInfoLimit>40</initInfoLimit>
                <textLabel>Deep water</textLabel>
                <severity>info</severity>
                <sliderStep>2</sliderStep>
                <enabled>false</enabled>
                <speechEnabled>true</speechEnabled>
                <alertEnabled>true</alertEnabled>
            </LimitAlarm>
            <LimitAlarm>
                <uuid>uuid2</uuid>
                <listenerKey>dbt_waterDepth</listenerKey>
                <type>high</type>
                <initAlertLimit>40</initAlertLimit>
                <initInfoLimit>40</initInfoLimit>
                <textLabel>Deep water</textLabel>
                <severity>info</severity>
                <sliderStep>2</sliderStep>
                <enabled>false</enabled>
                <speechEnabled>true</speechEnabled>
                <alertEnabled>true</alertEnabled>
            </LimitAlarm>
        </alarms>
        var alarmHandler:AlarmHandler = AlarmHandler.instance;
        alarmHandler.loadXML(xml1);
    }

    [Test]
    public function testGetXMLByChild():void {
        var alarmHandler:AlarmHandler = AlarmHandler.instance;
        var xml1:XML = <alarms>
            <version>1</version>
            <LimitAlarm>
                <uuid>uuid1</uuid>
                <listenerKey>dbt_waterDepth</listenerKey>
                <type>high</type>
                <initAlertLimit>40</initAlertLimit>
                <initInfoLimit>40</initInfoLimit>
                <textLabel>Deep water</textLabel>
                <severity>info</severity>
                <sliderStep>2</sliderStep>
                <enabled>false</enabled>
                <speechEnabled>true</speechEnabled>
                <alertEnabled>true</alertEnabled>
            </LimitAlarm>
            <LimitAlarm>
                <uuid>uuid2</uuid>
                <listenerKey>dbt_waterDepth</listenerKey>
                <type>high</type>
                <initAlertLimit>40</initAlertLimit>
                <initInfoLimit>40</initInfoLimit>
                <textLabel>Deep water</textLabel>
                <severity>info</severity>
                <sliderStep>2</sliderStep>
                <enabled>false</enabled>
                <speechEnabled>true</speechEnabled>
                <alertEnabled>true</alertEnabled>
            </LimitAlarm>
        </alarms>
        var uuid1:XML = alarmHandler.getXMLChildByUUID("uuid1", xml1);
        assertEquals("dbt_waterDepth", uuid1.listenerKey.text());
        assertNull(alarmHandler.getXMLChildByUUID("uuid3", xml1));
        assertNull(alarmHandler.getXMLChildByUUID("uuid1", null));
        assertNull(alarmHandler.getXMLChildByUUID(null, xml1));
    }

    [Test]
    public function mergeTwoXML():void {
        var xml1:XML = <LimitAlarm>
            <uuid>uuid1</uuid>
            <listenerKey>dbt_waterDepth</listenerKey>
            <type>high</type>
            <initAlertLimit>40</initAlertLimit>
            <initInfoLimit>40</initInfoLimit>
            <textLabel>Deep water</textLabel>
            <severity>info</severity>
            <sliderStep>2</sliderStep>
            <enabled>false</enabled>
            <speechEnabled>true</speechEnabled>
            <alertEnabled>true</alertEnabled>
        </LimitAlarm>
        var xml2:XML = <LimitAlarm>
            <uuid>uuid1</uuid>
            <listenerKey>dbt_waterDepth</listenerKey>
            <type>high</type>
            <initAlertLimit>30</initAlertLimit>
            <initInfoLimit>15</initInfoLimit>
            <textLabel>Deep water</textLabel>
            <severity>info</severity>
            <sliderStep>2</sliderStep>
            <enabled>true</enabled>
            <speechEnabled>true</speechEnabled>
            <alertEnabled>true</alertEnabled>
        </LimitAlarm>
        var alarmHandler:AlarmHandler = AlarmHandler.instance;
        alarmHandler.mergeXml2IntoXml1(xml1, xml2);
        assertEquals(30,xml1.initAlertLimit.text())
        assertEquals(15,xml1.initInfoLimit.text())
        assertEquals("true",xml1.enabled.text())


    }

    //load xml has config and saved one but the same
    //load xml has config but changed (added new element)
    //load xml has config but changed (one element name changed)

}
}
