/**
 * Created by seamantec on 03/04/14.
 */
package com.sailing {
import org.flexunit.asserts.assertEquals;

public class splitTest {

    public function splitTest() {
    }

    [Test]
    public function xTest():void {
        assertEquals(split.withValue(0).x, "0");
        assertEquals(split.withValue(12.36).x, "12");
        assertEquals(split.withValue(-56.336).x, "-56");
        assertEquals(split.withValue(465.45).x, "465");
        assertEquals(split.withValue(4999.99).x, "5000");
        assertEquals(split.withValue(-564897.00).x, "-564897");
        assertEquals(split.withValue(122).x, "122");
        assertEquals(split.withValue(-2).x, "-2");
        assertEquals(split.withValue(-0.45).x, "0");
        assertEquals(split.withValue(-0.99).x, "-1");
    }

    [Test]
    public function a2Test():void {
        assertEquals(split.withValue(0).a2, "0");
        assertEquals(split.withValue(12.36).a2, "12");
        assertEquals(split.withValue(-56.336).a2, "-E");
        assertEquals(split.withValue(465.45).a2, "E");
        assertEquals(split.withValue(-564897.00).a2, "-E");
        assertEquals(split.withValue(122).a2, "E");
        assertEquals(split.withValue(-2).a2, "-2");
        assertEquals(split.withValue(0.99).a2, "0");
        assertEquals(split.withValue(0.49).a2, "0");
        assertEquals(split.withValue(-0.99).a2, "-0");
        assertEquals(split.withValue(-0.49).a2, "-0");
    }

    [Test]
    public function a02Test():void {
        assertEquals(split.withValue(0).a02, "00");
        assertEquals(split.withValue(12.36).a02, "12");
        assertEquals(split.withValue(-56.336).a02, "-E");
        assertEquals(split.withValue(465.45).a02, "E");
        assertEquals(split.withValue(-564897.00).a02, "-E");
        assertEquals(split.withValue(122).a02, "E");
        assertEquals(split.withValue(-2).a02, "-2");
        assertEquals(split.withValue(0.99).a02, "00");
        assertEquals(split.withValue(0.49).a02, "00");
        assertEquals(split.withValue(-0.99).a02, "-0");
        assertEquals(split.withValue(-0.49).a02, "-0");
    }

    [Test]
    public function a3Test():void {
        assertEquals(split.withValue(0).a3, "0");
        assertEquals(split.withValue(12.36).a3, "12");
        assertEquals(split.withValue(-56.336).a3, "-56");
        assertEquals(split.withValue(465.45).a3, "465");
        assertEquals(split.withValue(4465.45).a3, "E");
        assertEquals(split.withValue(-465.45).a3, "-E");
        assertEquals(split.withValue(564897.00).a3, "E");
        assertEquals(split.withValue(-564897.00).a3, "-E");
        assertEquals(split.withValue(122).a3, "122");
        assertEquals(split.withValue(-2).a3, "-2");
        assertEquals(split.withValue(0.99).a3, "0");
        assertEquals(split.withValue(0.49).a3, "0");
        assertEquals(split.withValue(-0.99).a3, "-0");
        assertEquals(split.withValue(-0.49).a3, "-0");
    }

    [Test]
    public function a03Test():void {
        assertEquals(split.withValue(0).a03, "000");
        assertEquals(split.withValue(12.36).a03, "012");
        assertEquals(split.withValue(-56.336).a03, "-56");
        assertEquals(split.withValue(465.45).a03, "465");
        assertEquals(split.withValue(4465.45).a3, "E");
        assertEquals(split.withValue(-465.45).a3, "-E");
        assertEquals(split.withValue(564897.00).a03, "E");
        assertEquals(split.withValue(-564897.00).a03, "-E");
        assertEquals(split.withValue(122).a03, "122");
        assertEquals(split.withValue(-2).a03, "-02");
        assertEquals(split.withValue(0.99).a03, "000");
        assertEquals(split.withValue(0.49).a03, "000");
        assertEquals(split.withValue(-0.99).a03, "-00");
        assertEquals(split.withValue(-0.49).a03, "-00");
    }

    [Test]
    public function a4Test():void {
        assertEquals(split.withValue(0).a4, "0");
        assertEquals(split.withValue(12.36).a4, "12");
        assertEquals(split.withValue(-56.336).a4, "-56");
        assertEquals(split.withValue(465.45).a4, "465");
        assertEquals(split.withValue(4465.45).a4, "4465");
        assertEquals(split.withValue(-465.45).a4, "-465");
        assertEquals(split.withValue(564897.00).a4, "E");
        assertEquals(split.withValue(-564897.00).a4, "-E");
        assertEquals(split.withValue(122).a4, "122");
        assertEquals(split.withValue(-2).a4, "-2");
        assertEquals(split.withValue(0.99).a4, "0");
        assertEquals(split.withValue(0.49).a4, "0");
        assertEquals(split.withValue(-0.99).a4, "-0");
        assertEquals(split.withValue(-0.49).a4, "-0");
    }

    [Test]
    public function a04Test():void {
        assertEquals(split.withValue(0).a04, "0000");
        assertEquals(split.withValue(12.36).a04, "0012");
        assertEquals(split.withValue(-56.336).a04, "-056");
        assertEquals(split.withValue(465.45).a04, "0465");
        assertEquals(split.withValue(4465.45).a04, "4465");
        assertEquals(split.withValue(-465.45).a04, "-465");
        assertEquals(split.withValue(564897.00).a04, "E");
        assertEquals(split.withValue(-564897.00).a04, "-E");
        assertEquals(split.withValue(122).a04, "0122");
        assertEquals(split.withValue(-2).a04, "-002");
        assertEquals(split.withValue(0.99).a04, "0000");
        assertEquals(split.withValue(0.49).a04, "0000");
        assertEquals(split.withValue(-0.99).a04, "-000");
        assertEquals(split.withValue(-0.49).a04, "-000");
    }

    [Test]
    public function a5Test():void {
        assertEquals(split.withValue(0).a5, "0");
        assertEquals(split.withValue(12.36).a5, "12");
        assertEquals(split.withValue(-56.336).a5, "-56");
        assertEquals(split.withValue(465.45).a5, "465");
        assertEquals(split.withValue(4465.45).a5, "4465");
        assertEquals(split.withValue(4999.99).a5, "4999");
        assertEquals(split.withValue(-465.45).a5, "-465");
        assertEquals(split.withValue(64897.00).a5, "64897");
        assertEquals(split.withValue(-4897.91).a5, "-4897");
        assertEquals(split.withValue(564897.00).a5, "E");
        assertEquals(split.withValue(-564897.00).a5, "-E");
        assertEquals(split.withValue(122).a5, "122");
        assertEquals(split.withValue(-2).a5, "-2");
        assertEquals(split.withValue(0.99).a5, "0");
        assertEquals(split.withValue(0.49).a5, "0");
        assertEquals(split.withValue(-0.99).a5, "-0");
        assertEquals(split.withValue(-0.49).a5, "-0");
    }

    [Test]
    public function a05Test():void {
        assertEquals(split.withValue(0).a05, "00000");
        assertEquals(split.withValue(12.36).a05, "00012");
        assertEquals(split.withValue(-56.336).a05, "-0056");
        assertEquals(split.withValue(465.45).a05, "00465");
        assertEquals(split.withValue(4465.45).a05, "04465");
        assertEquals(split.withValue(4999.99).a05, "04999");
        assertEquals(split.withValue(-465.45).a05, "-0465");
        assertEquals(split.withValue(64897.00).a05, "64897");
        assertEquals(split.withValue(-4897.91).a05, "-4897");
        assertEquals(split.withValue(564897.00).a05, "E");
        assertEquals(split.withValue(-564897.00).a05, "-E");
        assertEquals(split.withValue(122).a05, "00122");
        assertEquals(split.withValue(-2).a05, "-0002");
        assertEquals(split.withValue(0.99).a05, "00000");
        assertEquals(split.withValue(0.49).a05, "00000");
        assertEquals(split.withValue(-0.99).a05, "-0000");
        assertEquals(split.withValue(-0.49).a05, "-0000");
    }

    [Test]
    public function _b1Test():void {
        assertEquals(split.withValue(0).b1, "0");
        assertEquals(split.withValue(12.36).b1, "4");
        assertEquals(split.withValue(-56.336).b1, "3");
        assertEquals(split.withValue(465.45).b1, "4");
        assertEquals(split.withValue(4465.45).b1, "4");
        assertEquals(split.withValue(4999.99).b1, "9");
        assertEquals(split.withValue(-465.45).b1, "4");
        assertEquals(split.withValue(64897.00).b1, "0");
        assertEquals(split.withValue(-4897.91).b1, "9");
        assertEquals(split.withValue(564897.00).b1, "0");
        assertEquals(split.withValue(-564897.00).b1, "0");
        assertEquals(split.withValue(122).b1, "0");
        assertEquals(split.withValue(-2).b1, "0");
        assertEquals(split.withValue(0.99).b1, "9");
        assertEquals(split.withValue(0.49).b1, "5");
        assertEquals(split.withValue(-0.99).b1, "9");
        assertEquals(split.withValue(-0.49).b1, "5");
    }

    [Test]
    public function _b2Test():void {
        assertEquals(split.withValue(0).b2, "00");
        assertEquals(split.withValue(12.36).b2, "36");
        assertEquals(split.withValue(-56.336).b2, "34");
        assertEquals(split.withValue(465.45).b2, "45");
        assertEquals(split.withValue(4465.45).b2, "45");
        assertEquals(split.withValue(4999.99).b2, "99");
        assertEquals(split.withValue(-465.45).b2, "45");
        assertEquals(split.withValue(64897.00).b2, "00");
        assertEquals(split.withValue(-4897.91).b2, "91");
        assertEquals(split.withValue(564897.00).b2, "00");
        assertEquals(split.withValue(-564897.00).b2, "00");
        assertEquals(split.withValue(122).b2, "00");
        assertEquals(split.withValue(-2).b2, "00");
        assertEquals(split.withValue(0.99).b2, "99");
        assertEquals(split.withValue(0.49).b2, "49");
        assertEquals(split.withValue(-0.99).b2, "99");
        assertEquals(split.withValue(-0.49).b2, "49");
    }

    [Test]
    public function _b3Test():void {
        assertEquals(split.withValue(0).b3, "000");
        assertEquals(split.withValue(12.361).b3, "361");
        assertEquals(split.withValue(-56.336).b3, "336");
        assertEquals(split.withValue(465.45448).b3, "454");
        assertEquals(split.withValue(4465.45).b3, "450");
        assertEquals(split.withValue(4999.99).b3, "990");
        assertEquals(split.withValue(-465.45).b3, "450");
        assertEquals(split.withValue(64897.00).b3, "000");
        assertEquals(split.withValue(-4897.91).b3, "910");
        assertEquals(split.withValue(564897.00).b3, "000");
        assertEquals(split.withValue(-564897.00).b3, "000");
        assertEquals(split.withValue(122).b3, "000");
        assertEquals(split.withValue(-2).b3, "000");
        assertEquals(split.withValue(0.99).b3, "990");
        assertEquals(split.withValue(0.49).b3, "490");
        assertEquals(split.withValue(-0.99).b3, "990");
        assertEquals(split.withValue(-0.49).b3, "490");
    }

    public function _b4Test():void {
        assertEquals(split.withValue(0).b4, "0000");
        assertEquals(split.withValue(12.361).b4, "3610");
        assertEquals(split.withValue(-56.336).b4, "3360");
        assertEquals(split.withValue(465.45448).b4, "4545");
        assertEquals(split.withValue(4465.45).b4, "4500");
        assertEquals(split.withValue(4999.99).b4, "9900");
        assertEquals(split.withValue(-465.45).b4, "4500");
        assertEquals(split.withValue(64897.00).b4, "0000");
        assertEquals(split.withValue(-4897.91).b4, "9100");
        assertEquals(split.withValue(564897.00).b4, "0000");
        assertEquals(split.withValue(-564897.00).b4, "0000");
        assertEquals(split.withValue(122).b4, "0000");
        assertEquals(split.withValue(-2).b4, "0000");
        assertEquals(split.withValue(0.99).b4, "9900");
        assertEquals(split.withValue(0.49).b4, "4900");
        assertEquals(split.withValue(-0.99).b4, "9900");
        assertEquals(split.withValue(-0.49).b4, "4900");
    }

    public function _b5Test():void {
        assertEquals(split.withValue(0).b5, "00000");
        assertEquals(split.withValue(12.361).b5, "36100");
        assertEquals(split.withValue(-56.336).b5, "33600");
        assertEquals(split.withValue(465.45448).b5, "45448");
        assertEquals(split.withValue(4465.45).b5, "45000");
        assertEquals(split.withValue(4999.99).b5, "99000");
        assertEquals(split.withValue(-465.45).b5, "45000");
        assertEquals(split.withValue(64897.00).b5, "00000");
        assertEquals(split.withValue(-4897.91).b5, "91000");
        assertEquals(split.withValue(564897.00).b5, "00000");
        assertEquals(split.withValue(-564897.00).b5, "00000");
        assertEquals(split.withValue(122).b5, "00000");
        assertEquals(split.withValue(-2).b5, "00000");
        assertEquals(split.withValue(0.99).b5, "99000");
        assertEquals(split.withValue(0.49).b5, "49000");
        assertEquals(split.withValue(-0.99).b5, "99000");
        assertEquals(split.withValue(-0.49).b5, "49000");
    }

    [Test]
    public function combinedTest():void {
        assertEquals(split.withValue(0).a2 + "." + split.instance.b1, "0.0");
        assertEquals(split.withValue(0).a2 + "." + split.instance.b2, "0.00");
        assertEquals(split.withValue(0).a2 + "." + split.instance.b3, "0.000");
        assertEquals(split.withValue(0).a02 + "." + split.instance.b1, "00.0");
        assertEquals(split.withValue(0).a03 + "." + split.instance.b2, "000.00");
        assertEquals(split.withValue(0).a04 + "." + split.instance.b3, "0000.000");
        assertEquals(split.withValue(0).a05 + "." + split.instance.b3, "00000.000");

        assertEquals(split.withValue(12.36).a2 + "." + split.instance.b1, "12.4");
        assertEquals(split.withValue(12.36).a3 + "." + split.instance.b2, "12.36");
        assertEquals(split.withValue(12.36).a4 + "." + split.instance.b3, "12.360");
        assertEquals(split.withValue(12.36).a02 + "." + split.instance.b1, "12.4");
        assertEquals(split.withValue(12.36).a03 + "." + split.instance.b2, "012.36");
        assertEquals(split.withValue(12.36).a04 + "." + split.instance.b3, "0012.360");
        assertEquals(split.withValue(12.36).a05 + "." + split.instance.b3, "00012.360");

        assertEquals(split.withValue(-12.36).a2 + "." + split.instance.b1, "-E.");
        assertEquals(split.withValue(-12.36).a3 + "." + split.instance.b2, "-12.36");
        assertEquals(split.withValue(-12.36).a4 + "." + split.instance.b3, "-12.360");
        assertEquals(split.withValue(-12.36).a02 + "." + split.instance.b1, "-E.");
        assertEquals(split.withValue(-12.36).a03 + "." + split.instance.b2, "-12.36");
        assertEquals(split.withValue(-12.36).a04 + "." + split.instance.b3, "-012.360");
        assertEquals(split.withValue(-12.36).a05 + "." + split.instance.b3, "-0012.360");

        assertEquals(split.withValue(0.9884).a2 + "." + split.instance.b1, "0.9");
        assertEquals(split.withValue(0.9884).a2 + "." + split.instance.b2, "0.99");
        assertEquals(split.withValue(0.9884).a2 + "." + split.instance.b3, "0.988");
        assertEquals(split.withValue(0.9884).a02 + "." + split.instance.b1, "00.9");
        assertEquals(split.withValue(0.9884).a03 + "." + split.instance.b2, "000.99");
        assertEquals(split.withValue(0.9884).a04 + "." + split.instance.b3, "0000.988");
        assertEquals(split.withValue(0.9884).a05 + "." + split.instance.b3, "00000.988");

        assertEquals(split.withValue(-0.9884).a2 + "." + split.instance.b1, "-0.9");
        assertEquals(split.withValue(-0.9884).a2 + "." + split.instance.b2, "-0.99");
        assertEquals(split.withValue(-0.9884).a2 + "." + split.instance.b3, "-0.988");
        assertEquals(split.withValue(-0.9884).a02 + "." + split.instance.b1, "-0.9");
        assertEquals(split.withValue(-0.9884).a03 + "." + split.instance.b2, "-00.99");
        assertEquals(split.withValue(-0.9884).a04 + "." + split.instance.b3, "-000.988");
        assertEquals(split.withValue(-0.9884).a05 + "." + split.instance.b3, "-0000.988");
    }

//    [Test]
//    public function testTest():void {
//        split.setTest();
//        assertEquals(split.instance.a2, "t");
//        assertEquals(split.instance.a3, "t");
//        assertEquals(split.instance.a4, "t");
//        assertEquals(split.instance.a5, "t");
//        assertEquals(split.instance.a01, "t");
//        assertEquals(split.instance.a02, "t");
//        assertEquals(split.instance.a03, "t");
//        assertEquals(split.instance.a04, "t");
//        assertEquals(split.instance.a05, "t");
//        assertEquals(split.instance.b1, "t");
//        assertEquals(split.instance.b2, "t");
//        assertEquals(split.instance.b3, "t");
//    }

}
}
