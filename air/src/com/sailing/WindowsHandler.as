package com.sailing {
import com.alarm.AlarmHandler;
import com.alarm.AnchorChange;
import com.alarm.speech.SpeechContainer;
import com.common.AppProperties;
import com.common.CleanAppProperies;
import com.events.EnableDisableEvent;
import com.events.UnitChangedEvent;
import com.events.UpdateNmeaDatasEvent;
import com.graphs.GraphHandler;
import com.greensock.events.LoaderEvent;
import com.layout.LayoutHandler;
import com.logbook.LogBookDataHandler;
import com.loggers.SystemLogger;
import com.polar.PolarContainer;
import com.sailing.ais.AisContainer;
import com.sailing.combinedDataHandlers.CombinedDataHandler;
import com.sailing.instruments.BaseInstrument;
import com.sailing.interfaces.IHeading;
import com.sailing.minMax.MinMaxHandler;
import com.sailing.units.UnitHandler;
import com.ui.TopBar;
import com.utils.EdoLocalStore;
import com.utils.HeadingUtil;
import com.utils.TimestampCalculator;

import components.IInstrument;
import components.InstrumentSelector;
import components.ais.AisComponent;
import components.ais.AisMap;
import components.graph.custom.GraphInstance;
import components.graph.custom.VGraphInstance;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.display.PixelSnapping;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.geom.Matrix;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.System;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.describeType;
import flash.utils.getTimer;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipFile;

//import mx.flash.UIMovieClip;

[Event(name="updateNmeaDatas", type="com.events.UpdateNmeaDatasEvent")]


public class WindowsHandler extends EventDispatcher {
    private static var _instance:WindowsHandler;
    public var listeners:Object = {};
    public var windows:Vector.<IInstrument> = new <IInstrument>[];
    private var _actualSailData:SailData;
    public var application:Edo;
    private var _dataSource:String = "socket";
    private var timestampCalculator:TimestampCalculator;
    private var loader:Loader;
    private var urlLoader:URLLoader
    private var request:URLRequest
    private var swcsArray:Array = [];
    private var swcsArrayFiles:Array = [];
    private var loadedSwcs:Number = 0;
    private var actualFile:File;
    private var _controllsDp:Array = [];

    private var _isValidTimer:Timer;
    public var allSwcsLoaded:Boolean = false;

    public function WindowsHandler() {
        if (_instance != null) {
            throw new Error("Singleton can only be accessed through Singleton.instance");
        } else {

            _actualSailData = new SailData();
            SailData.actualSailData = _actualSailData
            _instance = this;
//            _instance.addEventListener(UpdateNmeaDatasEvent.UPDATE_NMEA_DATAS, updateSailDatas, false, 0, true)
            CombinedDataHandler.instance.addEventListener(UpdateNmeaDatasEvent.UPDATE_NMEA_DATAS, combineDataHandler, false, 0, true)
            UnitHandler.instance.addEventListener(UnitChangedEvent.CHANGE, unitChangedNotifier, false, 0, true);
            timestampCalculator = new TimestampCalculator();

            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _handleComplete, false, 0, true);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _handleIOError, false, 0, true);
            [Embed(source="../../../assets/images/graf_icon.png")] var hLineGrapClass:Class;
            var hLineGrapBitmap:Bitmap = new hLineGrapClass();
            [Embed(source="../../../assets/images/h_graph_icon.png")] var hAreaGrapClass:Class;
            var hAreaGrapBitmap:Bitmap = new hAreaGrapClass();
            [Embed(source="../../../assets/images/v_graph_icon.png")] var vLineGrapClass:Class;
            var vLineGrapBitmap:Bitmap = new vLineGrapClass();
            [Embed(source="../../../assets/images/ais.png")] var aisBitmapClass:Class;
            var aisBitmap:Bitmap = new aisBitmapClass();
            [Embed(source="../../../assets/images/aismap.png")] var aisMapBitmapClass:Class;
            var aisMapBitmap:Bitmap = new aisMapBitmapClass();

            listSwcsInDirectory();

            _controllsDp.push({
                controllName: 'Horizontal  graph',
                controllClass: 'customGraph1',
                bitmap: new hAreaGrapClass()
            })
            _controllsDp.push({
                controllName: 'Vertical  graph',
                controllClass: 'customGraph2',
                bitmap: new vLineGrapClass()
            })
            _controllsDp.push({
                controllName: 'AIS',
                controllClass: 'aisComponent',
                bitmap: aisBitmap

            })
//            controllsDp.addItem({
//                controllName: 'AIS map',
//                controllClass: 'aisMapComponent',
//                bitmap: aisMapBitmap
//
//            })

            loadInstumentsFromGeneratedSource();

            // load the swc
            urlLoader = new URLLoader()
            urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            urlLoader.addEventListener(Event.COMPLETE, swcLoadCompleteHandler, false, 0, true);
            _isValidTimer = new Timer(1000);//BaseSailData.PRE_VALID_THRESHOLD);
            _isValidTimer.addEventListener(TimerEvent.TIMER, isValidTimer_timerHandler, false, 0, true);
            _isValidTimer.start();
        }
    }

    private function isValidTimer_timerHandler(event:TimerEvent):void {
        if (!isSocketDatasource()) {
            return;
        }
        for (var key:String in listeners) {
            if (_actualSailData[key].isInPreValid && !_actualSailData[key].isPreValid()) {
                _actualSailData[key].isInPreValid = false;
                setPreValid(key);
            }
            if (_actualSailData[key].isInValid && !_actualSailData[key].isValid()) {
                _actualSailData[key].isInValid = false;
                setValid(key);
            }
        }
        if (AppProperties.messagesWin != null && !AppProperties.messagesWin.closed) {
            AppProperties.messagesWin.validRefresh();
        }
    }

    public function setPreValid(key:String):void {
        var actualUpdatableListneres:Array = listeners[key];
        if (actualUpdatableListneres != null) {
            for (var i:int = 0; i < actualUpdatableListneres.length; i++) {
                var currentControll = actualUpdatableListneres[i];
                try {
                    currentControll.dataPreInvalidated(key);
                } catch (e:Error) {
                    continue;
                }
            }
        }
    }

    public function setValid(key:String):void {
        var actualUpdatableListneres:Array = listeners[key];
        if (actualUpdatableListneres != null) {
            for (var i:int = 0; i < actualUpdatableListneres.length; i++) {
                var currentControll = actualUpdatableListneres[i];
                try {
                    currentControll.dataInvalidated(key);
                } catch (e:Error) {
                    continue;
                }
            }
        }
    }

    public function unitChangedNotifier(event:UnitChangedEvent):void {
        for (var key:String in listeners) {
            var actualUpdatableListneres:Array = listeners[key];
            if (actualUpdatableListneres != null) {
                for (var i:int = 0; i < actualUpdatableListneres.length; i++) {
                    var currentControll = actualUpdatableListneres[i];
                    try {
                        currentControll.unitChanged();
                        if (currentControll is BaseInstrument) {
                            (currentControll as BaseInstrument).updateDatas(_actualSailData);
                        }
                    } catch (e:Error) {
                        continue;
                    }
                }
            }

        }
    }


    private function listSwcsInDirectory(path:String = "instruments"):void {
        var appDir:File = File.applicationDirectory;
        appDir = appDir.resolvePath(path)
        if (!appDir.exists) {
            return;
        }
        var filesInDirectory:Array = appDir.getDirectoryListing();
        for (var i:int = 0; i < filesInDirectory.length; i++) {
            var file:File = filesInDirectory[i];
            if (file.extension === "swc") {
                swcsArray.push(file.url)
                swcsArrayFiles.push(file)
            } else if (file.isDirectory) {
                listSwcsInDirectory(path + "/" + file.name)
            }
        }

    }

    public function loadSwcsByLoaderMax():void {
        allSwcsLoaded = true;
        allLoadingComplete();
//        LoaderMax.registerFileType("swc", BinaryDataLoader);
//        LoaderMax.activate([BinaryDataLoader]);
//        var queue:LoaderMax = LoaderMax.parse(swcsArray, {onProgress: progressHandler, onComplete: completeHandler, onChildFail: childFailHandler})
//        queue.addEventListener(LoaderEvent.CHILD_COMPLETE, swcLoadCompleteHandler, false, 0, true); //checks when a child has completed to load
//
//        queue.load()
    }

    function progressHandler(event:LoaderEvent):void {
        // trace("progress: " + event.target.progress);
    }

    function completeHandler(event:LoaderEvent):void {
        loadNextSwf();
    }

    private function startLoadingSwfByteArrays():void {

    }

    private var swfBytes:Array = [];
    private var actualSwfIndex = 0;

    private function loadNextSwf():void {
        var lc:LoaderContext = new LoaderContext();
        lc.allowCodeImport = true;
        if (actualSwfIndex < swfBytes.length) {
            var swf:Object = swfBytes[actualSwfIndex];
            actualFile = getActualFileFromSwcFiles(swf.url)
            if (actualFile == null) {
                return;
            }
            loader.loadBytes(swf.data, lc)
        } else {
            allSwcsLoaded = true;
            allLoadingComplete();
        }

    }

    public function allLoadingComplete():void {
        if (allSwcsLoaded && SpeechContainer.isComplete) {
            application.allLoadComplete();
            swfBytes = null;
            swcsArray = null;
            swcsArrayFiles = null;

        }
    }

    function childFailHandler(event:LoaderEvent):void {
        trace(event.target + " failed.");
    }


    private function swcLoadCompleteHandler(event:Event):void {
        var loadedData:ByteArray = event.target.content as ByteArray;
        var zipFile:ZipFile = new ZipFile(loadedData);
        var lc:LoaderContext = new LoaderContext();
        lc.allowCodeImport = true;
        // this example assumes there is only one swf file
        // in the swc :  library.swf
        // would be safer to parse catalog.xml

        SystemLogger.Debug("START LOADING SWC: " + event.target.url)
        for (var i:int = 0; i < zipFile.entries.length; i++) {
            var entry:ZipEntry = zipFile.entries[i];
            var data:ByteArray = zipFile.getInput(entry);

            if (entry.name == "catalog.xml") {
                // we'll do nothing in this example
            }
            if (entry.name == "library.swf") {
                // load the library
//                trace("loadbyte " + actualFile.name);
//                loader.loadBytes(data, lc);
                swfBytes.push({data: data, url: event.target.url})
            }
        }
    }

    private function getActualFileFromSwcFiles(url:String):File {
        for each (var file:File in swcsArrayFiles) {
            if (file.url == url) {
                return file;
            }
        }
        return null;
    }

    private function _handleComplete(event:Event):void {
        trace("handle swf complete ", actualFile.name);
        var loaderInfo:LoaderInfo = event.target as LoaderInfo;
        var loader:Loader = loaderInfo.loader;
        var object:* = loaderInfo.content;
        var dom:ApplicationDomain = loader.contentLoaderInfo.applicationDomain
        var classInfo:XML = describeType(object);
        if (classInfo.variable.toString() != "") {
            var class_:Class = dom.getDefinition(classInfo.variable[0].@type.toString()) as Class;
            var classAlias:String = actualFile.url;
            var tempObject:MovieClip = new class_();
            var bitmap:Bitmap;
            if (tempObject.hasOwnProperty("smallBitmap")) {
                bitmap = tempObject.smallBitmap;
            } else {
                bitmap = new Bitmap();
                var data:BitmapData = new BitmapData(tempObject.width, tempObject.height)
                data.draw(tempObject);
                bitmap.bitmapData = data;
            }

            trace("add item as " + actualFile.name)
            _controllsDp.push({controllName: actualFile.name, bitmap: bitmap, controllClass: classAlias, klass: class_, filePath: actualFile.nativePath})

        } else {
            SystemLogger.Debug("INSTRUMENT NOT FOUND " + actualFile.name)
        }

        actualSwfIndex++;
        loadNextSwf();

    }

    private function getItemByClassFromControllsDp(name:String):Object {
        for each (var object:Object in _controllsDp) {
            if (object.controllClass === name) {
                return object;
            }
        }
        return null;
    }

