/**
 * Created by pepusz on 15. 02. 17..
 */
package com.harbor {
import flash.events.Event;

public class PolarFileEvent extends Event {
    public static const FILE_READY:String = "polar-file-ready"

    public function PolarFileEvent() {
        super(FILE_READY, false);
    }
}
}
