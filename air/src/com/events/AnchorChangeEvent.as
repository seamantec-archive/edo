/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 15/11/13
 * Time: 16:48
 * To change this template use File | Settings | File Templates.
 */
package com.events {
import flash.events.Event;

public class AnchorChangeEvent extends Event {

    public var max:Number;
    public var reset:Boolean;
    public var enable:Boolean;

    public function AnchorChangeEvent(max:Number, reset:Boolean, enable:Boolean) {
        super("anchorChange", true);
        this.max = max;
        this.reset = reset;
        this.enable = enable;
    }
}
}
