package com.loggers {
import by.blooddy.crypto.MD5;

import com.common.WindCorrection;
import com.timeline.Segment;

import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public class LogRegister {
    protected static var _instance:LogRegister;
    protected var sqlc:SQLConnection = new SQLConnection();
    protected var sqls:SQLStatement = new SQLStatement();
    protected var _db:File;
    public var _dbPath:String;


    public function LogRegister(filePath:String = null) {
        if (_instance != null) {
        } else {
            _instance = this;
            initDb(filePath);
            createLogFilesTable();
            createVersionTable();
            createSegmentsTable();
            createGraphCacheTable();
            createGraphCacheTableDetails();
            runMigrations();
        }
    }

    public function closeDb():void{
        sqlc.close();
    }

    public function reInit() {
        if (_dbPath != _db.nativePath) {
            _db = new File(_dbPath);
            sqlc.close();
            sqlc.open(_db);
        }
    }

    private function initDb(filePath = null):void {
        if (filePath == null) {
            _db = File.applicationStorageDirectory;
            _db = _db.resolvePath("logregister.db");
            _dbPath = _db.nativePath;
        } else {
            _db = new File(filePath);
            _dbPath = _db.nativePath;
        }
        sqlc.open(_db);
        sqls.sqlConnection = sqlc;

    }

    private function createLogFilesTable():void {
        var sql:String = "CREATE  TABLE IF NOT EXISTS `log_files` (" +
                "`id` INTEGER PRIMARY KEY AUTOINCREMENT ," +
                "`path` TEXT ," +
                "`name` VARCHAR ," +
                "`line_counter` INTEGER," +
                "`max_line_counter` INTEGER," +
                "`max_number_of_segments` INTEGER," +
                "`number_of_segments` INTEGER," +
                "`first_timestamp` INTEGER," +
                "`last_timestamp` INTEGER," +
                "`created_at` DATETIME," +
                "`md5` VARCHAR );";
        try {
            sqls.text = sql;
            safeExecute()
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
        }
    }

    private function createVersionTable():void {
        var sql:String = "CREATE TABLE IF NOT EXISTS 'schema_versions'('version' VARCHAR);"
        try {
            sqls.text = sql;
            safeExecute();
        } catch (error:SQLError) {
            trace("CREATE VERSION Error message:", error.message);
            trace("CREATE VERSION Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
        }
    }

    private function runMigrations():void {
        var firstUpdate:LogRegisterMigration = new LogRegisterMigration("1", "Alter table log_files  ADD `wind_correction` INTEGER DEFAULT 0;")
        runUpdate(firstUpdate);
    }

    private function runUpdate(migration:LogRegisterMigration):void {
        sqls.text = "SELECT version from schema_versions where version = '" + migration.version + "'";
        safeExecute()
        if (sqls.getResult().data == null) {
            sqls.text = migration.sql
            safeExecute();
            sqls.text = "INSERT INTO schema_versions (version) VALUES('" + migration.version + "')";
            safeExecute();
        }
    }

    private function createSegmentsTable():void {
        var sql:String = "CREATE  TABLE IF NOT EXISTS `log_file_segments` (" +
                "`id` INTEGER PRIMARY KEY AUTOINCREMENT ," +
                "`log_file_id` INTEGER ," +
                "`name` VARCHAR ," +
                "`first_timestamp` INTEGER," +
                "`last_timestamp` INTEGER," +
                "`segment_index` INTEGER);";
        try {
            sqls.text = sql;
            safeExecute()
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
        }
    }

    private function createGraphCacheTable():void {
        var sql:String = "CREATE  TABLE IF NOT EXISTS `graph_caches` (" +
                "`id` INTEGER PRIMARY KEY AUTOINCREMENT ," +
                "`log_file_id` INTEGER ," +
                "`name` VARCHAR ," +
                "`last_timestamp` INTEGER," +
                "`loaded_tables` STRING);";
        try {
            sqls.text = sql;
            safeExecute()
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
    }

    private function createGraphCacheTableDetails():void {
        var sql:String = "CREATE  TABLE IF NOT EXISTS `graph_caches_loaded_datas` (" +
                "`id` INTEGER PRIMARY KEY AUTOINCREMENT ," +
                "`graph_cache_id` INTEGER ," +
                "`parameter_name` VARCHAR ," +
                "`last_timestamp_id` INTEGER);";
        try {
            sqls.text = sql;
            safeExecute()
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
    }

    public function addNewLog(file:File):void {
        var fileName:String = file.name;
        var filePath:String = file.nativePath;
        var md5:String = getMd5ForFile(file);
        var lineCounter:Number = 0;
        if (!isFileLoaded(file)) {
            sqls.text = "INSERT INTO log_files (path, name, line_counter, number_of_segments, md5, created_at, wind_correction) VALUES " +
                    "('" + filePath + "','" + fileName + "', '" + lineCounter + "', -1,'" + md5 + "', CURRENT_TIMESTAMP, " + WindCorrection.instance.windCorrection + ");";

            safeExecute()

            var insertResult:SQLResult = sqls.getResult();
            if (insertResult.complete || insertResult.data != null || insertResult.lastInsertRowID > 0) {
                sqls.cancel();
            }
            trace(insertResult.lastInsertRowID);
        }
    }

    public function addNewLogSegment(logFileId:Number, logFileName:String, index:Number, firstTimestamp:Number):void {
        var segment:Segment = getSegment(logFileId, index);
        if (segment == null) {
            var fileName:String = logFileName + "." + index + ".edodb";
            sqls.text = "INSERT INTO log_file_segments (log_file_id, name, first_timestamp, last_timestamp, segment_index) VALUES " +
                    "('" + logFileId + "','" + fileName + "', '" + firstTimestamp + "', 0,'" + index + "');";
            if (!safeExecute()) {
                return;
            }

            var insertResult:SQLResult = sqls.getResult();
            if (insertResult.complete || insertResult.data != null || insertResult.lastInsertRowID > 0) {
                sqls.cancel();
            }
        } else {
            //TODO run segment update if necesseary
            if (segment.minTime != firstTimestamp) {
                trace("segments not equal");
            }
        }
    }

    public function updateMaxLineCounter(lineCounter:Number, file:File):void {
        var maxSegmentsS:String = (lineCounter / 30000 + "").split(".")[0];
        var maxSegments:Number = new Number(maxSegmentsS);
        maxSegments++;
        sqls.text = "UPDATE log_files SET max_line_counter = " + lineCounter + ", max_number_of_segments = " + maxSegments +
                " WHERE path = '" + file.nativePath + "';"
        if (!safeExecute()) {
            return;
        }

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function updateSegmentLastTimestamp(logFileId:Number, index:Number, lastTimestamp:Number):void {
        sqls.text = "UPDATE log_file_segments SET last_timestamp = " + lastTimestamp +
                " WHERE log_file_id = '" + logFileId + "' and segment_index=" + index + ";"
        if (!safeExecute()) {
            return;
        }

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function updateMd5(file:File):void {
        var md5:String = getMd5ForFile(file);
        sqls.text = "UPDATE log_files SET md5 = '" + md5 + "' WHERE path = '" + file.nativePath + "';"
        if (!safeExecute()) {
            return;
        }

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function updateWindCorrection(file:File):void {
        sqls.text = "UPDATE log_files SET wind_correction = '" + WindCorrection.instance.windCorrection + "' WHERE path = '" + file.nativePath + "';"
        if (!safeExecute()) {
            return;
        }

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function getYDatasForLog(file:File):void {

    }

    public function getSegmentsNumber(file:File):Number {
        var results:SQLResult;
        try {
            sqls.text = "SELECT * from log_files where path = '" + file.nativePath + "';";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                if (results.data.length > 0) {
                    return results.data[0].number_of_segments;
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
        return -2;
    }

    public function getSegment(logFileId:Number, index:Number):Segment {
        var results:SQLResult;
        try {
            sqls.text = "SELECT * from log_file_segments where log_file_id = '" + logFileId + "' and segment_index=" + index + ";";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                if (results.data.length > 0) {
                    var segmentResult:Object = results.data[0];
                    var segment:Segment = mapSegmentResultToSegment(segmentResult);
                    return segment;
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            if (e.errorID != 1009) {
                trace(e.message);
                trace(e.getStackTrace());
            }

        }
        return null;
    }

    public function getSegments(logFileId:Number):Vector.<Segment> {
        var results:SQLResult;
        var rVector:Vector.<Segment> = new Vector.<Segment>();
        try {
            sqls.text = "SELECT * from log_file_segments where log_file_id = '" + logFileId + "';";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                for (var i:int = 0; i < results.data.length; i++) {
                    var segmentResult:Object = results.data[i];
                    var segment:Segment = mapSegmentResultToSegment(segmentResult);
                    rVector.push(segment);
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            if (e.errorID != 1009) {
                trace(e.message);
                trace(e.getStackTrace());
            }

        }

        return rVector;
    }

    public function getSegmentsFromTo(logFileId:Number, from, to):Vector.<Segment> {
        var results:SQLResult;
        var rVector:Vector.<Segment> = new Vector.<Segment>();
        try {
            sqls.text = "SELECT * from log_file_segments where log_file_id = '" + logFileId + "' and segment_index BETWEEN " + from + " and " + to + ";";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                for (var i:int = 0; i < results.data.length; i++) {
                    var segmentResult:Object = results.data[i];
                    var segment:Segment = mapSegmentResultToSegment(segmentResult);
                    rVector.push(segment);
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }

        return rVector;
    }

    private function mapSegmentResultToSegment(segmentResult:Object):Segment {
        var segment:Segment = new Segment(segmentResult.segment_index, segmentResult.name);
        segment.minTime = segmentResult.first_timestamp;
        segment.maxTime = segmentResult.last_timestamp;
        segment.name = segmentResult.name;
        return segment;
    }

    public function getLogEntry(file:File):LogEntry {
        var results:SQLResult;
        try {
            sqls.text = "SELECT * from log_files where path = '" + file.nativePath + "';";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                if (results.data.length > 0) {
                    return LogEntry.parseSqlResult(results.data[0]);
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            if (error.errorID == 3119) {
                safeExecute();
            }
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            if (e.errorID != 1009) {
                trace(e.message);
                trace(e.getStackTrace());
            }

        }
        return null;
    }

    public function refreshLogentry(logFileEntry:LogEntry):LogEntry {
        var results:SQLResult;
        try {
            sqls.text = "SELECT * from log_files where id = '" + logFileEntry.id + "';";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                if (results.data.length > 0) {
                    return LogEntry.parseSqlResult(results.data[0]);
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            if (e.errorID != 1009) {
                trace(e.message);
                trace(e.getStackTrace());
            }

        }
        return null;
    }


    public function getLineCounter(file:File):Number {
        var results:SQLResult;
        try {
            sqls.text = "SELECT * from log_files where path = '" + file.nativePath + "';";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                if (results.data.length > 0) {
                    return results.data[0].line_counter;
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
        return -1;
    }

    public function addYDatasForLog(file:File, yDatas:Array):void {

    }

    public function updateLineCounter(file:File, newLine:Number):void {
        sqls.text = "UPDATE log_files SET line_counter = " + newLine + " WHERE path = '" + file.nativePath + "';"
        if (!safeExecute()) {
            return;
        }

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function updateFirstTimestamp(file:File, timestamp:Number):void {
        sqls.text = "UPDATE log_files SET first_timestamp = " + timestamp + " WHERE path = '" + file.nativePath + "';"
        if (!safeExecute()) {
            return;
        }

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function updateLastTimestamp(file:File, timestamp:Number):void {
        sqls.text = "UPDATE log_files SET last_timestamp = " + timestamp + " WHERE path = '" + file.nativePath + "';"
        if (!safeExecute()) {
            return;
        }

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult == null) {
            return;
        }
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function updateSegmentsNumber(file:File, newSegment:Number):void {

        sqls.text = "UPDATE log_files SET number_of_segments = " + newSegment + " WHERE path = '" + file.nativePath + "';"
        if (!safeExecute()) {
            return;
        }

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function updateMaxSegmentsNumber(file:File, newSegment:Number):void {

        sqls.text = "UPDATE log_files SET max_number_of_segments = " + newSegment + " WHERE path = '" + file.nativePath + "';"
        if (!safeExecute()) {
            return;
        }

        var updateResult:SQLResult = sqls.getResult();
        if (updateResult.complete || updateResult.data != null) {
            sqls.cancel();
        }
    }

    public function isFileLoaded(file:File):Boolean {
        trace("isfileloaded")
        var fileName:String = file.name;
        var md5:String = getMd5ForFile(file);
        var results:SQLResult;
        try {
            sqls.text = "SELECT * from log_files where path = '" + file.nativePath + "' and name = '" + fileName + "' and md5='" + md5 + "' and wind_correction = '" + WindCorrection.instance.windCorrection + "';";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                if (results.data.length > 0) {
                    return true;
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
//            trace(e.message);
//            trace(e.getStackTrace());

        }
        return false;
    }

    //--------------- GRAP CACHE METHODS ----------------
    public function addGraphCacheEntry(name:String, parentLogId:Number):Object {
        var dataParameters:Array = ["log_file_id", "name"];
        var fieldValues:Array = [parentLogId, "'" + name + "'"];
        var lastId:Number = insertIntoTable("graph_caches", dataParameters, fieldValues);
        if (lastId > 0) {
            return getGraphCacheEntry(parentLogId);
        }
        return null;
    }

    public function addZoomDetails(parameterName:String, graphCacheId:Number, lastTimestampId:Number):void {
        var dataParameters:Array = ["graph_cache_id", "parameter_name", "last_timestamp_id"];
        var fieldValues:Array = [graphCacheId, "'" + parameterName + "'", lastTimestampId];
        var lastId:Number = insertIntoTable("graph_caches_loaded_datas", dataParameters, fieldValues);
    }

    public function updateLastTimestampIdZoomDetails(graghCacheId:Number, newTimestampId:Number, parameterName:String):void {
        sqls.text = "UPDATE graph_caches_loaded_datas SET last_timestamp_id = " + newTimestampId +
                " WHERE graph_cache_id = '" + graghCacheId + "' and parameter_name = '" + parameterName + "';"
        safeExecute()
    }

    public function getLastTimestampIdForZoom(parameterName:String, graphCacheId:Number):Number {
        sqls.text = "SELECT last_timestamp_id from graph_caches_loaded_datas where graph_cache_id = " + graphCacheId + " and parameter_name = '" + parameterName + "'";
        safeExecute()
        var result:SQLResult = sqls.getResult();
        if (result != null && result.data != null) {
            return new Number(result.data[0].last_timestamp_id);
        }
        return -1;
    }

    public function updateLastTimestampForGraphCache(entryId:Number, newLastTimestamp:Number):void {
        sqls.text = "UPDATE graph_caches SET last_timestamp = " + newLastTimestamp + " WHERE id = '" + entryId + "';"
        safeExecute()
    }


    public function updateLoadedTablesForGraphCache(entryId:Number, loadedTables:String):void {
        sqls.text = "UPDATE graph_caches SET loaded_tables = " + loadedTables + " WHERE id = '" + entryId + "';"
        safeExecute()
    }

    public function getGraphCacheEntry(parentLogId:Number):Object {
        var results:SQLResult;
        try {
            sqls.text = "SELECT * from graph_caches WHERE log_file_id = '" + parentLogId + "';";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                if (results.data.length > 0) {
                    return results.data[0];
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            if (e.errorID != 1009) {
                trace(e.message);
                trace(e.getStackTrace());
            }

        }
        return null;
    }

    public function getLastTimestampForGraphCache(entryId:Number):Number {
        var results:SQLResult;
        try {
            sqls.text = "SELECT last_timestamp from graph_caches WHERE id = '" + entryId + "';";
            safeExecute()
            results = sqls.getResult();
            if (results.complete || results.data != null) {
                if (results.data.length > 0) {
                    return results.data[0].last_timestamp;
                }
                sqls.cancel();
            }
        } catch (error:SQLError) {
            trace("Error message:", error.message);
            trace("Details:", error.details);
        } catch (e:Error) {
            trace(e.message);
            trace(e.getStackTrace());

        }
        return -1;
    }


    public function insertIntoTable(tableName:String, dataParameters:Array, fieldValues:Array):Number {
        var dataParamsLength:Number = dataParameters.length;
        var sql:String = "INSERT INTO " + tableName + " ( " + dataParameters.join(",") + ")";
        sql += " VALUES (" + fieldValues.join(',') + ")";
        sqls.text = sql;
        safeExecute()
        return sqlc.lastInsertRowID;
    }

    private function safeExecute():Boolean {
        try {
            sqls.execute();
            return true;
        } catch (error:SQLError) {
            SystemLogger.Debug("LOGREGISTER Error message: " + error.message);
            SystemLogger.Debug("LOGREGISTER Details: " + error.details);
            SystemLogger.Debug("LOGREGISTER " + error.getStackTrace());
            return false;
        } catch (e:Error) {
            SystemLogger.Debug("LOGREGISTER " + e.message);
            SystemLogger.Debug("LOGREGISTER " + e.getStackTrace());
            return false;
        }
        return false;
    }

    public static function get instance():LogRegister {
        if (_instance == null) {
            _instance = new LogRegister();
        }
        return _instance;
    }

    public static function getMd5ForFile(file:File):String {
        if (!file.exists) {
            return "";
        }
        var fileStream:FileStream = new FileStream();
        fileStream.open(file, FileMode.READ);
        fileStream.position = 0;
        var fileContent:ByteArray = new ByteArray();
        fileStream.readBytes(fileContent, 0, fileStream.bytesAvailable);
        return MD5.hashBytes(fileContent);
    }

    public function getNumberOfLogs():int {
        var sql:String = "select count(id) as number_of_logs from log_files";
        sqls.text = sql;
        safeExecute()
        return sqls.getResult().data[0].number_of_logs;
    }

    public function getOldLogFiles(numberOfFiles:int):Array {
        var sql:String = "select lFiles.id as logfileid,  lFiles.name as name from log_files lFiles " +
                "order by lFiles.created_at ASC limit " + numberOfFiles;
        sqls.text = sql;
        safeExecute()
        return sqls.getResult().data;
    }

    public function getSegmentsForLog(logId:int):Array {
        var sql:String = "select segments.id as segmentid,segments.name as segment_name from  log_file_segments segments where log_file_id =" + logId;
        sqls.text = sql;
        safeExecute()
        return sqls.getResult().data;
    }


    public function deletelogFiles(id:Number):void {
        var sql:String = "delete from log_files where id = " + id;
        sqls.text = sql;
        safeExecute()
        var sql:String = "delete from log_file_segments where log_file_id = " + id;
        sqls.text = sql;
        safeExecute()
    }


}
}