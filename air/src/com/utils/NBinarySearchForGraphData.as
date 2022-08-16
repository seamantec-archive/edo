/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.01.
 * Time: 12:06
 * To change this template use File | Settings | File Templates.
 */
package com.utils {
import com.graphs.GraphData;
import com.graphs.GraphDataContainer;

public class NBinarySearchForGraphData {
    private var initSize:int;
    private var mid:int;
    private var midValue:Number;
    private var begin:int;
    private var end:int;
    private var flagUp:Boolean = true;
    private var valueIn:Vector.<int> = new Vector.<int>(2, true);
    private var _container:GraphDataContainer
    private var index:int;

    public function NBinarySearchForGraphData(container:GraphDataContainer) {
        this._container = container
    }


    public function getSmallClosestValue(valueN:Number):Number {
        initSize = _container.dataProvider.length;
        if (initSize === 0 || isNaN(valueN)) {
            return NaN
        }
        index = recursiveBinarySearch(valueN, 0, initSize - 1);
        if (index >= 0) {
            return _container.dataProvider[index].data;
        } else {
            return NaN
        }
    }

    public function getSmallClosestGraphData(valueN:Number, begin:uint, tolerance:uint):GraphData {
        initSize = _container.dataProvider.length;
//        var startFrom:int = begin - tolerance-100;
//        if (startFrom < 0) {
//            startFrom = 0;
//        }
////        startFrom = 0
//        var end:int =  startFrom + 2 * tolerance + 100;
//        if(end > initSize-1){
//           end = initSize;
//        }
        var startFrom:uint = 0;
        var goTo:uint = initSize-1;
        if (initSize === 0 || isNaN(valueN)) {
            return null
        }
        index = recursiveBinarySearch(valueN, startFrom, goTo);
        if (index >= 0) {
            return _container.dataProvider[index];
        } else {
            return null
        }
    }

    private function recursiveBinarySearch(valueN:Number, begin:int, end:int):int {
        if (initSize === 0 || _container.dataProvider.length < 2) {
            return -1;
        }
        if (end < begin) {
            if (_container.dataProvider[valueIn[0]].timestamp > valueN) {
                return valueIn[0] - 1;
            }
            if (_container.dataProvider[valueIn[1]].timestamp < valueN) {
                return valueIn[1];
            }
            return valueIn[1] - 1;

        }
        mid = int((end + begin) / 2);
        midValue = _container.dataProvider[mid].timestamp;

        if (midValue === valueN) {
            return mid;
        }

        if (midValue > valueN) {
            end = mid - 1;

        } else if (midValue < valueN) {
            begin = mid + 1;

        }

        if (begin < end) {
            valueIn[0] = begin;
            valueIn[1] = end;
        }

        return recursiveBinarySearch(valueN, begin, end);
    }
}
}
