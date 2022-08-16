/**
 * Created by pepusz on 2014.01.07..
 */
package com.sailing.socket {
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Timer;

public class DemoConnection {
    public static const SEQUENCE_LENGTH:uint = 11;
    private var sequenceTimer:Timer = new Timer(1000);
    private var logFile:File;
    private var fileContent:Array = [];
    private var sequencePointer:uint = 0;
    private var _socket:SocketDispatcher;

    public function DemoConnection(socket:SocketDispatcher) {
        this._socket = socket;
        initSequenceTimerEventListener();
        loadFile();
    }

    private function loadFile():void {
        initFile();
        var fileStream:FileStream = new FileStream();
        fileStream.open(logFile, FileMode.READ)
        var fileContentString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
        fileContent = fileContentString.split("\n");
    }

    private function initFile():void {
        if (logFile === null) {
            logFile = File.applicationDirectory.resolvePath("configs/demo.nmea");
        }
    }

    private function initSequenceTimerEventListener():void {
        sequenceTimer.addEventListener(TimerEvent.TIMER, sequenceTimer_timerHandler, false, 0, true);
    }

    private function sequenceTimer_timerHandler(event:TimerEvent):void {
        _socket.handleRawData(readNextSegmentFromFile());
        restartLogIfNecessary();
    }

    private function restartLogIfNecessary():void {
        if (sequencePointer >= fileContent.length) {
            _socket.stopDemoConnect();
            _socket.connectDemo();
        }
    }

    private function readNextSegmentFromFile():String {
        var messageString:String = "";
        for (var i:int = sequencePointer; i < sequencePointer + SEQUENCE_LENGTH && i < fileContent.length; i++) {
            messageString += fileContent[i] + "\n";
        }
        sequencePointer += SEQUENCE_LENGTH;
        return messageString
    }


    public function start():void {
        resetSequencePointer();
        sequenceTimer.start();
    }

    private function resetSequencePointer():void {
        sequencePointer = 0;
    }

    public function stop():void {
        sequenceTimer.stop();
    }
}
}
