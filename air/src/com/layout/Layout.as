/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.25.
 * Time: 17:17
 * To change this template use File | Settings | File Templates.
 */
package com.layout {
import com.common.AppProperties;
import com.common.InstrumentMouseHandler;
import com.graphs.GraphHandler;
import com.loggers.SystemLogger;
import com.polar.PolarContainer;
import com.polar.PolarEvent;
import com.sailing.WindowsHandler;
import com.sailing.ais.AisContainer;
import com.sailing.ais.Vessel;
import com.sailing.instruments.BaseInstrument;
import com.sailing.minMax.MinMaxHandler;
import com.ui.TopBar;
import com.ui.controls.InstrumentsGroup;
import com.utils.EdoLocalStore;

import components.ControlEmbedable;
import components.ControlWindowAs;
import components.IInstrument;
import components.PolarSettings;
import components.ais.AisComponent;
import components.ais.AisDetails;
import components.ais.AisDetailsWindow;
import components.ais.AisMap;
import components.ais.IAisComponent;
import components.graph.IGraph;
import components.graph.custom.GraphInstance;
import components.graph.custom.VGraphInstance;

import flash.display.Sprite;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.utils.ByteArray;

public class Layout extends Sprite {

    public static const PREDEF_LAYOUT:int = 0;
    public static const USER_LAYOUT:int = 1;

    private var _layoutFile:File;
    private var _layoutName:String;
    private var _layoutType:int;
    private var _listeners:Object = {};
    private var _graphListeners:Object = {};
    private var _windows:Vector.<IInstrument> = new <IInstrument>[];
    private var _isFullscreen:Boolean = true;
    private var _editEnabled:Boolean = false;
    private var _predeopenfWidth:int;
    private var _predefHeight:int;
    private var _widthOffset:int;
    private var _heightOffset:int;
    private var _aisDetails:AisDetails;
    private var _predefWidth:int;
    private var _polarSettings:PolarSettings;

    private var _changeFullscreen:Boolean;
    private var _initWidth:uint;
    private var _initHeight:uint;
    private var _version:String = "";

    public function Layout(name:String) {
        super();
        drawBg();
        _initWidth = AppProperties.screenWidth;
        _initHeight = AppProperties.screenHeight;
        _aisDetails = new AisDetails();
        _aisDetails.hide();
//        _aisDetails.depth = 10000;

        _polarSettings = new PolarSettings();
        _polarSettings.hide();

//        PolarContainer.instance.addEventListener("openPolarSettings", openPolarSettingsHandler, false, 0, true);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_FILE_LOADED, polarFileLoadedHandler, false, 0, true);

        this.addChild(_aisDetails)
//        this.width = AppProperties.screenWidth;
//        this.height = AppProperties.screenHeight;
        this.x = 0;
        this.y = TopBar.barHeight
        this._layoutName = name;
        if (this._layoutName.match("usr")) {
            _layoutType = USER_LAYOUT
            _editEnabled = true;
        } else {
            _layoutType = PREDEF_LAYOUT;
            _editEnabled = true;
        }

        openFile();
        loadIsFullscreen();
        _changeFullscreen = false;
        if (_isFullscreen) {
            loadLayout()
        }
    }

    private function drawBg():void {
        this.graphics.clear();
        this.graphics.beginFill(0x00ff00, 0.0)
        this.graphics.drawRect(0, 0, AppProperties.screenWidth, AppProperties.screenHeight)
        this.graphics.endFill();
    }


    private function openFile():void {
        _layoutFile = File.applicationStorageDirectory.resolvePath("layouts/");
        var name:String = _layoutName + ".layout";

        if (_layoutType == USER_LAYOUT && checkIsLayoutPresent(name, _layoutFile)) {
            _layoutFile = _layoutFile.resolvePath(AppProperties.screenWidth + "_" + AppProperties.screenHeight + "/" + name);
        } else {
            var dir:String;
            if (_layoutType == PREDEF_LAYOUT) {
                _layoutFile = File.applicationDirectory.resolvePath("layouts/");
                dir = getPreDefFile(name);
            } else {
                _layoutFile = File.applicationStorageDirectory.resolvePath("layouts/");
                dir = getPreDefFile(name, true);
            }
            if (dir != null) {
                _layoutFile = _layoutFile.resolvePath(dir).resolvePath(name);
                var resolution:Array = dir.split("_");
                var w:Number = Number(resolution[0]);
                var h:Number = Number(resolution[1]);
                var widthDiff:Number = AppProperties.screenWidth / w;
                var heightDiff:Number = AppProperties.screenHeight / h;
                var ratio:Number = (widthDiff < heightDiff) ? widthDiff : heightDiff;
                var xDiff:Number = 0;
                if (AppProperties.screenWidth >= w) {
                    xDiff = (AppProperties.screenWidth - (w * ratio)) / 2;
                }
                var yDiff:Number = 0;
                if (AppProperties.screenHeight >= h) {
                    yDiff = (AppProperties.screenHeight - (h * ratio)) / 2;
                }

                var fileStream:FileStream = new FileStream();
                var input:XML;
                if (_layoutFile.exists) {
                    fileStream.open(_layoutFile, FileMode.READ);
                    fileStream.position = 0;
                    input = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
                }

                if (_layoutType == PREDEF_LAYOUT && checkIsLayoutPresent(name, File.applicationStorageDirectory.resolvePath("layouts/"))) {
                    var app:File = File.applicationStorageDirectory.resolvePath("layouts/" + AppProperties.screenWidth + "_" + AppProperties.screenHeight + "/" + name);
                    fileStream = new FileStream();
                    fileStream.open(app, FileMode.READ);
                    fileStream.position = 0;
                    var output:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
                    fileStream.close();
                    if (isXMLVersionDifference(input, output)) {
                        if (app.exists) app.deleteFile();
                        recalculateLayout(input, name, ratio, xDiff, yDiff);
                    }
                } else if (input != null) {
                    recalculateLayout(input, name, ratio, xDiff, yDiff);
                }
            }

            _layoutFile = File.applicationStorageDirectory.resolvePath("layouts/" + AppProperties.screenWidth + "_" + AppProperties.screenHeight + "/" + name);
        }
    }

    private function checkIsLayoutPresent(fileName:String, dir:File):Boolean {
        var file:File = dir.resolvePath(AppProperties.screenWidth + "_" + AppProperties.screenHeight + "/");
        if (file.exists) {
            file = file.resolvePath(fileName);
            if (file.exists) {
                return true;
            }
        }
        return false;
    }

    private function getPreDefFile(name:String, isUserLayout:Boolean = false):String {
        var resolutionDirectory:File = _layoutFile.resolvePath(AppProperties.screenWidth + "_" + AppProperties.screenHeight + "/" + name);
        if (resolutionDirectory.exists && !isUserLayout) {
            var destination:File = File.applicationStorageDirectory.resolvePath("layouts/" + AppProperties.screenWidth + "_" + AppProperties.screenHeight + "/" + name);
            if (destination.exists) {
                if (isLayoutVersionDifference(resolutionDirectory, destination)) {
                    //destination.deleteFile();
                    resolutionDirectory.copyTo(destination, true);
                }
            } else {
                resolutionDirectory.copyTo(destination, true);
            }
            return null;
        } else {
            var ratio:Number = AppProperties.screenWidth / AppProperties.screenHeight;
            var area:Number = AppProperties.screenWidth * AppProperties.screenHeight;
            var minDist:Number;
            var minDiff:Number;
            var minI:int = 0;
            if (!_layoutFile.exists) {
                return null;
            }
            var files:Array = _layoutFile.getDirectoryListing();
            for (var i:int = 0; i < files.length; i++) {
                var j:int = -1;
                var file:File = files[i] as File;

                var l:Boolean = file.isDirectory && file.name.indexOf("_") != -1;
                if (isUserLayout) {
                    l = l && file.name != (AppProperties.screenWidth + "_" + AppProperties.screenHeight);
                }
                if (l) {
                    j++;
                    var p:Array = file.name.split("_");
                    var directoryRatio:Number = Number(p[0]) / Number(p[1]);
                    var dist:Number = Math.abs(ratio - directoryRatio);
                    var diff:Number = Math.abs(Number(p[0]) * Number(p[1]) - area);
                    if (j == 0 || (minDist >= dist && minDiff > diff)) {
                        minDist = dist;
                        minDiff = diff;
                        minI = i;
                    }
                }
            }
            return (files[minI] as File).name;
        }
    }

    private function recalculateLayout(input:XML, name:String, ratio:Number, xDiff:Number, yDiff:Number):void {
        if (_layoutFile.exists) {
            var output:XML = new XML("<layout></layout>");
            if (_layoutType == PREDEF_LAYOUT && input.version != null && input.version.toString() != "") {
                _version = input.version.toString();
                output.appendChild(<version>{_version}</version>);
            }
            output.appendChild(<bg>{input.bg.toString()}</bg>);
            output.appendChild(<width>{AppProperties.screenWidth}</width>);
            output.appendChild(<height>{AppProperties.screenHeight}</height>);
            for each(var control:Object in input.control) {
                var subOutput:XML = <control>
                    <x>{Math.floor((control.x * ratio) + xDiff)}</x>
                    <y>{Math.floor((control.y * ratio) + yDiff)}</y>
                    {control.type}
                    <w>{Math.floor(control.w * ratio)}</w>
                    <h>{Math.floor(control.h * ratio)}</h>
                    {control.actualState}
                </control>
                output.appendChild(subOutput);
            }
            var stream:FileStream = new FileStream();
            stream.open(File.applicationStorageDirectory.resolvePath("layouts/" + AppProperties.screenWidth + "_" + AppProperties.screenHeight + "/" + name), FileMode.WRITE);
            stream.writeUTFBytes(output);
            stream.close();
        }
    }

    private function isLayoutVersionDifference(layout:File, appLayout:File):Boolean {
        var fileStream:FileStream = new FileStream();
        fileStream.open(layout, FileMode.READ);
        fileStream.position = 0;
        var inputLayout:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
        fileStream = new FileStream();
        fileStream.open(appLayout, FileMode.READ);
        fileStream.position = 0;
        var inputAppLayout:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));

        return isXMLVersionDifference(inputLayout, inputAppLayout);
    }

    private function isXMLVersionDifference(input:XML, inputApp:XML):Boolean {
        if (input.version != null && input.version.toString() != "" && (inputApp.version == null || (inputApp.version != null && inputApp.version.toString() == ""))) {
            return true;
        } else if (input.version != null && input.version.toString != "" && inputApp.version != null && inputApp.version.toString != "" && input.version.toString() > inputApp.version.toString()) {
            return true;
        }
        return false;
    }

