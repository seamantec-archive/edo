/**
 * Created by pepusz on 2014.04.10..
 */
package com.polar {
import com.loggers.SystemLogger;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.getTimer;

registerClassAlias("com.polar.PolarDataContainer", PolarDataContainer);
registerClassAlias("com.polar.PolarDataWindLayer", PolarDataWindLayer);
registerClassAlias("InnerVector", Vector.<Vector.<uint>> as Class);
registerClassAlias("InnerInnerVector", Vector.<uint> as Class);
registerClassAlias("outerVector", Vector.<PolarDataWindLayer> as Class);
registerClassAlias("uint", uint);

public class PolarDataContainer extends EventDispatcher {
    public static const MAX_WINDSPEED:uint = 30;
    public static const MAX_FILE_SIZE:Number = 31457280; // 30 MB
    public static const FILE_EXTENSION:String = "flh"
    private var _windLayers:Vector.<PolarDataWindLayer>;
    public static var isRecordOn:Boolean = true;

    public function PolarDataContainer() {
        _windLayers = new Vector.<PolarDataWindLayer>(MAX_WINDSPEED + 1, true);
    }

    public function saveToFile():void {
        var docsDir:File = File.desktopDirectory.resolvePath("polarcloud." + FILE_EXTENSION);
        try {
            docsDir.browseForSave("Save polar table");
            docsDir.addEventListener(Event.SELECT, docsDir_selectHandler, false, 0, true);
        } catch (e:Error) {
            SystemLogger.Error("Polar cloud save" + e.message);
        }

    }

    public function loadFromFile():void {
        var doc:File = File.desktopDirectory
        doc.browseForOpen("Open polar cloud");
        doc.addEventListener(Event.SELECT, doc_selectHandler, false, 0, true);
    }

    //TODO autosave

    public function addPolarData(polarData:PolarData):void {
        var wind:uint = Math.round(polarData.windSpeed);
        if (_windLayers[wind] == null) {
            _windLayers[wind] = new PolarDataWindLayer();
        }
        if (isRecordOn) {
            _windLayers[wind].addPolarData(polarData);
        }
    }

    public function resetLayer(wind:uint):void {
        if (_windLayers[wind] != null) {
            _windLayers[wind].nullifyAllData()
        }
    }

    public function resetAllLayer():void {
        for (var wind:int = 0; wind <= MAX_WINDSPEED; wind++) {
            resetLayer(wind);
        }
    }


    public function clearLayer(wind:uint):void {
        if (_windLayers[wind] != null) {
            _windLayers[wind].clearAllData()
            _windLayers[wind] = null;
        }
    }

    public function clearAllLayer():void {
        for (var wind:int = 0; wind <= MAX_WINDSPEED; wind++) {
            clearLayer(wind);
        }
        PolarContainer.instance.dispatchPolarResetEvent()
    }

    public function getPolarDataWindLayerAtWind(wind:uint):PolarDataWindLayer {
        return _windLayers[wind]
    }


    private function docsDir_selectHandler(event:Event):void {
        var newFile:File = event.target as File;
        var stream:FileStream = new FileStream();
        stream.open(newFile, FileMode.WRITE);
        var byteArray:ByteArray = new ByteArray();
        fillUpByteArray(byteArray);
        stream.writeBytes(byteArray, 0, byteArray.length);
        stream.close();
    }

    public function fillUpByteArray(byteArray:ByteArray, withCompression:Boolean = true):void {
        byteArray.writeObject(_windLayers);
        if (withCompression) {
            byteArray.compress();
        }
        byteArray.position = 0;
    }

    public function loadFile(file:File):void {
        var stream:FileStream = new FileStream();
        stream.open(file, FileMode.READ);
        var byteArray:ByteArray = new ByteArray();
        stream.readBytes(byteArray, 0, stream.bytesAvailable);
        stream.close;
        mergeFromByteArray(byteArray);
        PolarContainer.instance.dispatchEvent(new Event("enablePolar"));
    }

    public function mergeFromByteArray(byteArray:ByteArray, withCompress:Boolean = true):void {
        try {
            byteArray.position = 0
            if (withCompress) {
                byteArray.uncompress();
            }
            byteArray.position = 0
            var object:Vector.<PolarDataWindLayer> = byteArray.readObject() as Vector.<PolarDataWindLayer>;
            if (object != null) {
                var count:int = mergeWindLayers(object);
                PolarContainer.instance.dispatchPolarCloudReady();
                PolarContainer.instance.dispatchPolarCloudLoadReadyEvent(Number(count));
            }
        } catch (e:Error) {
            PolarContainer.instance.dispatchBadCloudWarningEvent();
        }
    }

    private function mergeWindLayers(newLayers:Vector.<PolarDataWindLayer>):int {
        var count:int = 0;
        for (var i:int = 0; i < _windLayers.length; i++) {
            var layer:PolarDataWindLayer = _windLayers[i];
            if (newLayers[i] != null) {
                if (layer === null) {
                    _windLayers[i] = new PolarDataWindLayer();
                    layer = _windLayers[i];
                }
                count += layer.mergeOther(newLayers[i])
            }
            PolarContainer.instance.dispatchPolarCloudLoadProcessEvent(((i + 1) / _windLayers.length) * 100)
        }
        return count;
    }

    private function doc_selectHandler(event:Event):void {
        var newFile:File = event.target as File;
        if (newFile.extension === FILE_EXTENSION) {
            loadFile(newFile);
        }
    }

    public function loadFromNmea():void {
        var doc:File = File.desktopDirectory
        doc.browseForOpen("Generate polar cloud from NMEA file");
        doc.addEventListener(Event.SELECT, loadFromNmeaHandler, false, 0, true);
    }

    private function loadFromNmeaHandler(event:Event):void {
        trace("file selected");
        var logFile:File = event.target as File;
        var startTime:uint = getTimer();
        var parsableKeys:RegExp = new RegExp(/MWV|VHW|RMC/i)
        if (logFile.size <= MAX_FILE_SIZE && (logFile.extension === "txt" || logFile.extension === "nmea")) {
            var packeter:NmeaPacketer = new NmeaPacketer();
            var fileStream:FileStream = new FileStream();
            fileStream.open(logFile, FileMode.READ);
            var fileContent:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
            fileStream.close();
            var messages:Array = packeter.newReadPacket(fileContent, true);
            var messagesLength:uint = messages.length;
            var x:Object;
            var found:uint = 0;
            for (var i:int = 0; i < messagesLength; i++) {
                if (messages[i].match(parsableKeys)) {
                    x = NmeaInterpreter.processWithMessageCode(messages[i]);
                    found++;
                }

            }

        }
        trace("found", found, "loadPolarDots time:", getTimer() - startTime)
    }
}
}
