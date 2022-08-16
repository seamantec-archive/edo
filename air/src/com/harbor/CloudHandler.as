/**
 * Created by seamantec on 04/02/15.
 */
package com.harbor {
import com.events.CloudEvent;
import com.polar.PolarContainer;
import com.polar.PolarEvent;
import com.seamantec.LicenseManager;
import com.utils.*;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.system.Capabilities;
import flash.utils.ByteArray;

public class CloudHandler extends EventDispatcher {

    private static var _instance:CloudHandler;

    private var _email:String = null;
    private var _deviceName:String = null;
    private var _token:String = null;
    private var _userId:String = null;

    private var _signInStatus:int;
    private var _actualPolarStatus:int;
    private var _getPolarsStatus:int;
    private var _savePolarStatus:int;
    private var _updatePolarStatus:int;
    private var _actualPolarId:String;
    private var _headers:Array;
    private var polarDownloadQueue:Vector.<PolarFile> = new <PolarFile>[];
    private var isDownloading:Boolean = false;
    private var serverEndpoint:String = LicenseManager.END_POINT_URI + "/api/v1/";


    public function CloudHandler() {
        _headers = [new URLRequestHeader("Accept", "application/json"), new URLRequestHeader("Content-Type", "application/json")];

        PolarContainer.instance.addEventListener(PolarEvent.POLAR_FILE_SAVED, polarFileSavedhandler, false, 0, true);
    }

    public static function get instance():CloudHandler {
        if (_instance == null) {
            _instance = new CloudHandler();
        }

        return _instance;
    }


    public function remove(sendEvent:Boolean = false):void {
        _email = null;
        _deviceName = null;
        _token = null;
        _userId = null;
        _headers.splice(2, 2);
        save();
        if (sendEvent) {
            WebsocketHandler.instance.disconnect(false);
            PolarFileHandler.instance.deleteAll();
            dispatchEvent(new CloudEvent(CloudEvent.SIGNOUT));
        }
    }

    public function get email():String {
        return _email;
    }


    public function get token():String {
        return _token;
    }


    public function get userId():String {
        return _userId;
    }

    public function get signedIn():Boolean {
        return (_email != null && _token != null)
    }

    public function addPolarToDownloadQueue(polarFile:PolarFile):void {
        for (var i:int = 0; i < polarDownloadQueue.length; i++) {
            if (polarDownloadQueue[i].id == polarFile.id) {
                return;
            }
        }
        polarDownloadQueue.push(polarFile);
        startDownload();
    }

    public function finishDownload():void {
        isDownloading = false;
        startDownload();
    }

    public function startDownload():void {
        if (polarDownloadQueue.length == 0) {
            isDownloading = false;
            return;
        }

        if (!isDownloading) {
            isDownloading = true
            polarDownloadQueue.pop().downloadPolar();
        }
    }


    public function set actualPolarId(value:String):void {
        _actualPolarId = value;
        var data:ByteArray = null;
        if (value != null) {
            data = new ByteArray();
            data.writeUTFBytes(value);
        }
        EdoLocalStore.setItem("actualPolarId", data);
    }

    public function get actualPolarId():String {
        var data:ByteArray = EdoLocalStore.getItem("actualPolarId");
        if (data != null) {
            _actualPolarId = data.toString();
        }
        return _actualPolarId;
    }

    public function save():void {
        var data:ByteArray = null;
        if (_email != null) {
            data = new ByteArray();
            data.writeUTFBytes(_email);

            _headers.push(new URLRequestHeader("email", _email));
        }
        EdoLocalStore.setItem("signInEmail", data);

        data = null;
        if (_deviceName != null) {
            data = new ByteArray();
            data.writeUTFBytes(_deviceName);
        }
        EdoLocalStore.setItem("signInDeviceName", data);

        data = null;
        if (_token != null) {
            data = new ByteArray();
            data.writeUTFBytes(_token);

            _headers.push(new URLRequestHeader("device-token", _token));
        }
        EdoLocalStore.setItem("signInToken", data);

        data = null;
        if (_userId != null) {
            data = new ByteArray();
            data.writeUTFBytes(_userId);
        }
        EdoLocalStore.setItem("userId", data);
    }

    public function load():void {
        var data:ByteArray = EdoLocalStore.getItem("signInEmail");
        if (data != null) {
            _email = data.toString();

            _headers.push(new URLRequestHeader("email", _email));
        }

        data = EdoLocalStore.getItem("signInDeviceName");
        if (data != null) {
            _deviceName = data.toString();
        }

        data = EdoLocalStore.getItem("signInToken");
        if (data != null) {
            _token = data.toString();

            _headers.push(new URLRequestHeader("device-token", _token));
        }
        data = EdoLocalStore.getItem("userId");
        if (data != null) {
            _userId = data.toString();
        }
    }


    public function signIn(email:String, password:String):void {
        _email = email;
        _deviceName = Capabilities.manufacturer + "&" + Capabilities.os;

        var data:URLVariables = new URLVariables();
        data.email = _email;
        data.password = password;
        data.device_name = _deviceName;
        var signInRequest:URLRequest = new URLRequest(serverEndpoint + "sign_in");
        signInRequest.method = URLRequestMethod.POST;
        signInRequest.data = data;

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onSignInStatus);
        loader.addEventListener(Event.COMPLETE, onSignInComplete);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSignInError);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onSignInError);
        loader.load(signInRequest);
    }

    private function onSignInStatus(event:HTTPStatusEvent):void {
        _signInStatus = event.status;
    }

    private function onSignInComplete(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onSignInComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSignInError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onSignInError);

        if (_signInStatus == 200) {
            var responsJson:Object = JSON.parse(loader.data)
            _token = getToken(responsJson.devices);
            _userId = responsJson.user_id;
            if (token != null) {
                save();
                WebsocketHandler.instance.connect();
                getPolars();
            } else {
                remove();
            }
            dispatchEvent(new CloudEvent(CloudEvent.SIGNIN_COMPLETE));

        } else {
            remove();

            dispatchEvent(new CloudEvent(CloudEvent.SIGNIN_ERROR, JSON.parse(loader.data).errors));
        }
    }

    private function onSignInError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onSignInComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSignInError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onSignInError);

        remove();

        var errors:Array = (loader.data == null || loader.data.length == 0) ? ["Unable to connect to the Internet"] : JSON.parse(loader.data).errors;
        dispatchEvent(new CloudEvent(CloudEvent.SIGNIN_ERROR, errors));
    }

    public function getActualPolar():void {
        if (_email != null && _token != null) {
            var getActualPolarRequest:URLRequest = new URLRequest(serverEndpoint + "get_actual_polar");
            getActualPolarRequest.requestHeaders = _headers;

            var loader:URLLoader = new URLLoader();
            loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onGetActualPolarStatus);
            loader.addEventListener(Event.COMPLETE, onGetActualPolarComplete);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetActualPolarError);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onGetActualPolarError);
            loader.load(getActualPolarRequest);
        }
    }

    private function onGetActualPolarStatus(event:HTTPStatusEvent):void {
        _actualPolarStatus = event.status;
    }

    private function onGetActualPolarComplete(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onGetActualPolarStatus);
        loader.removeEventListener(Event.COMPLETE, onGetActualPolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetActualPolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetActualPolarError);

        if (_actualPolarStatus == 200) {
            _actualPolarId = JSON.parse(loader.data).polar_id;
            //downloadPolar();
        }
    }

    private function onGetActualPolarError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onGetActualPolarStatus);
        loader.removeEventListener(Event.COMPLETE, onGetActualPolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetActualPolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetActualPolarError);
    }


    public function getDevices():void {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onGetDevicesComplete, false, 0, true);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetDevicesError, false, 0, true);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onGetDevicesError, false, 0, true);
        loader.load(new URLRequest(serverEndpoint + "devices"));
    }

    private function onGetDevicesComplete(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onGetDevicesComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetDevicesError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetDevicesError);

        dispatchEvent(new CloudEvent(CloudEvent.GET_DEVICES_COMPLETE, JSON.parse(loader.data)));
    }

    private function onGetDevicesError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onGetDevicesComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetDevicesError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetDevicesError);

        dispatchEvent(new CloudEvent(CloudEvent.GET_DEVICES_ERROR));
    }

    public function getLogs():void {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onGetLogsComplete, false, 0, true);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetLogsError, false, 0, true);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onGetLogsError, false, 0, true);
        loader.load(new URLRequest(serverEndpoint + "logs"));
    }

    private function onGetLogsComplete(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onGetLogsComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetLogsError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetLogsError);

        dispatchEvent(new CloudEvent(CloudEvent.GET_LOGS_COMPLETE, JSON.parse(loader.data)));
    }

    private function onGetLogsError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onGetLogsComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetLogsError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetLogsError);

        dispatchEvent(new CloudEvent(CloudEvent.GET_LOGS_ERROR));
    }

    public function getPolars():void {
        var getPolarsRequest:URLRequest = new URLRequest(serverEndpoint + "get_polars");
        getPolarsRequest.requestHeaders = _headers;

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onGetPolarsComplete, false, 0, true);
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onGetPolarsStatus);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetPolarsError, false, 0, true);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onGetPolarsError, false, 0, true);
        loader.load(getPolarsRequest);

        PolarFileHandler.instance.status = PolarFileHandler.STATUS_SYNCING;
    }

    private function onGetPolarsStatus(event:HTTPStatusEvent):void {
        _getPolarsStatus = event.status;
    }

    private function onGetPolarsComplete(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onGetPolarsComplete);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onGetPolarsStatus);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetPolarsError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetPolarsError);

        if (_getPolarsStatus == 200) {
//            dispatchEvent(new CloudEvent(CloudEvent.GET_POLARS_COMPLETE, JSON.parse(loader.data)));
            var polars:Array = JSON.parse(loader.data).polars as Array;
            PolarFileHandler.instance.addRemotes(polars)
        } else if (_getPolarsStatus == 204) {
            PolarFileHandler.instance.addRemotes([])
        }
    }

    private function onGetPolarsError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onGetPolarsComplete);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onGetPolarsStatus);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetPolarsError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetPolarsError);

        PolarFileHandler.instance.status = PolarFileHandler.STATUS_NOT_SYNCED;
        dispatchEvent(new CloudEvent(CloudEvent.GET_POLARS_ERROR));
    }


    public function sendPolarToDevices(id:String):void {
        var sendPolarToDevicesRequest:URLRequest = new URLRequest(serverEndpoint + "send_polar_to_devices?id=" + id);
        sendPolarToDevicesRequest.requestHeaders = _headers;

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onSendPolarToDevicesStatus);
        loader.addEventListener(Event.COMPLETE, onSendPolarToDevicesComplete, false, 0, true);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSendPolarToDevicesError, false, 0, true);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onSendPolarToDevicesError, false, 0, true);
        loader.load(sendPolarToDevicesRequest);
    }

    private function onSendPolarToDevicesStatus(event:HTTPStatusEvent):void {
        if (event.status == 404) {
        }
    }

    private function onSendPolarToDevicesComplete(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onSendPolarToDevicesStatus);
        loader.removeEventListener(Event.COMPLETE, onSendPolarToDevicesComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSendPolarToDevicesError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onSendPolarToDevicesError);
    }

    private function onSendPolarToDevicesError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onSendPolarToDevicesStatus);
        loader.removeEventListener(Event.COMPLETE, onSendPolarToDevicesComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSendPolarToDevicesError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onSendPolarToDevicesError);
    }


    public function get headers():Array {
        return _headers;
    }

    public function savePolar(name:String, content:String):void {
        var file:ByteArray = new ByteArray();
        file.writeMultiByte(content, "ascii");

        var upload:Multipart = new Multipart(serverEndpoint + "save_polar");
        upload.addField("name", name);
        upload.addFile("file", file, "text/csv", name + ".csv");

        var savePolarRequest:URLRequest = upload.request;
        var length:int = _headers.length;
        for (var i:int = 0; i < length; i++) {
            if (_headers[i].name != "Content-Type") {
                savePolarRequest.requestHeaders.push(_headers[i]);
            }
        }

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onSavePolarComplete, false, 0, true);
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onSavePolarStatus);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSavePolarError, false, 0, true);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onSavePolarError, false, 0, true);
        loader.load(savePolarRequest);
    }

    private function onSavePolarStatus(event:HTTPStatusEvent):void {
        _savePolarStatus = event.status;
    }

    private function onSavePolarComplete(event:Event):void {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onSavePolarStatus);
        loader.removeEventListener(Event.COMPLETE, onSavePolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSavePolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onSavePolarError);

        if (_savePolarStatus == 200) {
            actualPolarId = JSON.parse(loader.data).id;
            getPolars();
        }
    }

    private function onSavePolarError(event:Event):void {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onSavePolarStatus);
        loader.removeEventListener(Event.COMPLETE, onSavePolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSavePolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onSavePolarError);
    }

    public function updatePolar(content:String):void {
        var file:ByteArray = new ByteArray();
        file.writeMultiByte(content, "ascii");

        var upload:Multipart = new Multipart(serverEndpoint + "update_polar");
        upload.addField("id", actualPolarId);
        upload.addFile("file", file, "text/csv", PolarContainer.instance.polarTableName);

        var updatePolarRequest:URLRequest = upload.request;
        updatePolarRequest.method = URLRequestMethod.PUT;
        var length:int = _headers.length;
        for (var i:int = 0; i < length; i++) {
            if (_headers[i].name != "Content-Type") {
                updatePolarRequest.requestHeaders.push(_headers[i]);
            }
        }

        var loader:URLLoader = new URLLoader();
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onUpdatePolarStatus);
        loader.addEventListener(Event.COMPLETE, onUpdatePolarComplete, false, 0, true);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUpdatePolarError, false, 0, true);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onUpdatePolarError, false, 0, true);
        loader.load(updatePolarRequest);
    }

    private function onUpdatePolarStatus(event:HTTPStatusEvent):void {
        _updatePolarStatus = event.status;
    }

    private function onUpdatePolarComplete(event:Event):void {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onUpdatePolarStatus);
        loader.removeEventListener(Event.COMPLETE, onUpdatePolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUpdatePolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onUpdatePolarError);
    }

    private function onUpdatePolarError(event:Event):void {
        var loader:URLLoader = event.target as URLLoader;
        loader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onUpdatePolarStatus);
        loader.removeEventListener(Event.COMPLETE, onUpdatePolarComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUpdatePolarError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onUpdatePolarError);
    }

    public function getPolarClouds():void {
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, onGetPolarCloudsComplete, false, 0, true);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetPolarCloudsError, false, 0, true);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onGetPolarCloudsError, false, 0, true);
        loader.load(new URLRequest(serverEndpoint + "polar_clouds"));
    }

    private function onGetPolarCloudsComplete(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onGetPolarCloudsComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetPolarCloudsError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetPolarCloudsError);

        dispatchEvent(new CloudEvent(CloudEvent.GET_POLAR_CLOUDS_COMPLETE));
    }

    private function onGetPolarCloudsError(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        loader.removeEventListener(Event.COMPLETE, onGetPolarCloudsComplete);
        loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onGetPolarCloudsError);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onGetPolarCloudsError);

        dispatchEvent(new CloudEvent(CloudEvent.GET_POLAR_CLOUDS_ERROR));
    }

    private function getToken(devices:Array):String {
        var length:int = devices.length;
        var item:Object;
        for (var i:int = 0; i < length; i++) {
            item = devices[i];
            if (item.name == _deviceName) {
                return item.token;
            }
        }

        return null;
    }

    private function polarFileSavedhandler(event:PolarEvent):void {
        _actualPolarId = null;
    }
}
}
