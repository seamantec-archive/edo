/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.10.28.
 * Time: 12:51
 * To change this template use File | Settings | File Templates.
 */
package com.polar {
public class PolarBoatSpeed {
    public var calculated:Number = 0;
    public var cubicCalculated:Number = 0;
    public var cardinalCalculated:Number = 0;
    public var cardinalMediumCalculated:Number = 0;
    public var cardinalHardCalculated:Number = 0;
    public var catmullRomCalculated:Number = 0;
    public var hermiteCalculated:Number = 0;
    public var baseCalculated:Number = 0;
    public static const SPEED_THRESHOLD:Number = 0.3
    private var _lastThreeMax:Vector.<MaxBoatSpeed> = new Vector.<MaxBoatSpeed>(3, true);
    public var windBoatRatio:Number = 0;
    public var windBoatRatioInterpolated:Number = 0;
    private var windSpeed:uint = 0;
    public var isFromFile:Boolean = false;
    public var combinedMeasured:Number = 0;
    public var horizontalInterpolated:Number = 0;
    public var verticalInterpolated:Number = 0;
    public var combinedInterpolated:Number = 0;


    public function PolarBoatSpeed(windSpeed:uint) {
        this.windSpeed = windSpeed;
    }

    public function get measured():Number {
        if (isFromFile) {
            return baseCalculated;
        } else {
            for (var i:int = 0; i < 3; i++) {
                if (_lastThreeMax[i] != null && _lastThreeMax[i].numberOfPoints > 2) {
                    return _lastThreeMax[i].measured;
                }
            }
        }
        return 0;
    }

    public function setMax(number:Number):void {
        if (_lastThreeMax[0] === null) {
            _lastThreeMax[0] = new MaxBoatSpeed();
            _lastThreeMax[1] = new MaxBoatSpeed();
            _lastThreeMax[2] = new MaxBoatSpeed();
        }
        if (_lastThreeMax[0].measured < number) {
            _lastThreeMax[2] = _lastThreeMax[1];
            _lastThreeMax[1] = _lastThreeMax[0];
            _lastThreeMax[0] = new MaxBoatSpeed();
            _lastThreeMax[0].measured = number;
            _lastThreeMax[0].numberOfPoints = 0;
        } else if (_lastThreeMax[1].measured < number) {
            _lastThreeMax[2] = _lastThreeMax[1];
            _lastThreeMax[1] = new MaxBoatSpeed();
            _lastThreeMax[1].measured = number;
            _lastThreeMax[1].numberOfPoints = 0;
        } else if (_lastThreeMax[2].measured < number) {
            _lastThreeMax[2].measured = number;
            _lastThreeMax[2].numberOfPoints = 0;
        }

        for (var i:int = 0; i < 3; i++) {
            var m:MaxBoatSpeed = _lastThreeMax[i];
            if ((m.measured - SPEED_THRESHOLD) < number && (m.measured + SPEED_THRESHOLD) > number) {
                m.numberOfPoints++;
            }
        }
        calculateRatio();
    }

    public function setMaxFromOtherPolar(number:Number):void {
        if (_lastThreeMax[0] === null) {
            _lastThreeMax[0] = new MaxBoatSpeed();
            _lastThreeMax[1] = new MaxBoatSpeed();
            _lastThreeMax[2] = new MaxBoatSpeed();
        }
        if (measured < number) {
            _lastThreeMax[0].measured = number;
            _lastThreeMax[0].numberOfPoints = 3;
        }
    }

    public function calculateRatio():void {
        windBoatRatio = measured / windSpeed;
    }

    public function get lastThreeMax():Vector.<MaxBoatSpeed> {
        return _lastThreeMax;
    }
}
}
