/**
 * Created by seamantec on 23/04/14.
 */
package com.polar {
import flash.display.Sprite;

public class PolarLayerData {

    private var _ghost:Object;
    private var _auto:Object;

    public function PolarLayerData(ghost:Object, auto:Object) {
        _ghost = ghost;
        _auto = auto;
    }

    public function get ghostAsVector():Vector.<Number> {
        return (_ghost as Vector.<Number>);
    }

    public function get ghostAsSprite():Sprite {
        return (_ghost as Sprite);
    }

    public function get ghostAsNumber():Number {
        return (_ghost as Number);
    }

    public function get autoAsVector():Vector.<Number> {
        return (_auto as Vector.<Number>);
    }

    public function get autoAsSprite():Sprite {
        return (_auto as Sprite);
    }

    public function get autoAsNumber():Number {
        return (_auto as Number);
    }
}
}
