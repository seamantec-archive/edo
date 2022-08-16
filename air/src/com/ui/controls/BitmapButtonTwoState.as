/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 6/27/13
 * Time: 5:14 PM
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {

import flash.display.Bitmap;
import flash.display.Sprite;

public class BitmapButtonTwoState extends Sprite {

    private const OFF:int = 0;
    private const ON:int = 35;

    private var _state:Boolean = true;

    private var bg:Bitmap;
    private var tg:Bitmap;

    public function BitmapButtonTwoState(background:Class, toggle:Class)
    {
        super();
        bg = new background();
        tg = new toggle();

        initState();

        addChild(bg);
        addChild(tg);
    }

    public function switchBtn():void{
        _state = !_state;
        tg.x = (_state) ? ON : OFF;
    }

    private function initState(){
        tg.x = (_state) ? ON : OFF;
    }

    public function get state():Boolean {
        return _state;
    }

    public function set state(value:Boolean):void {
        _state = value;
        tg.x = (_state) ? ON : OFF;
    }
}
}
