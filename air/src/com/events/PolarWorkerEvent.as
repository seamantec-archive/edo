package com.events {
import flash.events.Event;

public class PolarWorkerEvent extends Event {

    public static var START_WORKER:String = "startWorker";

    public var action:String;
    public var filepath:String;

    public function PolarWorkerEvent(action:String, filepath:String) {
        super(START_WORKER);
        this.action = action;
        this.filepath = filepath;
    }
}
}