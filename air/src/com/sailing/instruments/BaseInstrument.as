/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.06.05.
 * Time: 14:38
 * To change this template use File | Settings | File Templates.
 */
package com.sailing.instruments {

import com.sailing.SailData;

import flash.display.MovieClip;

import flash.utils.getQualifiedClassName;

public class BaseInstrument extends MovieClip {
    public var updateVars:Array = [];
    public var minMaxVars:Object = {};
    public function BaseInstrument() {
        super();
    }

    public function updateDatas(datas:SailData, needTween:Boolean = true):void {
        throw new Error("Must be override updateDatas " + getQualifiedClassName(this));
    }

    public function updateState(stateType:String):void {
        throw new Error("Must be override updateState " + getQualifiedClassName(this));
    }

    public function dataInvalidated(key:String):void{
        throw new Error("Must be override dataInvalidate " + getQualifiedClassName(this));
    }

    public function dataPreInvalidated(key:String):void{
        //throw new Error("Must be override dataInvalidate " + getQualifiedClassName(this));
    }

    public function unitChanged():void{
        //Get from unit handler the necessary elements
        throw new Error("Must be override dataInvalidate " + getQualifiedClassName(this));
    }
    public function minMaxChanged():void{
        throw new Error("Must be override minMaxChanged " + getQualifiedClassName(this))
    }

}
}