//itt hozzuk letre az uj muszer objetumot
    public function createWindowControl(className:String):Object {
        trace(className);
        switch (className) {
//            case 'customFlexChart1342434130811':
//                return new HLineGraph(0x00aeef, 1, false, 0x000000, 1, 'vhw.waterHeadingMagnetic', 'vhw.waterHeadingMagnetic chart');
//                break;
//
//            case 'customFlexChart1342434130812':
//                return new VLineGraph(0x00aeef, 1, false, 0x000000, 1, 'mwv.windSpeedKnots', 'mwv.windSpeedKnots chart');
//                break;
//
//            case 'customFlexChart1342434130813':
//                return new HAreaGraph(0x00aeef, 1, false, 0x000000, 1, 0x00aeef, 0.8, 'mwd.windSpeed', 'mwv.windSpeedKnots chart');
//                break;
            case 'customGraph1':
                return new GraphInstance('rsa_rudderSensorStarboard', 0x000000);
                break;
            case 'customGraph2':
                return new VGraphInstance('rsa_rudderSensorStarboard', 0x000000);
                break;
            case 'aisComponent':
                return new AisComponent();
                break;
            case 'aisMapComponent':
                return new AisMap();
                break;

            default:
                try {
                    var item:Object = getItemByClassFromControllsDp(className);
                    if (item == null) {
                        trace(className, " is NULL")
                        return null;
                    }
                    var klass:Class = item.klass as Class;
                    var h:Object = new klass();
                    return h;

                } catch (e:Error) {
                    trace(e.getStackTrace());
                    trace(e.message)
                }

                break;

        }
        return null;
    }


    public static function get instance():WindowsHandler {
        if (_instance == null) {
            _instance = new WindowsHandler();

            //DataLogger.instance.addEventListener("graph-datas-need-refresh", handleGraphRefres, false, 0, true)
        }

        return _instance;
    }


    public function getActualSailData():SailData {

        return _actualSailData;
    }


    var tempTimestamp:Number = 0;

    private function combineDataHandler(event:UpdateNmeaDatasEvent):void {
        updateSailDatas(event.data);
    }

    public function updateSailDatas(data:Object):void {
        var key:String = data.key;
        var newData = data.data;
        if (data == null || key == null || newData == null) return;
        if (key === "vdm" || key === "vdo") {
            return;
        } //AIS data handled in other area


        //TODO itt lehet elteres, foleg ha loggal szimulalt live adat jon, de ha utc is van akkor is elterhet
        //ezert ket megoldas lehet. a new Date utc szerint konvertaljuk
        //vagy egeszen addig nem mentunk semmit sem amig nincs timestamp uzenetbol (ez jobb megoldasnak tunik)
        if (tempTimestamp == 0) {
            tempTimestamp = -1//new Date().time;
        }
//        trace(new Date(_actualSailData.sailDataTimestamp).toString())
        if (TimestampCalculator.isKeyHasTimestamp(key)) {
            if (key == "zda" || key == "rmc") {
                tempTimestamp = timestampCalculator.dateFromNmeaTimestamp(newData.hour, newData.min, newData.sec, newData.utc);
                if (tempTimestamp != -1) {
                    LogBookDataHandler.instance.gotNewZda();
                    AppProperties.licenseManager.validateByGps(new Date(tempTimestamp));
                }
            } else {
                tempTimestamp = timestampCalculator.dateFromNmeaTimestamp(newData.hour, newData.min, newData.sec); //new Date().time
            }
            if (tempTimestamp == -1) {
                tempTimestamp = timestampCalculator.actualTimestamp;
            }
            PolarContainer.instance.timestampChange(tempTimestamp);
        }
        _actualSailData.sailDataTimestamp = tempTimestamp;
        CleanAppProperies.actualNmeaTimestamp = getTimer();
        newData.lastTimestamp = getTimer();
        _actualSailData[key] = newData;
        //TODO ais own ship handle from vod
        AisContainer.instance.ownShip.timestamp = tempTimestamp;
        if (HeadingUtil.isKeyInRegexp(key) && newData is IHeading) {
            AisContainer.instance.ownShip.heading = newData.heading();
        }

        AlarmHandler.instance.sailDataChanged(key, newData);
        MinMaxHandler.instance.updateMinMax(key, newData);
        CombinedDataHandler.instance.updateDatas(key, newData, tempTimestamp);
        var actualUpdatableListneres:Array = listeners[key];
        if (actualUpdatableListneres != null && isSocketDatasource()) {
            for (var i:int = 0; i < actualUpdatableListneres.length; i++) {
                var currentControll = actualUpdatableListneres[i];
                if (currentControll is BaseInstrument) {
                    (currentControll as BaseInstrument).updateDatas(_actualSailData);
                }
            }
        }
        if (tempTimestamp != -1) {
            GraphHandler.instance.addLiveData(data, _actualSailData.sailDataTimestamp);
        }

        if (AppProperties.messagesWin != null && !AppProperties.messagesWin.closed) {
            AppProperties.messagesWin.messageRefreshed(key);
        }

        if (key === "truewindc" || key === "positionandspeed" || key === "vhw") {
            PolarContainer.instance.addLiveData(newData);
        }
    }


    public function resetInstruments():void {
        _actualSailData = new SailData();
        SailData.actualSailData = _actualSailData;
        timestampCalculator = new TimestampCalculator();
        _actualSailData.sailDataTimestamp = new Date().time;
        AisContainer.instance.ownShip.heading = 0;
        for (var key:String in listeners) {
            var actualUpdatableListneres:Array = listeners[key];
            if (actualUpdatableListneres != null && isSocketDatasource()) {
                for (var i:int = 0; i < actualUpdatableListneres.length; i++) {
                    var currentControll = actualUpdatableListneres[i];
                    if (currentControll is BaseInstrument) {
                        (currentControll as BaseInstrument).updateDatas(_actualSailData);
                    }
                }
            }
            setValid(key);
        }
    }

    public function isSocketDatasource():Boolean {
        return dataSource === "socket"
    }


    public function playLogData(data:Object, needTween:Boolean = true):void {
        var key:String = data.key;
//        var newData = data.data;

//        _actualSailData[key] = newData;
//        _actualSailData.sailDataTimestamp = new Date().time;


        var actualUpdatableListneres:Array = listeners[key];
        if (actualUpdatableListneres != null) {
            for (var i:int = 0; i < actualUpdatableListneres.length; i++) {
                var currentControll = actualUpdatableListneres[i];
                if (currentControll is BaseInstrument) {
                    (currentControll as BaseInstrument).updateDatas(_actualSailData, needTween);
                }
            }
        } else {
            SystemLogger.Debug("no listener found: " + key);
        }
        //AlertHandler.instance.broadcastData(PrevSailData);
    }


    public function loadSavedBarButton():void {
        var tempWindows:ByteArray = EdoLocalStore.getItem("savedWindows");
        var encodedeTempWindows:String;
        if (tempWindows != null) {
            encodedeTempWindows = tempWindows.readObject();
            LayoutHandler.instance.loadedButtonName = encodedeTempWindows;
        }

    }


    public function get dataSource():String {
        return _dataSource;
    }

    public function set dataSource(value:String):void {
        _dataSource = value;

        if (isSocketDatasource()) {
            PolarContainer.instance.isLiveData = true;
            AnchorChange.instance.logReplay = false;
            if (TopBar.menuList != null) {
                TopBar.menuList.dispatchEvent(new EnableDisableEvent(EnableDisableEvent.ENABLE, "nmeaMessagesE"));
            }
        } else {
            PolarContainer.instance.isLiveData = false;
            AnchorChange.instance.logReplay = true;
            if (TopBar.menuList != null) {
                TopBar.menuList.dispatchEvent(new EnableDisableEvent(EnableDisableEvent.DISABLE, "nmeaMessagesE"));
            }
        }
    }


    public function initInstrumentsSelector():void {
        TopBar.instrumentsGroup.x = 0;
        TopBar.instrumentsGroup.y = TopBar.barHeight;
        var object:Object
        for (var i:uint = 0; i < _controllsDp.length; i++) {
            object = _controllsDp[i]
            if (object.bitmap != null && (object.filePath == null || (object.filePath != null && object.filePath.search(/_nv\.swc$/) == -1))) {
                var instrumentSelector:InstrumentSelector = new InstrumentSelector(object.bitmap, object.klass, object.controllName, object.controllClass)
                TopBar.instrumentsGroup.addElement(instrumentSelector)
            }
        }

    }

    private function loadInstumentsFromGeneratedSource():void {

        for (var i:int = 0; i < WindowsHelper.generatedContent.length; i++) {
            var item:Object = WindowsHelper.generatedContent[i];
            if (item.filePath.match("_nv.swc")) {
                continue;
            }

            var tempObject:MovieClip = new (item.klass as Class)();
            var bitmap:Bitmap;
            var scale:Number = 0.10;
            var matrix:Matrix = new Matrix();
            matrix.scale(scale, scale);


            if (item.bitmap == null) {
                var data:BitmapData = new BitmapData(tempObject.width * scale, tempObject.height * scale, true, 0x000000);
                data.draw(tempObject, matrix, null, null, null, true);
                bitmap = new Bitmap(data, PixelSnapping.NEVER, true);

                item.bitmap = bitmap;
            }
            _controllsDp.push(item)
            tempObject = null;

        }
        System.gc();
    }

    private function getBitmap(url:String, callback:Function):void {
        var loader:Loader = new Loader;
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (event:Event):void {
            callback(loader.content);
        }, false, 0, true);
        loader.load(new URLRequest(url));
    }

    public function get actualSailData():SailData {
        return _actualSailData;
    }

//----------------------------------------------------------


    private function _handleIOError(event:IOErrorEvent):void {
        trace(event.toString())
    }

    //Hack hogy az swc loading ne haljon el
    //UIMovieClip

}
}