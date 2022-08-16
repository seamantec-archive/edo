package com.loggers {
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class SystemLogger extends EventDispatcher {
    private static var _instance:SystemLogger;
    private static const LOGLEVEL:Number =0; // Debug 0; error 1; fatal 2; info 3; warn 4;
    public function SystemLogger() {
        if (_instance != null) {

        } else {
            _instance = this;
        }
    }

    public static function Debug(message:String):void {
        if (SystemLogger.LOGLEVEL > 0) return;
        var _message:String = "[DEBUG] " + new Date().toString() + " " + message;
        SystemLogger.instance.writeLog(_message);
    }

    public static function Error(message:String):void {
        if (SystemLogger.LOGLEVEL > 1) return;
        var _message:String = "[ERROR] " + new Date().toString() + " " + message;
        SystemLogger.instance.writeLog(_message);
    }

    public static function Fatal(message:String):void {
        if (SystemLogger.LOGLEVEL > 2) return;
        var _message:String = "[FATAL] " + new Date().toString() + " " + message;
        SystemLogger.instance.writeLog(_message);
    }

    public static function Info(message:String):void {
        if (SystemLogger.LOGLEVEL > 3) return;
        var _message:String = "[INFO] " + new Date().toString() + " " + message;
        SystemLogger.instance.writeLog(_message);
    }

    public static function Warn(message:String):void {
        if (SystemLogger.LOGLEVEL > 4) return;
        var _message:String = "[WARN] " + new Date().toString() + " " + message;
        SystemLogger.instance.writeLog(_message);
    }


    private function writeLog(message:String):void {
        //var file:File = File.applicationStorageDirectory;
        try {
            var file:File = File.documentsDirectory;
            file = file.resolvePath("Edo instruments/system.log");
            var fs:FileStream = new FileStream();
            fs.open(file, FileMode.APPEND);
            fs.writeUTFBytes(message + "\r\n");
            fs.close();
            trace(message);
        } catch (error:*) {

        }
    }


    public static function get instance():SystemLogger {
        if (_instance == null) {
            _instance = new SystemLogger();
        }
        return _instance;
    }
}
}