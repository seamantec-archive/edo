/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.13.
 * Time: 14:41
 * To change this template use File | Settings | File Templates.
 */
package components.ais {
import com.sailing.ais.AisContainer;
import com.sailing.ais.events.ShipChangeEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

public class AisMap extends Sprite implements IAisComponent {
//    var map:Map


    public function AisMap() {
        this.height = 300;
        this.width = 300;

        AisContainer.instance.addEventListener(ShipChangeEvent.SHIP_CHANGED_EVENT,  vessel_changedHandler, false, 0, true);
       // AisContainer.instance.addEventListener("all-ship-data-changed", all_ship_data_changedHandler);

//        map = new Map();
//        this.addChild(map)
    }

    private function vessel_changedHandler(event:ShipChangeEvent):void {
//        map.ourVesselChanged();
//        map.vesselChanged(event.vessel);
    }

    private function all_ship_data_changedHandler(event:Event):void {
//        map.ourVesselChanged();
//        for each (var object:Vessel in AisContainer.instance.container) {
//            map.vesselChanged(object);
//        }

    }

    public function getParentBounds():Rectangle{
          return parent.getBounds(this.stage);
      }

    public function isEnoughSpaceOnTheLeft():Boolean {
        return false;
    }

    public function isEnoughSpaceOnTheRight():Boolean {
        return false;
    }


    public function get originWidth():Number {
        return 0;
    }

    public function get originHeight():Number {
        return 0;
    }
}
}
