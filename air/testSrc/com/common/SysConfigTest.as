/**
 * Created by seamantec on 07/05/14.
 */
package com.common {

import flash.filesystem.File;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertNull;
import org.flexunit.asserts.assertTrue;

public class SysConfigTest {

    public function SysConfigTest() {
        SysConfig.load(new File("/Users/seamantec/sailing/air/src/configs/sys.xml"));
    }

//    [Test]
//    public function containerTest():void {
//        assertNull(SysConfig.container);
//    }

    [Test]
    public function getBooleanTest():void {
        assertFalse(SysConfig.isNull("debug"));
        assertTrue(SysConfig.getBoolean());

        assertTrue(SysConfig.isNull("blabla"));
        assertFalse(SysConfig.getBoolean());
    }

    [Test]
    public function getBooleanWithoutNullCheckTest():void {
        assertTrue(SysConfig.getBoolean("debug"));

        assertFalse(SysConfig.getBoolean("blabla"));
    }

    [Test]
    public function getNumberTest():void {
        assertFalse(SysConfig.isNull("number.number"));
        assertEquals(SysConfig.getNumber(), 5.2);

        assertTrue(SysConfig.isNull("blabla"));
        assertEquals(SysConfig.getNumber(), 0);
    }

    [Test]
    public function getNumberWithoutNullCheckTest():void {
        assertEquals(SysConfig.getNumber("number.number"), 5.2);

        assertEquals(SysConfig.getNumber("blabla"), 0);
    }

    [Test]
    public function getIntTest():void {
        assertFalse(SysConfig.isNull("number.int"));
        assertEquals(SysConfig.getInt(), -5);

        assertTrue(SysConfig.isNull("blabla"));
        assertEquals(SysConfig.getInt(), 0);
    }

    [Test]
    public function getIntWithoutNullCheckTest():void {
        assertEquals(SysConfig.getInt("number.int"), -5);

        assertEquals(SysConfig.getInt("blabla"), 0);
    }

    [Test]
    public function getUintTest():void {
        assertFalse(SysConfig.isNull("number.uint"));
        assertEquals(SysConfig.getUint(), 5);

        assertTrue(SysConfig.isNull("blabla"));
        assertEquals(SysConfig.getUint(), 0);
    }

    [Test]
    public function getUintWithoutNullCheckTest():void {
        assertEquals(SysConfig.getUint("number.uint"), 5);

        assertEquals(SysConfig.getUint("blabla"), 0);
    }

    [Test]
    public function getStringTest():void {
        assertFalse(SysConfig.isNull("debug"));
        assertEquals(SysConfig.getString(), "true");

        assertFalse(SysConfig.isNull("alarmThresholds.depth.feet.high"));
        trace(SysConfig.getString("alarmThresholds.depth.feet.high"));

        assertTrue(SysConfig.isNull("blabla"));
        assertEquals(SysConfig.getString(), "null");
    }

    [Test]
    public function getStringWithoutNullCheckTest():void {
        assertEquals(SysConfig.getString("debug"), "true");

        assertEquals(SysConfig.getString("blabla"), "null");
    }

    [Test]
    public function getArrayTest():void {
        assertFalse(SysConfig.isNull("datas.data"));
        assertEquals(SysConfig.getArray().length, 3);
        for(var i=0; i<SysConfig.getArray().length; i++) {
            SysConfig.childContainer = SysConfig.getArray()[i];

            assertFalse(SysConfig.childIsNull("a"));
            assertEquals(SysConfig.childGetNumber(), i+1);
            assertFalse(SysConfig.childIsNull("b"));
            assertEquals(SysConfig.childGetNumber(), i+1);
            assertFalse(SysConfig.childIsNull("c"));
            assertEquals(SysConfig.childGetNumber(), i+1);

            assertTrue(SysConfig.childIsNull("e"));
            assertEquals(SysConfig.childGetNumber(), 0);
            assertTrue(SysConfig.childIsNull("f"));
            assertEquals(SysConfig.childGetNumber(), 0);
            assertTrue(SysConfig.childIsNull("g"));
            assertEquals(SysConfig.childGetNumber(), 0);

            assertFalse(SysConfig.childIsNull("x"));
            assertEquals(SysConfig.childGetBoolean(), true);
            assertFalse(SysConfig.childIsNull("y"));
            assertEquals(SysConfig.childGetString(), "adat");
            assertFalse(SysConfig.childIsNull("z"));
            assertEquals(SysConfig.childGetInt(), -(i+1));
        }

        assertTrue(SysConfig.isNull("data"));
        assertEquals(SysConfig.getArray(), null);
    }

    [Test]
    public function getArrayWithoutNullCheckTest():void {
        assertEquals(SysConfig.getArray("datas.data").length, 3);

        assertEquals(SysConfig.getArray("blabla"), null);
    }
}
}
