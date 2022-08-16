/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.07.
 * Time: 18:26
 * To change this template use File | Settings | File Templates.
 */
package com.utils {
public class NaiveBinarySearch {


    private var searchArray:* = new Array();
    private var initSize:int;
    private var mid:int;
    private var midValue:Number;
    private var begin:int;
    private var end:int;
    private var flagUp:Boolean = true;
    private var valueIn:Vector.<int> = new Vector.<int>(2, true);

    public function NaiveBinarySearch() {

    }

    public function initByVector(searchVector:Vector.<Number>):void {
        this.searchArray = searchVector;
        initSize = searchVector.length;
    }

    public function initByArray(searchArray:Array):void {
        this.searchArray = searchArray;
        initSize = searchArray.length;
    }

    public function getSmallClosestValue(valueN:Number):int {
        return recursiveBinarySearch(valueN, 0, initSize - 1);
    }

    private function recursiveBinarySearch(valueN:Number, begin:int, end:int):int {
        if (initSize === 0) {
            return -1;
        }
        if (end < begin) {
            if (searchArray[valueIn[0]] > valueN) {
                return valueIn[0] - 1;
            }
            if (searchArray[valueIn[1]] < valueN) {
                return valueIn[1];
            }
            return valueIn[1] - 1;

        }
        mid = int((end + begin) / 2);
        midValue = searchArray[mid];

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
