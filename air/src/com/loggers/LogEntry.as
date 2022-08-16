/**
 * Created by pepusz on 2014.05.13..
 */
package com.loggers {
public class LogEntry {
    public var id:Number = -1;
    public var path:String;
    public var name:String;
    public var md5:String;
    public var maxLineCounter:Number = 0;
    public var lineCounter:Number = 0;
    public var firstTimestamp:Number = 0;
    public var lastTimestamp:Number= 0;
    public var maxNumberOfSegments:Number= 0;
    public var numberOfSegments:Number= 0;
    public var windCorrection:Number;

    public static function parseSqlResult(result:Object):LogEntry {
        if (result === null) {
            return null;
        }
        var entry:LogEntry = new LogEntry();
        entry.id = Number(result.id);
        entry.path = result.path;
        entry.name = result.name;
        entry.lineCounter = Number(result.line_counter);
        entry.maxLineCounter = Number(result.max_line_counter);
        entry.maxNumberOfSegments = Number(result.max_number_of_segments)
        entry.numberOfSegments = Number(result.number_of_segments)
        entry.firstTimestamp = Number(result.first_timestamp);
        entry.lastTimestamp = Number(result.last_timestamp);
        entry.md5 = result.md5;
        entry.windCorrection = Number(result.wind_correction);
        return entry;

    }
}
}
