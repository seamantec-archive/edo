/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.22.
 * Time: 16:05
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.minMax {
import com.sailing.instruments.BaseInstrument;

public class MinMax {
    public var min:Number = undefined;
    public var max:Number = undefined;
    public var reseted:Boolean = true;
    private var _instrument:BaseInstrument;
    private var _unitClass:Class;

    public function MinMax(min:Number = undefined, max:Number = undefined, instrument:BaseInstrument = null, unitClass:Class = null) {
        this.min = min;
        this.max = max;
        this._instrument = instrument;
        this._unitClass = unitClass;
    }

    public function setMinMaxLimit(value:Number):Boolean {
        var r:Boolean = false;
        if (isNaN(max) || value > max) {
            max = value;
            reseted = false;
            r = true;
        }
        if (isNaN(min) || value < min) {
            min = value;
            reseted = false;
            r = true;
        }
        if (_instrument != null) {
            _instrument.minMaxChanged();
        }
        return r;
    }

    public function reset(unitClass):void {
        if (unitClass == this._unitClass) {
            min = undefined;
            max = undefined;
            reseted = true;
            if (_instrument != null) {
                _instrument.minMaxChanged();
            }
        }
    }


    public function get unitClass():Class {
        return _unitClass;
    }

    public function set unitClass(value:Class):void {
        _unitClass = value;
    }
}

}
