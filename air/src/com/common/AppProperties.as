/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.21.
 * Time: 15:11
 * To change this template use File | Settings | File Templates.
 */
package com.common {

import com.seamantec.License;
import com.seamantec.LicenseManager;
import com.seamantec.PKey;

import components.LicenseWindow;
import components.ToggleButton;
import components.ais.AisListWindow;
import components.alarm.AlarmWindow;
import components.cloud.LogInWindow;
import components.cloud.PolarWindow;
import components.logBook.LogBookWindow;
import components.message.MessagesWindow;
import components.port.PortWindow;
import components.settings.SettingsWindow;

import flash.desktop.NativeApplication;

import org.log5f.air.extensions.mouse.INativeMouse;
import org.log5f.air.extensions.mouse.NativeMouse;

[Bindable]
public class AppProperties {
    public static var screenWidth:int;
    public static var screenHeight:int;
    public static var appScreenWidth:int;
    public static var alarmWindow:AlarmWindow;
    public static var settingWin:SettingsWindow;
    public static var aisWin:AisListWindow;
    public static var portWindow:PortWindow;
    public static var messagesWin:MessagesWindow;
    public static var logInWin:LogInWindow;
    public static var polarWin:PolarWindow;
    public static var logBookWindow:LogBookWindow;
    public static var licenseWin:LicenseWindow;
    public static var nativeMouse:INativeMouse = new NativeMouse();
    public static var renderMode:String = "auto"
    private static var _licenseManager:LicenseManager
    private static var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
    private static var versionLabel:String = "";
    private static var versionNumber:String = "";
    private static var copyright:String = "";
    private static var _appId:String = "";
    private static var _websocketEndpoint:String = "";

    public static function initEnvProps():void {
        if (AppProperties.appId == "com.seamantec.edo.dev") {
            LicenseManager.END_POINT_URI = "http://beta.seamantec.com";
            _websocketEndpoint = "ws://beta.seamantec.com/websocket"
//            LicenseManager.END_POINT_URI = "http://localhost:3000";
//            _websocketEndpoint = "ws://localhost:3000/websocket"
            PKey.setPKeyForEnv("dev")
        } else if (AppProperties.appId == "com.seamantec.edo") {
            LicenseManager.END_POINT_URI = "https://seamantec.com";
            _websocketEndpoint = "wss://seamantec.com/websocket"
            PKey.setPKeyForEnv("prod")
        }

        _licenseManager = new LicenseManager();
    }

    public static function isDemoProduct():Boolean {
        if (hasComHobbyLicense()) {
            return false;
        } else {
            return true
        }
    }

    public static function getStrongestLicense():License {
        var lic:License = _licenseManager.getComHobby();
        if (lic != null) {
            return lic;
        }
        lic = _licenseManager.getTrialHobby();
        if (lic != null) {
            return lic;
        }

        lic = _licenseManager.getDemoHobby();
        if (lic != null) {
            return lic;
        }
        return null;

    }

    public static function openSettingsWindow():void {
        if (AppProperties.settingWin == null || AppProperties.settingWin.closed) {
            AppProperties.settingWin = new SettingsWindow();
        }
        AppProperties.settingWin.activate();
    }

    public static function openAlarmWindow():void {
        if (AppProperties.alarmWindow == null || AppProperties.alarmWindow.closed) {
            AppProperties.alarmWindow = new AlarmWindow();
        }
        AppProperties.alarmWindow.activate();

    }

    public static function openAisWindow():void {
        if (AppProperties.aisWin == null || AppProperties.aisWin.closed) {
            AppProperties.aisWin = new AisListWindow();
        }
        AppProperties.aisWin.activate();
    }

    public static function openLicenseWindow():void {
        if (AppProperties.licenseWin == null || AppProperties.licenseWin.closed) {
            AppProperties.licenseWin = new LicenseWindow();
        }
        AppProperties.licenseWin.activate();
    }

    public static function hasComHobbyLicense():Boolean {
        return licenseManager.hasValidComHobby() || licenseManager.hasValidTrialHobby();
    }

    public static function hasDemoHobbyLicense():Boolean {
        return licenseManager.hasValidDemoHobby();
    }


    public static function get licenseManager():LicenseManager {
        return _licenseManager;
    }

    public static function openPortWindow(button:ToggleButton):void {
        if (AppProperties.portWindow == null || AppProperties.portWindow.closed) {
            AppProperties.portWindow = new PortWindow(button);
        }
        AppProperties.portWindow.activate();

    }

    public static function openLogBookWindow():void {
        if (AppProperties.logBookWindow == null || AppProperties.logBookWindow.closed) {
            AppProperties.logBookWindow = new LogBookWindow()
        }
        AppProperties.logBookWindow.activate();

    }

    public static function getVersionLabel():String {
        if (versionLabel === "") {
            var ns:Namespace = appXml.namespace();
            versionLabel = appXml.ns::versionLabel
        }
        return versionLabel;
    }

    public static function getVersionNumber():String {
        if (versionNumber === "") {
            var ns:Namespace = appXml.namespace();
            versionNumber = appXml.ns::versionNumber
        }
        return versionNumber;
    }


    public static function getCopyright():String {
        if (copyright === "") {
            var ns:Namespace = appXml.namespace();
            copyright = appXml.ns::copyright
        }
        return copyright;
    }

    public static function get appId():String {
        if (_appId == "") {
            var ns:Namespace = appXml.namespace();
            _appId = appXml.ns::id;
        }
        return _appId;

    }


    public static function get websocketEndpoint():String {
        return _websocketEndpoint;
    }
}
}
