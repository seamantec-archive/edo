/**
 * Created by seamantec on 03/07/14.
 */
package com.notification {

import flash.desktop.NativeApplication;

public class NotificationHandler {

    private static var _container:Vector.<NotificationWindow>;

    public function NotificationHandler() {
    }

    public static function createWarning(type:int, msg:String, priority:int = 0, options:Object = null):void {
        createWindow(new WarningWindow(type, msg, priority, options));
    }

    public static function createAlert(type:int, msg:String, priority:int, yesCallback:Function, noCallback:Function = null, options:Object = null):void {
        createWindow(new AlertWindow(type, msg, priority, yesCallback, noCallback, options));
    }

    private static function createWindow(window:NotificationWindow):void {
        if (window == null || window.closed) {
            return;
        }
        var width:int = 0;
        var height:int = 0;
        if (NativeApplication.nativeApplication.openedWindows.length > 0) {
            width = NativeApplication.nativeApplication.openedWindows[0].width;
            height = NativeApplication.nativeApplication.openedWindows[0].height;

            window.x = (width / 2) - (window.width / 2);
            window.y = (height / 2) - (window.height / 2);
        }

        if (_container == null) {
            _container = new Vector.<NotificationWindow>();
        }
        if (_container.length > 0) {
            window.x = _container[_container.length - 1].x + 25;
            window.y = _container[_container.length - 1].y + 25;
            if ((window.x + window.width) > width) {
                window.x = width - window.width;
            }
            if ((window.y + window.height) > height) {
                window.y = height - window.height;
            }
        } else if (window.y > (window.height / 2)) {
            window.y -= (window.height / 2);
        }
        addWindow(window);
    }

    public static function close(window:NotificationWindow):void {
        for (var i:int = 0; i < _container.length; i++) {
            if (_container[i] == window) {
                _container.splice(i, 1);
            }
        }
    }

    private static function addWindow(window:NotificationWindow):void {
        var hasSame:Boolean = false;
        var item:NotificationWindow;
        for (var i:int = 0; i < _container.length; i++) {
            item = _container[i];
            if (window.getType() == item.getType()) {
                if (window.getPriority() <= item.getPriority()) {
                    window.x = item.x;
                    window.y = item.y;
                    item.close();
                    item = null;
                    _container[i] = window;
                    hasSame = true;
                } else {
                    window.close();
                    window = null;
                    return;
                }
            }
        }
        if (!hasSame) {
            _container.push(window);
        }
        window.activate();
    }
}
}
