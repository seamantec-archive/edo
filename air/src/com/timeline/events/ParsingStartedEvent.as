package com.timeline.events {
import flash.events.Event;

public class ParsingStartedEvent extends Event {
    public static const PARSING_STARTED:String = "parsing-started";
    public var fileName:String;
    public var lastTimestamp:Number;

    public function ParsingStartedEvent(fileName:String, lastTimestamp:Number) {
        super(PARSING_STARTED);
        this.fileName = fileName;
        this.lastTimestamp = lastTimestamp
    }
}
}