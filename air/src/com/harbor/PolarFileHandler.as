/**
 * Created by pepusz on 15. 02. 12..
 */
package com.harbor {
import com.loggers.LogRegisterMigration;
import com.loggers.SystemLogger;

import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.events.EventDispatcher;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;

public class PolarFileHandler extends EventDispatcher implements IPolarSelectCaller {
    public static const MAX_ITEMS:uint = 100;

    public static const STATUS_SYNCED:uint = 0;
    public static const STATUS_NOT_SYNCED:uint = 1;
    public static const STATUS_SYNCING:uint = 2;

    private static var _instance:PolarFileHandler;
    private var _container:Vector.<PolarFile>
    private var _db:File;
    private var _sqlConnection:SQLConnection = new SQLConnection();
    private var _selectStatement:SQLStatement = new SQLStatement();
    private var _dbReady:Boolean = false;
    private var _update:LogRegisterMigration;

    private var _status:uint;

    public function PolarFileHandler() {
        _container = new <PolarFile>[];
        status = STATUS_NOT_SYNCED;
        openDb();
    }

    public function get status():uint {
        return _status;
    }

    public function set status(value:uint):void {
        _status = (WebsocketHandler.instance.connected) ? value : STATUS_NOT_SYNCED;
        dispatchEvent(new PolarHandlerEvent(PolarHandlerEvent.POLAR_LIST_STATUS_CHANGE));
    }

    private function openDb():void {
        initSqlConnection()
        _db = File.applicationStorageDirectory.resolvePath("polar.db");
        _sqlConnection.openAsync(_db);
    }

    private function buildContainerFromLocalCache():void {
        select(100);
    }

    public function addRemotes(polarsJson:Array):void {
        var currentIds:Vector.<String> = new <String>[];
        for (var i:int = 0; i < _container.length; i++) {
            currentIds.push(_container[i].id);
        }
        var cPolar:PolarFile;
        for (var i:int = 0; i < polarsJson.length; i++) {
            cPolar = PolarFile.parseJson(polarsJson[i]);
            if (!containerHasPolar(cPolar)) {
                _container.push(cPolar);
                addFromRemote(cPolar);
                dispatchEvent(new PolarHandlerEvent(PolarHandlerEvent.POLAR_ELEMENT_ADDED))
            }
            removeIdFromCurrents(cPolar.id, currentIds);
        }
        removeDeletedPolars(currentIds);
        status = STATUS_SYNCED;
        dispatchEvent(new PolarHandlerEvent(PolarHandlerEvent.POLAR_LIST_READY));
    }

    public function deleteAll():void {
        var ids:Vector.<String> = new <String>[];
        for (var i:int = _container.length - 1; i >= 0; i--) {
            ids.push(_container[i].id);
        }
        removeDeletedPolars(ids);
    }

    private function removeIdFromCurrents(id:String, currentIds:Vector.<String>):void {
        for (var i:int = 0; i < currentIds.length; i++) {
            if (currentIds[i] == id) {
                currentIds.splice(i, 1);
                break;
            }
        }
    }

    private function removeDeletedPolars(ids:Vector.<String>):void {
        var id:String
        var removedItem:PolarFile
        for (var i:int = 0; i < ids.length; i++) {
            id = ids[i];
            deleteEntry(id);
            removedItem = removeElementFromContainer(id);
            try {
                new File(removedItem.filePath).deleteFile()
            } catch (e:Error) {
                trace("ERROR polar delete", e.message)
            }
        }
    }

    public function addFromRemote(polar:PolarFile):void {
        polar.saveToDb();

    }

    private function removeElementFromContainer(id:String):PolarFile {
        for (var i:int = 0; i < _container.length; i++) {
            if (_container[i].id == id) {
                return _container.splice(i, 1)[0];
            }
        }
        return null;
    }

    private function containerHasPolar(polar:PolarFile):Boolean {
        for (var i:int = 0; i < _container.length; i++) {
            if (_container[i].id == polar.id) {
                return true;
            }
        }
        return false;
    }

    public function hasId(id:String):Boolean {
        for (var i:int = 0; i < _container.length; i++) {
            if (_container[i].id == id) {
                return true;
            }
        }
        return false;
    }


    public function closeDb():void {
        _sqlConnection.close()
    }


    public function gotAfterInsertResult(entry:PolarFile):void {
        if (entry != null) {

        }
    }


    private function deleteEntry(id:String):void {
        if (!_dbReady) {
            trace("DB not ready")
            return;
        }
        try {
            var deleteStatement:SQLStatement = new SQLStatement();
            deleteStatement.sqlConnection = _sqlConnection;
            deleteStatement.addEventListener(SQLEvent.RESULT, deleteStatement_resultHandler, false, 0, true);
            deleteStatement.addEventListener(SQLErrorEvent.ERROR, deleteStatement_errorHandler, false, 0, true);

            deleteStatement.text = "DELETE FROM polars WHERE remote_id = '" + id + "';";
            deleteStatement.execute()
        } catch (e:Error) {

        }

    }

    private function select(limit:Number):void {
        if (!_dbReady) {
            return;
        }
        if (_selectStatement.executing) {
            _selectStatement.cancel();
        }
        _selectStatement.text = "SELECT * FROM polars order by created_at DESC LIMIT " + limit + ";";
        _selectStatement.execute(-1, new PolarSelectResponder(this));
    }


    public function gotSelectResult(entries:Vector.<PolarFile>):void {
        _container.length = 0;
        for (var i:int = 0; i < entries.length; i++) {
            _container.push(entries[i])
        }
        //TODO local cache ready
        status = STATUS_SYNCING;
        CloudHandler.instance.getPolars();
    }

    private function initDb():void {
        var sql:String = "CREATE TABLE IF NOT EXISTS ";
        sql += "polars (" +
        " id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        " remote_id VARCHAR(24), " +
        " name VARCHAR(150), " +
        " path VARCHAR(250), " +
        " created_at DATE, " +
        " updated_at DATE); ";
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
        _dbReady = true;
        buildContainerFromLocalCache()
//        _update = new LogRegisterMigration("1", "Alter table log_entries  ADD `trip_distance` REAL;")
//
//        var selectStatement:SQLStatement = new SQLStatement();
//        selectStatement.sqlConnection = _sqlConnection;
//        selectStatement.text = "SELECT version from schema_versions where version = '" + _update.version + "'";
//        selectStatement.addEventListener(SQLEvent.RESULT, selectVersionStatement_resultHandler, false, 0, true);
//        selectStatement.addEventListener(SQLErrorEvent.ERROR, selectVersionStatement_errorHandler, false, 0, true);
//        selectStatement.execute();
    }

    private function openFailure(event:SQLErrorEvent):void {
        SystemLogger.Debug("Can't open polars db!" + event.error);
        _dbReady = false;
    }

    private function createStatement_resultHandler(event:SQLEvent):void {
        //trace("create ok")
        //_dbReady = true;
        var createStatement:SQLStatement = new SQLStatement();
        createStatement.sqlConnection = _sqlConnection;
        createStatement.text = "CREATE TABLE IF NOT EXISTS 'schema_versions'('version' VARCHAR);";

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


    private function deleteStatement_resultHandler(event:SQLEvent):void {
        var statement:SQLStatement = (event.currentTarget as SQLStatement);
        statement.removeEventListener(SQLEvent.RESULT, deleteStatement_resultHandler);
        statement.removeEventListener(SQLErrorEvent.ERROR, deleteStatement_errorHandler);
        //TODO dispatch event, or call logbookdatahandler method
    }

    private function deleteStatement_errorHandler(event:SQLErrorEvent):void {
        var statement:SQLStatement = (event.currentTarget as SQLStatement);
        statement.removeEventListener(SQLEvent.RESULT, deleteStatement_resultHandler);
        statement.removeEventListener(SQLErrorEvent.ERROR, deleteStatement_errorHandler);
    }


    private function counterStatement_resultHandler(event:SQLEvent):void {
        try {

        } catch (e:Error) {

        }
    }


    private function initSqlConnection():void {
        _sqlConnection.addEventListener(SQLEvent.OPEN, openSuccess, false, 0, true);
        _sqlConnection.addEventListener(SQLErrorEvent.ERROR, openFailure, false, 0, true);
        _selectStatement.sqlConnection = _sqlConnection;
    }

    public static function get instance():PolarFileHandler {
        if (_instance == null) {
            _instance = new PolarFileHandler();
        }
        return _instance;
    }

    public function get container():Vector.<PolarFile> {
        return _container;
    }


    public function get sqlConnection():SQLConnection {
        return _sqlConnection;
    }


}
}
