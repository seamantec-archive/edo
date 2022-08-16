/**
 * Created by pepusz on 2014.02.19..
 */
package com.ui {
import com.common.AppProperties;
import com.seamantec.LicenseManager;
import com.store.Statuses;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

public class VersionChecker extends EventDispatcher {
    private static var _instance:VersionChecker

    public function VersionChecker(target:IEventDispatcher = null) {
        super(target);
    }

    public function checkVersion():void {
        var request:URLRequest = new URLRequest(LicenseManager.END_POINT_URI + "/get_current_version");
        request.method = URLRequestMethod.GET;
        var datas:URLVariables = new URLVariables();
        datas.os = Statuses.instance.isWindows() ? "win" : "mac";
        request.data = datas.toString();
        var loader:URLLoader = new URLLoader(request);
        loader.addEventListener(Event.COMPLETE, loader_completeHandler, false, 0, true);
        loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler, false, 0, true);
    }

    private function newVersionFound():void {
        dispatchEvent(new Event("new-version"))
    }

    public static function get instance():VersionChecker {
        if (_instance === null) {
            _instance = new VersionChecker();
        }
        return _instance;
    }

    private function loader_completeHandler(event:Event):void {
        var data:String = event.currentTarget.data;
        if(data != "" && isNewVersion(AppProperties.getVersionNumber(), data)) {
            trace("new version:", data);
            newVersionFound();
        }
    }

    private function loader_ioErrorHandler(event:IOErrorEvent):void {
    }

    private function isNewVersion(currentVersion:String, newVersion:String):Boolean {
//        var currentArray:Array = currentVersion.split(".");
//        var newArray:Array = newVersion.split(".");
//
//        var length:int = (newArray.length>currentArray.length) ? currentArray.length : newArray.length;
//        for(var i:int=0; i<length; i++) {
//            if(Number(newArray[i])>Number(currentArray[i])) {
//                return true;
//            }
//        }
//
//        return false;
        return Number(newVersion.replace(/\.|[a-zA-Z]|\(|\)|\s/g, "")) > Number(currentVersion.replace(/\.|[a-zA-Z]|\(|\)|\s/g, ""))
    }
}
}
