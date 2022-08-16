/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.12.06.
 * Time: 17:12
 * To change this template use File | Settings | File Templates.
 */
package com.seamantec {
import by.blooddy.crypto.MD5;
import by.blooddy.crypto.SHA256;

import com.hurlant.crypto.rsa.RSAKey;
import com.hurlant.util.Base64;
import com.hurlant.util.der.PEM;

import flash.utils.ByteArray;

public class License {
    private static const MAX_DISTANCE:uint = 2 * 4;
    static const COMMERCIAL:String = "commercial";
    static const TRIAL:String = "trial";
    static const DEMO:String = "demo";
    public var name:String;
    public var data:String;
    public var localActivated:Date;
    public var lastGpsDate:Date;

    private var _email:String;
    private var _serial:String;
    private var _expireAt:Date;
    private var _activatedAt:Date;
    private var _licenseType:String;
    private var _licenseSubType:String;
    private var _appVersion:String;
    private var _isValid:Boolean;
    private var _licHwKey:String;
    private var _lm:LicenseManager

    private var licXml:XML;

    public function License(lm:LicenseManager = null, data:String = "", localActivated:Date = null, email:String = "", serial:String = "") {
        this.data = data;
        this.localActivated = localActivated;
        this._email = email;
        this._serial = serial;
        this._lm = lm;

    }

    public function isLicenseValid():Boolean {
        if (_isValid == null) {
            validateLicense()
        }
        return _isValid
    }


    public function get lm():LicenseManager {
        return _lm;
    }

    public function setLm(value:LicenseManager):void {
        _lm = value;
    }

    function activate():void {
        licXml = decryptLicense();
        if (licXml == null) {
            return;
        }
        _activatedAt = new Date(Date.parse(licXml["activated-at"].toString().slice(0, 10).replace(/-/g, "/")));
        _expireAt = new Date(Date.parse(licXml["expire-at"].toString().replace(/-/g, "/")));
        _licHwKey = licXml["hw-key"].toString();
        _licenseType = licXml["license-type"]
        _licenseSubType = licXml["license-sub-type"]
        name = _licenseType + "_" + _licenseSubType;
        validateLicense();
    }

    function isHashValid():Boolean {
        var children:XMLList = licXml.children();
        var encKey:String = licXml.signiture;
        var encKey2:String = ""
        if (licXml.hasOwnProperty("signiture2")) {
            encKey2 = licXml.signiture2;
        } else {
            return false;
        }
        var puKey:String = Base64.decode(licXml["pu-key"].toString());
        var rsa:RSAKey = PEM.readRSAPublicKey(puKey);
        var rsa2:RSAKey = PEM.readRSAPublicKey(PKey.pKey);
        var hashKeyba:ByteArray = new ByteArray();
        var hashKeyba2:ByteArray = new ByteArray();
        var src:ByteArray = Base64.decodeToByteArray(encKey);
        var src2:ByteArray = Base64.decodeToByteArray(encKey2);
        try {
            rsa.verify(src, hashKeyba, src.length);
            rsa2.verify(src2, hashKeyba2, src2.length)
        } catch (e:Error) {
            trace("license file is corrupted")
            return false;
        }
        var hashKey:String = Base64.decode(Base64.encodeByteArray(hashKeyba));
        var signitureString:String = ""

        for each (var child:XML in children) {
            if (child.name().toString() != "signiture" && child.name().toString() != "signiture2") {
                signitureString += child.toString();
            }
        }


        var generatedSha:String = SHA256.hash(signitureString)
        return hashKey === generatedSha;
    }

    static const DAY:uint = 1000 * 60 * 60 * 24;

    function isDateValid():Boolean {
        var localTime:Date = new Date();
        if (lastGpsDate == null || (lastGpsDate != null && lastGpsDate.time < localTime.time)) {
            return validateDate(localTime, _activatedAt, _expireAt, localActivated);
        } else {
            return validateDate(lastGpsDate, _activatedAt, _expireAt, localActivated);
        }
    }

    internal function validateGpsTime(gpsTime:Date):Boolean {
        lastGpsDate = gpsTime;
        if(lastGpsDate.time > new Date().time){
            _isValid = validateDate(gpsTime, _activatedAt, _expireAt, localActivated);
            return _isValid;

        }else{
            return true
        }
    }

    function isHwKeyValid():Boolean {

        return distance(_lm.getHwKey(), _licHwKey) < MAX_DISTANCE
    }

    private function validateLicense():void {
        _isValid = isDateValid() && isHashValid() && isHwKeyValid();
    }

    static function validateDate(localTime:Date, activatedAt:Date, expireAt:Date, _localActivated:Date):Boolean {
        var rule1:Boolean = (localTime.time - activatedAt.time) > DAY * -1
        var rule2:Boolean = (expireAt.time > localTime.time);
        var rule3:Boolean = (localTime.time - _localActivated.time) > DAY * -1;
        return rule1 && rule2 && rule3;
    }


    function decryptLicense():XML {
        var license:License = this;
        if (license === null) {
            return null;
        }
        var x:String = license._email + license._serial + _lm.getHwKey();

        var sha:String = SHA256.hash(x);
        var key:String = MD5.hash(sha);
        trace("AESKEY", key)
        var decryptedXml:String = AES.decrypt(license.data, key);
        try {
            var xmlResults:XML = new XML(decryptedXml)
        } catch (e:Error) {
            trace("xml parse error", e.message);
        }

        return xmlResults;
    }

    public function getLicenseValidationString():String {
        if (!isDateValid()) {
            if (lastGpsDate == null || (lastGpsDate != null && lastGpsDate.time < new Date().time)) {
                return "License has expired! Visit <a href='http://www.seamantec.com'>www.seamantec.com</a>.";
            } else {
                return "License has disabled by gps date! Visit <a href='http://www.seamantec.com'>www.seamantec.com</a>"
            }
        } else if (!isHashValid() || !isHwKeyValid()) {
            return "License is not valid for this computer! Visit <a href='http://www.seamantec.com'>www.seamantec.com</a>"
        }
        return "License is valid";
    }

    //TODO implement
    public function daysRemaining():String {
        return ""
    }

    static function distance(string_1:String, string_2:String):int {
        var matrix:Array = new Array();
        var dist:int;
        for (var i:int = 0; i <= string_1.length; i++) {
            matrix[i] = new Array();
            for (var j:int = 0; j <= string_2.length; j++) {
                if (i != 0) {
                    matrix[i].push(0);
                } else {
                    matrix[i].push(j);
                }
            }
            matrix[i][0] = i;
        }
        for (i = 1; i <= string_1.length; i++) {
            for (j = 1; j <= string_2.length; j++) {
                if (string_1.charAt(i - 1) == string_2.charAt(j - 1)) {
                    dist = 0;
                } else {
                    dist = 1;
                }
                matrix[i][j] = Math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + dist);
            }
        }
        return matrix[string_1.length][string_2.length];
    }

    public function get serial():String {
        return _serial;
    }

    public function get expireAt():Date {
        return _expireAt;
    }

    public function get email():String {
        return _email;
    }

    public function get activatedAt():Date {
        return _activatedAt;
    }

    public function get licenseType():String {
        return _licenseType;
    }

    public function get appVersion():String {
        return _appVersion;
    }


    public function set email(value:String):void {
        _email = value;
    }

    public function set serial(value:String):void {
        _serial = value;
    }


    public function get licenseSubType():String {
        return _licenseSubType;
    }


}
}
