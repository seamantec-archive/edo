package com.workers {
import com.common.WindCorrection;
import com.events.UpdateNmeaDatasEvent;
import com.loggers.DataLogger;
import com.loggers.LogEntry;
import com.loggers.LogRegister;
import com.loggers.SystemLogger;
import com.sailing.combinedDataHandlers.CombinedDataHandler;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;
import com.sailing.nmeaParser.utils.NmeaUtil;
import com.sailing.units.Direction;
import com.utils.TimestampCalculator;

import flash.display.Sprite;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.registerClassAlias;
import flash.system.MessageChannel;
import flash.system.Worker;
import flash.utils.ByteArray;

import logreader.GraphDataLogger;


public class NmeaLogReader extends Sprite {
    NmeaUtil.registerNmeaDatas();
    registerClassAlias("com.loggers.LogRegister", LogRegister);
    private var nmeaReaderToMain:MessageChannel;
    private var mainToNmeaReader:MessageChannel;
    private var logFile:File;
    private var logRegister:LogRegister;
    private var messages:Array;
    private var messagesLength:Number;
    private var stop:Boolean = false;
    private var logEntry:LogEntry;
    private var storagePath:String = "";
    private var timestampCalculator:TimestampCalculator;
    private var graphDataLogger:GraphDataLogger;
    private var lastTimestamp:Number;
    private var firstTimestamp:Number
    private var fileStream:FileStream;

    public function NmeaLogReader() {
        super();
        trace("nmealogreader constructor")
        Direction.isVariationValid = false;
        Direction.variation = 0;
        nmeaReaderToMain = Worker.current.getSharedProperty("nmeaReaderToMain");
        mainToNmeaReader = Worker.current.getSharedProperty("mainToNmeaReader");
        storagePath = Worker.current.getSharedProperty("storageDirectoryPath");
        WindCorrection.instance.load(storagePath);
        var bArray:ByteArray = Worker.current.getSharedProperty("LogRegister");
        logRegister = bArray.readObject();
        reinitLogregister();
        graphDataLogger = new GraphDataLogger(storagePath);
        mainToNmeaReader.addEventListener(Event.CHANNEL_MESSAGE, messageReceivedHandler, false, 0, true);
        CombinedDataHandler.instance.addEventListener(UpdateNmeaDatasEvent.UPDATE_NMEA_DATAS, updateNmeaDatasHandler, false, 0, true);
    }



    private function reinitLogregister():void {
        try {
            logRegister.reInit();
        } catch (e:Error) {
            trace("NMEA WORKER logregister re init: " + e.message);
            trace(e.getStackTrace());
        }
    }




    protected function messageReceivedHandler(event:Event):void {
        var message:Object = mainToNmeaReader.receive();
        switch (message.action) {
            case "start":
            {
                logFile = new File(message.logFile.nativePath);
                startParsing();
                break;
            }

            case "setupHandlers":
            {
                //listeners = message.listeners;
                break;
            }
            case "stop":
            {
                stop = true;
                break;
            }


            case "continue":
            {
                continueParsing(message.from);
                break;
            }

            default:
            {
                trace("unknown message action " + message.action);
                break;
            }
        }
    }

    private function packetingMessages():void {
        fileStream.position = 0;
        var fileContent:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
        var packeter:NmeaPacketer = new NmeaPacketer();
        messages = packeter.newReadPacket(fileContent, true);
        messagesLength = messages.length;
        timestampCalculator = new TimestampCalculator(messages);
        timestampCalculator.removeWrongZdas();
    }


    private function startParsing():void {
        openFileStream();


        if (isFileLoaded()) return;
        packetingMessages();
        setFirstTimestamp();
        if (logEntry == null || logEntry.maxLineCounter == 0) {
            //NO FILE, START LOADING
            trace("Start new FILE to parse")
            LogRegister.instance.addNewLog(logFile);
            initAndStartParsing(0);
            return;
        }


        if (logEntry.md5 != LogRegister.getMd5ForFile(logFile) && logEntry.windCorrection == WindCorrection.instance.windCorrection) {
            SystemLogger.Debug("log file is changed continue parsing");
            logEntry = null;
            LogRegister.instance.updateMd5(logFile);
            logEntry = LogRegister.instance.getLogEntry(logFile);
            var startFrom:Number = logEntry.lineCounter + 1;
            SystemLogger.Debug("log file is changed md5 updated");
            if (startFrom >= 30000) {
                LogRegister.instance.updateMaxLineCounter(messagesLength, logFile);
                stopForSegmentationCONTINUE();
                SystemLogger.Debug("continue unfinished log file");
            } else {
                initAndStartParsing(0)
            }
            return;
        }

        if (logEntry.windCorrection != WindCorrection.instance.windCorrection) {
            SystemLogger.Debug("wind correction changed");
            LogRegister.instance.deletelogFiles(logEntry.id);
            LogRegister.instance.addNewLog(logFile);
            LogRegister.instance.updateFirstTimestamp(logFile, firstTimestamp);
            logEntry = LogRegister.instance.getLogEntry(logFile);
            reinitLogregister();
            initAndStartParsing(0)
            return;
        }

        if (logEntry.md5 == LogRegister.getMd5ForFile(logFile) && logEntry.windCorrection == WindCorrection.instance.windCorrection && logEntry.maxLineCounter != logEntry.lineCounter) {
            trace("continue file from last segment")
            if (logEntry.lineCounter >= 30000) {
                stopForSegmentationCONTINUE();
            } else {
                initAndStartParsing(0)
            }
            return;
        }
    }


    private function stopForSegmentationCONTINUE():void {
        logEntry = LogRegister.instance.getLogEntry(logFile);
        graphDataLogger.buildGraphSqlConnection(logEntry.name);
        nmeaReaderToMain.send({action: "parsing-started", nativePath: logFile.nativePath, lastTimestamp: timestampCalculator.lastTimestamp});
        nmeaReaderToMain.send({action: "stop-for-segmentation", actualIndex: logEntry.lineCounter, fileName: logFile.name + "." + (logEntry.numberOfSegments + 1),
            fileNativePath: logFile.nativePath, actualSegment: logEntry.numberOfSegments});
        SystemLogger.Debug("continue unfinished log file");
    }

    private function initAndStartParsing(from:Number):void {
        trace("init and start parsing", from)
        if (from == 0) {
            if (graphDataLogger == null) {
                graphDataLogger = new GraphDataLogger(storagePath);
            }
            graphDataLogger.deleteLogDb(logEntry.name)
            graphDataLogger.buildGraphSqlConnection(logEntry.name);
        }

        LogRegister.instance.updateMaxLineCounter(messagesLength, logFile);
        nmeaReaderToMain.send({action: "parsing-started", nativePath: logFile.nativePath, lastTimestamp: timestampCalculator.lastTimestamp});
        nmeaReaderToMain.send({action: "update-segments", nativePath: logFile.nativePath});
        logEntry = LogRegister.instance.getLogEntry(logFile);
        var timestamp:Number = logEntry.lastTimestamp == 0 ? logEntry.firstTimestamp : logEntry.lastTimestamp
        SystemLogger.Debug("parsing inited and started from timestamp:" + timestamp);
        var ready:Boolean = loadMessages(from, timestamp);
        sendReadyToMain(ready, messagesLength)
    }

    private function setFirstTimestamp():void {
        firstTimestamp = timestampCalculator.getFirstTimestamp();
        trace("FIRST TIMESTAMP", firstTimestamp);
        trace("LAST TIMESTAMP ", timestampCalculator.lastTimestamp);
        LogRegister.instance.updateFirstTimestamp(logFile, firstTimestamp);
        logEntry = LogRegister.instance.getLogEntry(logFile);

    }

    private function openFileStream():void {
        SystemLogger.Debug("Parsing started on " + logFile.nativePath + " File");
        nmeaReaderToMain.send({action: "status-update", actual: 0, from: 100})
        fileStream = new FileStream();
        fileStream.open(logFile, FileMode.READ);
        logEntry = LogRegister.instance.getLogEntry(logFile);
    }

    private function isFileLoaded():Boolean {
        if (logEntry != null && logEntry.md5 == LogRegister.getMd5ForFile(logFile) && logEntry.maxLineCounter != 0 && logEntry.maxLineCounter == logEntry.lineCounter && logEntry.windCorrection == WindCorrection.instance.windCorrection) {
            nmeaReaderToMain.send({action: "parsing-started", nativePath: logFile.nativePath, lastTimestamp: logEntry.lastTimestamp});

            sendReadyToMain(true, logEntry.maxLineCounter);
            SystemLogger.Debug("log file is loaded, parsing is not necessary " + logEntry.maxLineCounter);
            return true;
        }
        return false;
    }


    private function sendReadyToMain(ready:Boolean, lineCounter):void {
        if (ready) {
            LogRegister.instance.updateLineCounter(logFile, lineCounter);
            nmeaReaderToMain.send({action: "ready", fileName: logFile.name + ".0", nativePath: logFile.nativePath});
        }
    }

    private function continueParsing(from:Number):void {
        logEntry = LogRegister.instance.getLogEntry(logFile);
        SystemLogger.Debug("continue parsing from " + from + " file: " + logFile.nativePath);
        var timestamp:Number;
        if (logEntry.lastTimestamp != 0) {
            timestamp = logEntry.lastTimestamp;
            timestampCalculator.actualDate = new Date(timestamp);
            SystemLogger.Debug("last timestamp " + timestampCalculator.actualDate.toTimeString());
        } else {
            if (from === 0) {
                timestamp = timestampCalculator.getFirstTimestamp();
            } else {
                timestamp = timestampCalculator.getTimestampFrom(from);
            }
            SystemLogger.Debug("last timestamp from " + from + " " + timestampCalculator.actualDate.toTimeString());
        }

        if (!stop) {
            var ready:Boolean = loadMessages(from, timestamp);
            sendReadyToMain(ready, messagesLength);
        } else {
            stop = false;
            sendReadyToMain(true, from);
        }
    }


    var timestampId:Number;
    var i:int;
    var from:int;
    var filterOutKeys:RegExp = new RegExp(/VDO|VDM|GSA|GSV|HCC|HCD|HSC|HTC|HWM|MHU|MMB|MTA|rotnmea|VDM|VDR|VLW|ZLZ|ZZU/i);



    private function loadMessages(from:int, timestamp:Number):Boolean {
        if (!CombinedDataHandler.instance.hasEventListener(UpdateNmeaDatasEvent.UPDATE_NMEA_DATAS)) {
            trace("no cominedata handler event listener");
            CombinedDataHandler.instance.addEventListener(UpdateNmeaDatasEvent.UPDATE_NMEA_DATAS, updateNmeaDatasHandler, false, 0, true);
        }
        this.from = from;
        logEntry = LogRegister.instance.getLogEntry(logFile);
        var actualSegmentNumber:Number = LogRegister.instance.getSegmentsNumber(logFile) + 1;
        if (actualSegmentNumber == -1) {
            throw new Error("Can't find a segments number for this log file " + logFile.nativePath);
        }
        var segmentFileName:String = logFile.name + "." + actualSegmentNumber;
        SystemLogger.Debug("LOG loading segment, " + segmentFileName);
        DataLogger.instance.startLogging(segmentFileName, storagePath);
        DataLogger.instance.startTransaction();
        graphDataLogger.startTransaction()

        var messagesLength:Number = messages.length;
        if (timestamp === 0) {
            trace("TIMESTAMP 0000000")
        }
        timestampId = DataLogger.instance.insertNewTimestampWithId(from * 30000, timestamp);
        graphDataLogger.insertNewTimestampToGraph(timestampId, timestamp);
        trace("ADD NEW SEGMENT", actualSegmentNumber, timestamp)
        LogRegister.instance.addNewLogSegment(logEntry.id, logEntry.name, actualSegmentNumber, timestamp);

        for (i = from; i < messagesLength; i++) {
            try {
                if (i % 1000 == 0) {
                    nmeaReaderToMain.send({action: "status-update", actual: i, from: messagesLength})
                }
                if (messages[i].match(filterOutKeys)) {
                    continue;
                }

                var x:Object = NmeaInterpreter.processWithMessageCode(messages[i]);
                if (x != null && x.data != null) {
                    if (x.key.match(TimestampCalculator.regexpForKey)) {
                        try {
                            if (x.key == "zda") {
                                timestamp = timestampCalculator.dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec, x.data.utc);
                            } else {
                                timestamp = timestampCalculator.dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec);
                            }

                            if (timestamp != -1) {
                                if (timestamp === 0) {
                                    trace("TIMESTAMP 0", messages[i]);
                                }
                                timestampId = DataLogger.instance.insertNewTimestampWithId(from * 30000 + i + 1, timestamp);
                                graphDataLogger.insertNewTimestampToGraph(timestampId, timestamp);
                            } else {
                                timestamp = timestampCalculator.actualTimestamp;
                            }
                        } catch (e:Error) {
                            trace("EROR", e)
                        }
                    }

                    if (x.key != "vdm" ) {
                        CombinedDataHandler.instance.updateDatas(x.key, x.data, timestamp, true);
                        DataLogger.instance.insertMessageFromLogFileOneTable(x, timestampId, 30000 * from + i);
                        graphDataLogger.insertGraphData(x, timestampId, 30000 * from + i)
                    }
                }

                if (i % 30000 == 0 && i != 0) {
                    updateLogEntryAndStopTransactions(actualSegmentNumber, timestamp);
                    nmeaReaderToMain.send({action: "stop-for-segmentation", actualIndex: i, fileNativePath: logFile.nativePath,
                        fileName: segmentFileName, actualSegment: actualSegmentNumber});
                    return false;
                }
            } catch (e:Error) {
                trace(e.message);
                trace(e.getStackTrace());
                return false;
            }
        }
        updateLogEntryAndStopTransactions(actualSegmentNumber, timestamp);
        return true;
    }


    private function updateLogEntryAndStopTransactions(actualSegmentNumber:Number, timestamp:Number):void {
        trace("UPDATE LOG ENTRY", actualSegmentNumber, timestamp);
        LogRegister.instance.updateSegmentsNumber(logFile, actualSegmentNumber);
        LogRegister.instance.updateLineCounter(logFile, i);
        LogRegister.instance.updateLastTimestamp(logFile, timestamp)
        LogRegister.instance.updateSegmentLastTimestamp(logEntry.id, actualSegmentNumber, timestamp);
        DataLogger.instance.stopTransaction();
        graphDataLogger.stopTransaction()
        DataLogger.instance.closeConnection();
        logEntry = LogRegister.instance.getLogEntry(logFile);
    }

    private function updateNmeaDatasHandler(event:UpdateNmeaDatasEvent):void {
        if (event.data == null || event.data.key == null || event.data.data == null || event.data.key == "performance") return;
        DataLogger.instance.insertMessageFromLogFileOneTable(event.data, timestampId, 30000 * from + i);
        graphDataLogger.insertGraphData(event.data, timestampId, 30000 * from + i)
        CombinedDataHandler.instance.updateDatas(event.data.key, event.data.data, timestampCalculator.actualTimestamp, true);

    }




}


}