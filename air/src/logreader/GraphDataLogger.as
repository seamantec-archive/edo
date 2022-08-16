/**
 * Created by pepusz on 2014.05.06..
 */
package logreader {
import com.graphs.YDatas;
import com.loggers.DataLogger;
import com.loggers.SystemLogger;
import com.sailing.SailData;
import com.sailing.datas.BaseSailData;
import com.sailing.units.Unit;
import com.utils.ObjectUtils;

import flash.data.SQLConnection;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.filesystem.File;
import flash.utils.describeType;


public class GraphDataLogger {
    //graphs db connection
    private var sqlConnection:SQLConnection = new SQLConnection();
    private var sqlStatement:SQLStatement = new SQLStatement();
    private var connectionPath:String;
    private var storagePath:String;
    var sailData:SailData = new SailData();

    public function GraphDataLogger(storagePath:String) {
        this.storagePath = storagePath;
    }

    private function buildDatabase():void {

    }

    public function closeSqlConnectionIfOpen():void {
        if (sqlConnection.connected) {
            sqlConnection.close();
        }
    }

    public function buildGraphSqlConnection(dbName:String):void {
        try {
            connectionPath = storagePath + "/" + dbName + "_graphCache.db"
            closeSqlConnectionIfOpen();
            sqlConnection.open(new File(connectionPath));
            sqlStatement.sqlConnection = sqlConnection;
            createGraphTables();
        } catch (e:Error) {
            trace(e.getStackTrace());
        }
    }

    private function createGraphTables():void {
        trace("create graph tables")
        createTimestampTable();
        YDatas.initYDatas();
        for (var i:int = 0; i < YDatas.keys.length; i++) {
            createDataTable(YDatas.keys[i]);
        }
    }

    private function createDataTable(key:String):void {
        var parameters:Array = sailData[key].ownProperties;
        var paramsLength:Number = parameters.length;

        var fields:Array = [];
        var sql = "CREATE TABLE IF NOT EXISTS " + key + " (";
        fields.push("id INTEGER PRIMARY KEY AUTOINCREMENT")
        fields.push("timestamp_id INTEGER")

        for (var j:int = 0; j < paramsLength; j++) {
            var ckey = parameters[j];
            fields.push("" + ckey + " " + DataLogger.instance.getTypeForField(sailData[key][ckey]));
        }
        fields.push("FOREIGN KEY(timestamp_id) REFERENCES timestamps(id)");
        sql += fields.join(",");
        sql += ");"
        sqlStatement.text = sql;
        sqlStatement.execute();
    }





    private function createTimestampTable():void {
        sqlStatement.text = "CREATE  TABLE IF NOT EXISTS `timestamps` (" +
                "`id` INTEGER PRIMARY KEY AUTOINCREMENT ," +
                "`timestamp` INTEGER );";
        sqlStatement.execute()
    }

    public function deleteLogDb(name:String):void {
        closeSqlConnectionIfOpen();
        var dbFileForDelete:File = new File(storagePath + "/" + name + "_graphCache.db");
        if (dbFileForDelete.exists) {
            dbFileForDelete.deleteFile();
        }
    }

    public function startTransaction():void {
        sqlConnection.begin();
    }

    public function stopTransaction():void {
        sqlConnection.commit();

    }

    public function insertNewTimestampToGraph(id:Number, timestamp:Number):void {
        try {
            sqlStatement.text = "INSERT INTO timestamps (id,timestamp) VALUES (" + id + ",'" + timestamp + "');";
            sqlStatement.execute();
        } catch (e:SQLError) {
            SystemLogger.Debug("Graph db insert error " + sqlStatement.text + " " + e.details);
        }
    }

    public function insertGraphData(data:Object, timestampId:Number, id:Number = 0):void {
        if (isNaN(timestampId)) {
            return;
        }


        var key:String = data.key;
        var couldContinue:Boolean = false;
        for (var j:int = 0; j < YDatas.keys.length; j++) {
            if (YDatas.keys[j] == key) {
                couldContinue = true;
                break;
            }
        }
        if (!couldContinue) {
            return;
        }
        var newData:BaseSailData = data.data;
        var dataParameters = newData.ownProperties;
        var dataParamsLength = dataParameters.length;
        var idString = "";
        if (id != 0) {
            idString = ",id";
        }
        if (dataParameters.length == 0) {
            return;
        }
        var sql:String = "INSERT INTO " + key + " (timestamp_id, " + dataParameters.join(",") + idString + ")";
        var fields:Array = []
        fields.push(timestampId);
        for (var i:int = 0; i < dataParamsLength; i++) {
            var dKey = dataParameters[i];
            fields.push("'" + ((newData[dKey] is Unit) ? newData[dKey].getPureData() : newData[dKey]) + "'");
        }
        if (id != 0) {
            fields.push(id);
        }
        sql += " VALUES (" + fields.join(',') + ")";
        sqlStatement.text = sql;
        try {
            sqlStatement.execute();
        } catch (e:SQLError) {
//            trace("graph data insert ERROR:", data.key + " " + e.details);
//                        trace(e.getStackTrace());
//            trace("-----------------------")
        }
    }
}
}
