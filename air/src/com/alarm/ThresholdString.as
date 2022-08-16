/**
 * Created by pepusz on 2014.03.25..
 */
package com.alarm {
public class ThresholdString {
    public var low:String;
    public var medium:String;
    public var high:String;

    public function ThresholdString(high:String="", medium:String="", low:String="") {
        this.low = low;
        this.medium = medium;
        this.high = high;
    }
}
}
