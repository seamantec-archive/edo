/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.07.09.
 * Time: 17:18
 * To change this template use File | Settings | File Templates.
 */
package com.graphs {
import flash.events.Event;

public class GraphDataChangeEvent extends Event {
    public static const DATA_CHANGED:String = "graphDataChanged";
    public function GraphDataChangeEvent() {
        super(DATA_CHANGED);
    }
}
}
