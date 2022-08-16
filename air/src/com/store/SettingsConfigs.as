package com.store {
import com.common.LLNAngle;
import com.common.WindCorrection;
import com.logbook.LogBookDataHandlerEvent;
import com.sailing.socket.ScannerPort;
import com.sailing.units.UnitHandler;
import com.utils.EdoLocalStore;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

//import com.logbook.LogBookDataHandler;
[Bindable]
public class SettingsConfigs extends EventDispatcher {
    public static const TCP:uint = 0;
    public static const SERIAL:uint = 1;
    public static const UDP:uint = 2;
    public static const UNICAST:uint = 0;
    public static const BROADCAST:uint = 1;
    private static var _instance:SettingsConfigs = new SettingsConfigs();
    private var _host:String = "localhost";
    private var _port:Number = 3331;
    private var _udpPort:Number = 33333;
    private var _udpHost:String = "127.0.0.1";
    private var _udpType:uint = BROADCAST;
    private var _logging:Boolean = false;
    private var _isSerial:Boolean = false;
    private var _portName:String;
    private var _portBaud:int = 9600;
    private var _isLogBookOn:Boolean = true;
    private var _logBookEventInterval:Number = 60 * 60 * 1000;
    private var _isEconomicMode:Boolean = false;
    private var _connectionType:uint = TCP;

    public function SettingsConfigs() {
        if (_instance != null) {
            //throw new Error("Singleton can only be accessed through Singleton.instance");
        } else {
            if (Statuses.instance.isMac()) {
                portName = "/dev/ptys5"
            } else {
                portName = "COM1"
            }
            _instance = this;

        }
    }


    public function get logging():Boolean {
        return _logging;
    }

    public function set logging(value:Boolean):void {
        _logging = value;
    }

    public function get host():String {
        return _host;
    }

    public function set host(value:String):void {
        this._host = value;
    }

    public function get port():Number {
        return _port;
    }

    public function set port(value:Number):void {
        _port = value;
    }


    public function get udpPort():Number {
        return _udpPort;
    }

    public function set udpPort(value:Number):void {
        _udpPort = value;
    }

    public function get isLogBookOn():Boolean {
        return _isLogBookOn;
    }

    public function get logBookEventInterval():Number {
        return _logBookEventInterval;
    }


    public function set isLogBookOn(value:Boolean):void {
        _isLogBookOn = value;
        dispatchEvent(new LogBookDataHandlerEvent(LogBookDataHandlerEvent.ON_OFF_LOGBOOK))
    }

    public function set logBookEventInterval(value:Number):void {
        if (_logBookEventInterval != value) {
            _logBookEventInterval = value;
            dispatchEvent(new LogBookDataHandlerEvent(LogBookDataHandlerEvent.EVENT_INTERVAL_CHANGED))
        }
    }

    public function get isEconomicMode():Boolean {
        return _isEconomicMode;
    }

    public function set isEconomicMode(value:Boolean):void {
        _isEconomicMode = value;
    }

    public static function get instance():SettingsConfigs {
        if (_instance == null)  _instance = new SettingsConfigs();

        return _instance;
    }

    public static function loadBackInstance():void {
        var tempInstance = EdoLocalStore.getItem("settings");
        if (tempInstance != null) {
            _instance = tempInstance.readObject();
        }
        UnitHandler.instance.loadUnits();
        LLNAngle.instance.load();
        WindCorrection.instance.load();
        //SpeedToUse.instance.container = GraphHandler.instance.containers;
    }

    public static function saveInstance():void {
        var data:ByteArray = new ByteArray();
        data.writeObject(_instance);
        data.position = 0;
        EdoLocalStore.setItem('settings', data);
        UnitHandler.instance.saveUnits();
        LLNAngle.instance.save();
        WindCorrection.instance.save();
    }

    public function get isSerial():Boolean {
        return _connectionType == SERIAL;
    }

    public function set connectionType(value:uint):void {
        _connectionType = value;
    }


    public function get connectionType():uint {
        return _connectionType;
    }

    public function get isUdp():Boolean {
        return _connectionType == UDP;
    }

    public function get isTcp():Boolean {
        return _connectionType == TCP;
    }


    public function get portName():String {
        return _portName;
    }

    public function set portName(value:String):void {
        _portName = value;
    }

    public function get portBaud():int {
        return _portBaud;
    }

    public function set portBaud(value:int):void {
        _portBaud = value;
    }


    public function get udpType():uint {
        return _udpType;
    }

    public function set udpType(value:uint):void {
        _udpType = value;
    }

    public function isUnicastUdp():Boolean{
       return isUdp && _udpType == UNICAST;
    }
    public function isBroadcastUdp():Boolean{
       return isUdp && _udpType == BROADCAST;
    }


    public function get udpHost():String {
        return _udpHost;
    }

    public function set udpHost(value:String):void {
        _udpHost = value;
    }

    public function setPort(port:ScannerPort):void {
        if (port.type == "TCP") {
            _host = port.ip;
            _port = port.port;
            _isSerial = false;
        } else {
            _portName = port.name;
            _portBaud = port.baud;
            _isSerial = true;
        }
        dispatchEvent(new Event("setConnection"));
    }
}
}