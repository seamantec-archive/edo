/**
 * Created by pepusz on 2014.04.10..
 */
package com.polar {
public class PolarDataWindLayer {
    public static const MAX_BOAT_SPEED:uint = 30;
    public static const MAX_POINTS_IN_CELL:uint = 10;
    private var _container:Vector.<Vector.<uint>>;
    private var _maxSpeed:Number = 0;

    public function PolarDataWindLayer() {
        initLayer();
    }

    private function initLayer():void {
        _container = new Vector.<Vector.<uint>>(360, true);
        for (var angle:int = 0; angle < 360; angle++) {
            _container[angle] = new Vector.<uint>(MAX_BOAT_SPEED * 10 + 1, true);
            for (var boatSpeed:int = 0; boatSpeed <= MAX_BOAT_SPEED * 10; boatSpeed++) {
                _container[angle][boatSpeed] = 0;
            }
        }
    }

    public function addPolarData(polarData:PolarData):void {
        var boatSpeed:uint = Math.floor(polarData.boatSpeed * 10);
        var windAngle:uint = polarData.windDir < 0 ? Math.floor(360 + polarData.windDir) : Math.floor(polarData.windDir);
        if (polarData.boatSpeed > _maxSpeed) {
            _maxSpeed = polarData.boatSpeed;
        }
        if (_container[windAngle][boatSpeed] < MAX_POINTS_IN_CELL) {
            _container[windAngle][boatSpeed]++;
        }
    }

    public function nullifyAllData():void {
        for (var angle:int = 0; angle < 360; angle++) {
            for (var boatSpeed:int = 0; boatSpeed <= MAX_BOAT_SPEED * 10; boatSpeed++) {
                _container[angle][boatSpeed] = 0;
            }
        }
        _maxSpeed = 0
    }

    public function clearAllData():void {
        for (var angle:int = 0; angle < 360; angle++) {
            _container[angle] = null;
        }
        _container = null;
        _maxSpeed = 0
    }

    public function mergeOther(other:PolarDataWindLayer):int {
        var count:int = 0;
        for (var angle:int = 0; angle < 360; angle++) {
            for (var boatSpeed:int = 0; boatSpeed <= MAX_BOAT_SPEED * 10; boatSpeed++) {
                if(other.container[angle][boatSpeed]!=0) {
                    _container[angle][boatSpeed] += other.container[angle][boatSpeed];
                    if ((boatSpeed/10) > _maxSpeed) {
                        _maxSpeed = (boatSpeed/10);
                    }
                    if (_container[angle][boatSpeed] > 10) {
                        _container[angle][boatSpeed] = 10;
                    }
                    count++;
                }
            }
        }
        return count;
    }

    public function getMaxSpeedForAngle(angle:int):Number {
        var i:int = MAX_BOAT_SPEED*10;
        while(i>=0) {
            if(_container[angle][i]>=3) {
                return i/10;
            }
            i--;
        }

        return 0;
    }


    public function get container():Vector.<Vector.<uint>> {
        return _container;
    }


    public function set container(value:Vector.<Vector.<uint>>):void {
        _container = value;
    }


    public function set maxSpeed(value:Number):void {
        _maxSpeed = value;
    }

    public function get maxSpeed():Number {
        return _maxSpeed;
    }
}
}
