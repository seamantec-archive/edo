/**
 * Created by pepusz on 2014.05.28..
 */
package com.workers {
import com.common.WindCorrection;
import com.events.UpdateNmeaDatasEvent;
import com.polar.PolarData;
import com.polar.PolarDataContainer;
import com.polar.PolarDataWindLayer;
import com.sailing.combinedDataHandlers.CombinedDataHandler;
import com.sailing.datas.BaseSailData;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.TrueWindC;
import com.sailing.datas.Vhw;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;
import com.sailing.nmeaParser.utils.NmeaUtil;
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
import flash.utils.getTimer;



registerClassAlias("com.polar.PolarDataContainer", PolarDataContainer);
registerClassAlias("com.polar.PolarDataWindLayer", PolarDataWindLayer);
registerClassAlias("InnerVector", Vector.<Vector.<uint>> as Class);
registerClassAlias("InnerInnerVector", Vector.<uint> as Class);
registerClassAlias("outerVector", Vector.<PolarDataWindLayer> as Class);
registerClassAlias("uint", uint);
public class PolarWorker extends Sprite {
    NmeaUtil.registerNmeaDatas();


    private var polarWorkerToMain:MessageChannel;
    private var mainToPolarWorker:MessageChannel;
    private var polarDataContainer:PolarDataContainer;
    private var timestampCalculator:TimestampCalculator;
    var timestamp:Number;
    private var isSog:Boolean = true;
    private var _sharedBA:ByteArray;
    private var storagePath:String;

    private var _pointCounter;

    public function PolarWorker() {
        super();
        polarDataContainer = new PolarDataContainer();
        CombinedDataHandler.instance.addEventListener(UpdateNmeaDatasEvent.UPDATE_NMEA_DATAS, updateNmeaDatasHandler, false, 0, true);
        mainToPolarWorker = Worker.current.getSharedProperty("mainToPolarWorker")
        polarWorkerToMain = Worker.current.getSharedProperty("polarWorkerToMain")
        storagePath = Worker.current.getSharedProperty("storageDirectoryPath");
        WindCorrection.instance.load(storagePath);
        isSog = Worker.current.getSharedProperty("speedToUseIsSog") as Boolean;
        _sharedBA = Worker.current.getSharedProperty("sharedBA") as ByteArray;
        mainToPolarWorker.addEventListener(Event.CHANNEL_MESSAGE, mainToPolarWorker_channelMessageHandler, false, 0, true);
    }



    private function mainToPolarWorker_channelMessageHandler(event:Event):void {
        var message:Object = mainToPolarWorker.receive();
        switch (message.action) {
            case "start":
            {
                trace("start load log", message.logFilePath);
                parseLogFile(message.logFilePath)
                break;
            }
            default:
            {
                trace("unkonw message polar worker", message.action)
                break;
            }
        }
    }


    private function parseLogFile(filePath:String):void {
        var parsableKeys:RegExp = new RegExp(/MWV|VHW|RMC|VTG|ZDA|GGA|GLL|GMP|ZLZ/i)
        var logFile:File = new File(filePath);
        var startTime:uint = getTimer();
        var lastPercent:uint = 0;
        if (logFile.exists && logFile.size <= 31457280) {
            if (logFile.extension === "txt" || logFile.extension === "nmea") {
                polarWorkerToMain.send({action: "status-update", percent: 0});
                _pointCounter = 0;


                var packeter:NmeaPacketer = new NmeaPacketer();
                var fileStream:FileStream = new FileStream();
                fileStream.open(logFile, FileMode.READ);
                var fileContent:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
                fileStream.close();
                var messages:Array = packeter.newReadPacket(fileContent, true);
                timestampCalculator = new TimestampCalculator(messages);
                timestampCalculator.removeWrongZdas();
                timestamp = timestampCalculator.getFirstTimestamp();
                var messagesLength:uint = messages.length;
                var x:Object;
                var found:uint = 0;
                for (var i:int = 0; i < messagesLength; i++) {
                    if (messages[i].match(parsableKeys)) {
                        x = NmeaInterpreter.processWithMessageCode(messages[i]);
                        if (x != null && x.data != null) {
                            if (x.key.match(TimestampCalculator.regexpForKey)) {
                                if (x.key == "zda") {
                                    timestamp = timestampCalculator.dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec, x.data.utc);
                                } else {
                                    timestamp = timestampCalculator.dateFromNmeaTimestamp(x.data.hour, x.data.min, x.data.sec);
                                }

                                if (timestamp == -1) {
                                    timestamp = timestampCalculator.actualTimestamp;
                                } else {
                                    timestampChange(timestamp);
                                }
                            }
                            if (lastPercent != Math.floor(i / messagesLength * 100)) {
                                lastPercent = Math.floor(i / messagesLength * 100)
                                polarWorkerToMain.send({action: "status-update", percent: lastPercent})
                            }
                            try {
                                addLiveData(x.data)
                                CombinedDataHandler.instance.updateDatas(x.key, x.data, timestamp, true);
                            } catch (e:Error) {
                                trace("PolarWorker error in message: " + messages[i]);
                            }
                        }
                    }
                }
                polarDataContainer.fillUpByteArray(_sharedBA, false);
                trace("found", _pointCounter, "loadPolarDots time:", getTimer() - startTime);
                polarWorkerToMain.send({action: "ready", count: _pointCounter});
            } else {
                polarWorkerToMain.send({action: "bad-extension"});
            }
        } else {
            polarWorkerToMain.send({action: "too-large"});
        }
        trace("last ready")
        polarWorkerToMain.send({action: "ready", count: _pointCounter});
    }

    private function updateNmeaDatasHandler(event:UpdateNmeaDatasEvent):void {
        if (event.data == null || event.data.key == null || event.data.data == null) return;
        addLiveData(event.data.data as BaseSailData)
        CombinedDataHandler.instance.updateDatas(event.data.key, event.data.data, timestampCalculator.actualTimestamp, true);

    }

    private var lastPolarData:PolarData;
    private var tempTimestamp:Number;
    private var tempWindTimestamp:Number = 0;
    private var tempBoatSpeedTimestamp:Number = 0;

    public function timestampChange(newTimestamp:Number):void {
        tempTimestamp = newTimestamp;

        if (lastPolarData === null) {
            createNewPolarData();
        }
        if (newTimestamp === lastPolarData.timestamp) {
            return;
        }
        if (lastPolarData.isValid()) {
            startNewPolarData();
        }
    }

    public function addLiveData(data:BaseSailData):void {
        if (lastPolarData === null) {
            return;
        }
        if (data is TrueWindC) {
            lastPolarData.windSpeed = Math.floor((data as TrueWindC).windSpeed.getPureData());
            lastPolarData.windDir = (data as TrueWindC).windDirection.getPureData()
            tempWindTimestamp = timestamp
        }
        if (data is Vhw && !isSog) {
            lastPolarData.boatSpeed = (data as Vhw).waterSpeed.getPureData();
            tempBoatSpeedTimestamp = timestamp;
        }
        if (data is PositionAndSpeed && isSog) {
            lastPolarData.boatSpeed = (data as PositionAndSpeed).sog.getPureData();
            tempBoatSpeedTimestamp = timestamp;
        }
        if (lastPolarData.isValid() && Math.abs(tempBoatSpeedTimestamp - tempWindTimestamp) <= 5000) {
            startNewPolarData();
        } else if (Math.abs(tempBoatSpeedTimestamp - tempWindTimestamp) > 5000 && tempWindTimestamp != 0 && tempBoatSpeedTimestamp != 0) {
            createNewPolarData();
        }
    }


    private function startNewPolarData():void {
        lastPolarData.timestamp = tempTimestamp;
        if (lastPolarData.windSpeed < PolarDataContainer.MAX_WINDSPEED) {
            polarDataContainer.addPolarData(lastPolarData);
            _pointCounter++;
        }
        createNewPolarData();
    }

    private function createNewPolarData():void {
        lastPolarData = new PolarData();
        lastPolarData.timestamp = tempTimestamp;
        tempWindTimestamp = 0;
        tempBoatSpeedTimestamp = 0;
    }
}
}
