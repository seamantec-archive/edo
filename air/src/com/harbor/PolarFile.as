/**
 * Created by pepusz on 15. 02. 12..
 */
package com.harbor {
import com.loggers.DataLogger;
import com.seamantec.LicenseManager;

import flash.data.SQLStatement;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

public class PolarFile extends EventDispatcher {
    public var id:String;
    public var name:String;
    public var extension:String;
    public var filePath:String;
    public var createdAt:Date;
    public var updatedAt:Date;
    private var _downloadPolarStatus:int;
    private var isSaved:Boolean = false;

    public function PolarFile():void {
        extension = "csv";
    }

    public static function parseJson(object:Object):PolarFile {
        var pDao:PolarFile = new PolarFile();
        pDao.id = object.id;
        pDao.name = object.name;
        pDao.createdAt = new Date();
        pDao.updatedAt = new Date();
        return pDao;
    }

    public static function parseSql(object:Object):PolarFile {
        var pDao:PolarFile = new PolarFile();
        pDao.id = object.remote_id;
        pDao.name = object.name;
        pDao.createdAt = new Date();
        pDao.updatedAt = new Date();
        pDao.filePath = object.path;
        if (!pDao.hasFile()) {
            CloudHandler.instance.addPolarToDownloadQueue(pDao);
        } else {
            pDao.dispatchFileReady();
        }
        return pDao;
    }

    public function dispatchFileReady():void {
        dispatchEvent(new PolarFileEvent());
    }

    public function hasFile():Boolean {
        return !(this.filePath == "" || this.filePath == null);
    }

    public function deletePolar():void {
        var deletePolarRequest:URLRequest = new URLRequest(LicenseManager.END_POINT_URI + "/api/v1/destroy_polar?id=" + this.id);
        deletePolarRequest.method = URLRequestMethod.DELETE;
        deletePolarRequest.requestHeaders = CloudHandler.instance.headers;

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onDeletePolarStatus, false, 0, true);
        loader.addEventListener(Event.COMPLETE, onDeletePolarComplete, false, 0, true);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDeletePolarError, false, 0, true);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onDeletePolarError, false, 0, true);
        loader.load(deletePolarRequest);
    }

    private function onDeletePolarStatus(event:HTTPStatusEvent):void {
        if (event.status == 200) {
            CloudHandler.instance.getPolars();
        }
    }

    private function onDeletePolarComplete(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onDeletePolarStatus);
        loader.removeEventListener(Event.COMPLETE, onDeletePolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDeletePolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onDeletePolarError);
    }

    private function onDeletePolarError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onDeletePolarStatus);
        loader.removeEventListener(Event.COMPLETE, onDeletePolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDeletePolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onDeletePolarError);
    }

    public function downloadPolar():void {
        var downloadPolarRequest:URLRequest = new URLRequest(LicenseManager.END_POINT_URI + "/api/v1/download_polar?id=" + id);
        downloadPolarRequest.requestHeaders = CloudHandler.instance.headers;

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onDownloadPolarStatus);
        loader.addEventListener(Event.COMPLETE, onDownloadPolarComplete);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadPolarError);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onDownloadPolarError);
        loader.load(downloadPolarRequest);
    }

    private function onDownloadPolarStatus(event:HTTPStatusEvent):void {
        _downloadPolarStatus = event.status;
        if (_downloadPolarStatus == 200) {
            var length:int = event.responseHeaders.length;
            var i:int = 0;
            while (i < length) {
                if (event.responseHeaders[i].name == "Content-Disposition") {
                    var name:String = event.responseHeaders[i].value.split("=")[1];
                    extension = name.substring(1, name.length - 1).split(".")[1];
                    break;
                }
                i++;
            }
        }
    }

    private function onDownloadPolarComplete(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onDownloadPolarStatus);
        loader.removeEventListener(Event.COMPLETE, onDownloadPolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadPolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadPolarError);

        if (_downloadPolarStatus == 200) {
            var file:File = File.applicationStorageDirectory.resolvePath("polars/" + id + "." + extension);
            filePath = file.nativePath;
            updatePath();
            var stream:FileStream = new FileStream();
            stream.open(file, FileMode.WRITE);
            stream.writeUTFBytes(loader.data);
            stream.close();
            sendPolarDownloaded();
        }
    }

    private function onDownloadPolarError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onDownloadPolarStatus);
        loader.removeEventListener(Event.COMPLETE, onDownloadPolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadPolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadPolarError);
        CloudHandler.instance.finishDownload();
    }

    private function sendPolarDownloaded():void {
        var polarDownloadedRequest:URLRequest = new URLRequest(LicenseManager.END_POINT_URI + "/api/v1/polar_downloaded?id=" + id);
        polarDownloadedRequest.requestHeaders = CloudHandler.instance.headers;
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, polarDownloaded_completeHandler);
        loader.load(polarDownloadedRequest);
    }

    private function polarDownloaded_completeHandler(event:HTTPStatusEvent):void {
        CloudHandler.instance.finishDownload();
        dispatchFileReady();
    }

    private function onPolarDownloadedError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onPolarDownloadedError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onPolarDownloadedError);
    }


    public function saveToDb():void {
        if (!PolarFileHandler.instance.dbReady) {
            trace("DB not ready");
            return;
        }

        var insertStatement:SQLStatement = new SQLStatement();
        insertStatement.sqlConnection = PolarFileHandler.instance.sqlConnection;
        insertStatement.addEventListener(SQLEvent.RESULT, insertStatement_resultHandler, false, 0, true);
        insertStatement.addEventListener(SQLErrorEvent.ERROR, insertStatement_errorHandler, false, 0, true);
        var sql:String = "INSERT INTO polars (remote_id, name, created_at, updated_at, path) VALUES (" +
                "'" + this.id + "', " +
                "'" + this.name + "', " +
                "strftime('%J','" + DataLogger.toSqlDate(this.createdAt) + "'), " +
                "strftime('%J','" + DataLogger.toSqlDate(this.updatedAt) + "'), " +
                "''); ";
        insertStatement.text = sql;
        insertStatement.execute();
    }

    private function insertStatement_resultHandler(event:SQLEvent):void {
        CloudHandler.instance.addPolarToDownloadQueue(this);
        isSaved = true;
        var statement:SQLStatement = event.currentTarget as SQLStatement;
        statement.removeEventListener(SQLEvent.RESULT, insertStatement_resultHandler);
        statement.removeEventListener(SQLErrorEvent.ERROR, insertStatement_errorHandler);

    }

    private function insertStatement_errorHandler(event:SQLErrorEvent):void {
        isSaved = false;
        var statement:SQLStatement = event.currentTarget as SQLStatement;
        statement.removeEventListener(SQLEvent.RESULT, insertStatement_resultHandler);
        statement.removeEventListener(SQLErrorEvent.ERROR, insertStatement_errorHandler);
    }


    public function updatePath():void {
        if (!PolarFileHandler.instance.dbReady) {
            trace("DB not ready")
            return;
        }
        var statement:SQLStatement = new SQLStatement();
        statement.sqlConnection = PolarFileHandler.instance.sqlConnection;
        statement.addEventListener(SQLEvent.RESULT, updateResult, false, 0, true);
        statement.addEventListener(SQLErrorEvent.ERROR, updateStatement_errorHandler, false, 0, true);
        var sql:String = "UPDATE polars SET path='" + filePath + "' WHERE remote_id='" + id + "';";
        statement.text = sql;
        statement.execute();
    }


    private function updateResult(event:SQLEvent):void {
        trace("update success")
    }

    private function updateStatement_errorHandler(event:SQLErrorEvent):void {
        trace("update failed")
    }


}
}
