/**
 * Created by pepusz on 2014.03.25..
 */
package com.alarm {
public class Threshold {
    public static const LOW:uint = 0;
    public static const MEDIUM:uint = 1;
    public static const HIGH:uint = 2;

    private var _thresholdString:ThresholdString;
    private var low:ThresholdContainer;
    private var medium:ThresholdContainer;
    private var high:ThresholdContainer;


    public function Threshold() {
        low = new ThresholdContainer();
        medium = new ThresholdContainer();
        high = new ThresholdContainer();
    }




    public function get thresholdString():ThresholdString {
        return _thresholdString;
    }

    public function set thresholdString(value:ThresholdString):void {
        _thresholdString = value;
    }

    public function parseThresholdStrings():void {
        low.parseThresholdStrings(_thresholdString.low);
        medium.parseThresholdStrings(_thresholdString.medium);
        high.parseThresholdStrings(_thresholdString.high);
    }

    public function getThreshold(actualValue:Number, level:uint):Number {
        switch (level) {
            case LOW:
                return low.getThreshold(actualValue);
            case MEDIUM:
                return medium.getThreshold(actualValue);
            case HIGH:
                return high.getThreshold(actualValue);
        }
        return 0.5;
    }



}
}
