/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/18/13
 * Time: 2:34 PM
 * To change this template use File | Settings | File Templates.
 */
package com.events {
import flash.events.Event;

public class ListElementSelectedEvent extends Event{

    public static const SELECT:String = "LIST_ELEMENT_SELECTED";
    public var index;
    public var data;
    public function ListElementSelectedEvent(index:int, data:String) {
        super(SELECT);
        this.index = index;
        this.data = data;
    }
}
}