/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.01.
 * Time: 16:52
 * To change this template use File | Settings | File Templates.
 */
package com.events {
import flash.events.Event;

public class AppClick extends Event {
    public static const APP_CLICK:String = "appClick"
    public var prevTarget:Object;

    public function AppClick(prevTarget) {
        super(APP_CLICK);
        this.prevTarget = prevTarget;
    }
}
}
