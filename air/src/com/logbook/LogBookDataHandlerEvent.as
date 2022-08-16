/**
 * Created by pepusz on 2014.02.07..
 */
package com.logbook {
import flash.events.Event;

public class LogBookDataHandlerEvent extends Event {
    public static const READY_ENTRIES:String = "logbook-entries-ready";
    public static const START_SELECT_ENTRIES:String = "logbook-entries-start-select";
    public static const ON_OFF_LOGBOOK:String = "logbook-on-off";
    public static const EVENT_INTERVAL_CHANGED:String = "logbook-event-interval-changed";
    public static const INSERT_READY:String = "logbook-event-inser-ready";
    public static const DELETED_ALL_DEMO:String = "logbook-event-deleted-all-demo";
    public static const COUNTER_CHANGED:String = "logbook-event-counter-changed";

    public function LogBookDataHandlerEvent(type:String) {
        super(type, false);
    }
}
}
