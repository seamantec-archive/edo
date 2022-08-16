/**
 * Created by seamantec on 02/04/14.
 */
package com.common {
import com.polar.PolarContainer;
import com.utils.EdoLocalStore;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

public class SpeedToUse extends EventDispatcher {

    public static const SOG:int = 0;
    public static const STW:int = 1;

    private static var _instance:SpeedToUse;
    private var _selected:int = STW;
    private var _container:Object;

    public function SpeedToUse() {
        load();
    }

    public static function get instance():SpeedToUse {
        if (_instance == null) {
            _instance = new SpeedToUse();
        }
        return _instance;
    }

    public function get selected():int {
        return _selected;
    }

    public function setSelectedAndContainer(value:int, container:Object):void {
        _selected = value;
        _container = container;
        save();
//        PolarContainer.instance.loadDataFromGraphs(_container);
        this.dispatchEvent(new Event("speedToUseChange"));
    }

    public function set container(value:Object):void {
        _container = value;
    }

    public function save():void {
        var data:ByteArray = new ByteArray();
        data.writeInt(_selected);
        EdoLocalStore.setItem('speedToUse', data);
    }

    public function load():void {
        var data:ByteArray = EdoLocalStore.getItem("speedToUse");
        if (data != null) {
            _selected = data.readInt();
        } else {
            _selected = STW;
        }
    }
}
}
