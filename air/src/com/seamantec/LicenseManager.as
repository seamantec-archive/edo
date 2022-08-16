/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.12.06.
 * Time: 10:14
 * To change this template use File | Settings | File Templates.
 */
package com.seamantec {


import com.hurlant.util.Base64;
import com.seamantec.hwKeyAne.HwKeyAne;
import com.utils.EdoLocalStore;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.Timer;

public class LicenseManager extends EventDispatcher {
    registerClassAlias("com.seamantec.License", License)
//    private static const END_POINT_URI:String = "http://beta.com.seamantec.com"
    public static var END_POINT_URI:String = "http://localhost:3000"
    private static const DOWNLOAD_LICENSE_URI:String = "/api/v1/download_license"
    private static const STORE_NAME:String = "licenses";
    private var hwKeyAne:HwKeyAne;
    private var fileName:String = "demo.lic";
    public var loadingComplete:Boolean = false;
    private var _tempEmail:String = "";
    private var _tempSerial:String = "";
    private var _licenses:Vector.<License>
    private var licenseTimer:Timer = new Timer(60 * 60 * 1000);

    public function LicenseManager() {
        hwKeyAne = new HwKeyAne();
        loadLicenses();
        licenseTimer.addEventListener(TimerEvent.TIMER, checkLicenseInTimer);
        licenseTimer.start();
    }

//    public function isLicenseValid():Boolean {
//        return isLicValid(getActiveLicense());
//    }

    public function hasValidComHobby():Boolean {
        return isLicValid(getComHobby());
    }

    public function hasValidTrialHobby():Boolean {
        return isLicValid(getTrialHobby());
    }

    private function isLicValid(lic:License):Boolean {
        return lic != null && lic.isLicenseValid();
    }

    public function hasValidTrialPro():Boolean {
        return isLicValid(getTrialPro());
    }

    public function hasValidComPro():Boolean {
        return isLicValid(getComPro());
    }

    public function hasValidDemoHobby():Boolean {
        return isLicValid(getDemoHobby());
    }

    public function hasValidDemoPro():Boolean {
        return isLicValid(getDemoPro());
    }


//    public function isActivated():Boolean {
//        return getActiveLicense() != null
//    }


//    public function getActiveLicense():License {
//        return getLicenseByIndex(0);
//    }

    public function getTrialHobby():License {
        return getLicenseByName("trial_hobby");
    }

    public function getComHobby():License {
        return getLicenseByName("commercial_hobby");
    }

    public function getTrialPro():License {
        return getLicenseByName("trial_pro")
    }

    public function getComPro():License {
        return getLicenseByName("commercial_pro")
    }

    public function getDemoPro():License {
        return getLicenseByName("demo_pro")
    }

    public function getDemoHobby():License {
        return getLicenseByName("demo_hobby");
    }

    function getLicenseByName(name:String):License {
        for (var i:int = 0; i < _licenses.length; i++) {
            if (_licenses[i].name === name) {
                return _licenses[i];
            }
        }
        return null;
    }

    public function validateByGps(gpsDate:Date):void {
        var hasRemoved:Boolean = false
        for (var i:int = 0; i < _licenses.length; i++) {
            var lic:License = _licenses[i];
//            if (lic != null) {
//                lic.activate();
//            }

            if (lic != null && !lic.validateGpsTime(gpsDate)) {
//                removeLicense(lic)
                dispatchEvent(new LicenseEvent(LicenseEvent.DEACTIVATED)) //TODO az eventekben kuldjuk el hogy milyen license lett deaktivalva
                hasRemoved = true;
            }
        }

        if (hasRemoved) {
            writeOutLicenses();
            loadLicenses();
        }

    }

    function getLicenseByIndex(index:uint):License {
        if (_licenses.length > 0 && index < _licenses.length) {
            return _licenses[index]
        }
        return null;
    }


    public function getLicenseFromServer(email:String, serial_key:String):void {
        loadingComplete = false;
        var request:URLRequest = new URLRequest(END_POINT_URI + DOWNLOAD_LICENSE_URI);
        request.method = URLRequestMethod.POST;
        var datas:URLVariables = new URLVariables();
        datas.email = email;
        datas.serial_key = serial_key;
        datas.hw_key = escape(Base64.encode(getHwKey()));
        _tempEmail = email;
        _tempSerial = serial_key;
        request.data = datas.toString();
        var loader:URLLoader = new URLLoader(request);
        loader.addEventListener(Event.COMPLETE, loader_completeHandler);
        loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
        loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loader_httpResponseStatusHandler);
    }

    public function getLicenseFromFile(file:File, email:String, serailKey:String):void {
        if (file.extension != "lic") {
            return;
        }
        _tempEmail = email;
        _tempSerial = serailKey;
        var fileStream:FileStream = new FileStream();
        fileStream.open(file, FileMode.READ);
        var byteArray:ByteArray = new ByteArray();
        fileStream.readBytes(byteArray);
        fileStream.close();
        byteArray.position = 0;
        var licenseString:String = byteArray.readUTFBytes(byteArray.bytesAvailable);
        loadLicenseData(licenseString);
    }


    public function getHwKey():String {
        var serial:String = hwKeyAne.getHwKey();
        trace("HWKEY in sdk", serial)
        return serial;
    }


    private function loader_completeHandler(event:Event):void {
        var data:String = event.currentTarget.data;
        loadLicenseData(data);
    }

    function loadLicenseData(data:String):void {
        if (!data.match("errors") && data != "") {
            var license:License = new License(this, data, new Date(), _tempEmail, _tempSerial);
            license.activate();
            if (license.isLicenseValid()) {
                compareNewLicenseWithOld(license);
                _licenses.push(license);
                writeOutLicenses();
                dispatchEvent(new LicenseEvent(LicenseEvent.ACTIVATED))
                dispatchEvent(new LicenseEvent(LicenseEvent.LICENSE_DOWNLOADED));
            } else {
                dispatchEvent(new LicenseErrorEvent(""));
            }

        } else {
            dispatchEvent(new LicenseErrorEvent(data));
        }
        loadingComplete = true;
    }


    function compareNewLicenseWithOld(lic:License):void {
        var sameSubTypeLicenses:Vector.<License> = getSameSubTypeLicenses(lic.licenseSubType)
        if (lic.licenseType === License.COMMERCIAL || lic.licenseType === License.TRIAL) {
            removeDemoLicenseFromSubTypes(sameSubTypeLicenses);
        }
        if (lic.licenseType === License.COMMERCIAL) {
            removeTrialLicenseFromSubTypes(sameSubTypeLicenses);
        }
        var sameLicense:License = getLicenseByName(lic.name);

        if (sameLicense != null && sameLicense.expireAt.time <= lic.expireAt.time) {  //&& lic.licenseType !== License.TRIAL
            removeLicense(sameLicense);
        }

    }

    function removeDemoLicenseFromSubTypes(subTypeLicenses:Vector.<License>):void {
        for (var i:int = 0; i < subTypeLicenses.length; i++) {
            if (subTypeLicenses[i].licenseType === License.DEMO) {
                removeLicense(subTypeLicenses[i])
            }

        }
    }

    function removeTrialLicenseFromSubTypes(subTypeLicenses:Vector.<License>):void {
        for (var i:int = 0; i < subTypeLicenses.length; i++) {
            if (subTypeLicenses[i].licenseType === License.TRIAL) {
                removeLicense(subTypeLicenses[i])
            }

        }
    }

    function removeLicense(license:License):void {
        for (var i:int = 0; i < _licenses.length; i++) {
            if (_licenses[i] === license) {
                _licenses.splice(i, 1);
                break;
            }

        }
    }

    function getSameSubTypeLicenses(subType:String):Vector.<License> {
        var vector:Vector.<License> = new <License>[];
        for (var i:int = 0; i < _licenses.length; i++) {
            if (_licenses[i].licenseSubType === subType) {
                vector.push(_licenses[i]);
            }
        }
        return vector;
    }

    function writeOutLicenses():void {
        var d:ByteArray = new ByteArray();
        d.clear();
        d.writeObject(_licenses);
        EdoLocalStore.setItem(STORE_NAME, d);
    }

    public function get licenses():Vector.<License> {
        return _licenses
    }

    public function deactivateAll():void {
        var d:ByteArray = new ByteArray();
        EdoLocalStore.setItem(STORE_NAME, d);
        loadLicenses();
        dispatchEvent(new LicenseEvent(LicenseEvent.DEACTIVATED))
    }

    private function loadLicenses():void {
        _licenses = new <License>[];
        try {
            var d:ByteArray = EdoLocalStore.getItem(STORE_NAME);
            if (d === null) {
                return;
            }
            d.position = 0;
            if (d.bytesAvailable > 0) {
                _licenses = d.readObject() as Vector.<License>;

            }
            for (var i:int = 0; i < _licenses.length; i++) {
                _licenses[i].setLm(this);
                _licenses[i].activate();
                if (_licenses[i].isLicenseValid()) {
                    dispatchEvent(new LicenseEvent(LicenseEvent.ACTIVATED))
                }

            }
        }catch(e:Error){
            trace(e.message);
        }
    }

    private function loader_ioErrorHandler(event:IOErrorEvent):void {
        loadingComplete = true;
        dispatchEvent(new LicenseEvent(LicenseEvent.NETWORK_ERROR))
    }


    private function loader_httpResponseStatusHandler(event:HTTPStatusEvent):void {
        if (event.status === 200) {
            for (var i:int = 0; i < event.responseHeaders.length; i++) {
                var object:URLRequestHeader = event.responseHeaders[i];
                if (object.name === "Content-Disposition") {
                    fileName = object.value.replace("attachment; filename=\"", "").replace("\"", "");
                    break;
                }
            }
        }
    }

    private function checkLicenseInTimer(event:TimerEvent):void {
        for (var i:int = 0; i < _licenses.length; i++) {
            var lic:License = _licenses[i];
            if (lic != null) {
                lic.activate();
            }
            if (lic == null || !lic.isLicenseValid()) {
                dispatchEvent(new LicenseEvent(LicenseEvent.DEACTIVATED)) //TODO az eventekben kuldjuk el hogy milyen license lett deaktivalva
            }
        }
    }

    function set tempEmail(value:String):void {
        _tempEmail = value;
    }

    function set tempSerial(value:String):void {
        _tempSerial = value;
    }
}

}