//    private function isVersionGreater(version:String, appVersion:String):Boolean {
//        if(version!="" && appVersion!="") {
//            var p1:Array = version.split(".");
//            var p2:Array = appVersion.split(".");
//            var length:int = (p1.length<=p2.length) ? p1.length : p2.length;
//            for(var i:int=0; i<length; i++) {
//                if(p1[i]>p2[i]) {
//                    return true;
//                }
//            }
//        }
//        return false;
//        return (version>appVersion) ? true : false;
//    }


    private function loadLayout():void {
        trace("Load layout for FILENAME: " + _layoutFile.nativePath);
        GraphHandler.instance.listeners = _graphListeners;

        try {
            var fileStream:FileStream = new FileStream();
            fileStream.open(_layoutFile, FileMode.READ);
            fileStream.position = 0;
            var xml:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            importLayout(xml);
        } catch (e:Error) {
            trace(e.message);
        }
    }

    private function loadIsFullscreen():void {
        try {
            var fileStream:FileStream = new FileStream();
            fileStream.open(_layoutFile, FileMode.READ);
            fileStream.position = 0;
            var xml:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            try {
                if (xml.bg.toString() != "" && xml.bg.toString() != null) {
                    _isFullscreen = xml.bg.toString() == "true" ? true : false;
                } else {
                    _isFullscreen = true;
                }


            } catch (e:Error) {
                SystemLogger.Fatal("Incorrect xml " + e.message);
                trace(e.getStackTrace());
            }
        } catch (e:Error) {
            trace(e.message);
        }
    }

    public function deactivate():void {
        closeAisDetails();
        saveLayout();
//        WindowsHandler.instance.application.removeChild(this);
        this.visible = false;
        if (!_isFullscreen) {
            removeAllWindows();
        }

    }

    public function activate(needLoad:Boolean = false):void {
        if (needLoad) {
            _changeFullscreen = true;
        } else {
            _changeFullscreen = false;
        }
        if (!_isFullscreen || needLoad) {
            loadLayout();
        }
        if (!WindowsHandler.instance.application.contains(this)) {
            WindowsHandler.instance.application.addChild(this)
        }
        this.visible = true;
        LayoutHandler.instance.editEnabled = editEnabled;
        WindowsHandler.instance.listeners = _listeners;
        WindowsHandler.instance.windows = _windows;
        GraphHandler.instance.listeners = _graphListeners;
        LayoutHandler.instance.toggleFullscreen();
        GraphHandler.instance.updateAllGraphsAfterLayoutActivate();

        for (var i:int = 0; i < _windows.length; i++) {
            try {
                if (_windows[i].control is BaseInstrument) {
                    (_windows[i].control as BaseInstrument).updateDatas(WindowsHandler.instance.actualSailData);
                }
            } catch (e:Error) {
                trace(e.message)
            }
        }
        retriggerAisChange();

        var windows:WindowsHandler = WindowsHandler.instance;
        if (windows.isSocketDatasource()) {
            for (var key:String in WindowsHandler.instance.listeners) {
                if (!windows.actualSailData[key].isPreValid()) {
                    windows.setPreValid(key);
                }
                if (!windows.actualSailData[key].isValid()) {
                    windows.setValid(key);
                }
            }

        }

        refreshPolar();
    }


    public function importLayout(xml:XML):void {
        if (xml.bg.toString() != "" && xml.bg.toString() != null) {
            _isFullscreen = xml.bg.toString() == "true" ? true : false;
        } else {
            _isFullscreen = true;
        }
        if (xml.width.toString() != "" && xml.width.toString() != null) {
            _predefWidth = int(xml.width.toString());
        }
        if (xml.height.toString() != "" && xml.height.toString() != null) {
            _predefHeight = int(xml.height.toString());
        }
        if (_predefWidth > 0) {
            _widthOffset = Math.round((AppProperties.screenWidth - _predefWidth) / 2);
        }
        if (_predefHeight > 0) {
            _heightOffset = Math.round((AppProperties.screenHeight - _predefHeight) / 2);
        }
        if (_layoutType == PREDEF_LAYOUT) {
            _version = xml.version.toString();
        }
        for each(var control:Object in xml.control) {
            try {
                openControlWindowByImport(control.type, control.x, control.y, control.w, control.h, control.actualState);
            } catch (e:Error) {
                SystemLogger.Fatal("Incorrect xml " + e.message);
                trace(e.getStackTrace());
            }
        }
    }

    public function openControlWindowByImport(name:String, x:Number, y:Number, w:Number, h:Number, state:String = ""):void {
        var control:Object = WindowsHandler.instance.createWindowControl(name);
        var isChart:Boolean = name.match("FlexChart") || control is GraphInstance || control is IGraph;
        var isAis:Boolean = control is IAisComponent;
        y = y;
        if (isAis) {
            if (!isAIS(control)) {
                return;
            }
        }
        if (control is Polar && getPolarInstrument() != null) {
            return;
        }

        if (control != null) {
            if (!isChart && !isAis && control.updateVars == null) {
                return;
            }

            if (isChart && state != "") {
                control.yData = state;
            }
            var window:IInstrument;
            if (_isFullscreen) {
                window = new ControlEmbedable();
            } else {
                window = new ControlWindowAs();
            }

            if (!isChart && !isAis) {
                for (var i:int = 0; i < control.updateVars.length; i++) {
                    addListener(control.updateVars[i], control);
                }
            }
            _windows.push(window);
            window.addControl(control, w, h);
            window.controlType = name;
            window.resize(w, h);
            window.open(this);
            window.visible = false;
            window.controlState = state;
            var zeroHeight:int = TopBar.barHeight + InstrumentsGroup.height;
            zeroHeight -= zeroHeight % InstrumentMouseHandler.SNAP_GRID_SIZE;
            if (x > AppProperties.screenWidth) {
                x = 0;
            } else if (x < (-window.width)) {
                x = 0;
            }
            if (y < (-window.height)) {
                y = zeroHeight;
            } else if (y > AppProperties.screenHeight) {
                y = zeroHeight;
            }
            if (_widthOffset) {
                x += _widthOffset;
            }
            if (window is ControlWindowAs) {
                if (Capabilities.os.match("Windows")) {
                    window.move(x, y + 50);
                } else {
                    window.move(x, y + 72);

                }
            } else {
                window.move(x, y);
            }


            window.addToStageControl();
            window.visible = true;


        }
        else {
            SystemLogger.Warn("controll not found " + name);
        }
    }


    private function getWindowPosition(x:Number, y:Number, window:*, zeroHeight:int):Point {
        if (x > AppProperties.screenWidth) {
            x = 0;
        } else if (x < (-window.width)) {
            x = 0;
        }
        if (y < (-window.height)) {
            y = zeroHeight;
        } else if (y > AppProperties.screenHeight) {
            y = zeroHeight;
        }
        if (_widthOffset) {
            x += _widthOffset;
        }
        return new Point(x, y);

    }

    public function openControlWindowByMouse(name:String, x:Number, y:Number):void {
        var control = WindowsHandler.instance.createWindowControl(name);
        var isChart:Boolean = name.match("FlexChart") || control is GraphInstance || control is IGraph;
        var isAis:Boolean = control is IAisComponent;
        if (isAis) {
            if (!isAIS(control)) {
                return;
            }
        }
        if (control is Polar && getPolarInstrument() != null) {
            return;
        }
        if (control != null) {
            if (!isChart && !isAis && control.updateVars == null) {
                return;
            }

            var window:IInstrument;
            if (_isFullscreen) {
                window = new ControlEmbedable();
            } else {
                window = new ControlWindowAs();
            }
            _windows.push(window);
            if (!isChart && !isAis) {
                for (var i:Number = 0; i < control.updateVars.length; i++) {
                    addListener(control.updateVars[i], control);
                }
            }
            window.mouseHandler.initControlInitDimensions(control.width, control.height)


            var w:Number;
            var h:Number;
            if (control.width > control.height) {
                w = 400;
                h = w / window.mouseHandler.aspectRatio;
            } else if (control.height > control.width) {
                h = 400;
                w = h * window.mouseHandler.aspectRatio;
            } else {
                h = 200;
                w = 200
            }
            if (control is GraphInstance) {
                w = 450;
                h = 350;
            } else if (control is VGraphInstance) {
                w = 350;
                h = 450;
            }
            window.addControl(control, w, h);
            window.controlType = name;
            window.resize(w, h);

            if (window is ControlWindowAs) {
                if (Capabilities.os.match("Windows")) {
                    window.move(x, y + 50);
                } else {
                    window.move(x, y + 72);
                }
            } else {
                window.move(x, y);
            }


            window.open(this);
            window.addToStageControl();
        }
        else {
            SystemLogger.Warn("controll not found " + name);
        }
    }

    private function getWH(control:*, window:IInstrument):Point {
        var w:Number;
        var h:Number;
        if (control.width > control.height) {
            w = 400;
            h = w * window.mouseHandler.aspectRatio;
        } else if (control.height > control.width) {
            h = 400;
            w = h / window.mouseHandler.aspectRatio;
        } else {
            h = 200;
            w = 200
        }
        if (control is GraphInstance) {
            w = 450;
            h = 350;
        } else if (control is VGraphInstance) {
            w = 350;
            h = 450;
        }
        return new Point(w, h);
    }

    private function isAIS(control:Object):Boolean {
        if (hasAisComponent()) {
            control.removeAllListeners();
            control = null;
            return false;
        }
        if (!(control is AisMap)) {
            (control as AisComponent).layout = this;
        }
        return true;
    }


    public function addListener(eventName:String, control:Object):void {
        if (!(_listeners[eventName])) {
            _listeners[eventName] = [];
        }
        _listeners[eventName].push(control);
        MinMaxHandler.instance.addListener(control);
    }

    private function removeControl(control:Object):void {
        if (control is GraphInstance) {
            GraphHandler.instance.removeListener(control.yData, control);
        } else if (!(control is IAisComponent)) {
            for (var i:Number = 0; i < control.updateVars.length; i++) {
                this.removeListener(control.updateVars[i], control);
            }
            MinMaxHandler.instance.removeListener(control);
        }
    }

    private function removeListener(eventName:String, control:Object):void {
        var listenerLength:int = _listeners[eventName] != null ? _listeners[eventName].length : 0
        if (listenerLength == 0) {
            return;
        }
        for (var i:int = 0; i < listenerLength; i++) {
            var current = _listeners[eventName][i];
            if (current == control) {
                _listeners[eventName].splice(i, 1);
                break;
            }
        }
        if (_listeners[eventName].length == 0) {
            delete _listeners[eventName];
            //listeners.remove(eventName);
        }
    }

    public function removeWindow(window):void {
        for (var i:int = 0; i < _windows.length; i++) {
            var current = this._windows[i];
            if (current == window) {
                deleteWindow(current, i)
                break;
            }
        }
    }

    public function closeAllWindows():void {
        saveLayout();
        removeAllWindows();
        if (LayoutHandler.instance.activeBtn) {
            var data:ByteArray = new ByteArray();
            data.writeObject(_layoutName);
            EdoLocalStore.setItem("savedWindows", data);
        }

    }

    private function removeAllWindows():void {
        while (_windows.length > 0) {
            var w = _windows[0];
            //removeWindow(w)
            w = deleteWindow(w, 0);
        }
    }

    private function deleteWindow(w:*, i:int):* {
        removeControl(w.control);
        w.customClose();
        w = null;
        _windows.splice(i, 1);
        return w;
    }

    public function bringControlToFront(control:ControlEmbedable):void {
        setChildIndex(control, numChildren - 1);
        for (var i:int = 0; i < _windows.length; i++) {
            if (_windows[i] == control) {
                _windows.splice(i, 1);
                break;
            }
        }
        _windows.push(control);
    }

    public function exportLayout(_toggleFullscreen:Boolean = false):XML {
        var data:XML = new XML("<layout></layout>");
        if (_layoutType == PREDEF_LAYOUT) {
            data.appendChild(<version>{_version}</version>);
        }
        data.appendChild(<bg>{_isFullscreen}</bg>);
        data.appendChild(<width>{AppProperties.screenWidth}</width>)
        data.appendChild(<height>{AppProperties.screenHeight}</height>)
//        var tempWindows:Vector.<IInstrument> = new Vector.<IInstrument>(_windows.length)
//        var index:int;
//        for (var i:int = 0; i < _windows.length; i++) {
//            index = _isFullscreen && !_toggleFullscreen ? this.getChildIndex(_windows[i] as Sprite) : i
//            tempWindows[index] = _windows[i];
//        }
        for (var j:int = 0; j < _windows.length; j++) {
            var w:IInstrument = _windows[j];
            if (w === null || (w is ControlWindowAs && (w as ControlWindowAs).closed)) {
                throw new Error("LAYOUT MENTES HIBA!!!! MIT CSINALTUNK???");
                continue;
            }
            //w = tempWindows[j];
            var sXml:XML
            var state = "actualState" in w.control ? w.control.actualState : "";
            if (w.control is IGraph) {
                state = (w.control as IGraph).yData
                sXml = <control>
                    <x>{w.getCoordinates().x}</x>
                    <y>{w.getCoordinates().y}</y>
                    <type>{w.controlType}</type>
                    <w>{w.control.originWidth}</w>
                    <h>{w.control.originHeight}</h>
                    <actualState>{state}</actualState>
                </control>
            } else if (w.control is IAisComponent) {
                sXml = <control>
                    <x>{w.getCoordinates().x}</x>
                    <y>{w.getCoordinates().y}</y>
                    <type>{w.controlType}</type>
                    <w>{w.control.originWidth}</w>
                    <h>{w.control.originHeight}</h>
                    <actualState>{state}</actualState>
                </control>
            } else {
                sXml = <control>
                    <x>{w.getCoordinates().x}</x>
                    <y>{w.getCoordinates().y}</y>
                    <type>{w.controlType}</type>
                    <w>{w.originWidth}</w>
                    <h>{w.originHeight}</h>
                    <actualState>{state}</actualState>
                </control>

            }

            data.appendChild(sXml);
        }
        return data;
    }

    public function saveLayout(_toggleFullscreen:Boolean = false):void {
//        if (_layoutType == PREDEF_LAYOUT) {
//            return;
//        }
        trace("SAVEDIR " + _layoutFile.nativePath)
        var data:XML = exportLayout(_toggleFullscreen);
        var stream:FileStream = new FileStream();
        stream.open(_layoutFile, FileMode.WRITE);
        stream.writeUTFBytes(data);
        stream.close();
    }

    public function toggleFullScreen():void {
        _isFullscreen = !_isFullscreen;
        saveLayout(true);
        removeAllWindows();
        activate(true);
    }


    public function get editEnabled():Boolean {
        return _editEnabled;
    }

    public function set editEnabled(value:Boolean):void {
        _editEnabled = value;
    }


    public function get listeners():Object {
        return _listeners;
    }

    public function get windows():Vector.<IInstrument> {
        return _windows;
    }

    public function get isFullscreen():Boolean {
        return _isFullscreen;
    }


    public function get layoutFile():File {
        return _layoutFile;
    }

    public function get graphListeners():Object {
        return _graphListeners;
    }

    private function retriggerAisChange():void {
        AisContainer.instance.selectedShipMMSI = AisContainer.instance.selectedShipMMSI;
    }

    public function openAisDetails(ship:Vessel, x:int, y:int):void {
        _aisDetails.ship = ship;
        if (!_isFullscreen) {
            if (contains(_aisDetails)) {
                removeChild(_aisDetails);
            }
            openDetailsWindow(x, y)
        }
        if (_isFullscreen && !contains(_aisDetails)) {
            this.addChildAt(_aisDetails, this.numChildren - 1);
        }
        if (_isFullscreen) {
            _aisDetails.x = x;
            _aisDetails.y = y;
        } else {
            _aisDetails.x = 0;
            _aisDetails.y = 0;
        }
        this.setChildIndex(_aisDetails, this.numChildren - 1)
        _aisDetails.show();
    }

    var detailWindow:AisDetailsWindow;

    private function openDetailsWindow(x:int, y:int):void {
        if (detailWindow == null || detailWindow.closed) {
            detailWindow = new AisDetailsWindow(190, 320);
            detailWindow.stage.addChild(_aisDetails);
            detailWindow.x = x;
            detailWindow.y = y;
            detailWindow.orderToFront();
            detailWindow.activate();
        }
    }

    public function deselectVessel():void {
        AisContainer.instance.selectedShipMMSI = null;
        closeAisDetails();

    }

    public function closeAisDetails():void {
        if (_isFullscreen) {
            _aisDetails.hide();
        } else {
            _aisDetails.hide();
            if (detailWindow != null && !detailWindow.closed) {
                detailWindow.close();
            }
        }
    }


    public function get aisDetails():AisDetails {
        return _aisDetails;
    }

    public function isActiveLayout():Boolean {
        return LayoutHandler.instance.activeLayout === this;
    }

    public function hasAisComponent():Boolean {
        for (var i:int = 0; i < _windows.length; i++) {
            if (_windows[i].control is AisComponent) {
                return true;
            }
        }
        return false;
    }


    private function getPolarInstrument():Object {
        for (var i:int = 0; i < _windows.length; i++) {
            if (_windows[i].control is Polar) {
                return _windows[i];
            }
        }
        return null;
    }


