package com.utils {
import com.loggers.SystemLogger;
import com.sailing.nmeaParser.utils.NmeaInterpreter;

import flash.utils.Dictionary;

public class TimestampCalculator {

    private var messages:Array;
    private var messagesLength:Number;
    private var _actualDate:Date;
    private var _actualTimestamp:Number;
    private var _zdaDate:Date;
    public var lastTimestamp:Number = -2;
    private static var regexp:RegExp = new RegExp(/^..GGA|^..GLL|^..GMP|^..RMC|^..ZDA|^..ZLZ/);
    public static var regexpForKey:RegExp = new RegExp(/gga|gll|gmp|rmc|zda|zlz/);


    /**
     * 1. save actual date, or get it from paramater. This date define the timestamp year, month, day
     * 2. generate timestamp from hour, min, sec parameters
     * 3. ms always 0
     * 4. if old timestamp equal with new timestamp, than return false or something
     * 5.
     * */
    public function TimestampCalculator(messages:Array = null, actualDate:Date = null) {
        if (actualDate == null) {
            this.actualDate = new Date();
        } else {
            this.actualDate = actualDate;
        }
        if (messages == null) {
            this.messages = [];
        } else {
            this.messages = messages;
        }
        messagesLength = this.messages.length;
    }


    public function removeWrongZdas():void {
        reset();
        var zdaContainer:Array = [];
        for (var i:int = 0; i < messagesLength; i++) {
            var localMessage:String = messages[i];
            collectZDAs(localMessage, i, zdaContainer);
        }
        filterOutWrongZdas(zdaContainer)
        setLastTimestamp();
    }

    private function collectZDAs(message:String, index:uint, container:Array):void {
        if (message.match(regexp)) {
            var x:Object = NmeaInterpreter.processWithMessageCode(message);
            if (x != null && x.data != null) {
                if (x.key == "zda") {
                    container.push({index: index, date: x.data.utc})
                }
            }
        }
    }

    private function setLastTimestamp():void {
        reset();
        var message:String = ""
        var x:Object
        var tempTimestamp:Number = 0;
        for (var i:int = 0; i < messagesLength; i++) {
            message = messages[i];
            if (message.match(regexp)) {
                x = NmeaInterpreter.processWithMessageCode(message);
                if (x != null && x.data != null) {
                    if (x.key == "zda") {
                        tempTimestamp = dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec, x.data.utc);
                    } else {
                        tempTimestamp = dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec);
                    }

                    if (tempTimestamp != -1) {
                        lastTimestamp = tempTimestamp;
                    }
                }
            }
        }
    }

    private function filterOutWrongZdas(container:Array):void {
        var separatedByYear:Dictionary = new Dictionary();
        var date:Date;
        for (var i:int = 0; i < container.length; i++) {
            date = container[i].date
            if (separatedByYear[getKeyFromDate(date)] == null) {
                separatedByYear[getKeyFromDate(date)] = [];
            }
            separatedByYear[getKeyFromDate(date)].push(container[i]);
        }
        var dates:Array = [];
        for (var key:String in separatedByYear) {
            dates.push(Date.parse(key));
        }
        var timezoneOffset:Number = new Date().timezoneOffset * 60 * 1000;
        dates.sort(Array.DESCENDING);
        var prevDate:Number = dates[0];
        for (var i:int = 1; i < dates.length; i++) {
            if (prevDate - dates[i] > 24 * 60 * 60 * 1000) {
                removeIndexesFromMessages(separatedByYear[getKeyFromDate(new Date(dates[i] - timezoneOffset))]);
            } else {
                prevDate = dates[i];
            }

        }
    }

    private function removeIndexesFromMessages(indexes:Array):void {
        if (indexes == null) {
            return;
        }
        for (var i:int = 0; i < indexes.length; i++) {
            messages[indexes[i].index] = "";
        }
    }

    private function getKeyFromDate(date:Date):String {
        return date.fullYearUTC + "/" + (date.monthUTC + 1) + "/" + date.dateUTC;
    }

    public function getTimestampFrom(from:Number):Number {
        reset();
        var maxWait:int = Math.floor((messagesLength - from) / 2) + from;
        for (var i:int = from; i < messagesLength; i++) {
            var localMessage:String = messages[i];
            var lTimestamp:Number = getTimestampFromMessage(localMessage, i < maxWait);
            if (lTimestamp != 0) {
                return lTimestamp;
            }
        }
        return 0;
    }

    public function reset():void {
        actualDate = new Date();
        _zdaDate = null;
        _actualTimestamp = null;
    }

    public function getFirstTimestamp():Number {
        reset();
        var timestamp:Number = findFirstZda();
        if (timestamp !== 0) {
            var prevDateFromZda:Date = new Date(timestamp);
            actualDate = new Date(Math.floor(prevDateFromZda.time / 86400000) * 86400000);
            _actualTimestamp = actualDate.time;
        }
        timestamp = findFirstTimestamp();
        return timestamp;
    }

    public function findFirstZda():Number {
        var timestamp:Number = 0
        for (var i:int = 0; i < messagesLength && i < 80000; i++) {
            var localMessage:String = messages[i];
            timestamp = getTimestampFromMessage(localMessage, true);

            if (timestamp != 0) {
                break;
            }
        }
        return timestamp;
    }

    public function findFirstTimestamp():Number {
        var timestamp:Number = 0
        for (var i:int = 0; i < messagesLength; i++) {
            var localMessage:String = messages[i];
            timestamp = getTimestampFromMessage(localMessage, false);
            if (timestamp != 0 && timestamp != -1) {
                break;
            }
        }
        return timestamp;
    }

    public function dateFromNmeaTimestamp(hour:Number, min:Number, sec:Number, date:Date = null):Number {
        if (date != null) {
            if (_zdaDate != null && date < _zdaDate && _zdaDate.time - date.time >= 86400) {  //rossz zda kezelese, ha sokat visszaugrik az idoben akkor dobjuk
                return -1;
            }

            _zdaDate = date;
        }
        var now:Date = actualDate;
        if (date != null) {
            now.setUTCFullYear(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate());
        }
        now.setUTCHours(hour);
        now.setUTCMinutes(min);
        now.setUTCSeconds(sec);
        now.setUTCMilliseconds(0);

        if (now.time < _actualTimestamp) { // && _zdaDate != null
            var diff:Number = (_actualTimestamp - now.time) / 1000;
            //masodperc korrekcio
            if (Math.abs(diff) < 10) {
                return -1; //nincs valtozas
            }
            var d:Date = new Date(_actualTimestamp);
            if (now.getUTCHours() < d.getUTCHours()) {
                var secNow:uint = now.getUTCMinutes() * 60 + now.getUTCSeconds();
                var secD:uint = d.getUTCMinutes() * 60 + d.getUTCSeconds();
                if (Math.abs(secNow - secD) < 3) {
                    SystemLogger.Info("hour jumped: " + now.toUTCString() + "||" + d.toUTCString())
                    now.hoursUTC = d.getUTCHours();
                } else if (date == null) {
                    now.date += 1;  // +1day
                    SystemLogger.Info("Day correction " + now.toUTCString() + "||" + d.toUTCString())
                }
//
            }
        }
        if (now.time != _actualTimestamp) {
            _actualTimestamp = now.time;
            _actualDate = now;
            return now.time;
        } else {
            return -1;
        }
    }

    public static function isKeyHasTimestamp(key:String):Boolean {
        return key.match(regexpForKey);
    }

    private function getTimestampFromMessage(localMessage:String, justZda:Boolean = false):Number {
        if (localMessage.match(regexp)) {
            var x:Object = NmeaInterpreter.processWithMessageCode(localMessage);
            if (x != null && x.data != null) {
                try {
                    if (justZda) {
                        if (x.key == "zda") {
                            return dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec, x.data.utc);
                        }
                        return 0;
                    } else {
                        if (x.key == "zda") {
                            return dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec, x.data.utc);
                        } else {
                            return dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec);
                        }
                    }
                } catch (e:Error) {
                    SystemLogger.Debug("message hasn't timestamp value: " + localMessage + " | " + e.message);
                    return 0;
                }
            }
        }
        return 0;
    }


    public function get actualTimestamp():Number {
        return _actualTimestamp;
    }

    public function set actualTimestamp(value:Number):void {
        _actualTimestamp = value;
    }

    public function get actualDate():Date {
        return _actualDate;
    }

    public function set actualDate(value:Date):void {
        _actualDate = value;
    }
}
}