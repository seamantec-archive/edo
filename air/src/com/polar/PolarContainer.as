/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.18.
 * Time: 20:26
 * To change this template use File | Settings | File Templates.
 */
package com.polar {
import com.common.SpeedToUse;
import com.events.PolarWorkerEvent;
import com.loggers.SystemLogger;
import com.sailing.SailData;
import com.sailing.datas.BaseSailData;
import com.sailing.datas.PositionAndSpeed;
import com.sailing.datas.TrueWindC;
import com.sailing.datas.Vhw;
import com.utils.EdoLocalStore;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

//import com.workers.WorkersHandler;

public class PolarContainer extends EventDispatcher {
    private static const LIVE_DATA_COUNTER:uint = 30;

    private static var _instance:PolarContainer;
    private var liveDataCounter:uint = 0;

    private var lastPolarData:PolarData;
    private var tempTimestamp:Number;
    private var tempWindTimestamp:Number = 0;
    private var tempBoatSpeedTimestamp:Number = 0;
    private var _polarTable:PolarTable;
    private var _polarTableFromFile:PolarTable;
//    private var _isAppendOn:Boolean = true;
    public var isLiveData:Boolean = true;
    private var _polarTableName:String = "";
    private var _polarcalculatorTimer:Timer = new Timer(200);
    private var _polarFileAutoSaveTimer:Timer = new Timer(10000);

    private var _isChanged:Boolean = false;

    /*
     * data container holds datas in two dimensional vector.
     * Outside dimension is wind speed and inside is the wind direction;
     * */
//    private var _dataContainer:Vector.<Vector.<PolarData>> = new <Vector.<PolarData>>[];
    private var _dataContainer:PolarDataContainer = new PolarDataContainer();

    private var _lastRender:Number;

    public static function get instance():PolarContainer {
        if (_instance == null) {
            _instance = new PolarContainer();

        }
        return _instance;
    }

    public function PolarContainer() {
        if (_instance != null) {
            throw new Error("this is a singleton class use instance")
        } else {
            loadSettings();
            _polarTable = new PolarTable();
            _polarTableFromFile = new PolarTable();
            _polarcalculatorTimer.addEventListener(TimerEvent.TIMER, polarcalculatorTimer_timerHandler, false, 0, true);
            _polarFileAutoSaveTimer.addEventListener(TimerEvent.TIMER, polarFileAutoSaveTimer_timerHandler, false, 0, true);
        }
    }


    private function saveSettings():void {
        var saveObject:Object = {};
        saveObject["hIntOnOff"] = PolarTable.horizontalInterpolationEnabled;
        saveObject["vIntOnOff"] = PolarTable.verticalInterpolationEnabled;
        saveObject["whiteWeight"] = PolarTable.measuredMaxWeight
        saveObject["vIntWeight"] = PolarTable.vInterpolatedWeight;
        saveObject["hIntWeight"] = PolarTable.hInterpolatedWeight;
        saveObject["angleAvg"] = PolarTable.angleAvg;
        saveObject["windFilter"] = windFilterSelectedIndex
        saveObject["ffieldsShow"] = PolarTable.showForceFields;

        var data:ByteArray = new ByteArray();
        data.writeObject(saveObject);
        data.position = 0;
        EdoLocalStore.setItem('polarSettings', data);
    }

    private function loadSettings():void {
        var tempInstance:ByteArray = EdoLocalStore.getItem("polarSettings");
        if (tempInstance != null) {
            var savedObject:Object = tempInstance.readObject();
            PolarTable.horizontalInterpolationEnabled = savedObject["hIntOnOff"];
            PolarTable.verticalInterpolationEnabled = savedObject["vIntOnOff"];
            PolarTable.measuredMaxWeight = savedObject["whiteWeight"];
            PolarTable.vInterpolatedWeight = savedObject["vIntWeight"];
            PolarTable.hInterpolatedWeight = savedObject["hIntWeight"];
            PolarTable.angleAvg = savedObject["angleAvg"];
            PolarTable.showForceFields = savedObject["ffieldsShow"];
            setWindFilter(savedObject["windFilter"]);
        }
    }

    public function get dataContainer():PolarDataContainer {
        return _dataContainer;
    }


    public function get polarTable():PolarTable {
        if (isLiveData) {
            return _polarTable;
        } else if (_polarTableFromFile != null) {
            return _polarTableFromFile;
        }

        return _polarTable;
    }

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
            tempWindTimestamp = SailData.actualSailData.sailDataTimestamp;
        }
//        if (data is Rmc) {
//            lastPolarData.boatSpeed = (data as Rmc).gpsSog.getPureData();
//            tempBoatSpeedTimestamp = SailData.actualSailData.sailDataTimestamp;
//        }
        if (data is Vhw && SpeedToUse.instance.selected == SpeedToUse.STW) {
            lastPolarData.boatSpeed = (data as Vhw).waterSpeed.getPureData();
            tempBoatSpeedTimestamp = SailData.actualSailData.sailDataTimestamp;
        }
        if (data is PositionAndSpeed && SpeedToUse.instance.selected == SpeedToUse.SOG) {
            lastPolarData.boatSpeed = (data as PositionAndSpeed).sog.getPureData();
            tempBoatSpeedTimestamp = SailData.actualSailData.sailDataTimestamp;
        }
        if (lastPolarData.isValid() && Math.abs(tempBoatSpeedTimestamp - tempWindTimestamp) <= 5000) {
            startNewPolarData();
        } else if (Math.abs(tempBoatSpeedTimestamp - tempWindTimestamp) > 5000 && tempWindTimestamp != 0 && tempBoatSpeedTimestamp != 0) {
            createNewPolarData();
        }
    }

    private function startNewPolarData():void {
        lastPolarData.timestamp = tempTimestamp;
        if (lastPolarData.windSpeed < PolarTable.MAX_WINDSPEED) {
            _dataContainer.addPolarData(lastPolarData);
            dispatchEvent(new PolarEvent(lastPolarData));
            _polarTable.addData(lastPolarData);
            liveDataCounter++;
            if (PolarDataContainer.isRecordOn) {
                dispatchEvent(new Event("enablePolar"));
            }
            if (liveDataCounter == LIVE_DATA_COUNTER) {
//                _polarTable.polarLoadReady();
//                dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_READY));
                liveDataCounter = 0;
            }
        }
        createNewPolarData();
    }

    private function createNewPolarData():void {
        lastPolarData = new PolarData();
        lastPolarData.timestamp = tempTimestamp;
        tempWindTimestamp = 0;
        tempBoatSpeedTimestamp = 0;
    }

    public function reset(containers:Object = null):void {
//        _dataContainer.clearAllLayer();
        lastPolarData = null;
        _polarTable = null;
        _polarTable = new PolarTable();
        //_polarTableFromFile = new PolarTable();
        this.containers = containers;
//        dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_RESET_EVENT))
    }

    public function clearPolar():void {
//        _polarTableFromFile = null;
//        isAppendOn = true;
        reset();
    }


    private var containers:Object


    public function addData(polarData:PolarData):void {
        _dataContainer.addPolarData(polarData);
    }

    public function loadFromFile():void {
        var file:File = File.documentsDirectory;
        //TODO add notification if demo license
        file.browseForOpen("Load polar table");
        file.addEventListener(Event.SELECT, file_selectHandler, false, 0, true);
    }

    public function exportToFile():void {
        //TODO add notification if demo license

//        var docsDir:File = File.desktopDirectory.resolvePath("polar.csv");
        var docsDir:File = File.desktopDirectory.resolvePath(_polarTableName);
        try {
            docsDir.browseForSave("Save Polar");
            docsDir.addEventListener(Event.SELECT, docsDir_selectHandler, false, 0, true);
        } catch (e:Error) {
            SystemLogger.Error("Polar save" + e.message);
        }
    }


    public function resetContainer():void {
        _dataContainer.clearAllLayer();
        dispatchEvent(new Event("disablePolar"));
    }


    private function file_selectHandler(event:Event):void {
        var file:File = event.target as File;
        openPolarFromFile(file);
    }

    public function openPolarFromFile(file:File, onLoad:Boolean = false, name:String = null):void {
        var extension:String = file.extension;
        if (file.size <= 1048576) {
            if (extension == "d" || extension == "csv") {
                var fs:FileStream = new FileStream();
                fs.open(file, FileMode.READ);
                var fileContent:String = fs.readUTFBytes(fs.bytesAvailable);
                var hasLoadedFile:Boolean = false;
                var lines:Array = fileContent.split("\n");
                if (extension === "d") {
                    hasLoadedFile = loadDeckmanFile(lines);
                } else if (extension === "csv") {
                    hasLoadedFile = loadCsvFile(lines)
                }
                if (hasLoadedFile) {
                    _polarTableFromFile.polarLoadReadyForFile();

                    if (!onLoad) {
                        save(file, name);
                    }

                    //mergeTableFromFileIntoPolarTable();
                    _isChanged = false;
                    _lastRender = getTimer();
                    dispatchPolarFileLoaded();
                } else {
                    dispatchBadFileWarningEvent()
                }
            } else {
                dispatchBadExtensionWarningEvent();
            }
        } else {
            dispatchTooLargeWarningEvent();
        }
    }

    private function loadCsvFile(lines:Array):Boolean {
        var isComma:Boolean = (lines[0] as String).match(",") != null;
        var isSemmicolon:Boolean = (lines[0] as String).match(";") != null;
        if (!isComma && !isSemmicolon) {
            dispatchBadFileWarningEvent()
            return false;
        }
        for (var i:int = 0; i < lines.length; i++) {
            lines[i] = lines[i].replace(/[\r]*/gim, "");
            if (lines[i] == "") {
                lines.splice(i, 1);
            }
        }
        var splitter:String = ""
        if (isSemmicolon) {
            splitter = ";";
        } else {
            splitter = ",";
        }
        var setNewPolarTable:Boolean = false;

        var header:Array = lines[0].split(splitter);
        for (var i:int = 1; i < lines.length; i++) {
            var line:String = lines[i];
            var segments:Array = line.split(splitter);
            if (segments.length != header.length) {
                continue;
            }
            if (!setNewPolarTable) {
                _polarTableFromFile = new PolarTable();
                setNewPolarTable = true;
            }

            for (var j:int = 1; j < segments.length; j++) {
                var polarData:PolarData = new PolarData()
                polarData.boatSpeed = Number(segments[j]);
                polarData.windDir = int(segments[0]);
                polarData.windSpeed = int(header[j]);
                polarData.timestamp = new Date().time;
                _polarTableFromFile.addFileData(polarData);
            }
        }
        if (!setNewPolarTable) {
            return false
        }
        return true
    }

    private function loadDeckmanFile(lines:Array):Boolean {
        var line:String
        //remove empty lines
        for (var i:int = 0; i < lines.length; i++) {
            line = lines[i];
            line = line.replace(/(\t)/gi, "  ")
            line = line.replace(/\s{2,}/g, "|");
            line = line.replace(/\s{1,}/g, "|");
            line = line.replace(/[\r]*/gim, "");
            if (line == "") {
                lines.splice(i, 1);
            } else {
                lines[i] = line;
            }

        }
        var setNewPolarTable:Boolean = false;
        var segments:Array
        for (var i:int = 1; i < lines.length; i++) {
            line = lines[i];
            segments = line.split("|");
            if (segments.length < 3 && segments.length % 2 == 0) {
                continue
            }
            if (!setNewPolarTable) {
                _polarTableFromFile = new PolarTable();
                setNewPolarTable = true;
            }

            for (var j:int = 2; j < segments.length; j += 2) {
                var polarData:PolarData = new PolarData()
                polarData.boatSpeed = Number(segments[j]);
                polarData.windDir = int(segments[j + 1]);
                polarData.windSpeed = int(segments[1]);
                polarData.timestamp = new Date().time;
                _polarTableFromFile.addFileData(polarData);
            }
        }
        if (!setNewPolarTable) {
            return false
        }
        return true;
    }

    public function dispatchPolarFileLoaded():void {
        dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_FILE_LOADED));
    }

    public function dispatchBadExtensionWarningEvent():void {
        dispatchEvent(new Event("bad-extension"));
    }

    public function dispatchBadFileWarningEvent():void {
        dispatchEvent(new Event("bad-file"));
    }

    public function dispatchBadCloudWarningEvent():void {
        dispatchEvent(new Event("bad-cloud"));
    }

    public function dispatchTooLargeWarningEvent():void {
        dispatchEvent(new Event("too-large"));
    }

    public function dispatchPolarCloudLoadProcessEvent(data:Number):void {
        dispatchEvent(new PolarCloudLoadEvent(PolarCloudLoadEvent.LOAD_PROCESS, data));
    }

    public function dispatchPolarCloudLoadReadyEvent(data:Number):void {
        dispatchEvent(new PolarCloudLoadEvent(PolarCloudLoadEvent.LOAD_READY, data));
    }

    public function load():void {
        var data:ByteArray = EdoLocalStore.getItem("polarFile");
        if (data != null) {
//            var polarFile:String = String(data.readObject());
//            var split:Array = polarFile.split(/\\|\//);
//            _polarTableName = split[split.length - 1];
            _polarTableName = String(data.readObject());
//            var file:File = File.applicationStorageDirectory.resolvePath(polarFile);
//            data = EdoLocalStore.getItem("polarFileModificationDate");
//            if (file.exists && data != null && file.modificationDate != null && file.modificationDate.getTime() > (data.readObject() as Date).getTime()) {
//                openPolarFromFile(file, false);
//            } else {
            loadPolarFromFile();
//            }
        } else {
            loadDemoPolar();
        }
    }

    private function loadPolarFromFile(onLoad:Boolean = true):void {
        var file:File = File.applicationStorageDirectory.resolvePath("polar." + _polarTableName.split(".")[1]);
        if (file.exists) {
            openPolarFromFile(file, true);
        } else {
            loadDemoPolar();
        }
    }

    private function loadDemoPolar():void {
        _polarTableName = "";
        var file:File = File.applicationDirectory.resolvePath("configs/demo_polar.csv");
        if (file.exists) {
            _polarTableName = "Default polar";
            openPolarFromFile(file, true);
        }
    }

    private function save(file:File, name:String = null):void {
        if (name == null) {
            name = file.name;
        }
        _polarTableName = name;
        savePolarFilePropertiesToEdoLocalStore(file, false, name);
        file.copyTo(File.applicationStorageDirectory.resolvePath("polar." + name.split(".")[1]), true);

        dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_FILE_SAVED));
    }

    private function savePolarFilePropertiesToEdoLocalStore(file:File, isAuto:Boolean = false, name:String = null):void {
        if (name == null) {
            name = file.name;
        }
        var data:ByteArray = new ByteArray();
        if (!isAuto) {
            data.writeObject(name);
            EdoLocalStore.setItem("polarFile", data);
        }
        if (file.modificationDate != null) {
            data = new ByteArray();
            data.writeObject(file.modificationDate);
            EdoLocalStore.setItem("polarFileModificationDate", data);
        }
    }

    public function get polarTableName():String {
        return _polarTableName;
    }

