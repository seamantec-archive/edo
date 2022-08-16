/**
 * Created by pepusz on 2014.02.06..
 */
package com.logbook {
import com.common.TripDataHandler;
import com.loggers.DataLogger;
import com.loggers.SystemLogger;
import com.sailing.SailData;
import com.sailing.WindowsHandler;
import com.sailing.socket.SocketDispatcher;
import com.sailing.units.Depth;
import com.sailing.units.Distance;
import com.sailing.units.Speed;
import com.sailing.units.Temperature;
import com.sailing.units.Unit;
import com.sailing.units.WindSpeed;
import com.store.SettingsConfigs;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Timer;

public class LogBookDataHandler extends EventDispatcher implements ISelectCaller {
    private static var _instance:LogBookDataHandler;
    private var logBookDb:LogBookDb
    private var _lastLogBookEntries:Vector.<LogBookEntry> = new <LogBookEntry>[];
    private var _timer:Timer;
    private var _possibleNextEventTime:Number;
    private var _allCounter:Number = 0;

    public function LogBookDataHandler() {
        if (_instance != null) {
            throw new Error("This is a singleton use instance");
        } else {
            logBookDb = new LogBookDb();
            SettingsConfigs.instance.addEventListener(LogBookDataHandlerEvent.ON_OFF_LOGBOOK, logbook_on_offHandler, false, 0, true);
            SettingsConfigs.instance.addEventListener(LogBookDataHandlerEvent.EVENT_INTERVAL_CHANGED, logbook_event_interval_changedHandler, false, 0, true);
            _timer = new Timer(1000, 1);
            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete, false, 0, true);
        }
    }


    public function gotNewZda():void {
        if (!_timer.running && WindowsHandler.instance.isSocketDatasource() && SettingsConfigs.instance.isLogBookOn) {
            initAndStartTimerForDelay();
        } else {
            // ha kell itt tudunk korrigalni
        }
    }

    public function stopLogBook():void {
        _timer.stop();
    }

    public function deleteAllDemoEntry():void {
        logBookDb.deleteAllDemoEntry();
        dispatchEvent(new LogBookDataHandlerEvent(LogBookDataHandlerEvent.DELETED_ALL_DEMO))

    }

    public function clearAll():void{
        logBookDb.clearAllEntry();
        getLogBookEntries()
    }

    private function initAndStartTimerForDelay():void {
        if (SailData.actualSailData.sailDataTimestamp === -1) {
            return;
        }
        _timer.delay = calculateTimerDelay(SailData.actualSailData.sailDataTimestamp, SettingsConfigs.instance.logBookEventInterval);
        _possibleNextEventTime = SailData.actualSailData.sailDataTimestamp + _timer.delay;
//        trace("Set timer delay", _timer.delay, getTimer(), new Date(_possibleNextEventTime).toUTCString(), new Date().time);
        _timer.repeatCount = 1
        _timer.start();
    }

    static function calculateTimerDelay(actualTime:Number, offset:uint):Number {
        return Math.ceil(actualTime / offset) * offset - actualTime;
    }

    public function getLogBookEntries():void {
        logBookDb.selectLastNEntry(this);
        dispatchEvent(new LogBookDataHandlerEvent(LogBookDataHandlerEvent.START_SELECT_ENTRIES));
    }


    public function gotResult(entries:Vector.<LogBookEntry>):void {
        if (entries != null) {
            _lastLogBookEntries = entries;
        } else {
            _lastLogBookEntries = new <LogBookEntry>[];
        }
        dispatchEvent(new LogBookDataHandlerEvent(LogBookDataHandlerEvent.READY_ENTRIES));
    }

    public function get lastLogBookEntries():Vector.<LogBookEntry> {
        return _lastLogBookEntries;
    }

    public static function get instance():LogBookDataHandler {
        if (_instance === null) {
            _instance = new LogBookDataHandler();
        }
        return _instance;
    }

    private function timerComplete(event:TimerEvent):void {
        if (SailData.actualSailData.sailDataTimestamp - _possibleNextEventTime < 0) {
//            trace("reinit", new Date(SailData.actualSailData.sailDataTimestamp).toUTCString(), " ||||", getTimer());
            initAndStartTimerForDelay()
        } else {
//            trace("insert", new Date(SailData.actualSailData.sailDataTimestamp).toUTCString(), " ||||", getTimer());
            logBookDb.insertLogEntry(collectSailDatas());
        }
    }

    private function collectSailDatas():LogBookEntry {
        return new LogBookEntry(SailData.actualSailData.positionandspeed.lat,
                SailData.actualSailData.positionandspeed.lon,
                new Date(SailData.actualSailData.sailDataTimestamp),
                SailData.actualSailData.positionandspeed.isValid() ? SailData.actualSailData.positionandspeed.sog : Speed.getInvalidSpeed(),
                SailData.actualSailData.positionandspeed.isValid() ? SailData.actualSailData.positionandspeed.cog.getPureData() : Unit.INVALID_VALUE,
                SailData.actualSailData.dbt.isValid() ? SailData.actualSailData.dbt.waterDepth : Depth.getInvalidDepth(),
                SailData.actualSailData.mtw.isValid() ? SailData.actualSailData.mtw.temperature : Temperature.getInvalidTemp(),
                SailData.actualSailData.mta.isValid() ? SailData.actualSailData.mta.temperature : Temperature.getInvalidTemp(),
                SailData.actualSailData.truewindc.isValid() ? SailData.actualSailData.truewindc.windSpeed : WindSpeed.getInvalidSpeed(),
                SailData.actualSailData.truewindc.isValid() ? SailData.actualSailData.truewindc.windDirection.getPureData() : Unit.INVALID_VALUE,      //SailData.actualSailData.mwvt.windDirection.getPureData()
                TripDataHandler.instance().getOverallDistance()!=null ? TripDataHandler.instance().getOverallDistance() : Distance.getInvalidDistance(),
                ((WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).isDemoConnected ? 1 : 0)
        )
    }

    private function logbook_on_offHandler(event:LogBookDataHandlerEvent):void {
        if (!SettingsConfigs.instance.isLogBookOn) {
            stopLogBook();
        }
    }

    private function logbook_event_interval_changedHandler(event:LogBookDataHandlerEvent):void {
        stopLogBook();
    }

    function insertReady():void {
        dispatchEvent(new LogBookDataHandlerEvent(LogBookDataHandlerEvent.INSERT_READY))
    }

    function counterChanged(newCounter:Number):void {
        _allCounter = newCounter;
        dispatchEvent(new LogBookDataHandlerEvent(LogBookDataHandlerEvent.COUNTER_CHANGED))
    }

    public function countAllElements():void {
        logBookDb.countAllElements();
    }


    public function get allCounter():Number {
        return _allCounter;
    }

    public function openSaveFile():void {

        var docsDir:File = File.desktopDirectory.resolvePath("logBook_"+DataLogger.toFormatedUTCDateForFile(new Date())+".csv");
        try {
            docsDir.browseForSave("Save Log Book");
            docsDir.addEventListener(Event.SELECT, docsDir_selectHandler, false, 0, true);
        } catch (e:Error) {
            SystemLogger.Error("Save Log Book" + e.message);
        }
    }

    private var exportFile:File;

    private function docsDir_selectHandler(event:Event):void {
        exportFile = event.target as File;
        logBookDb.exportSelect();
    }

    function saveExportToFile(str:String):void {
        var stream:FileStream = new FileStream();
        stream.open(exportFile, FileMode.WRITE);
        stream.writeUTFBytes(str);
        stream.close();
    }

    public function closeDb():void{
       logBookDb.closeDb();
    }
}
}
