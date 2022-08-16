package com.loggers {


import com.sailing.SailData;
import com.sailing.datas.BaseSailData;
import com.sailing.units.Unit;
import com.utils.ObjectUtils;

import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.events.EventDispatcher;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;

public class DataLogger extends EventDispatcher {
    private static const MAX_LOGFILES:int = 10;
    private static var _instance:DataLogger;
    private static var _db:File;


    private var sqlc:SQLConnection = new SQLConnection();
    private var sqls:SQLStatement = new SQLStatement();
    private var _databaseReady:Boolean = false;
    private var _logEntry:LogEntry;
    private var actualLineNumber:Number = 0;

    public function DataLogger() {
        if (_instance != null) {

        } else {
            //startLogging();
            _instance = this;
        }
    }

    public function checkDirectories():void {
        var numberOfLogs:int = LogRegister.instance.getNumberOfLogs();

        if (numberOfLogs > MAX_LOGFILES) {
            var diff:int = numberOfLogs - MAX_LOGFILES;
            var filesForDelete:Array = LogRegister.instance.getOldLogFiles(diff);
            for (var i:int = 0; i < filesForDelete.length; i++) {
                var object:Object = filesForDelete[i];
                var segments:Array = LogRegister.instance.getSegmentsForLog(object.logfileid);
                if (segments != null) {
                    for (var j:int = 0; j < segments.length; j++) {
                        deleteSegmentLogFile(segments[j].segment_name);
                    }
                }
                deleteCache(object.name);
                LogRegister.instance.deletelogFiles(object.logfileid);
            }

        }

    }

    private static function deleteCache(name:String):void {
        var file:File = File.applicationStorageDirectory;
        file = file.resolvePath(name + "_graphCache.db");
        if (file.exists) {
            file.deleteFile()
        }
    }

    public function get logEntry():LogEntry {
        return _logEntry;
    }

    public function set logEntry(value:LogEntry):void {
        _logEntry = value;
    }

    public function get db():File {
        return _db;
    }

    public function get databaseReady():Boolean {
        return _databaseReady;
    }

    public function set databaseReady(value:Boolean):void {
        _databaseReady = value;
    }

    public static function get instance():DataLogger {
        if (_instance == null) {
            _instance = new DataLogger();
        }
        return _instance;
    }

    var attachedDb:String = "";

    public function startLogging(dbName:String = null, storagePath:String = null):void {
        if (sqlc.connected) {
            sqlc.close();
        }
        if (storagePath == null) {
            _db = File.applicationStorageDirectory;
        } else {
            _db = new File(storagePath);
        }
        var s:File = _db.resolvePath("sailing");
        s.createDirectory();

//        if (dbName != null) {
        clearSegmentLogFile("sailing/" + dbName + ".edodb", storagePath);
        SystemLogger.Debug("opendb " + dbName);
        _db = _db.resolvePath("sailing/" + dbName + ".edodb");

        if (attachedDb != "") {
            sqlc.open();
            sqlc.attach("main_db", _db)
        } else {
            sqlc.open(_db);
        }

        sqls.sqlConnection = sqlc;

        initDatabaseInsyncmode();
        databaseReady = true;
    }

    public function clearSegmentLogFile(dbName:String, storagePath:String = null):void {
        var file:File;
        if (storagePath == null) {
            file = File.applicationStorageDirectory;
        } else {
            file = new File(storagePath);
        }
        if (dbName.match(".edodb")) {
            file = file.resolvePath(dbName);
        } else {
            file = file.resolvePath("sailing/" + dbName + ".edodb");
        }
//        if (file.exists) {
//            file.deleteFile();
//        }
        try {
            if (file.exists) {
                SystemLogger.Debug("Delete log file " + dbName);
                file.deleteFile();
            } else {
                SystemLogger.Debug("FILE not exists " + file.nativePath)
            }
        } catch (e:Error) {
            SystemLogger.Debug("File delete error " + dbName + " error: " + e.message);
        }
    }

    public function deleteSegmentLogFile(dbName:String):void {
        var file:File;
        file = File.applicationStorageDirectory;
        file = file.resolvePath("sailing/" + dbName);

        if (file.exists) {
            file.deleteFile();
        }
    }

    protected function db_opened(event:SQLEvent):void {

    }

    protected function result(event:SQLEvent):void {
        trace(event.toString());

    }

    protected function error(event:SQLErrorEvent):void {
        trace("error" + event.error.message);


    }

    protected function initDatabaseInsyncmode():void {
        var sailData:SailData = new SailData();
        var parameters:Array = ObjectUtils.getProperties(sailData);
        var paramsLength:Number = parameters.length;
        var sql:String = "";

        sqls.text = "CREATE TABLE IF NOT EXISTS " + attachedDb + "timestamps (" +
                "    id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "    timestamp INTEGER );"
        sqls.execute();
//        sqls.text = "CREATE INDEX  IF NOT EXISTS  "+ attachedDb+"timestamp_t_index ON "+ attachedDb+"timestamps (timestamp);";
//        sqls.execute();


        for (var i:int = 0; i < paramsLength; i++) {
            var key = parameters[i];
            /*sql = "CREATE TABLE IF NOT EXISTS " +key + "_" + ckey +  " (" +
             "    id INTEGER PRIMARY KEY AUTOINCREMENT, " +
             "  timestamp_id INTEGER, " +
             "    field_value " +getTypeForField(parent[ckey]) +
             ",FOREIGN KEY(timestamp_id) REFERENCES timestamps(id)  );"

             sqls.text = sql;
             sqls.execute();

             sqls.text = "CREATE INDEX  IF NOT EXISTS timestamp_id_index ON " +key + "_" + ckey +  " (timestamp_id);";
             sqls.execute();

             */
            var parent = sailData[key];

            var parentParameters = ObjectUtils.getProperties(parent);
            var parentParamsLength = parentParameters.length;
            var fields:Array = [];
            sql = "CREATE TABLE IF NOT EXISTS " + attachedDb + key + " (";
            fields.push("id INTEGER PRIMARY KEY AUTOINCREMENT")
            fields.push("timestamp_id INTEGER")

            for (var j:int = 0; j < parentParamsLength; j++) {
                var ckey = parentParameters[j];
                fields.push("" + ckey + " " + getTypeForField(parent[ckey]));
            }
            fields.push("FOREIGN KEY(timestamp_id) REFERENCES timestamps(id)");
            sql += fields.join(",");
            sql += ");"
            sqls.text = sql;
            sqls.execute();

//            sqls.text = "CREATE INDEX  IF NOT EXISTS "+ attachedDb+"timestamp_id_index ON " +attachedDb+key + " (timestamp_id);";
//            sqls.execute();

        }


    }

    public function getTypeForField(field:*):String {
        var type:String = "";
        if (field is Number || field is Unit) {
            return "REAL";
        } else if (field is String) {
            return "VARCHAR";
        } else if (field is Boolean) {
            return "BOOLEAN"
        } else if (field is Date) {
            return "DATE"
        } else {
            //trace("UNKNOWN field " + getQualifiedClassName(field));
            return "VARCHAR";
        }
    }

    public var tempTimestamp:Number;
    var timestampId:Number;

    //TODO bypass
//    public function insertNewMessage(data:Object, timestamp:Number) {
//        if (timestamp == -1) {
//            return;
//        }
//        actualLineNumber++;
//        if (tempTimestamp != timestamp) {
//            tempTimestamp = timestamp;
//            timestampId = DataLogger.instance.insertNewTimestampWithId(actualLineNumber, timestamp);
//        }
//        LogRegister.instance.updateMaxLineCounter(actualLineNumber, NmeaLogger.instance.getLogFile());
//        LogRegister.instance.updateLineCounter(NmeaLogger.instance.getLogFile(), actualLineNumber);
//        LogRegister.instance.updateLastTimestamp(NmeaLogger.instance.getLogFile(), timestamp);
//        if (actualLineNumber % 10000 == 0) {
//            LogRegister.instance.updateLastTimestamp(NmeaLogger.instance.getLogFile(), tempTimestamp);
//            startNewSegment();
//        }
//        try {
//            insertMessageFromLogFileOneTable(data, timestampId);
//        } catch (e:Error) {
//            trace("DATALOGGER ERROR" + e.message)
//        }
//        if (actualLineNumber % 50 == 0) {
//            this.dispatchEvent(new Event("graph-datas-need-refresh"));
//        }
//
//    }

//    private function startNewSegment():void {
//        LogRegister.instance.updateSegmentLastTimestamp(logEntry.id, logEntry.numberOfSegments, tempTimestamp);
//        LogRegister.instance.addNewLogSegment(logEntry.id, logEntry.name, logEntry.numberOfSegments + 1, new Date().time);
//        LogRegister.instance.updateSegmentsNumber(NmeaLogger.instance.getLogFile(), logEntry.numberOfSegments + 1);
//        LogRegister.instance.updateMaxSegmentsNumber(NmeaLogger.instance.getLogFile(), logEntry.maxNumberOfSegments + 1);
//        logEntry = LogRegister.instance.getLogEntry(NmeaLogger.instance.getLogFile());
//        var segmentEntry = LogRegister.instance.getSegment(logEntry.id, logEntry.numberOfSegments);
//        _db = File.applicationStorageDirectory.resolvePath("sailing/" + segmentEntry.name);
////        if(!_db.exists){
////           _db.save("")
////            _db = File.documentsDirectory.resolvePath("sailing/" + segmentEntry.name);
////        }
//        sqlc.detach("main_db");
//        sqlc.attach("main_db", _db)
//        initDatabaseInsyncmode();
//
//    }

    public function insertMessageFromLogFileOneTable(data:Object, timestampId:Number, id:Number = 0) {
        if (isNaN(timestampId)) {
            return;
        }

        var key:String = data.key;
        var newData:BaseSailData = data.data;
        var dataParameters:Array = newData.ownProperties
        var dataParamsLength:uint = dataParameters.length;
        var idString:String = "";
        if (id != 0) {
            idString = ",id";
        }
        if (dataParameters.length == 0) {
            return;
        }
        var sql:String = "INSERT INTO " + attachedDb + key + " (timestamp_id, " + dataParameters.join(",") + idString + ")";

        var fields:Array = []
        fields.push(timestampId);
        for (var i:int = 0; i < dataParamsLength; i++) {
            var dKey = dataParameters[i];
            if (newData[dKey] is Date) {
                fields.push("strftime('%J','" + toSqlDate(newData[dKey]) + "')")
//                fields.push("'" + (newData[dKey] as Date).toDateString()+"'"  )
            } else {
                fields.push("'" + ((newData[dKey] is Unit) ? newData[dKey].getPureData() : newData[dKey]) + "'");
            }
        }
        if (id != 0) {
            fields.push(id);
        }
        sql += " VALUES (" + fields.join(',') + ")";
        sqls.text = sql;

        try {
            sqls.execute();
        } catch (e:Error) {
            trace("sql:", sqls.text);
            trace("DATALOGGER ERROR:", data.key);
            trace(e.getStackTrace());
            trace("-----------------------")
        }

        var insertResult:SQLResult = sqls.getResult();
        if (insertResult == null) {
            sqls.cancel();
            return;
        }
        if (insertResult.complete || insertResult.data != null || insertResult.lastInsertRowID > 0) {
            sqls.cancel();
        }
    }

    public static function lpad(original:Object, length:int, pad:String):String {
        var padded:String = original == null ? "" : original.toString();
        while (padded.length < length) padded = pad + padded;
        return padded;
    }

    public static function toSqlDate(dateVal:Date):String {
        return dateVal == null ? null : dateVal.fullYear
                + "-" + lpad(dateVal.month + 1, 2, '0')  // month is zero-based
                + "-" + lpad(dateVal.date, 2, '0')
                + " " + lpad(dateVal.hours, 2, '0')
                + ":" + lpad(dateVal.minutes, 2, '0')
                + ":" + lpad(dateVal.seconds, 2, '0')
                ;
    }

    public static function toFormatedUTCDateWithoutSec(dateVal:Date):String {
        return dateVal == null ? null : dateVal.fullYearUTC
                + "-" + lpad(dateVal.monthUTC + 1, 2, '0')  // month is zero-based
                + "-" + lpad(dateVal.dateUTC, 2, '0')
                + " " + lpad(dateVal.hoursUTC, 2, '0')
                + ":" + lpad(dateVal.minutesUTC, 2, '0')
                ;
    }

    public static function toFormatedUTCDateForFile(dateVal:Date):String {
        return dateVal == null ? null : dateVal.fullYearUTC
                + "-" + lpad(dateVal.monthUTC + 1, 2, '0')  // month is zero-based
                + "-" + lpad(dateVal.dateUTC, 2, '0')
                ;
    }


    public function startTransaction():void {
        sqlc.begin();
    }

    public function stopTransaction():void {
        sqlc.commit();
    }

    private function insertNewData(tableName:String, fieldValue:*, timestampId:Number):void {
        sqls.text = "INSERT INTO " + tableName +
                " (timestamp_id, field_value) VALUES ( " + timestampId + ", '" +
                fieldValue + "');";
        sqls.execute();

        var insertResult:SQLResult = sqls.getResult();
        if (insertResult.complete || insertResult.data != null || insertResult.lastInsertRowID > 0) {
            sqls.cancel();
        }
    }

    public function insertBatch(insertString:Array):void {
        sqlc.begin();
        for (var i:int = 0; i < insertString.length; i++) {
            sqls.text = insertString[i];
            sqls.execute();
        }
        sqlc.commit();

        var insertResult:SQLResult = sqls.getResult();
        if (insertResult.complete || insertResult.data != null || insertResult.lastInsertRowID > 0) {
            sqls.cancel();
        }
    }

    private function updaeTimestapmId(tableName:String, timestampId:Number, rowId:Number):void {
        sqls.text = "UPDATE " + tableName + " SET timestamp_id = " + timestampId + " WHERE id = " + rowId + ";";
        sqls.execute();

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function insertNewTimestamp(timestamp):Number {
        sqls.text = "INSERT INTO timestamps (timestamp) VALUES ('" + timestamp + "');";
        sqls.execute();

        var insertResult:SQLResult = sqls.getResult();
        if (insertResult.complete || insertResult.data != null || insertResult.lastInsertRowID > 0) {
            sqls.cancel();
        }
        return insertResult.lastInsertRowID;
    }

    public function insertNewTimestampWithId(id:Number, timestamp:Number):Number {
        try {
            sqls.text = "INSERT INTO " + attachedDb + "timestamps (id,timestamp) VALUES (" + id + ",'" + timestamp + "');";
            sqls.execute();

            var insertResult:SQLResult = sqls.getResult();
            if (insertResult.complete || insertResult.data != null || insertResult.lastInsertRowID > 0) {
                sqls.cancel();
            }
            return insertResult.lastInsertRowID;
        } catch (e:Error) {
            return timestampId;
        }
        return timestampId;
    }

    public function closeConnection():void {
        sqlc.close();
    }


}
}






