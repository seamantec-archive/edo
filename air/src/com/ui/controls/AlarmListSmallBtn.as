/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.04.02.
 * Time: 21:38
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import flash.display.Bitmap;
import flash.display.Sprite;

public class AlarmListSmallBtn extends Sprite {
    protected var upStateBitmap:Bitmap;
    protected var downStateBitmap:Bitmap;


    private var _customEnabled:Boolean = true;
    protected var _id:String;


    public function AlarmListSmallBtn(upState:Class, overState:Class) {
        super();
        this.upStateBitmap = new upState();
        this.downStateBitmap = new overState();
        this.upStateBitmap.visible = false;
        this.downStateBitmap.visible = false;
        addChild(upStateBitmap)
        addChild(downStateBitmap)
        resetStates();
    }

    public function resetStates():void {
        if (_customEnabled) {
            upStateBitmap.visible = true;
            downStateBitmap.visible = false
        } else {
            upStateBitmap.visible = false;
            downStateBitmap.visible = true;
        }
        this.useHandCursor = true;
    }



    public function set customEnabled(value:Boolean):void {
        _customEnabled = value;
        resetStates();
    }

    public function get customEnabled():Boolean {
        return _customEnabled;
    }
}
}
