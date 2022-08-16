/**
 * Created by seamantec on 25/03/14.
 */
package com.common {

import com.utils.EdoLocalStore;

import flash.filesystem.File;
import flash.utils.ByteArray;

public class WindCorrection {

    private static var _instance:WindCorrection;
    private var _windCorrection:Number = 0;

    public function WindCorrection() {
    }

    public static function get instance():WindCorrection {
        if(_instance==null) {
            _instance = new WindCorrection();
        }
        return _instance;
    }

    public function get windCorrection():Number {
        return _windCorrection;
    }

    public function set windCorrection(value:Number):void {
        _windCorrection = value;
        save();
    }

    public function load(storageDirectory:String = null):void {
        if(storageDirectory!=null) {
            EdoLocalStore.storageDirectory = new File(storageDirectory);
        }
        var data:ByteArray = EdoLocalStore.getItem("windCorrection");
        if(data!=null) {
            _windCorrection = data.readDouble();
        } else {
            _windCorrection = 0;
        }
    }

    public function save():void {
        var data:ByteArray = new ByteArray();
        data.writeDouble(_windCorrection);
        EdoLocalStore.setItem('windCorrection', data);
    }
}
}
