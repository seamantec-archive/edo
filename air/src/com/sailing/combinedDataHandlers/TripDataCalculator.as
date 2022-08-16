/**
 * Created by seamantec on 02/01/14.
 */
package com.sailing.combinedDataHandlers {
import com.common.Coordinate;
import com.common.TripDataEventHandler;
import com.common.TripDataObject;
import com.sailing.datas.BaseSailData;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.TripData;
import com.utils.CoordinateSystemUtils;

import flash.events.Event;

public class TripDataCalculator extends CombinedData {

    private const STAND:Number = 0.5;

    private var _hasZda:Boolean;

    private var _data:TripData;

    private var _time:Number;
    private var _prevTime:Number;

    private var _prevPosition:Coordinate;
    private var _position:Coordinate;

    private var _enable:Boolean;

    public function TripDataCalculator() {
        dataKey = "tripdata";
        listenerKeys.push("positionandspeed");
        listenerKeys.push("zda");

        _hasZda = false;

        _data = new TripData();

        _time = 0;
        _prevTime = 0;

        TripDataEventHandler.instance.addEventListener("enableTripData", enableHandler, false, 0, true);
        TripDataEventHandler.instance.addEventListener("disableTripData", disableHandler, false, 0, true);

        _enable = true;
    }

    override public function reset():void {
        _data = new TripData();
        lastDatas = new Object();
        _hasZda = false;
        _time = 0;
        _prevTime = 0;
        _enable = true;

    }

    private function enableHandler(e:Event):void {
        _enable = true;
    }

    private function disableHandler(e:Event):void {
        _enable = false;
    }

    override public function calculate(timestamp:Number, key:String):BaseSailData {
        var pas:PositionAndSpeed = lastDatas.positionandspeed;
        if (pas != null && _enable) {
            if (_prevTime == 0) {
                _prevTime = timestamp;
                _prevPosition = new Coordinate(pas.lat, pas.lon);
                if (_data.overall.start == 0) {
                    _data.overall.start = timestamp;
                    _data.overall.utc = false;
                }
                if (_data.user.start == 0) {
                    _data.user.start = timestamp;
                    _data.user.utc = false;
                }
                if (_data.day.start == 0) {
                    _data.day.start = timestamp;
                    _data.day.utc = false;
                }
            }
            if (lastDatas.zda != null && lastDatas.zda.lastTimestamp > 0 && !_hasZda) {
                if (!_data.overall.utc) {
                    _data.overall.start = timestamp - _data.overall.time;
                    _data.overall.utc = true;
                }
                if (!_data.user.utc) {
                    _data.user.start = timestamp - _data.user.time;
                    _data.user.utc = true;
                }
                if (!_data.day.utc) {
                    _data.day.start = timestamp - _data.day.time;
                    _data.day.utc = true;
                }

                _prevTime = timestamp;
                _hasZda = true;
            }

            if (timestamp < _prevTime) {
                _prevTime = timestamp;
            }
            _time = timestamp;

            if ((new Date(_time)).getUTCDate() != (new Date(_prevTime)).getUTCDate()) {
                resetDay();
            }

            _data.overall.i++;
            _data.user.i++;
            _data.day.i++;

            _position = new Coordinate(pas.lat, pas.lon);
            var dist:Number = CoordinateSystemUtils.distanceBetweenTwoPointsInNMI(_prevPosition, _position);
            _data.overall.distance.value += dist;
            _data.user.distance.value += dist;
            _data.day.distance.value += dist;

            var speed:Number = pas.sog.getPureData();
            _data.overall.avg.value = (_data.overall.avg.getPureData() * (_data.overall.i - 1) + speed) / _data.overall.i;
            if (speed > _data.overall.max.getPureData()) {
                _data.overall.max.value = speed;
            }
            _data.user.avg.value = (_data.user.avg.getPureData() * (_data.user.i - 1) + speed) / _data.user.i;
            if (speed > _data.user.max.getPureData()) {
                _data.user.max.value = speed;
            }
            _data.day.avg.value = (_data.day.avg.getPureData() * (_data.day.i - 1) + speed) / _data.day.i;
            if (speed > _data.day.max.getPureData()) {
                _data.day.max.value = speed;
            }

            var time:Number = _time - _prevTime;
            if (speed < STAND) {
                _data.overall.stand += time;
                _data.user.stand += time;
                _data.day.stand += time;
            } else {
                _data.overall.go += time;
                _data.user.go += time;
                _data.day.go += time;
            }

            _data.overall.time += time;
            _data.user.time += time;
            _data.day.time += time;

            _prevTime = _time;
            _prevPosition = _position;
        }

        return _data;
    }


    public function get data():TripData {
        return _data;
    }

    public function get overall():TripDataObject {
        return _data.overall;
    }

    public function set overall(data:TripDataObject):void {
        _data.overall = data;
    }

    public function resetUser():void {
        _data.user = new TripDataObject();
        _data.user.start = _time;
        _data.user.utc = _hasZda;
    }

    public function get user():TripDataObject {
        return _data.user;
    }

    public function set user(data:TripDataObject) {
        _data.user = data;
    }

    private function resetDay():void {
        _data.day = new TripDataObject();
        _data.day.start = _time;
        _data.day.utc = _hasZda;
    }

    public function get day():TripDataObject {
        return _data.day;
    }

    public function set day(data:TripDataObject) {
        _data.day = data;
    }
}
}