//    public function get isAppendOn():Boolean {
//        return _isAppendOn;
//    }

//    public function set isAppendOn(value:Boolean):void {
//        if (value == _isAppendOn) {
//            return;
//        }
//        if (_polarTableFromFile == null && !isLiveData) {
//            _isAppendOn = true;
//        } else {
//            _isAppendOn = value;
//        }
//        dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_APPEND_CHANGED));
//    }

    private function docsDir_selectHandler(event:Event):void {
        var newFile:File = event.target as File;
        var str:String = _polarTableFromFile != null ? _polarTableFromFile.getContentForExportJustBaseDatas() : "";
        var stream:FileStream = new FileStream();
        stream.open(newFile, FileMode.WRITE);
        stream.writeUTFBytes(str);
        stream.close();
        save(newFile);
        dispatchEvent(new Event("savePolar"));

//        AppProperties.polarWin.deactivate();
    }

    public function polarAutoSave():void {
        //TODO add notification if demo license

        var file:File = File.applicationStorageDirectory.resolvePath("polar.csv");
        var str:String = _polarTableFromFile != null ? _polarTableFromFile.getContentForExportJustBaseDatas() : "";
        var stream:FileStream = new FileStream();
        stream.open(file, FileMode.WRITE);
        stream.writeUTFBytes(str);
        stream.close();
        savePolarFilePropertiesToEdoLocalStore(file, true);

    }

    public function changemeasuerdWeights(n:Number):void {
        PolarTable.measuredMaxWeight = n;
        polarReady();
    }

    public function changemeasuerdVInterpolatedWeights(n:Number):void {
        PolarTable.vInterpolatedWeight = n;
        PolarTable.hInterpolatedWeight = 30 - n;
        polarReady();
    }

    public function changemeasuerdHInterpolatedWeights(n:Number):void {
        PolarTable.hInterpolatedWeight = n;
        polarReady();
    }

    public function changemeasuerdMInterpolatedWeights(n:Number):void {
        PolarTable.mInterpolatedWeight = n;
        polarReady();
    }

    public function onOffHorizontalInterpolation(b:Boolean):void {
        PolarTable.horizontalInterpolationEnabled = b
        polarTableFromFile.polarLoadReadyForFile();
        dispatchPolarFileLoaded();
    }

    public function setTension(value:Number):void {
        PolarTable.tension = value;
        polarTableFromFile.polarLoadReadyForFile();
        dispatchPolarFileLoaded();
    }

    public function onOffVerticalInterpolation(b:Boolean):void {
        PolarTable.verticalInterpolationEnabled = b
        polarTableFromFile.polarLoadReadyForFile();
        dispatchPolarFileLoaded();
    }

    public function wAngle(n:Number):void {
        PolarTable.angleAvg = n;
        polarReady();

    }

    public function polarReady():void {
        _polarTable.polarLoadReady();
//        _polarTableFromFile.polarLoadReady();
        dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_READY));