//    private function openPolarSettingsHandler(event:Event):void {
//        if (isActiveLayout()) {
//
////            _polarSettings.open(getPolarInstrument());
//            if (_isFullscreen && !contains(_polarSettings)) {
////                addChild(_polarSettings);
//            }
//            if (!_isFullscreen) {
//                if (contains(_polarSettings)) {
////                    removeElement(_polarSettings);
//                }
//                openPolarSettingsWindow(_polarSettings.x, _polarSettings.y)
//                _polarSettings.x = 0;
//                _polarSettings.y = 0;
//            }
//        }
//    }

    private function polarFileLoadedHandler(event:PolarEvent):void {
        if (LayoutHandler.instance.activeLayout == this) {
            refreshPolar();
        }
    }

    private function refreshPolar():void {
        var polar:Object = getPolarInstrument();
        if (polar != null) {
            (polar.control as Polar).polarFileLoaded();
            return;
        }
    }

    var polarSettingsWindow:AisDetailsWindow;

    public function openPolarSettingsWindow(x:int, y:int):void {
        if (polarSettingsWindow == null || polarSettingsWindow.closed) {
            polarSettingsWindow = new AisDetailsWindow(400, 300);
            polarSettingsWindow.stage.addChild(_polarSettings);
            polarSettingsWindow.x = x;
            polarSettingsWindow.y = y;
            polarSettingsWindow.activate();
        }
    }

    public function closePolarSettingsWindow() {
        if (polarSettingsWindow != null && !polarSettingsWindow.closed) {
            polarSettingsWindow.close();
        }
    }


    public function closePolarSettings():void {
        if (isActiveLayout()) {
            _polarSettings.hide();
            if (!_isFullscreen) {
                closePolarSettingsWindow()
            }
        }


    }


    public function get initWidth():uint {
        return _initWidth;
    }

    public function get initHeight():uint {
        return _initHeight;
    }


    public function get layoutName():String {
        return _layoutName;
    }
}
}
