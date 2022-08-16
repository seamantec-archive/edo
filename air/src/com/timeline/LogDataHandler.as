package com.timeline {
import com.graphs.GraphHandler;
import com.loggers.SystemLogger;
import com.sailing.SailData;
import com.sailing.WindowsHandler;
import com.sailing.datas.BaseSailData;
import com.sailing.minMax.MinMaxHandler;
import com.sailing.units.Direction;
import com.sailing.units.Unit;

import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.display.Sprite;
import flash.errors.SQLError;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;
import flash.net.Responder;
import flash.utils.Timer;
import flash.utils.getTimer;

public class LogDataHandler extends Sprite {

    private const SPEEDLIMIT:Array = new Array(new LogSpeedLimit(1, 0), new LogSpeedLimit(2, 0), new LogSpeedLimit(5, 0), new LogSpeedLimit(10, 0), new LogSpeedLimit(25, 240), new LogSpeedLimit(50, 360));

    private var _logFile:File;

    /*private var sqlConnection:SQLConnection = new SQLConnection();
     private var sqlStatement:SQLStatement = new SQLStatement();*/
    private var sqlConnectionSelect:SQLConnection = new SQLConnection();
    private var sqlStatementSelect:SQLStatement = new SQLStatement();
    private var _firstData:*;
    private var _lastData:*;
    private var _timer:Timer = new Timer(1000);
    private var minMaxDistance:Number;
    private var _fragementLength:Number;
    private var _speed:Number = 1;
    private var _fragementsNumber:Number = 100;
    private var segmentsNumber:Number;
    private var maxSegmentsNumber:Number;
    private var actualSegment:Number;
    private var marker:Marker;
    private var _dataProvider:Array;
    private var _yData:String;
    var dbCloseOpen:Responder = new Responder(onDbCloseOpenResult);
    var firstResponder:Responder = new Responder(firstResultHandler);
    var lastResponder:Responder = new Responder(lastResultHandler);

    private var hasChart:Boolean;

    public function LogDataHandler(marker:Marker, logFile:File = null, hasChart:Boolean = false, dataProvider:Array = null, yData:String = null) {
        this.hasChart = hasChart;
        this.marker = marker;
        this.dataProvider = dataProvider;
        this.yData = yData;
        logFile = logFile;
        sqlStatementSelect.sqlConnection = sqlConnectionSelect;
        if (logFile != null) {
            sqlConnectionSelect.open(logFile);
            sqlConnectionSelect.cacheSize = 20000;
        } else {
            sqlConnectionSelect.open();
        }
        openLog();
        play();

    }

    public function closeSqlConnection():void {
        sqlConnectionSelect.close();
    }

    private function openLog():void {
        /*sqlStatement.sqlConnection = sqlConnection;
         sqlConnection.addEventListener(SQLEvent.OPEN, db_opened, false, 0, true);
         sqlStatement.addEventListener(SQLErrorEvent.ERROR, error, false, 0, true);
         sqlStatement.addEventListener(SQLEvent.RESULT, result, false, 0, true);
         sqlConnection.openAsync(logFile);*/
    }

    protected function db_opened(event:SQLEvent):void {
        if (hasChart) {
            fillDp();
        } else {
            getFirst();
        }
        play();
    }

    private function play():void {
        timer.delay = 1000 / _speed;
        timer.addEventListener("timer", stepTimer, false, 0, true);
        if (!timer.running) {
            timer.reset();
        }

    }

    private function stepTimer(eventTimerEvent):void {
        dispatchEvent(new Event("step-timer"));
    }

    private function fillDp():void {
        var tableName:String = yData;
        /*try{
         sqlStatement.text = "SELECT d.field_value as 'field_value', t.timestamp as sailDataTimestamp" +
         " FROM timestamps t, "+tableName+" d WHERE t.id = d.timestamp_id;";
         sqlStatement.execute();
         }catch(error:SQLError){
         trace("Error message:", error.message);
         trace("Details:", error.details);
         }catch(e:Error){
         trace(e.message);
         }*/

    }

    private function firstResultHandler(result:SQLResult):void {
        if (result.data != null) {
            firstData = {sailDataTimestamp: result.data[0].timestamp}
        }
        /*			sqlStatement.cancel();
         */
        getLast();
    }

    private function lastResultHandler(result:SQLResult):void {
        if (result.data != null) {
            lastData = {sailDataTimestamp: result.data[0].timestamp}
        }
        /*			sqlStatement.cancel();
         */
    }

    private function getFirst():void {
        try {
            /*sqlStatement.text = "SELECT timestamp from timestamps order by id ASC limit 1 ";
             sqlStatement.execute(1, firstResponder);*/
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
    }

    private function getLast():void {
        try {
            /*sqlStatement.text = "SELECT timestamp from timestamps order by id DESC limit 1 ";
             sqlStatement.execute(1, lastResponder);		*/
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
    }

    public function getLastDataForLog(tableName:String, timestamp:Number):* {
        var results:SQLResult;
        try {
            sqlStatementSelect.text = "SELECT d.field_value as 'field_value', t.timestamp as sailDataTimestamp" +
                    " FROM timestamps t, " + tableName + " d" +
                    " WHERE t.id = d.timestamp_id and t.timestamp <= " + timestamp + " ORDER BY sailDataTimestamp DESC LIMIT 1;";
            sqlStatementSelect.execute();
            trace(sqlStatementSelect.text);
            results = sqlStatementSelect.getResult();
            if (results.complete || results.data != null) {
                //sqlStatement.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
        if (results.data != null) {
            return results.data[0].field_value
        } else {
            return null;
        }
    }


    public function getLastDataForLogOneTable(tableName:String, timestamp:Number, segmentName:String):* {
        var results:SQLResult;
        try {
            sqlStatementSelect.text = "SELECT d.*, t.timestamp as sailDataTimestamp" +
                    " FROM " + segmentName + ".timestamps t, " + segmentName + "." + tableName + " d" +
                    " WHERE t.id = d.timestamp_id and t.timestamp <= " + timestamp + " ORDER BY sailDataTimestamp DESC LIMIT 1;";
            sqlStatementSelect.execute();
            results = sqlStatementSelect.getResult();
            if (results.complete || results.data != null) {
                //sqlStatement.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
        if (results != null && results.data != null) {
            return results.data[0]
        } else {
            return null;
        }
    }

    private var attachedSegments:Array = [];

    private function addSegment(segmentName:String):void {
        if(!sqlConnectionSelect.connected){
            return;
        }
        for each(var sName:String in attachedSegments) {
            if (sName == segmentName) {
                return; // not necessary loading because it has loaded
            }
        }
        if (attachedSegments.length < 10) {
            attachedSegments.push(segmentName);
        } else {
            sqlConnectionSelect.detach(attachedSegments.shift());
            attachedSegments.push(segmentName);
        }
        trace("ATTACH segment ", segmentName)
        sqlConnectionSelect.attach(segmentName, logFile);
    }

    public function loadMinMaxes(segments:Vector.<Segment>):void {
        var oldSegmentName:String = attachedSegments[attachedSegments.length - 1];
        var oldLogFile:File = logFile
        var isTimerRunning:Boolean = false;
        if (_timer.running) {
            _timer.stop();
            isTimerRunning = true;
        }
        var selectField:String = "Select ";
        var fromField:String = " FROM ";
        var tString:String;
        var segmentName:String;
        var result:SQLResult;
        for (var j:int = 0; j < segments.length; j++) {
            if (segments[j].maxTime == -1 || segments[j].minTime == -1) {
                continue;
            }
            logFile = getExistingLogFile(segments[j].name)
            segmentName = "segment" + j;
            if (logFile.exists) {
                addSegment(segmentName);
                for (var i:int = 0; i < MinMaxHandler.predefKeys.length; i++) {
                    selectField = "Select ";
                    fromField = " FROM ";
                    tString = MinMaxHandler.predefKeys[i];
                    selectField += " MIN(" + tString + ") as \"min\", MAX(" + tString + ") as \"max\"";
                    fromField += segmentName + "." + tString.split(".")[0] + ";"
                    sqlStatementSelect.text = selectField + fromField;
                    try {
                        if (sqlConnectionSelect.connected) {
                            sqlStatementSelect.execute();
                            result = sqlStatementSelect.getResult();
                            if (result.data != null && result.data[0].min!=null && result.data[0].max!=null) {
                                MinMaxHandler.instance.updateMinMaxesFromLog(result.data, tString);
                            }
                        }
                    } catch (e:SQLError) {

                    }
                }
            }
        }
        logFile = oldLogFile;
        if (oldSegmentName != null) {
            addSegment(oldSegmentName);
        }
        if (isTimerRunning) {

            _timer.start();
        }
    }

    public function openDb(file:File, segmentIndex:Number):void {
        SystemLogger.Debug("OPEN LOG FILE " + file.nativePath);
        logFile = file;
        //sqlConnectionSelect.close();

        try {
            trace("open db with segment")
            addSegment("segment" + segmentIndex);
        } catch (e:SQLError) {
            trace("db attach" + e.message);
            trace(e.details);
            trace(e.getStackTrace());
        }
        dispatchEvent(new Event("select-connection-ready"));
        //sqlConnection.close(dbCloseOpen);
    }

    protected function error(event:SQLErrorEvent):void {
        trace("SQL ERROR " + event.error.details);
    }

    protected function result(event:Event):void {
        //var results:SQLResult = sqlStatement.getResult();
        //if(results.data != null){
        //	firstData = results.data[0];
        //	lastData = results.data[results.data.length-1];
        /*if(marker == null){
         initMarker();
         }*/
        //marker.actualTime = firstData.sailDataTimestamp;
        //marker.calculateActulateX();
        //	minMaxDistance = lastData.sailDataTimestamp - firstData.sailDataTimestamp;
        //	fragementLength = minMaxDistance / 100;
        //marker.minTime = firstData.sailDataTimestamp;
        //marker.maxTime = lastData.sailDataTimestamp;
        //}
        if (dataProvider != null) {
            //dataProvider = new ArrayCollection(results.data);
        }

    }

    private function onDbCloseOpenResult(result:SQLEvent):void {
        try {
            /*	sqlConnection.openAsync(logFile);
             if(sqlConnectionSelect.connected){
             sqlConnectionSelect.close();
             sqlConnectionSelect.open(logFile);
             sqlConnectionSelect.cacheSize = 20000;
             dispatchEvent(new Event("select-connection-ready"));

             }*/
        } catch (e:Error) {
            trace("onDbCloseOpenResult " + e.message);
        }

    }

    public function changeSpeed(event:MouseEvent, fullTime:Number):void {
        fullTime = (fullTime / 1000) / 60;

        for (var i:int = 0; i < SPEEDLIMIT.length; i++) {
            if (SPEEDLIMIT[i].speed == _speed) {
                if (i == (SPEEDLIMIT.length - 1) || SPEEDLIMIT[i + 1].limit >= fullTime) {
                    _speed = 1;
                    break;
                } else {
                    _speed = SPEEDLIMIT[i + 1].speed;
                    break;
                }
            }
        }
        /*
         switch (speed) {
         case 1:
         {
         speed = 2;
         break;
         }
         case 2:
         {
         speed = 5;
         break;
         }
         case 5:
         {
         speed = 10;
         break;
         }
         case 10:
         {
         speed = 1;
         break;
         }
         }
         */
        timer.delay = 1000 / _speed;

        event.currentTarget.label = "X" + _speed;
        dispatchEvent(new Event("speed-changed"))

    }

    public function updateInstrumentsManualy(maxTime:Number, segmentIndex:Number = 0, needTween:Boolean = true):void {
        sqlConnectionSelect.cancel();
        var wListeners = WindowsHandler.instance.listeners;
        var sailData:SailData = WindowsHandler.instance.getActualSailData();// ObjectUtil.copy() as SailData;
        //TODO le cachelni a valtozokat amig nincs ui valtas

        if (sqlConnectionSelect.inTransaction) {
            sqlConnectionSelect.cancel();
        }
        updateMagneticVariation(maxTime, segmentIndex);
        sqlConnectionSelect.begin();
        for (var key in wListeners) {
            var item:BaseSailData = sailData[key];
            var parameters:Array = item.ownProperties;
            var data:Object = getLastDataForLogOneTable(key, maxTime, "segment" + segmentIndex);
            if (data != null) {
                sailData.sailDataTimestamp = data.sailDataTimestamp;
                for each(var pKey:String in parameters) {
                    if (pKey == "eta") {
                        continue;
                    }
                    if (item[pKey] is Unit) {
                        item[pKey].value = data[pKey];
                    } else {
//                        if(item[pKey] is Date){
//                            item[pKey] = new Date(Date.parse(data[pKey]));
//                        }else{
                        item[pKey] = data[pKey];
//                        }

                    }
                }
                (item as BaseSailData).lastTimestamp = getTimer()


            } else {
//                (item as BaseSailData).lastTimestamp = -1;
//                WindowsHandler.instance.setValid(key);
            }
            WindowsHandler.instance.playLogData({key: key}, needTween);

        }
        sqlConnectionSelect.commit();
    }

    private function updateMagneticVariation(maxTime:Number, segmentIndex:Number = 0):void {
//        var sailData:SailData = WindowsHandler.instance.getActualSailData();
        var rmcData:Object = getLastDataForLogOneTable("rmc", maxTime, "segment" + segmentIndex);
        if (rmcData != null) {
            Direction.variation = rmcData.magneticVariation;
        } else if (Direction.variation === 0) {
            var hdgData:Object = getLastDataForLogOneTable("hdg", maxTime, "segment" + segmentIndex);
            if (hdgData != null) {
                Direction.variation = hdgData.magneticVariation;
            }
        } else if (Direction.variation === 0) {
            var hvmData:Object = getLastDataForLogOneTable("hvm", maxTime, "segment" + segmentIndex);
            if (hvmData != null) {
                Direction.variation = hvmData.magneticVariation;
            }
        }

        if (Direction.variation !== 0) {
            Direction.isVariationValid = true;
        }
    }


    public function getExistingLogFile(fileName:String = null):File {
        if (fileName == null) {
            fileName = logFile.name;
        }
        //TODO ha nincs a file, akkor baj van, ezt lekell kezelni
        var file:File = File.applicationStorageDirectory;
        if (fileName.match(".edodb")) {
            file = file.resolvePath("sailing/" + fileName);
        } else {
            file = file.resolvePath("sailing/" + fileName + ".edodb");
        }
        return file;
    }

    public function getFileNameFromSegmentName(name:String):String {
        var temp:Array = name.split(".");
        var newFileContent:Array = [];
        for (var i:int = 0; i < temp.length - 2; i++) {
            newFileContent.push(temp[i]);
        }
        return newFileContent.join(".");
    }

    public function updateGraphs():void {
        //marker.actualTime
        //TODO refactor
        var listeners:Object = GraphHandler.instance.listeners;
        /*for(var key:String in listeners){
         var dp:ArrayCollection = getDataForChart(key, marker.actualTime);
         for(var i:int=0;i<listeners[key].length;i++){
         var graph:GraphInstanceAs = listeners[key][i] as GraphInstanceAs;
         if(!graph.chartScroller.isDragging){
         listeners[key][i].dataContainer = dp;
         listeners[key][i].refreshMinMax();
         }
         }
         }*/

    }

    public function getDataForChart(tableName:String, timestamp:Number):Array {
        var results:SQLResult;
        try {
            sqlStatementSelect.text = "SELECT d.field_value as '" + tableName + "', t.timestamp as sailDataTimestamp" +
                    " FROM timestamps t, " + tableName + " d" +
                    " WHERE t.id = d.timestamp_id and t.timestamp >= " + (timestamp - 5 * 60 * 1000) + " and t.timestamp <= " + timestamp + " ORDER BY sailDataTimestamp DESC;";
            sqlStatementSelect.execute();
            results = sqlStatementSelect.getResult();
            if (results.complete || results.data != null) {

                //TODO ez itt minek van itt????
                //sqlStatement.cancel();
                return new Array(results.data);
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
        return [];
    }

    public function get timer():Timer {
        return _timer;
    }

    public function set timer(value:Timer):void {
        _timer = value;
    }

    public function get yData():String {
        return _yData;
    }

    public function set yData(value:String):void {
        _yData = value;
        fillDp();
    }

    public function get logFile():File {
        return _logFile;
    }

    public function set logFile(value:File):void {
        _logFile = value;
    }

    public function get firstData():* {
        return _firstData;
    }

    public function set firstData(value:*):void {
        _firstData = value;
        this.dispatchEvent(new Event("firstdata-ready"));

    }

    public function get lastData():* {
        return _lastData;
    }

    public function set lastData(value:*):void {
        _lastData = value;
        this.dispatchEvent(new Event("lastdata-ready"));
    }

    [Bindable]
    public function get dataProvider():Array {
        return _dataProvider;
    }

    public function set dataProvider(_value:Array):void {
        _dataProvider = _value;
        this.dispatchEvent(new Event("data-ready"));
    }

    public function get fragementsNumber():Number {
        return _fragementsNumber;
    }

    public function set fragementsNumber(value:Number):void {
        _fragementsNumber = value;
    }

    public function get fragementLength():Number {
        return _fragementLength;
    }

    public function set fragementLength(value:Number):void {
        _fragementLength = value;
    }

    public function get speed():Number {
        return _speed;
    }

}
}