//        dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_FILE_LOADED));
        saveSettings();
    }

    public var windFilterSelectedIndex:uint = 3;

    public function setWindFilter(n:uint):void {
        switch (n) {
            case 0:
                PolarTable.bypass1 = true;
                PolarTable.bypass2 = true;
                PolarTable.bypass3 = true;
                PolarTable.bypass4 = true;
                PolarTable.bypass5 = true;
                PolarTable.bypass6 = true;
                break;
            case 1:
                PolarTable.setWindFilterLow()
                break;
            case 2 :
                PolarTable.setWindFilterMed()
                break;
            case 3:
                PolarTable.setWindFilterHigh()
                break;
        }
        windFilterSelectedIndex = n;
        resetReadd();
        saveSettings();
    }

    public function resetReadd():void {
        reset(this.containers);
//        loadDataFromGraphs(this.containers);

    }

    public function openCloseSettings():void {
        dispatchEvent(new Event("openPolarSettings"));
    }

    public function set showForceFields(value:Boolean):void {
        PolarTable.showForceFields = value;
        dispatchEvent(new PolarEvent(null, PolarEvent.SHOW_FORCE_DOTS));
        saveSettings()
    }

    public function polarFileDataChange(boatSpeed:Number, windDirection:Number, windSpeed:Number):void {
        _polarTableFromFile.table[windSpeed][windDirection].baseCalculated = boatSpeed;
        _polarTableFromFile.table[windSpeed][windDirection].isFromFile = true;
        restartPolarCalculatorTimer();
    }

    public function clearTableAtSpeed(windSpeed:Number):void {
        var length:int = _polarTableFromFile.table[windSpeed].length;
        for (var i:int = 0; i < length; i++) {
            _polarTableFromFile.table[windSpeed][i].baseCalculated = 0;
            _polarTableFromFile.table[windSpeed][i].isFromFile = true;
        }
        setChanged();
        restartPolarCalculatorTimer();
    }

    private function polarcalculatorTimer_timerHandler(event:TimerEvent):void {
        _polarTableFromFile.polarLoadReadyForFile();
        _lastRender = getTimer();
        dispatchPolarFileLoaded();
        _polarcalculatorTimer.stop();
        _polarFileAutoSaveTimer.start();
    }

    public function resetPolarCalculatorTimer():void {
        _polarcalculatorTimer.reset();
        _polarFileAutoSaveTimer.reset();
    }

    public function restartPolarCalculatorTimer():void {
        resetPolarCalculatorTimer()
        _polarcalculatorTimer.start();
    }

    public function get polarTableFromFile():PolarTable {
        return _polarTableFromFile;
    }

    private function polarFileAutoSaveTimer_timerHandler(event:TimerEvent):void {
        polarAutoSave()
        _polarFileAutoSaveTimer.stop();
    }

    public function get lastRender():Number {
        return _lastRender;
    }

    public function set lastRender(value:Number):void {
        _lastRender = value;
    }

//    public function loadFromNmea():void {
//        var doc:File = File.desktopDirectory
//        doc.browseForOpen("Load Polar cloud from NMEA file");
//        doc.addEventListener(Event.SELECT, loadFromNmeaHandler, false, 0, true);
//    }
//
//    private function loadFromNmeaHandler(event:Event):void {
//        var logFile:File = event.target as File;
//        //WorkersHandler.instance.mainToPolarWorker.send({action: "start", logFilePath: logFile.nativePath});
//        dispatchEvent(new PolarWorkerEvent("start", logFile.nativePath));
//        dispatchEvent(new Event("enablePolar"));
//    }

    public function loadFromNmea(file:File):void {
        dispatchEvent(new PolarWorkerEvent("start", file.nativePath));
        //dispatchEvent(new Event("enablePolar"));
    }


    public function dispatchPolarResetEvent():void {
        dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_RESET_EVENT))
    }

    public function dispatchPolarCloudReady():void {
        dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_CLOUD_READY));
    }


    public function setChanged():void {
        _isChanged = true;

        dispatchEvent(new PolarEvent(null, PolarEvent.POLAR_CHANGED));
    }

    public function get isChanged():Boolean {
        return _isChanged;
    }
}
}
