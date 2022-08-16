package com.utils {
import com.graphs.GraphDataContainer;
import com.graphs.GraphHandler;
import com.graphs.YDatas;
import com.loggers.SystemLogger;

import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.filesystem.File;

/**
 * In this class we handle all of the data which is need for graphs.
 * Importing datas from all of the segments, and cache them into a separated sqlite db.
 * Generate zoomlevel datas for 10 different zoomlevels.
 *
 * */

public class GraphDataHandler {
    private var sqlConnection:SQLConnection = new SQLConnection();
    private var sqlStatement:SQLStatement = new SQLStatement();

    private var dbFileName:String;
    private var _db:File;
    private var logFileEntry:Object;
    private var hasAttachedDb:Boolean = false;

    public function GraphDataHandler() {
        sqlStatement.sqlConnection = sqlConnection;
        sqlConnection.open();
    }


    public function openLogEntry(logFileEntry:Object):void {
        trace("db open")
        if (logFileEntry == null) {
            SystemLogger.Error("Graph data handler is null when open log entry ");
            return;
        }
        this.logFileEntry = logFileEntry;
        this.dbFileName = logFileEntry.name;

        _db = File.applicationStorageDirectory;
        _db = _db.resolvePath(dbFileName + "_graphCache.db");
        if (hasAttachedDb) {
            sqlConnection.detach("main_db");
        }

        sqlConnection.attach("main_db", _db);
        hasAttachedDb = true;

    }

    public function detachMainDb():void {
        if (hasAttachedDb) {
            sqlConnection.detach("main_db");
        }
        hasAttachedDb = false;
    }

    public function fillGraphDataContainers():void {
        var k:String;
        var sk:String
        var ssk:String;
        var cont:GraphDataContainer;
        for (var i:int = 0; i < YDatas.datas.length; i++) {
            k = YDatas.datas[i].dataKey;
            sk = k.split("_")[0];
            ssk = k.split("_")[1];

            cont = GraphHandler.instance.containers[sk][ssk];
            cont.loadDataFromLog(getDataForZoomLevelCustomGraph(k));

        }
    }

    public function resetGraphDataContainers():void {
        var k:String;
        var sk:String
        var ssk:String;
        var cont:GraphDataContainer;
        for (var i:int = 0; i < YDatas.datas.length; i++) {
            k = YDatas.datas[i].dataKey;
            sk = k.split("_")[0];
            ssk = k.split("_")[1];

            cont = GraphHandler.instance.containers[sk][ssk];
            cont.reset();

        }
    }

    public function getDataForPolar():Array {
        sqlStatement.text = "SELECT timestamps.timestamp AS timestamp, truewindc.windDirection AS windDir, truewindc.windSpeed AS windSpeed, rmc.gpsSog AS boatSpeed FROM truewindc, rmc, timestamps WHERE rmc.timestamp_id = truewindc.timestamp_id AND timestamps.id = rmc.timestamp_id";
        try {
            sqlStatement.execute()


        } catch (e:Error) {
            trace(e.getStackTrace());
        }
        var results:SQLResult = sqlStatement.getResult();
        if (results != null && results.data != null) {
            return results.data;
        }
        return [];
    }


    public function getDataForZoomLevelCustomGraph(tableAndProperty:String, isHorizontal:Boolean = true):Array {
        if (this.logFileEntry == null) {
            return [];
        }
        var splittedParams:Array = tableAndProperty.split("_");
        var valueFrom:String = splittedParams[1];
        var where:Array = [];
        var columnName:String;
        var tableName:String = tableAndProperty;
        var order = "ASC"
        if (!isHorizontal) {
            order = "DESC";
        }
        columnName = valueFrom;
        tableName = splittedParams[0];

        where.push("t.id = d.timestamp_id");
        where.push(columnName + " IS NOT NULL");
        //TODO maybe set async connection (create a queue for it and store respondehandler and graph into it) if one respone handler ready go to next
        sqlStatement.text = "SELECT d." + columnName + " as 'data', t.timestamp as sailDataTimestamp" +
                " FROM timestamps t, " + tableName + " d" +
                " WHERE " + where.join(" and ") + " ORDER BY sailDataTimestamp " + order + ";";
        try {
            sqlStatement.execute()


        } catch (e:Error) {
            trace(e.getStackTrace());
        }
        var results:SQLResult = sqlStatement.getResult();
        if (results != null && results.data != null) {
            return results.data;
        }
        return [];
    }


    public function getMarkerData(key:String, timestamp:Number):Number {
        var x:Array = key.split("_");
        sqlStatement.text = "SELECT d." + x[1] + " as data, t.timestamp as sailDataTimestamp" +
                " FROM timestamps t, " + x[0] + " d" +
                " WHERE t.id = d.timestamp_id and t.timestamp <= " + timestamp + " ORDER BY sailDataTimestamp DESC LIMIT 1;";
        try {
            sqlStatement.execute();
        } catch (e:Error) {
            trace(e.getStackTrace());
        }
        var results:SQLResult = sqlStatement.getResult();
        if (results != null && results.data != null) {
            return results.data[0].data;
        }
        return NaN;
    }


    public function get db():File {
        return _db;
    }

    public function set db(value:File):void {
        _db = value;
    }


}
}