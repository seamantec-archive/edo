/**
 * Created by pepusz on 2013.12.15..
 */
package com.seamantec.hwKeyAne {
import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;

public class HwKeyAne extends EventDispatcher {
    private var extContext:ExtensionContext = null;
    private static var _shouldCreateInstance:Boolean = false;

    public function HwKeyAne() {
        trace("Extension Context Created Constructor");
        try {
            extContext = ExtensionContext.createExtensionContext("com.seamantec.hwKeyAne", null);
        } catch (e:Error) {
            trace("ERROR during context creation")
            trace(e.message);
        }
    }

    public function getHwKey():String {
        return extContext.call("getHwKey") as String
    }
}
}
