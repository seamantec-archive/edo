/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.26.
 * Time: 18:16
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.combinedDataHandlers {
import com.sailing.datas.BaseSailData;

public class CombinedData {
    private var _listenerKeys:Array = [];
    protected var lastDatas:Object = {};
    public var dataKey:String;
    public function dataChanged(key:String, data:BaseSailData, timestamp:Number):BaseSailData {
        lastDatas[key] = data;
        return calculate(timestamp, key);
    }

    //in this method we can calculate the sailData values and after that save it, and update instruments (just notify handlers)
    public function calculate(timestamp:Number, key:String):BaseSailData {
        throw new Error("need to override");
    }


    public function get listenerKeys():Array {
        return _listenerKeys;
    }

    public function reset():void{

    }
}
}
