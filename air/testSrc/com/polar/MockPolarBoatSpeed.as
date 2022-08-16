/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.30.
 * Time: 13:46
 * To change this template use File | Settings | File Templates.
 */
package com.polar {
public class MockPolarBoatSpeed extends PolarBoatSpeed {
    public var _measured:Number

    public function MockPolarBoatSpeed(windSpeed:uint) {
        super(windSpeed);
    }

    public override function get measured():Number {
        return _measured;
    }


    override public function setMax(number:Number):void {
       calculateRatio()
    }
}
}
