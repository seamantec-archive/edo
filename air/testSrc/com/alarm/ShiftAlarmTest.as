/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 9/14/13
 * Time: 3:09 PM
 * To change this template use File | Settings | File Templates.
 */
package com.alarm {
import org.flexunit.asserts.assertEquals;

public class ShiftAlarmTest {
    public function ShiftAlarmTest() {
    }

    [Test]
    public function testDegreechange():void {
        assertEquals(diffOneWay(340,345),5);
        assertEquals(diffOneWay(340,310),330);
        assertEquals(diffOneWay(340,1),21);
        assertEquals(diffOneWay(1,340),339);
        assertEquals(diffOneWay(1,180),179);
        assertEquals(diffOneWay(180,90),270);
        assertEquals(diffOneWay(90,180),90);
    }[Test]
    public function testRelativeDiff():void {
        assertEquals(realtiveDiff(340,345),5);
        assertEquals(realtiveDiff(340,310),30);
        assertEquals(realtiveDiff(340,1),21);
        assertEquals(realtiveDiff(1,340),21);
        assertEquals(realtiveDiff(1,180),179);
        assertEquals(realtiveDiff(180,90),90);
        assertEquals(realtiveDiff(90,180),90);
    }

    private function diffOneWay(n1:Number, n2:Number):Number{
       if(n1 < n2){
           return n2-n1;
       }
       if(n2<n1){
           return 360-n1+n2;
       }
       return 0;
    }

    private function realtiveDiff(n1, n2):Number{
        var x:Number = Math.abs(n1-n2);
        if(x <= 180){
            return x;
        }else{
            return 360-x;
        }
    }
}
}
