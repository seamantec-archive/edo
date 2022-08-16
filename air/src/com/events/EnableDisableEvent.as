/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.22.
 * Time: 16:13
 * To change this template use File | Settings | File Templates.
 */
package com.events {
import flash.events.Event;

public class EnableDisableEvent extends Event {
    public static const ENABLE_DISABLE:String = "enableDisableElement";
    public static const ENABLE:int = 0;
    public static const DISABLE:int = 1;
    public var methodType:int;
    public var elementId:String;

    public function EnableDisableEvent(type:int, elementId:String ) {
        super(ENABLE_DISABLE);
        this.elementId = elementId;
        this.methodType = type;
    }
}
}
