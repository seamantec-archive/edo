/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.06.07.
 * Time: 13:05
 * To change this template use File | Settings | File Templates.
 */
package com.events {
import flash.events.Event;

public class UnitChangedEvent extends Event {
    public static const CHANGE:String = "unit-changed-event"
    public var typeKlass:Class;
    public function UnitChangedEvent(typeKlass:Class) {
        super(CHANGE);
        this.typeKlass = typeKlass
    }
}
}
