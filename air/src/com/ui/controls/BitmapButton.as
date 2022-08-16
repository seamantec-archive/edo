/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.05.
 * Time: 10:20
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import flash.display.Bitmap;
import flash.display.SimpleButton;

public class BitmapButton extends SimpleButton {
    protected var upStateBitmap:Bitmap;
    protected var overStateBitmap:Bitmap;
    protected var downStateBitmap:Bitmap;
    protected var hitTestStateBitmap:Bitmap;
    protected var disableState:Bitmap;
    protected var _customEnabled:Boolean = true;
    protected var _id:String;
    protected var initUpState:BitmapButtonState;
    protected var initOverState:BitmapButtonState;
    protected var initDownState:BitmapButtonState;
    protected var initHitTestState:BitmapButtonState;
    protected var initDisableState:BitmapButtonState;

    private var _options:BitmapButtonOptions;


    public function BitmapButton(upState:Class, overState:Class, downState:Class, hitTestState:Class, disableSate:Class, label:String = "", iconBitmap:Class = null, fontSize = 14, color:uint = 0xDEDEDE, textAlign:String = "center", margin:Number = 0, bold:Boolean = true, alphaDisabled:Boolean = false) {
        super();
        this.downStateBitmap = new downState();
        this.upStateBitmap = new upState();
        this.overStateBitmap = new overState();
        this.hitTestStateBitmap = new hitTestState();
        if(alphaDisabled) {
            this.disableState = new upState();
            this.disableState.alpha = 0.5;
        } else {
            this.disableState = new disableSate();
        }
        _options = new BitmapButtonOptions(label, fontSize, color, iconBitmap, textAlign, margin, bold);

        initStates();
        resetStates();
    }

    private function initStates():void {
        this.initUpState = new BitmapButtonState(this.upStateBitmap, _options);
        this.initOverState = new BitmapButtonState(this.overStateBitmap, _options);
        this.initDownState = new BitmapButtonState(this.downStateBitmap, _options);
        this.initHitTestState = new BitmapButtonState(this.hitTestStateBitmap, _options);
        this.initDisableState = new BitmapButtonState(this.disableState, _options);
    }

    public function resetStates():void {
        if (enabled) {
            this.upState = initUpState;
            this.overState = initOverState;
            this.downState = initDownState;
            this.hitTestState = initHitTestState;
        } else {
            this.upState = initDisableState;
            this.overState = initOverState;
            this.downState = initDownState;
            this.hitTestState = null;
        }
        this.useHandCursor = true;
    }

    public function deAlloc():void {
        this.initUpState.dealloc();
        this.initUpState = null;
        this.initOverState.dealloc();
        this.initOverState = null;
        this.initDownState.dealloc();
        this.initDownState = null;
        this.initHitTestState.dealloc();
        this.initHitTestState = null;
        this.initDisableState.dealloc();
        this.initDisableState = null;

        this.upState = null;
        this.overState = null;
        this.downState = null;
        this.hitTestState = null;
        _options = null;
    }


    public function get options():BitmapButtonOptions {
        return _options;
    }

    public function set options(value:BitmapButtonOptions):void {
        _options = value;
        initStates();
    }


    public function set customEnabled(value:Boolean):void {
        _customEnabled = value;
        resetStates();
    }

    public override function set enabled(value:Boolean):void {
        super.enabled = value;
        resetStates();
    }

    public function get id():String {
        return _id;
    }

    public function set id(value:String):void {
        _id = value;
    }

    public function get labelText():String {
        return _options.text;
    }

    public function set labelText(value:String):void {
        _options.text = value;
    }

    public function set label(value:String):void {
        this.initUpState.label = value;
        this.initOverState.label = value;
        this.initDownState.label = value;
        this.initHitTestState.label = value;
        this.initDisableState.label = value;
    }

    public function set color(color:uint):void {
        _options.color = color;
        this.initUpState.color = color;
        this.initOverState.color = color;
        this.initDownState.color = color;
        this.initHitTestState.color = color;
        this.initDisableState.color = color;
        //resetStates()
    }


    public function get buttonWidth():Number {
        return this.downStateBitmap.width;
    }

    public function get buttonHeight():Number {
        return this.downStateBitmap.height;
    }

}
}
