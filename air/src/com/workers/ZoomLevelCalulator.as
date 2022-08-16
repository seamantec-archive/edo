//package com.workers {
//import com.loggers.LogRegister;
//import com.loggers.SystemLogger;
//import com.sailing.nmeaParser.utils.NmeaUtil;
//import com.timeline.Segment;
//import com.utils.RamerDouglasPeuckerReduction;
//
//import flash.data.SQLColumnSchema;
//import flash.data.SQLConnection;
//import flash.data.SQLResult;
//import flash.data.SQLSchemaResult;
//import flash.data.SQLStatement;
//import flash.data.SQLTableSchema;
//import flash.display.Sprite;
//import flash.errors.SQLError;
//import flash.events.Event;
//import flash.filesystem.File;
//import flash.net.registerClassAlias;
//import flash.system.MessageChannel;
//import flash.system.Worker;
//import flash.utils.ByteArray;
//import flash.utils.getDefinitionByName;
//
//
//public class ZoomLevelCalulator extends Sprite {
//    registerClassAlias("com.loggers.LogRegister", LogRegister);
//
//    private var mainToZoomLevelCalulator:MessageChannel;
//    private var zoomLevelCalulatorToMain:MessageChannel;
//    private var sqlConnection:SQLConnection = new SQLConnection();
//    private var sqlStatement:SQLStatement = new SQLStatement();
//    private var graphCacheEntry:Object;
//    private var connectionPath:String;
//    private var logRegister:LogRegister;
//    private var logFileEntry:Object;
//    public static const ZOOMLEVEL_NUMBERS = 1
//    var executionCounter:int = 0;
//    private var bArray:ByteArray;
//    private var storagePath:String = "";
//
//
//    public function ZoomLevelCalulator() {
//        trace("ZOOM LEVEL CALCULATERO CONST")
//        super();
//        sqlStatement.sqlConnection = sqlConnection;
//
//        zoomLevelCalulatorToMain = Worker.current.getSharedProperty("zoomLevelCalulcatorToMain");
//        mainToZoomLevelCalulator = Worker.current.getSharedProperty("mainToZoomLevelCalulator");
//        storagePath = Worker.current.getSharedProperty("storageDirectoryPath");
//        bArray = Worker.current.getSharedProperty("bArray");
//        var bArrayLogregister:ByteArray = Worker.current.getSharedProperty("LogRegister");
//        logRegister = bArrayLogregister.readObject();
//        logRegister.reInit();
//        mainToZoomLevelCalulator.addEventListener(Event.CHANNEL_MESSAGE, messageReceivedHandler);
//        getSharedProperties();
//    }
//
//    private function getSharedProperties():void {
//        try {
//            var oldConnectionPath = connectionPath;
//            graphCacheEntry = Worker.current.getSharedProperty("graphCacheEntry");
//            logFileEntry = Worker.current.getSharedProperty("logFileEntry");
//            connectionPath = Worker.current.getSharedProperty("sqlConnectionPath");
//
//            if (connectionPath != oldConnectionPath) {
//                if (sqlConnection.connected) {
//                    sqlConnection.close();
//                }
//                sqlConnection.open();
//                sqlConnection.attach("main_db", new File(connectionPath));
//            }
//        } catch (e:Error) {
//            //trace(e.getStackTrace());
//        }
//    }
//
//    protected function messageReceivedHandler(event:Event):void {
//        getSharedProperties();
//        var message:Object = mainToZoomLevelCalulator.receive();
//        trace("got message", message.action)
//        switch (message.action) {
//
//            case "copyAllTimestamps":
//            {
//               // copyAllTimestamps();
//                break;
//            }
//
//            case "copyCustomTable":
//            {
//                //copyCustomTable(message.tableAndPropery);
//                break;
//            }
//
//
//            default:
//            {
//                break;
//            }
//        }
//    }
//
//    /**
//     * copy all of the timestamps from segments
//     *
//     * */
//    public function copyAllTimestamps():void {
//        trace("copy all timestamps")
//        if (graphCacheEntry == null) {
//            insertNewGraphCacheEntry();
//            refreshGraphCacheEntry();
//        }
//        createTable("timestamps")
//        copyTable("timestamps", 0, logFileEntry.number_of_segments);
//        LogRegister.instance.updateLastTimestampForGraphCache(graphCacheEntry.id, getLastTimestampFromTable());
//        refreshGraphCacheEntry();
//        zoomLevelCalulatorToMain.send({action: "timestampChanged"})
//    }
//
//    private function insertNewGraphCacheEntry():void {
//        if (graphCacheEntry == null) {
//            graphCacheEntry = LogRegister.instance.addGraphCacheEntry(logFileEntry.name, logFileEntry.id);
//        }
//    }
//
//    /**
//     * If original table is empty, return false. This mean no zoom level and other things to do
//     *
//     * */
//    private function createTable(tableName:String):Boolean {
//        var returnValue:Boolean = false;
//
//        var segment:Segment = LogRegister.instance.getSegment(logFileEntry.id, 0);
//        if (segment == null) {
//            return false;
//        }
//        sqlConnection.attach("segment0", getExistingLogFile(segment.name));
//
//        try {
//            sqlStatement.text = "CREATE TABLE main_db." + tableName + " as  SELECT * FROM segment" + segment.index + "." + tableName +
//                    " LIMIT 1";
//            tryExecution()
//            returnValue = true;
//        } catch (e:Error) {
//            if (e.errorID == 3115) {
//                returnValue = true;
//            } else {
//                returnValue = false;
//                trace("Create table return value is false")
//            }
//
//        }
//        sqlConnection.detach("segment0");
//        return returnValue;
//
//    }
//
//    private function getExistingLogFile(fileName:String = null):File {
//        var file:File = new File(storagePath);
//        if (fileName.match(".edodb")) {
//            file = file.resolvePath("sailing/" + fileName);
//        } else {
//            file = file.resolvePath("sailing/" + fileName + ".edodb");
//        }
//        return file;
//    }
//
//    private function refreshGraphCacheEntry():void {
//        graphCacheEntry = LogRegister.instance.getGraphCacheEntry(logFileEntry.id);
//    }
//
//    /**
//     * copy all of the segments between from and to, into the cache db.
//     *
//     * */
//    public function copyTable(tableName:String, segmentFrom:Number, segmentTo:Number):void {
//        var segments:Vector.<Segment> = LogRegister.instance.getSegmentsFromTo(logFileEntry.id, segmentFrom, segmentTo);
//        var statement:String = "INSERT INTO";
//        var statementDelimeter = " ";
//        var fromId:Number = getLastIdFromTable(tableName);
//        var i:Number = 0;
//        while (i < segments.length) {
//            var segment:Segment = segments[i];
//            sqlConnection.attach("segment" + segment.index, getExistingLogFile(segment.name));
//            //try{
//            sqlStatement.text = statement + " main_db." + tableName + statementDelimeter + "  SELECT * FROM segment" + segment.index + "." + tableName +
//                    " WHERE id >= " + fromId;
//            tryExecution();
//            i++;
//            sqlConnection.detach("segment" + segment.index);
//        }
//    }
//
//
//    /**
//     * import table from graph eventlistener key. In general key looks like "vhw_wateherHeadingMagnetic"
//     * the separator is _. First part of the key means the table of the data, and the second is the column.
//     * when we imported all of the data, after we generate zoomlevels tables if necessary, and calculate the values.
//     *
//     *
//     *
//     * */
//    public function copyCustomTable(tableAndProperty:String):void {
//
//        var splittedParams:Array = tableAndProperty.split("_")
//        var tableName:String = splittedParams[0];
//        var columnName:String = splittedParams[1];
//        //copyAllTimestamps();
//        //nincs meg ilyen tabla behuzva ezert letrekell hozni a tablat, es bemasolni az adatokat, majd a zoomleveleket kiszamolni
//
//        if (!hasTable(tableName)) {
//            if (!createTable(tableName)) {
//                zoomLevelCalulatorToMain.send({action: "ready-no-data", key: tableAndProperty})
//                return;
//            }
//            addLoadedTableToGraphCache(tableName);
//        }
//
//        //create zoom level for new property. or continue
//        copyTable(tableName, 0, logFileEntry.number_of_segments);
//        if (columnName != null) {
//            //createZoomLeveles(tableName, columnName);
//        }
//
//        refreshGraphCacheEntry();
//        zoomLevelCalulatorToMain.send({action: "ready", key: tableAndProperty})
//    }
//
//    private function createZoomTable(tableName:String):void {
//        sqlStatement.text = "CREATE TABLE IF NOT EXISTS main_db." + tableName + "(id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp_id INTEGER);";
//        tryExecution()
//        //tryExecution();
//    }
//
//    private function tryExecution():void {
//        var bArrayIsEmpty:Boolean = bArray.length == 0;
//        var counter:int = 0;
//
//        while (!bArrayIsEmpty) {
//            bArrayIsEmpty = bArray.length == 0
//            counter++;
//        }
//        try {
//            sqlStatement.execute()
//        } catch (e:Error) {
//            if (e.errorID == 3119) {
//                tryExecution();
//            } else if (e.errorID == 3123) {
//                trace(e.message, " ||| ", sqlStatement.text)
//            } else {
//                throw e
//            }
//
//        }
//    }
//
//
//    private function createZoomLeveles(tableName:String, parameterName:String):void {
//        var zoomTableName:String = tableName + "_" + parameterName
//        createZoomTable(zoomTableName);
//
//        var className:String = NmeaUtil.upperCase(tableName);
//        var classref:Class = getDefinitionByName("com.sailing.datas." + className) as Class;
//        var needZoomLevelCalulation = false;
//        for (var i:int = 0; i < ZOOMLEVEL_NUMBERS; i++) {
//            if (!hasTableColumn(zoomTableName, "_" + i)) {
//                sqlStatement.text = "ALTER TABLE  main_db." + zoomTableName + " ADD " + "_" + i;
//                tryExecution();
//                needZoomLevelCalulation = true;
//            }
//        }
//        var lastIdFromOriginTable:Number = getLastTimestampIdFromTable(tableName);
//        var lastIdFromZoomTable:Number = LogRegister.instance.getLastTimestampIdForZoom(zoomTableName, graphCacheEntry.id);
//        if (lastIdFromOriginTable != lastIdFromZoomTable && lastIdFromOriginTable != 0) {
//            //calculateZoomLevels(tableName, parameterName);
//
//            calculateZoomLevels(tableName, parameterName);
//        }
//
//    }
//
//    private function getLastTimestampIdFromTable(tableName:String):Number {
//        try {
//            sqlStatement.text = "SELECT timestamp_id from main_db." + tableName + " ORDER BY timestamp_id DESC LIMIT 1";
//            tryExecution();
//            var result:SQLResult = sqlStatement.getResult();
//            if (result != null) {
//                return new Number(result.data[0].timestamp_id);
//            }
//        } catch (e:Error) {
//
//        }
//        return 0;
//    }
//
//    private function hasTableColumn(tableName:String, columnName:String):Boolean {
//
//        sqlConnection.loadSchema(SQLTableSchema, tableName, "main_db");
//
//        var results:SQLSchemaResult = sqlConnection.getSchemaResult();
//        var columns:Array = results.tables[0].columns;
//        for each(var table:SQLColumnSchema in columns) {
//            if (table.name == columnName) {
//                return true;
//            }
//        }
//        return false;
//    }
//
//    private function hasTable(tableName:String):Boolean {
//        if (graphCacheEntry == null) {
//            refreshGraphCacheEntry();
//        }
//        if (graphCacheEntry.loaded_tables == null) {
//            return false;
//        }
//        var loadedTable:Array = graphCacheEntry.loaded_tables.split(",");
//        for each(var key:String in loadedTable) {
//            if (key == tableName) {
//                return true;
//            }
//        }
//        return false;
//    }
//
//    private function getLastIdFromTable(tableName:String):Number {
//        try {
//            sqlStatement.text = "SELECT id from main_db." + tableName + " ORDER BY ID DESC LIMIT 1";
//            tryExecution()
//            var result:SQLResult = sqlStatement.getResult();
//            if (result != null) {
//                return new Number(result.data[0].id);
//            }
//        } catch (e:Error) {
//            //trace(e.getStackTrace());
//        }
//        return 0;
//    }
//
//    private function calculateZoomLevels(tableName:String, columnName:String):void {
//        var minMax:Object = getMinMax(tableName, columnName);
//        if (minMax == null) {
//            //TODO ez akkor van ha valamiert nem jott letre egy tabla es nem talalunk benne semmit. Ezt majd mashogy kell kezelni
//            return;
//        }
//        var diff:Number = minMax.max - minMax.min;
//        var x:Number = diff / 4;
//        var datas:Vector.<Object> = getAllDataFromTableColumn(tableName, columnName);
//        var rdp:RamerDouglasPeuckerReduction = new RamerDouglasPeuckerReduction(datas);
//        //trace(tableName, columnName, datas.length);
//        var updateValues:Object = {};
//        for (var i:int = 0; i < ZOOMLEVEL_NUMBERS; i++) {
//            var tolerance:Number = diff / (50 + i * x);
//            var reducedPoints:Vector.<Object> = rdp.RDPsimplify(tolerance);
//            //trace("tolerance ", tolerance, " number of points ", reducedPoints.length);
//            for each(var nPoint:Object in reducedPoints) {
//                var e:Object = updateValues[nPoint.timestamp_id];
//                if (e == null) {
//                    updateValues[nPoint.timestamp_id] = {}
//                }
//                updateValues[nPoint.timestamp_id]["_" + i] = nPoint.y;
//
//            }
//        }
//        sqlConnection.begin();
//        for (var key:String in updateValues) {
//            insertZoomLevelValue(tableName + "_" + columnName, updateValues[key], key);
//        }
//        var bArrayIsEmpty:Boolean = bArray.length == 0;
//        var counter:int = 0;
//        while (!bArrayIsEmpty) {
//            bArrayIsEmpty = bArray.length == 0
//            counter++;
//        }
//        sqlConnection.commit();
//    }
//
//    private function insertZoomLevelValue(tableName:String, columns:Object, timestampId:String):void {
//        var setValues:Array = [];
//        var setColumns:Array = [];
//        for (var key:String in columns) {
//            setColumns.push("'" + key + "'");
//            setValues.push("'" + columns[key] + "'");
//        }
//        setColumns.push("timestamp_id");
//        setValues.push(timestampId);
//        sqlStatement.text = "INSERT INTO main_db." + tableName + " (" + setColumns.join(",") + ") VALUES (" + setValues.join(",") + ")";
//        try {
//            tryExecution()
//        } catch (e:Error) {
//            if (e.errorID == 3115) {
//                /*createZoomLeveles(tableName, tableName.split("_")[1])
//                 try{
//                 sqlStatement.text = "INSERT INTO main_db." + tableName + " ("+ setColumns.join(",")+") VALUES (" +setValues.join(",")+")";
//                 tryExecution()
//                 }catch(e:Error){
//                 trace("NEM SIKERULT UJRA
//                 }*/
//            }
//        }
//    }
//
//    private function getMinMax(tableName:String, columnName:String):Object {
//        try {
//            sqlStatement.text = "SELECT min(" + columnName + ") as min, max(" + columnName + ") as max FROM main_db." + tableName;
//            tryExecution()
//            var results:SQLResult = sqlStatement.getResult();
//            if (results.data != null) {
//                return {min: results.data[0].min, max: results.data[0].max}
//            }
//        } catch (e:Error) {
//
//        }
//
//        return null;
//    }
//
//    private function getAllDataFromTableColumn(tableName:String, columnName:String):Vector.<Object> {
//        var returnPoints:Vector.<Object> = new Vector.<Object>();
//        var lastId:Number
//        try {
//            lastId = LogRegister.instance.getLastTimestampIdForZoom(tableName + "_" + columnName, graphCacheEntry.id);
//        } catch (e:Error) {
//            try {
//                lastId = LogRegister.instance.getLastTimestampIdForZoom(tableName + "_" + columnName, graphCacheEntry.id);
//            } catch (e:Error) {
//                trace("LAST ID NOT FOUND");
//            }
//        }
//        sqlStatement.text = "SELECT d.timestamp_id as timestamp_id,  d." + columnName + " as 'y', t.timestamp as 'x'" +
//                " FROM main_db.timestamps t, main_db." + tableName + " d" +
//                " WHERE t.id = d.timestamp_id and d.timestamp_id > " + lastId + " ORDER BY x ASC;"
//        tryExecution()
//        var results:SQLResult = sqlStatement.getResult();
//        if (results.data != null) {
//            for each(var point:Object in results.data) {
//                returnPoints.push(point);
//            }
//        }
//        if (returnPoints.length != 0) {
//            if (lastId == -1) {
//                LogRegister.instance.addZoomDetails(tableName + "_" + columnName, graphCacheEntry.id, returnPoints[returnPoints.length - 1].timestamp_id);
//            } else {
//                LogRegister.instance.updateLastTimestampIdZoomDetails(graphCacheEntry.id, returnPoints[returnPoints.length - 1].timestamp_id, tableName + "_" + columnName);
//            }
//        }
//        return returnPoints;
//    }
//
//    private function isLastTimestampOk():Boolean {
//        return graphCacheEntry.last_timestamp == logFileEntry.last_timestamp;
//    }
//
//
//    public function addLoadedTableToGraphCache(newTableName:String):void {
//        var loadedTable:Array = []
//        if (graphCacheEntry.loaded_tables != null) {
//            loadedTable = graphCacheEntry.loaded_tables.split(",");
//        }
//
//        loadedTable.push(newTableName);
//        LogRegister.instance.updateLoadedTablesForGraphCache(graphCacheEntry.id, "'" + loadedTable.join(",") + "'");
//    }
//
//
//    private function getLastTimestampFromTable():Number {
//        sqlStatement.text = "SELECT timestamp FROM timestamps ORDER BY id DESC LIMIT 1;"
//        try {
//            tryExecution()
//            var result:SQLResult = sqlStatement.getResult();
//
//            if (result.data != null && result.data.length > 0) {
//                return result.data[0].timestamp;
//            }
//        } catch (e:Error) {
//            trace(e.getStackTrace());
//        }
//        return -1;
//
//
//    }
//}
//}