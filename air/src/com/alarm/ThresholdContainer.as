/**
 * Created by pepusz on 2014.03.25..
 */
package com.alarm {
public class ThresholdContainer {
    private var gt:Array = [];
    private var lt:Array = [];
    private var ge:Array = [];
    private var le:Array = [];
    private var eq:Array = [];

    public function ThresholdContainer() {
    }
    private function reset():void{
        gt.length = 0;
        lt.length = 0;
        ge.length = 0;
        le.length = 0;
        eq.length = 0;
    }

    public function parseThresholdStrings(_thresholdString:String):void {
        reset();
        if (_thresholdString == null || _thresholdString === "") {
            return;
        }
        _thresholdString = _thresholdString.replace(/\s+/igm, "");
        var splittedString:Array = _thresholdString.split(";");
        var splittedStringLength:int = splittedString.length;
        for (var i:int = 0; i < splittedStringLength; i++) {
            var s:String = splittedString[i];
            var splittedS:Array = s.split(":");
            var value:Number = new Number(splittedS[1]);
            var limitString:String = splittedS[0].match(/\d+/).toString();
            var limit:Number = new Number(limitString);
            switch (splittedS[0].slice(0, splittedS[0].length - limitString.length)) {
                case ">":
                    gt.push({limit: limit, value: value});
                    break;
                case "<":
                    lt.push({limit: limit, value: value});
                    break;
                case ">=":
                    ge.push({limit: limit, value: value});
                    break;
                case "<=":
                    le.push({limit: limit, value: value});
                    break;
                case "==":
                    eq.push({limit: limit, value: value});
                    break;
            }
        }

        gt.sort(sortOnLimit);
        ge.sort(sortOnLimit);
        le.sort(sortOnLimit);
        lt.sort(sortOnLimit);
        eq.sort(sortOnLimit);

    }

    private function sortOnLimit(a:Object, b:Object):int {
        var x:Number = Number(a.limit);
        var y:Number = Number(b.limit)
        if (x < y) {
            return -1;
        }
        else if (x > y) {
            return 1;
        }
        else {
            return 0;
        }
    }

    public function getThreshold(value:Number):Number {
        var o:Object
        if (gt.length > 0 && value > gt[gt.length - 1].limit) {
            for (var i:int = 0; i < gt.length; i++) {
                o = gt[i];
                if (value > o.limit) {
                    return o.value;
                }
            }
        }
        if (ge.length > 0 && value >= ge[ge.length - 1].limit) {
            for (var i:int = 0; i < ge.length; i++) {
                o = ge[i];
                if (value >= o.limit) {
                    return o.value;
                }
            }
        }
        if (lt.length > 0 && value < lt[lt.length - 1].limit) {
            for (var i:int = 0; i < lt.length; i++) {
                o = lt[i];
                if (value < o.limit) {
                    return o.value;
                }
            }
        }
        if (le.length > 0 && value <= le[le.length - 1].limit) {
            for (var i:int = 0; i < le.length; i++) {
                o = le[i];
                if (value <= o.limit) {
                    return o.value;
                }
            }
        }
        return 0.5;
    }
}
}
