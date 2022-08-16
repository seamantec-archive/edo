/**
 * Created by pepusz on 2014.02.06..
 */
package com.logbook {
import com.loggers.LogRegisterMigration;
import com.loggers.SystemLogger;

import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;

public class LogBookDb {
    public static const MAX_ITEMS:uint = 100;
    private var _db:File
    private var _sqlConnection:SQLConnection = new SQLConnection();
    private var _insertStatement:SQLStatement = new SQLStatement();
    private var _selectStatement:SQLStatement = new SQLStatement();
    private var _counterStatement:SQLStatement = new SQLStatement();
    private var _deleteStatement:SQLStatement = new SQLStatement();
    private var _exportStatement:SQLStatement = new SQLStatement();
    private var _dbReady:Boolean = false;

    private var _update:LogRegisterMigration;


    public function LogBookDb() {
        openDb();
    }
    public function closeDb():void{
        _sqlConnection.close()

    }

    public function insertLogEntry(logBookEntry:LogBookEntry):void {
        if (!_dbReady) {
            trace("DB not ready")
            return;
        }
        var sql:String = "INSERT INTO log_entries (timestamp, lat, lon, sog, cog, depth, water_temp, air_temp, wind_speed, wind_dir, trip_distance, is_demo) VALUES (" +
                "'" + Math.round((logBookEntry.timestamp.time / 1000) / 60) * 60 + "', " +
                logBookEntry.lat + ", " +
                logBookEntry.lon + ", " +
                logBookEntry.sog.getPureData() + ", " +
                logBookEntry.cog + ", " +
                logBookEntry.depth.getPureData() + ", " +
                logBookEntry.waterTemp.getPureData() + ", " +
                logBookEntry.airTemp.getPureData() + ", " +
                logBookEntry.windSpeed.getPureData() + ", " +
                logBookEntry.windDir + ", " +
                logBookEntry.tripDistance.getPureData() + ", " +
                logBookEntry.isDemo + ");"
        _insertStatement.text = sql;
        if (_insertStatement.executing) {
            _insertStatement.cancel();
        }
        _insertStatement.execute();
    }

    public function selectLastEntry(caller:ISelectCaller):void {
        select(1, new Date(Date.UTC(2000, 1, 1)), new Date(), caller);
    }

    public function selectLastNEntry(caller:ISelectCaller, n:uint = MAX_ITEMS):void {
        if (n > MAX_ITEMS) {
            n = MAX_ITEMS
        }
        select(n, new Date(Date.UTC(2000, 1, 1)), new Date(), caller);
    }

    public function selectEntriesFromTo(from:Date, to:Date, caller:ISelectCaller):void {
        select(MAX_ITEMS, from, to, caller);
    }

    public function clearAllEntry():void {
        if (!_dbReady) {
            trace("DB not ready")
            return;
        }
        try {
            _deleteStatement.text = "DELETE FROM log_entries;";
            _deleteStatement.execute();
        } catch (e:Error) {

        }
    }

    public function deleteAllDemoEntry():void {
        if (!_dbReady) {
            trace("DB not ready")
            return;
        }
        try {
            _deleteStatement.text = "DELETE FROM log_entries WHERE is_demo = 1";
            _deleteStatement.execute();
        } catch (e:Error) {

        }
    }

    private function select(limit:Number, from:Date, to:Date, caller:ISelectCaller):void {
        if (!_dbReady) {
            return;
        }
        if (_selectStatement.executing) {
            _selectStatement.cancel();
        }
        _selectStatement.text = "SELECT * FROM log_entries WHERE timestamp >= " + from.time / 1000 + " AND timestamp <=" + to.time / 1000 + " order by timestamp DESC LIMIT " + limit + ";"
        _selectStatement.execute(-1, new SelectResponder(caller));

    }


    private function openDb():void {
        initSqlConnection()
        _db = File.applicationStorageDirectory.resolvePath("logbook.db");
        _sqlConnection.openAsync(_db);
    }

    private function initSqlConnection():void {
        _sqlConnection.addEventListener(SQLEvent.OPEN, openSuccess, false, 0, true);
        _sqlConnection.addEventListener(SQLErrorEvent.ERROR, openFailure, false, 0, true);
        _insertStatement.sqlConnection = _sqlConnection;
        _insertStatement.addEventListener(SQLEvent.RESULT, insertStatement_resultHandler, false, 0, true);
        _insertStatement.addEventListener(SQLErrorEvent.ERROR, insertStatement_errorHandler, false, 0, true);
        _selectStatement.sqlConnection = _sqlConnection;
        _deleteStatement.sqlConnection = _sqlConnection;
        _counterStatement.sqlConnection = _sqlConnection;
        _deleteStatement.addEventListener(SQLEvent.RESULT, deleteStatement_resultHandler, false, 0, true);
        _deleteStatement.addEventListener(SQLErrorEvent.ERROR, deleteStatement_errorHandler, false, 0, true);
        _counterStatement.addEventListener(SQLEvent.RESULT, counterStatement_resultHandler, false, 0, true);
        _exportStatement.sqlConnection = _sqlConnection;
        _exportStatement.addEventListener(SQLEvent.RESULT, exportStatement_resultHandler, false, 0, true);
    }

    private function initDb():void {
        var sql:String = "CREATE TABLE IF NOT EXISTS ";
        sql += "log_entries (" +
                " id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                " timestamp INTEGER not null unique, " +
                " lat REAL, " +
                " lon REAL, " +
                " sog REAL, " +
                " cog REAL, " +
                " depth REAL, " +
                " water_temp REAL, " +
                " air_temp REAL, " +
                " wind_speed REAL, " +
                " wind_dir REAL ," +
                " is_demo TINYINT(1) DEFAULT 0," +
                " CONSTRAINT 'timestamp_uq' UNIQUE (timestamp COLLATE BINARY DESC) ON CONFLICT IGNORE); ";
        var createStatement:SQLStatement = new SQLStatement();
        createStatement.sqlConnection = _sqlConnection;
        createStatement.text = sql;
        createStatement.addEventListener(SQLEvent.RESULT, createStatement_resultHandler, false, 0, true);
        createStatement.addEventListener(SQLErrorEvent.ERROR, createStatement_errorHandler, false, 0, true);
        createStatement.execute();
    }

    private function openSuccess(event:SQLEvent):void {
        // trace("db open")
        initDb();
    }

    private function runMigrations():void {
        _update = new LogRegisterMigration("1", "Alter table log_entries  ADD `trip_distance` REAL;")

        var selectStatement:SQLStatement = new SQLStatement();
        selectStatement.sqlConnection = _sqlConnection;
        selectStatement.text = "SELECT version from schema_versions where version = '" + _update.version + "'";
        selectStatement.addEventListener(SQLEvent.RESULT, selectVersionStatement_resultHandler, false, 0, true);
        selectStatement.addEventListener(SQLErrorEvent.ERROR, selectVersionStatement_errorHandler, false, 0, true);
        selectStatement.execute();
    }

    private function openFailure(event:SQLErrorEvent):void {
        SystemLogger.Debug("Can't open logbook db!" + event.error);
        _dbReady = false;
    }

    private function createStatement_resultHandler(event:SQLEvent):void {
        //trace("create ok")
        //_dbReady = true;
        var createStatement:SQLStatement = new SQLStatement();
        createStatement.sqlConnection = _sqlConnection;
        createStatement.text = "CREATE TABLE IF NOT EXISTS 'schema_versions'('version' VARCHAR);";
        ;
        createStatement.addEventListener(SQLEvent.RESULT, createVersionStatement_resultHandler, false, 0, true);
        createStatement.addEventListener(SQLErrorEvent.ERROR, createVersionStatement_errorHandler, false, 0, true);
        createStatement.execute();
    }

    private function createVersionStatement_resultHandler(event:SQLEvent):void {
        //trace("create version ok");
        runMigrations();
    }

    private function selectVersionStatement_resultHandler(event:SQLEvent):void {
        //trace("migration select ok");
        var result:SQLResult = (event.target as SQLStatement).getResult();
        if (result == null || result.data == null) {
            var migrationStatement:SQLStatement = new SQLStatement();
            migrationStatement.sqlConnection = _sqlConnection;
            migrationStatement.text = _update.sql;
            migrationStatement.addEventListener(SQLEvent.RESULT, migrationStatement_resultHandler, false, 0, true);
            migrationStatement.addEventListener(SQLErrorEvent.ERROR, migrationStatement_errorHandler, false, 0, true);
            migrationStatement.execute();
        } else {
            _dbReady = true;
        }
    }

    private function migrationStatement_resultHandler(event:SQLEvent):void {
        //trace("migration ok");
        var insertMigrationStatement:SQLStatement = new SQLStatement();
        insertMigrationStatement.sqlConnection = _sqlConnection;
        insertMigrationStatement.text = "INSERT INTO schema_versions (version) VALUES('" + _update.version + "')";
        insertMigrationStatement.addEventListener(SQLEvent.RESULT, insertMigrationStatement_resultHandler, false, 0, true);
        insertMigrationStatement.addEventListener(SQLErrorEvent.ERROR, insertMigrationStatement_errorHandler, false, 0, true);
        insertMigrationStatement.execute();
    }

    private function insertMigrationStatement_resultHandler(event:SQLEvent):void {
        //trace("insert migration ok");
        _dbReady = true;
    }

    private function createStatement_errorHandler(event:SQLErrorEvent):void {
        trace("create error", event.error);
    }

    private function createVersionStatement_errorHandler(event:SQLErrorEvent):void {
        trace("create version error", event.error);
    }

    private function selectVersionStatement_errorHandler(event:SQLErrorEvent):void {
        trace("select version error", event.error);
    }

    private function migrationStatement_errorHandler(event:SQLErrorEvent):void {
        trace("migration error", event.error);
    }

    private function insertMigrationStatement_errorHandler(event:SQLErrorEvent):void {
        trace("insert migration error", event.error);
    }

    internal function get dbReady():Boolean {
        return _dbReady;
    }

    private function insertStatement_resultHandler(event:SQLEvent):void {
        LogBookDataHandler.instance.insertReady();
    }

    private function insertStatement_errorHandler(event:SQLErrorEvent):void {
        trace("insert error", event.error);
    }

    private function deleteStatement_resultHandler(event:SQLEvent):void {
        // trace("delete ok");
        //TODO dispatch event, or call logbookdatahandler method
    }

    private function deleteStatement_errorHandler(event:SQLErrorEvent):void {
        trace("delete error", event.error);
    }

    private function counterStatement_resultHandler(event:SQLEvent):void {
        try {
            LogBookDataHandler.instance.counterChanged(event.currentTarget.getResult().data[0].counter);
        } catch (e:Error) {

        }
    }

    public function countAllElements():void {
        if (_dbReady) {
            _counterStatement.text = "SELECT count(id) AS counter FROM log_entries;"
            _counterStatement.execute();
        }
    }

    function exportSelect():void {
        _exportStatement.text = "SELECT * FROM log_entries";
        _exportStatement.execute();
    }

    private function exportStatement_resultHandler(event:SQLEvent):void {
        var result:SQLResult = event.currentTarget.getResult();
        if (result.data != null) {
            var str:String = LogBookEntry.csvHeader() + "\n"
            for (var i:int = 0; i < result.data.length; i++) {
                str += LogBookEntry.parseSql(result.data[i]).exportForCsv() + "\n";
            }
            LogBookDataHandler.instance.saveExportToFile(str);
        }
    }

    private function safeExecute(sql:SQLStatement):Boolean {
        try {
            sql.execute();
            return true;
        } catch (error:SQLError) {
            SystemLogger.Debug("LOGBOOKDB Error message: " + error.message);
            SystemLogger.Debug("LOGBOOKDB Details: " + error.details);
            SystemLogger.Debug("LOGBOOKDB " + error.getStackTrace());
            return false;
        } catch (e:Error) {
            SystemLogger.Debug("LOGBOOKDB " + e.message);
            SystemLogger.Debug("LOGBOOKDB " + e.getStackTrace());
            return false;
        }
        return false;
    }
}
}

