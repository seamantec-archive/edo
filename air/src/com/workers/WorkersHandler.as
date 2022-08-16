package com.workers {
import com.common.SpeedToUse;
import com.events.PolarWorkerEvent;
import com.events.UpdateNmeaDatasEvent;
import com.loggers.LogRegister;
import com.polar.PolarCloudLoadEvent;
import com.polar.PolarContainer;
import com.sailing.WindowsHandler;
import com.timeline.DataParserHandler;

import flash.events.Event;
import flash.filesystem.File;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.system.WorkerState;
import flash.utils.ByteArray;

public class WorkersHandler {
    private static var _instance:WorkersHandler;


    private var _mainWorker:Worker;
    private var _parserWorker:Worker;
    private var _nmeaLogReaderWorker:Worker;
    private var _polarWorker:Worker;

    private var _mainToParser:MessageChannel;
    private var _parserToMain:MessageChannel;

    private var _mainToNmeaReader:MessageChannel;
    private var _nmeaReaderToMain:MessageChannel;

    private var _mainToPolarWorker:MessageChannel;
    private var _polarWorkerToMain:MessageChannel;


    public var inited:Boolean = false;
    public var _polarWorkerSharedBA:ByteArray;

    public function WorkersHandler() {
        if (_instance != null) {

        } else {
            _instance = this;
            PolarContainer.instance.addEventListener(PolarWorkerEvent.START_WORKER, handlePolarWorkerStart, false, 0, true);
        }


    }

    private function handlePolarWorkerStart(e:PolarWorkerEvent):void {
         mainToPolarWorker.send({action: "start", logFilePath: e.filepath});

    }

    public function get nmeaLogReaderWorker():Worker {
        initNmeaReaderWorker();

        return _nmeaLogReaderWorker;
    }

    public function isNmeaLogReaderWorkerNull():Boolean {
        return _nmeaLogReaderWorker == null;
    }

    public function setLogWorkerToNull():void{
        _nmeaLogReaderWorker = null;
    }

    public function get nmeaReaderToMain():MessageChannel {
        initNmeaReaderWorker();

        return _nmeaReaderToMain;
    }

    public function set nmeaReaderToMain(value:MessageChannel):void {
        _nmeaReaderToMain = value;
    }

    public function get mainToNmeaReader():MessageChannel {
        initNmeaReaderWorker();
        return _mainToNmeaReader;
    }


    public function get polarWorker():Worker {
        initPolarWorker();
        return _polarWorker;
    }

    public function set mainToNmeaReader(value:MessageChannel):void {
        _mainToNmeaReader = value;
    }

    public function get mainToParser():MessageChannel {
        initParserWorker();
        return _mainToParser;
    }


    public function get parserToMain():MessageChannel {
        initParserWorker();
        return _parserToMain;
    }


    public function get parserWorker():Worker {
        initParserWorker();
        return _parserWorker;
    }

    private function initParserWorker():void {
        if (_parserWorker == null) {
            _parserWorker = WorkerDomain.current.createWorker(Workers.com_workers_ParserWorker, true);
            _parserToMain = parserWorker.createMessageChannel(mainWorker);
            _mainToParser = mainWorker.createMessageChannel(parserWorker);
            _parserWorker.setSharedProperty("mainToParser", mainToParser);
            _parserWorker.setSharedProperty("parserToMain", parserToMain);
            _parserWorker.start();

            _parserToMain.addEventListener(Event.CHANNEL_MESSAGE, handleParserToMain, false, 0, true);
        }
    }

    private function initNmeaReaderWorker():void {
        if (_nmeaLogReaderWorker == null || _nmeaLogReaderWorker.state == WorkerState.TERMINATED) {
            _nmeaLogReaderWorker = WorkerDomain.current.createWorker(Workers.com_workers_NmeaLogReader, true);

            _nmeaReaderToMain = nmeaLogReaderWorker.createMessageChannel(mainWorker);
            _mainToNmeaReader = mainWorker.createMessageChannel(nmeaLogReaderWorker);
            _nmeaLogReaderWorker.setSharedProperty("mainToNmeaReader", mainToNmeaReader);
            _nmeaLogReaderWorker.setSharedProperty("nmeaReaderToMain", nmeaReaderToMain);
            _nmeaLogReaderWorker.setSharedProperty("storageDirectoryPath", File.applicationStorageDirectory.nativePath);

            var sharedLogRegister:ByteArray = new ByteArray();
            var lIntance:LogRegister = LogRegister.instance;
            sharedLogRegister.writeObject(lIntance);
            sharedLogRegister.position = 0;
            sharedLogRegister.shareable = true;

            _nmeaLogReaderWorker.setSharedProperty("LogRegister", sharedLogRegister);
            _nmeaLogReaderWorker.start();

            nmeaReaderToMain.addEventListener(Event.CHANNEL_MESSAGE, nmeaReaderToMainHandler, false, 0, true);
        }
    }

    private function initPolarWorker():void {
        if (_polarWorker == null || _polarWorker.state === WorkerState.TERMINATED) {
            _polarWorker = WorkerDomain.current.createWorker(Workers.com_workers_PolarWorker, true);
            _mainToPolarWorker = _mainWorker.createMessageChannel(_polarWorker);
            _polarWorkerToMain = _polarWorker.createMessageChannel(_mainWorker);
            _polarWorker.setSharedProperty("mainToPolarWorker", _mainToPolarWorker);
            _polarWorker.setSharedProperty("polarWorkerToMain", _polarWorkerToMain);
            _polarWorker.setSharedProperty("storageDirectoryPath", File.applicationStorageDirectory.nativePath);
            _polarWorker.setSharedProperty("speedToUseIsSog", SpeedToUse.instance.selected === SpeedToUse.SOG);
            if (_polarWorkerSharedBA == null) {
                _polarWorkerSharedBA = new ByteArray();
                _polarWorkerSharedBA.shareable = true;
            }

            _polarWorkerSharedBA.position = 0;
            _polarWorker.setSharedProperty("sharedBA", _polarWorkerSharedBA);
            _polarWorker.start();
            _polarWorkerToMain.addEventListener(Event.CHANNEL_MESSAGE, polarWorkerToMain_channelMessageHandler, false, 0, true);

        }
    }


    protected function nmeaReaderToMainHandler(event:Event):void {
        //TODO itt csak a statuszt frissitjuk
        var message:Object = nmeaReaderToMain.receive();
        if (message == null) {
            return;
        }
        switch (message.action) {
            case "status-update":
            {
                DataParserHandler.instance.setProgress(message.actual, message.from);
                break;
            }
            case "ready":
            {
                trace("ready");
                DataParserHandler.instance.updateSegmentsStatusHandler(message.nativePath);
                DataParserHandler.instance.readyLoadingHandler(message.fileName, message.nativePath);
                break;
            }
            case "stop-for-segmentation":
            {
                DataParserHandler.instance.refreshLoadingHandler(message.fileName, message.actualIndex, message.fileNativePath, message.actualSegment);
                break;
            }
            case "parsing-started":
            {
                DataParserHandler.instance.logFileParsingStartedHandler(message.nativePath, message.lastTimestamp);
                break;
            }
            case "update-segments":
            {
                DataParserHandler.instance.updateSegmentsStatusHandler(message.nativePath);
                break;
            }


            default:
            {
                trace("unknown message action " + message.action);
                break;
            }
        }
    }

    protected function handleParserToMain(event:Event):void {
        var data = parserToMain.receive();
        /*var x:Object = {key: data.key}
         var bArray:ByteArray = data.data;
         bArray.position = 0;
         var oldData = bArray.readObject();
         x["data"] = oldData;
         trace(oldData);*/
        //byteArray.position = 0;
        //var data = byteArray.readObject();
        WindowsHandler.instance.dispatchEvent(new UpdateNmeaDatasEvent(data));
    }

    public function get mainWorker():Worker {
        return _mainWorker;
    }

    public function set mainWorker(value:Worker):void {
        _mainWorker = value;

    }

    public static function get instance():WorkersHandler {
        if (_instance == null) {
            _instance = new WorkersHandler();
        }
        return _instance;

    }


    public function get mainToPolarWorker():MessageChannel {
        initPolarWorker();
        return _mainToPolarWorker;
    }

    private function polarWorkerToMain_channelMessageHandler(event:Event):void {
        var message:Object = _polarWorkerToMain.receive();
        switch (message.action) {
            case "too-large":
                PolarContainer.instance.dispatchTooLargeWarningEvent();
                break;
            case "bad-extension":
                PolarContainer.instance.dispatchBadCloudWarningEvent();
                break;
            case "status-update":
                PolarContainer.instance.dispatchPolarCloudLoadProcessEvent(message.percent);
                break;
            case "ready":
                trace("ready");
                //1. load bytearray
                PolarContainer.instance.dataContainer.mergeFromByteArray(_polarWorkerSharedBA, false);
                PolarContainer.instance.dispatchPolarCloudLoadReadyEvent(Number(message.count));
                if (message.count == 0) {
                    PolarContainer.instance.dispatchEvent(new Event("enablePolar"));
                }
                terminatePolarWorker();
                break;
        }

    }

    public function terminatePolarWorker():void {
        if (polarWorker.state === WorkerState.RUNNING) {
            _polarWorker.terminate();
            _polarWorker = null;
        }
    }
}
}