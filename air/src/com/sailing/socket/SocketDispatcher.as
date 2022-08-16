package com.sailing.socket {
import com.alarm.AlarmHandler;
import com.common.AppProperties;
import com.graphs.GraphHandler;
import com.logbook.LogBookDataHandler;
import com.loggers.NmeaLogger;
import com.loggers.SystemLogger;
import com.notification.NotificationHandler;
import com.notification.NotificationTypes;
import com.quetwo.Arduino.ArduinoConnector;
import com.sailing.WindowsHandler;
import com.sailing.ais.AisContainer;
import com.sailing.combinedDataHandlers.CombinedDataHandler;
import com.sailing.minMax.MinMaxHandler;
import com.sailing.nmeaParser.utils.NmeaInterpreter;
import com.sailing.nmeaParser.utils.NmeaPacketer;
import com.sailing.units.Direction;
import com.seamantec.LicenseEvent;
import com.seamantec.extensions.Wrapper;
import com.store.SettingsConfigs;
import com.store.Statuses;
import com.ui.TopBar;
import com.workers.WorkersHandler;

import flash.events.DataEvent;
import flash.events.DatagramSocketDataEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.DatagramSocket;
import flash.net.Socket;
import flash.system.System;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

public class SocketDispatcher extends EventDispatcher {

    private var _socket:Socket;

    //external parser or internal parser
    private var withParser:Boolean;

    private var _updateTimer:Timer;
    // periodic update interval in milliseconds
    private static var _updateInterval:Number = 100;
    private var _demoConnect:DemoConnection;
    private var _isDemoConnected:Boolean = false;
    private static var _arduino:ArduinoConnector;
    private static var _udpSocket:Wrapper;
    private var _unicastUdpSocket:DatagramSocket;

    public function SocketDispatcher() {
        this.withParser = false;
        _socket = new Socket();
        _socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData, false, 0, true);
        _socket.addEventListener(Event.CONNECT, onSocketConnected, false, 0, true);
        _socket.addEventListener(Event.CLOSE, onSocketClosed, false, 0, true);
        _socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError, false, 0, true);
        _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketSecurityError, false, 0, true);
        initUdpSocket()
        //Start timer to fetch data from socket
        _updateTimer = new Timer(_updateInterval, 0);
        _updateTimer.addEventListener("timer", onUpdateTimer, false, 0, true);
        Statuses.instance.socketStatus = false;
        _demoConnect = new DemoConnection(this);
        AppProperties.licenseManager.addEventListener(LicenseEvent.DEACTIVATED, licenceMangerDeactivatedHandler, false, 0, true);
        _udpSocket = new Wrapper();
        _udpSocket.addEventListener(Wrapper.On_UDP_Broadcast_Data_Received_EVENT_ID, onUdpData, false, 0, true);
    }

    private function initUdpSocket():void {
        _unicastUdpSocket = new DatagramSocket();
        _unicastUdpSocket.addEventListener(DatagramSocketDataEvent.DATA, udpSocket_dataHandler, false, 0, true);
        _unicastUdpSocket.addEventListener(IOErrorEvent.IO_ERROR, udpIoErrorHandler, false, 0, true);
        _unicastUdpSocket.addEventListener(Event.CLOSE, udpCloseHandler, false, 0, true);
    }

    public function connectDemo():void {
        if (TopBar.timeline != null) {
            TopBar.timeline.smallTimeline.stopLoading();
        }

        close();
        Statuses.instance.socketStatus = true;
        initComponentsForConnect();
        setInitValidation();
        _demoConnect.start();
        _isDemoConnected = true;
        TopBar.visibleSimulationLabel(true);
//        if(AppProperties.settingWin!=null) {
//            AppProperties.settingWin.enableLLN();
//        }
        dispatchEvent(new Event("connectDisconnectDemo"));
    }

    public function stopDemoConnect():void {
        Statuses.instance.socketStatus = false;
        _demoConnect.stop();
        _isDemoConnected = false;
        TopBar.visibleSimulationLabel(false);
//        if(AppProperties.settingWin!=null) {
//            AppProperties.settingWin.enableLLN();
//        }
        resetEverythingAfterClose();
        dispatchEvent(new Event("connectDisconnectDemo"))
    }

    public function connect():void {
        if (!AppProperties.hasComHobbyLicense()) {
            return;
        }
        if (AppProperties.portWindow != null && !AppProperties.portWindow.closed) {
            AppProperties.portWindow.beforeClose();
            AppProperties.portWindow.close();
        }
        setUpConnectAndConnect();

    }

    private function setUpConnectAndConnect():void {
        LogBookDataHandler.instance.deleteAllDemoEntry();
        if (TopBar.timeline != null) {
            TopBar.timeline.smallTimeline.stopLoading();
        }
        stopDemoConnect();
        initComponentsForConnect();
        if (SettingsConfigs.instance.isTcp) {
            try {
                if (!_socket.connected) {
                    _socket.connect(SettingsConfigs.instance.host, SettingsConfigs.instance.port);
                }
            } catch (e:Error) {
                SystemLogger.Warn(e.message);
            }
        } else if (SettingsConfigs.instance.isSerial) {
            if (_arduino == null) {
                _arduino = new ArduinoConnector();

            } else {
                trace("ARDUINO NOT NULL")
                _arduino.reinitiate();
//                AppProperties._serialPortConnector.removeEventListener("socketData", portDataHandler)
            }
            _arduino.addEventListener("socketData", portDataHandler, false, 0, true);

            try {
                _arduino.connect(SettingsConfigs.instance.portName, SettingsConfigs.instance.portBaud); ///dev/ptys5
            } catch (e:Error) {
                trace("error", e.message, e.getStackTrace())
            }

            Statuses.instance.socketStatus = _arduino.portOpen;
            dispatchEvent(new Event("connectDisconnect"));
        } else if (SettingsConfigs.instance.isUdp) {
            if(SettingsConfigs.instance.isBroadcastUdp()){
                trace('broadcast connect')
                Statuses.instance.socketStatus = true;
                _udpSocket.UDP_Broadcast_Open(SettingsConfigs.instance.udpPort.toString());
                dispatchEvent(new Event("connectDisconnect"));
            }else if(SettingsConfigs.instance.isUnicastUdp()){
                trace("unicast connect")
                if (_unicastUdpSocket.bound) {
                    _unicastUdpSocket.close()
                    initUdpSocket();
                }
                _unicastUdpSocket.bind(SettingsConfigs.instance.udpPort)
                _unicastUdpSocket.receive();
                var data:ByteArray = new ByteArray();

                data.writeUTFBytes("u");
                _unicastUdpSocket.send(data, 0, 0, SettingsConfigs.instance.udpHost, SettingsConfigs.instance.udpPort);
            }
        }
        setInitValidation();
    }

    private function setInitValidation():void {
        for (var key:String in WindowsHandler.instance.listeners) {
            WindowsHandler.instance.setValid(key);
        }
    }

    public function initComponentsForConnect():void {
        Direction.isVariationValid = false;
        Direction.variation = 0;
        WindowsHandler.instance.dataSource = "socket";
        NmeaPacketer.reset();
        if (TopBar.timeline != null) {
            TopBar.timeline.hideLogReplay();
        }
        GraphHandler.instance.resetAllGraphs();
        CombinedDataHandler.instance.resetHandlerDatas();

//        PolarContainer.instance.reset(GraphHandler.instance.containers);
        MinMaxHandler.instance.datasourceChanged();
        AlarmHandler.instance.resetAlarms();
    }

    public function close(withMessage:Boolean = true):void {
        if (SettingsConfigs.instance.isTcp) {
            if (_socket.connected) {
                if (withMessage) {
                    NotificationHandler.createAlert(NotificationTypes.USER_CONNECTION_CLOSE_ALERT, NotificationTypes.USER_CONNECTION_CLOSE_ALERT_TEXT, 1, closeSocket);
                } else {
                    closeSocket()
                }
            }
        } else if (SettingsConfigs.instance.isSerial) {
            if (_arduino != null) {
                if (withMessage) {
                    NotificationHandler.createAlert(NotificationTypes.USER_CONNECTION_CLOSE_ALERT, NotificationTypes.USER_CONNECTION_CLOSE_ALERT_TEXT, 1, closeSerial);
                } else {
                    closeSerial()
                }
            }
        } else if (SettingsConfigs.instance.isUdp) {
            if(SettingsConfigs.instance.isUnicastUdp() && _unicastUdpSocket.bound){
                if (withMessage) {
                    NotificationHandler.createAlert(NotificationTypes.USER_CONNECTION_CLOSE_ALERT, NotificationTypes.USER_CONNECTION_CLOSE_ALERT_TEXT, 1, closeUnicast);
                } else {
                    closeUnicast()
                }
            }
            Statuses.instance.socketStatus = false;
            _udpSocket.UDP_Broadcast_Close();
            resetEverythingAfterClose();
            dispatchEvent(new Event("connectDisconnect"));
        }
    }
    private function closeUnicast():void{
        _unicastUdpSocket.close();
        initUdpSocket();
        Statuses.instance.socketStatus = _unicastUdpSocket.bound;

        resetEverythingAfterClose();
        dispatchEvent(new Event("connectDisconnect"));
    }

    private function closeSocket():void {
        _socket.close();
        Statuses.instance.socketStatus = _socket.connected;

        resetEverythingAfterClose();
        dispatchEvent(new Event("connectDisconnect"));
    }

    private function closeSerial():void {
        try {
            _arduino.close();
            _arduino.removeEventListener("socketData", portDataHandler);
            _arduino.dispose();
            _arduino = null;
        } catch (e:Error) {
            trace("Arduinio close error", e.message);
        }

        Statuses.instance.socketStatus = false;

        resetEverythingAfterClose();
        dispatchEvent(new Event("connectDisconnect"));
    }

    private function resetEverythingAfterClose():void {
        WindowsHandler.instance.resetInstruments();
        AlarmHandler.instance.resetAlarms();
        AisContainer.instance.reset();
        GraphHandler.instance.resetAllGraphs();
        CombinedDataHandler.instance.resetHandlerDatas();
        LogBookDataHandler.instance.stopLogBook();
        System.pauseForGCIfCollectionImminent(0.15);
//        PolarContainer.instance.reset(GraphHandler.instance.containers);
    }

    public function connectDisconnect():void {
        AisContainer.instance.deleteAllShip();
        if (Statuses.instance.socketStatus && !isDemoConnected) {
            close();
        } else {
            connect();
        }
//        if(AppProperties.settingWin!=null) {
//            AppProperties.settingWin.enableLLN();
//        }
    }

    public function getStatus():int {
        if (_socket.connected) {
            return 1;
        } else {
            return 0;
        }
    }

    private function onSocketConnected(e:Event):void {
        SystemLogger.Debug("onSocketConnected");
        Statuses.instance.socketStatus = _socket.connected;
        _updateTimer.start();
        SystemLogger.Debug("TImerstarted " + _updateTimer.running);
        dispatchEvent(new Event("connectDisconnect"))
//        if(AppProperties.settingWin!=null) {
//            AppProperties.settingWin.enableLLN();
//        }
    }

    private function onSocketClosed(e:Event):void {
        SystemLogger.Debug("onSocketClosed");
        Statuses.instance.socketStatus = _socket.connected;
        _updateTimer.stop();
        AlarmHandler.instance.resetAlarms();
        LogBookDataHandler.instance.stopLogBook();
        dispatchEvent(new Event("connectDisconnect"))

    }

    private function onSocketData(e:ProgressEvent):void {
        var str:String = e.currentTarget.readUTFBytes(e.currentTarget.bytesAvailable);
        handleRawData(str);
    }

    private function onUdpData(event:DataEvent):void {
        handleRawData(event.data as String);
    }

    internal function handleRawData(str:String):void {
        NmeaLogger.instance.writeLog(str);
//        if (WorkersHandler.instance.inited) {
//            WorkersHandler.instance.mainToParser.send(str);
//        } else {
        handleSocketDataWithoutParser(str);
//        }
    }

    private function onSocketError(e:IOErrorEvent):void {
        if (_socket.connected) {
            NotificationHandler.createWarning(NotificationTypes.SYSTEM_CONNECTION_CLOSE_WARNING, NotificationTypes.SYSTEM_CONNECTION_CLOSE_WARNING_TEXT);
        }
        if (_isDemoConnected) {
            Statuses.instance.socketStatus = _isDemoConnected
        } else {
            Statuses.instance.socketStatus = _socket.connected
        }
        trace(e);
        SystemLogger.Debug("onSocketError");
        dispatchEvent(new Event("connectDisconnect"))
    }

    private function onSocketSecurityError(e:SecurityErrorEvent):void {
        if (_socket.connected) {
            NotificationHandler.createWarning(NotificationTypes.SYSTEM_CONNECTION_CLOSE_WARNING, NotificationTypes.SYSTEM_CONNECTION_CLOSE_WARNING_TEXT);
        }
        Statuses.instance.socketStatus = _socket.connected;
        trace(e);
        SystemLogger.Debug("onSocketSecurityError");
        dispatchEvent(new Event("connectDisconnect"))
    }


    public function onUpdateTimer(e:TimerEvent):void {
        var message:String;
        message = getMessageWithoutParser()
        sendText(message);
    }

    private function sendText(str:String):void {
        if (_socket.connected) {
            _socket.writeUTFBytes(str);
            _socket.flush();
        } else {
            //Alert.show("No socket connetcion");
        }
    }


    private function getMessageWithoutParser():String {
        return "u";
    }

    private var packeter:NmeaPacketer = new NmeaPacketer();

    private function handleSocketDataWithoutParser(str:String):void {
        NmeaLogger.instance.writeLog(str);
        var packet_data:Array = packeter.newReadPacket(str);
        for each(var a:String in packet_data) {
            var x:Object = NmeaInterpreter.processWithMessageCode(a);
            if (x != null && x.data != null) {
                WindowsHandler.instance.updateSailDatas(x);
            } else {
                //trace("x is null", a);

            }
        }

    }


    private function portDataHandler(event:Event):void {
        var str:String = _arduino.readBytesAsString();
        handleSocketDataWithoutParser(str);
    }


    public function get isDemoConnected():Boolean {
        return _isDemoConnected;
    }

    private function licenceMangerDeactivatedHandler(event:LicenseEvent):void {
        if (!AppProperties.hasComHobbyLicense()) {
            close();
        }
    }

    public static function isArduinoNull():Boolean {
        return _arduino == null;
    }

    public static function get arduino():ArduinoConnector {
        if (_arduino == null) {
            _arduino = new ArduinoConnector();
        }
        return _arduino;
    }


    public static function set arduino(value:ArduinoConnector):void {
        _arduino = value;
    }

    private function udpSocket_dataHandler(event:DatagramSocketDataEvent):void {
        if(!Statuses.instance.socketStatus){
            Statuses.instance.socketStatus = _unicastUdpSocket.bound;
            dispatchEvent(new Event("connectDisconnect"))
        }
        handleRawData(event.data.readUTFBytes(event.data.bytesAvailable));
    }

    private function udpIoErrorHandler(event:IOErrorEvent):void {
        trace("UDP IO ERROR")
    }

    private function udpCloseHandler(event:Event):void {
        trace("UDP CLOSED");
    }


}
}