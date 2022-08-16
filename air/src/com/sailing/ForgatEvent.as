/**
 * Created by seamantec on 19/03/14.
 */
package com.sailing {
import com.sailing.instruments.BaseInstrument;

import flash.display.DisplayObject;
import flash.events.Event;

public class ForgatEvent extends Event {

    public static const FORGAT:String = "forgatHandler";
    public var mutato:DisplayObject;
    public var control:BaseInstrument;

    public function ForgatEvent(mutato:DisplayObject, control:BaseInstrument) {
        super(FORGAT);
        this.mutato = mutato;
        this.control = control;
    }
}
}
