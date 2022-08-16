package com.sailing.socket {

import com.sailing.WindowsHandler;
import com.sailing.nmeaParser.utils.NmeaPacketer;

import flash.events.*;
import flash.net.*;
import flash.utils.Timer;

public class PortScanner {
    private static var instance:PortScanner;

    private const N:uint = 10;
    private const STARTPORT:uint = 1024;
    private const STOPPORT:uint = 4096;

    private var _scanner:Boolean;

    private var _processes:Timer;
    private var _port:uint;

    private var _sockets:Vector.<ScannerSocket>;
    private var _ip:String;
    private var _ip4:uint;

    private var _serials:Array;
    private var _serialTimer:Timer;

    public var ports:Vector.<ScannerPort>;

    private var _comport:Object;

    private const _defaultPorts:Array = new Array(1470, 2000, 3331, 5300, 7000, 10001, 10002, 10110, 20175);

    public var connectSum:uint;
    public var connectCounter:uint;

    function PortScanner() {
        _sockets = new Vector.<ScannerSocket>();
        for (var i = 0; i < N; i++) {
            var socket = new Socket();
            socket.timeout = 250;

            socket.addEventListener(Event.CLOSE, closeHandler, false, 0, true);
            socket.addEventListener(Event.CONNECT, connectHandler, false, 0, true);
            socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
            socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler, false, 0, true);

            _sockets.push(new ScannerSocket(socket));
        }
        _comport = { index: 0, data: "", dataCounter: 0, port: "", baud: 0 };
        SocketDispatcher.arduino.reinitiate();
        _processes = new Timer(10);
        _processes.addEventListener(TimerEvent.TIMER, doProcess, false, 0, true);
        _serialTimer = new Timer(3000);
        _serialTimer.addEventListener(TimerEvent.TIMER, doSerial, false, 0, true);
        ports = null;
    }

    public static function getInstance():PortScanner {
        if (instance == null) {
            PortScanner.instance = new PortScanner();
        }
        return PortScanner.instance;
    }

    public function startScan():void {
        ports = new Vector.<ScannerPort>();
        var hosts:Vector.<String> = getHosts();
        if (hosts.length > 0) {

            var p:Array = hosts[hosts.length - 1].split('.');
            _port = 0;//STARTPORT;
            _ip = "";
            for (var i = 0; i < (p.length - 1); i++) {
                _ip += p[i] + ".";
            }
        }
        _ip4 = 1;
        _serials = SocketDispatcher.arduino.getComPorts();
        connectSum = 255 * _defaultPorts.length + _serials.length * 2;//
        connectCounter = 0;

        SocketDispatcher.arduino.addEventListener("socketData", comDataHandler, false, 0, true);
        if (_serials.length > 0) {
            addRemoveListeners()
            SocketDispatcher.arduino.connect(_serials[0], 4800);
            _comport.port = _serials[0];
            _comport.baud = 4800;
            _comport.index = 0;
            connectCounter++;
            _serialTimer.start();
        }

        WindowsHandler.instance.application.socketDispatcher.close(false);
        _processes.start();
    }

    private function addRemoveListeners():void {
        SocketDispatcher.arduino.removeEventListener("socketData", comDataHandler);
        SocketDispatcher.arduino.reinitiate();
        SocketDispatcher.arduino.addEventListener("socketData", comDataHandler, false, 0, true);

    }

    public function stopScan():void {
        _processes.stop();
        for (var i:int = 0; i < _sockets.length; i++) {
            var socket:ScannerSocket = _sockets[i];
            if (socket.socket.connected) {
                socket.socket.close();
            }
            socket.status = true;
            socket.sendCounter = 0;
        }
        stopSerial();
    }


    public function getHosts():Vector.<String> {
        var result:Vector.<String> = new Vector.<String>();
        var networkInfo:NetworkInfo = NetworkInfo.networkInfo;
        var interfaces:Vector.<NetworkInterface> = networkInfo.findInterfaces();
        if (interfaces != null) {
            for (var i:int = 0; i < interfaces.length; i++) {
                var interfaceObj:NetworkInterface = interfaces[i];
                if (!interfaceObj.active) {
                    continue;
                }
                for (var j:int = 0; j < interfaceObj.addresses.length; j++) {
                    var address:InterfaceAddress = interfaceObj.addresses[j];
                    if (address.ipVersion == "IPv4" && address.address != "127.0.0.1") {
                        result.push(address.address);
                    }
                }
            }
        }
        return result;
    }

    private function doProcess(event:TimerEvent):void {
        if (_port < _defaultPorts.length) {
            for (var i:int = 0; i < _sockets.length; i++) {
                var socket:ScannerSocket = _sockets[i];
                if (socket.status && _defaultPorts[_port] != undefined) {
                    socket.socket.connect(_ip + String(_ip4), _defaultPorts[_port]);
                    socket.status = false;
                    _port++;
                    connectCounter++;

                }
            }
        } else {
            _port = 0;
            _ip4++;
            if (_ip4 == 256) {
                _processes.stop();
            }
        }
    }

    private function closeHandler(event:Event):void {
        var s:Socket = event.target as Socket;
        for (var i:int = 0; i < _sockets.length; i++) {
            var socket:Socket = _sockets[i].socket;
            if (socket == s) {
                socket.close();
            }

        }
    }

    private function connectHandler(event:Event):void {
        var s:Socket = event.target as Socket;
        for (var i:int = 0; i < _sockets.length; i++) {
            var socket:ScannerSocket = _sockets[i];
            if (socket.socket == s) {
                //trace("connect on: " + s.remoteAddress + ":" + s.remotePort);
                sendData(socket);
            }

        }
    }

    private function sendData(socket:ScannerSocket):void {
        socket.socket.writeUTFBytes("u");
        socket.socket.flush();
        socket.sendCounter++;
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
        var s:Socket = event.target as Socket;
        for (var i:int = 0; i < _sockets.length; i++) {
            var socket:ScannerSocket = _sockets[i];
            if (socket.socket == s) {
                socket.status = true;
                socket.socket.close();
            }
        }
    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        trace("securityErrorHandler: " + event);
    }

    private function socketDataHandler(event:ProgressEvent):void {
        var s:Socket = event.target as Socket;
        //trace("data from: " + s.remoteAddress + ":" + s.remotePort);
        for (var i:int = 0; i < _sockets.length; i++) {
            var socket:ScannerSocket = _sockets[i];
            if (socket.socket == s) {
                var data:Array = new NmeaPacketer().newReadPacket(socket.socket.readUTFBytes(socket.socket.bytesAvailable));
                if (socket.sendCounter <= 5) {
                    if (data.length > 0) {
                        socket.status = true;
                        socket.sendCounter = 0;
                        ports.push(newTCP(s.remoteAddress, s.remotePort));
                        socket.socket.close();
                    } else {
                        sendData(socket);
                    }
                }
            }
        }
    }

    private function doSerial(event:TimerEvent):void {
        var port:String = _serials[_comport.index];
        var baud:uint = _comport.baud;
        if (_comport.baud == 4800) {
            _comport.baud = 9600;
        } else {
            _comport.baud = 4800;
            _comport.index++;
        }
        if (port == null) {
            stopSerial();
            return;
        }

        _comport.port = port;
        SocketDispatcher.arduino.close();
        addRemoveListeners()
        SocketDispatcher.arduino.connect(port, baud);
        connectCounter++;

    }

    private function stopSerial():void {
        _serialTimer.stop();
        try {
            SocketDispatcher.arduino.close();
            SocketDispatcher.arduino.removeEventListener("socketData", comDataHandler)
            SocketDispatcher.arduino.dispose();
            SocketDispatcher.arduino = null;
        } catch (e:Error) {
        }
    }

    private function comDataHandler(event:Event):void {
        _comport.data += SocketDispatcher.arduino.readBytesAsString();
        _comport.dataCounter++;
        var data:Array = new NmeaPacketer().newReadPacket(_comport.data);
        if (_comport.dataCounter <= 5) {
            if (data.length > 0) {
                _comport.index++;
                _comport.data = "";
                _comport.dataCounter = 0;
                connectCounter++;
                connectCounter++;
                ports.push(newCOM(_comport.port, _comport.baud));
                SocketDispatcher.arduino.close();
            }
        } else {
            _comport.index++;
            _comport.data = "";
            _comport.dataCounter = 0;
        }
    }

    private function newTCP(ip:String, port:uint):ScannerPort {
        return new ScannerPort("TCP", ip, port);
    }

    private function newCOM(name:String, baud:uint):ScannerPort {
        return new ScannerPort("COM", null, 0, name, baud);
    }

}
}
