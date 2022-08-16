/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.06.27.
 * Time: 14:34
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import com.utils.FontFactory;

import components.alarm.Badge;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

public class MenuElement extends Sprite {
    [Embed(source="../../../../assets/images/lic_key_ico.png")]
    private static var keyClass:Class;
    protected var clickFunction:Function;
    protected var _w:int;
    protected var _h:int;
    protected var _label:String;
    protected var _labelText:TextField;
    protected var _labelFormatter:TextFormat;
    protected var _enabled:Boolean = true;
    protected var _keyBitmap:Bitmap;
    protected var _iconBitmap:Bitmap;
    protected var _iconVisibility:Boolean = true;
    protected var _bdg:Badge;

    public function MenuElement(label:String, click:Function, w:int = -1, h:int = 22) {
        this.clickFunction = click;
        this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_DOWN, mouseOverHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_UP, clickHandler, false, 0, true);
        if (w == -1) {
            w = Menu.MENU_WIDTH
        }
        this._w = w;
        this._h = h;
        this._label = label;
        _labelText = FontFactory.getLeftTextField()
        _labelFormatter = _labelText.defaultTextFormat;
        _labelText.x = 2;
        _labelText.y = 2;
        _labelText.width = _w;
        _labelText.text = _label;
        addChild(_labelText);
        drawUpState();
    }

    public function changeBadgeLabel(str:String):void {
        _bdg.setText(str);
    }

    public function addBadge():void {
        _bdg = new Badge();
        _bdg.x = this.width - _bdg.width - 10;
        _bdg.y = 0;
        this.addChild(_bdg);
    }


    public function addIcon(icon:Class):void {
        if(_iconBitmap!=null && this.contains(_iconBitmap)) {
            this.removeChild(_iconBitmap);
        }
        _iconBitmap = new Bitmap((new icon as Bitmap).bitmapData);
        _iconBitmap.height = 14;
        _iconBitmap.width = 12;
        _iconBitmap.x = this.width - _iconBitmap.width - 3;
        _iconBitmap.y = (this.height - _iconBitmap.height) / 2;
        this.addChild(_iconBitmap);
    }

    public function addLicenseIcon():void {
        if(_iconBitmap!=null) {
            _iconBitmap.visible = false;
        }
        if(_keyBitmap!=null && this.contains(_keyBitmap)) {
            return;
        }
        _keyBitmap = new Bitmap((new keyClass as Bitmap).bitmapData);
        _keyBitmap.height = 14;
        _keyBitmap.width = 12;
        _keyBitmap.x = this.width - _keyBitmap.width - 3;
        _keyBitmap.y = (this.height - _keyBitmap.height) / 2;
        this.addChild(_keyBitmap);
    }

    public function removeLicenseIcon():void {
        if (_keyBitmap!=null && this.contains(_keyBitmap)) {
            this.removeChild(_keyBitmap);
        }
    }

    public function disableByLicense():void {
        this.enabled = false;
        addLicenseIcon();
    }

    public function enableByLicense():void {
        this.enabled = true;
        removeLicenseIcon();
        if(_iconBitmap!=null) {
            _iconBitmap.visible = _iconVisibility;
        }
    }

    public function showIcon():void {
        _iconBitmap.visible = true;
        _iconVisibility = true;
    }

    public function hideIcon():void {
        _iconBitmap.visible = false;
        _iconVisibility = false;
    }

    protected function drawUpState():void {
        this.graphics.clear();
        this.graphics.beginFill(0xc9c9c9);
        this.graphics.drawRect(0, 0, this._w, this._h);
        this.graphics.endFill();
        upStateLabel();
    }

    protected function drawDisabledState():void {
        this.graphics.clear();
        this.graphics.beginFill(0xc9c9c9);
        this.graphics.drawRect(0, 0, this._w, this._h);
        this.graphics.endFill();
        disabledStateLabel();
    }

    protected function drawDownState():void {
        this.graphics.clear();
        this.graphics.beginFill(0x023abd);
        this.graphics.drawRect(0, 0, this._w, this._h);
        this.graphics.endFill();
        downStateLabel();
    }

    protected function upStateLabel():void {
        _labelFormatter.color = 0x000000; //0xDEDEDE;
        _labelFormatter.size = 12;
        _labelFormatter.underline = false;
        _labelFormatter.italic = false;
        _labelFormatter.bold = true;
        _labelText.defaultTextFormat = _labelFormatter;
        _labelText.text = _label;

    }

    protected function downStateLabel():void {
        _labelFormatter.color = 0xffffff; //0xDEDEDE;
        _labelFormatter.size = 12;
        _labelFormatter.underline = false;
        _labelFormatter.italic = false;
        _labelFormatter.bold = true;
        _labelText.defaultTextFormat = _labelFormatter;
        _labelText.text = _label;

    }

    protected function disabledStateLabel():void {
        _labelFormatter.color = 0x999999; //0xDEDEDE;
        _labelFormatter.size = 12;
        _labelFormatter.underline = false;
        _labelFormatter.italic = false;
        _labelFormatter.bold = true;
        _labelText.defaultTextFormat = _labelFormatter;
        _labelText.text = _label;

    }

    protected function mouseOverHandler(event:MouseEvent):void {
        if (_enabled) {
            drawDownState();
        }
    }

    protected function mouseOutHandler(event:MouseEvent):void {
        if (_enabled) {
            drawUpState();
        }
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(value:Boolean):void {
        _enabled = value;
        if (_enabled) {
            drawUpState()
        } else {
            drawDisabledState();
        }
    }

    protected function clickHandler(event:MouseEvent):void {
        if (_enabled) {
            clickFunction(event);
        }
    }

    public function get label():String {
        return _label;
    }

    public function set label(value:String):void {
        _label = value;
        _labelText.text = _label;
    }

    public function get badge():Badge {
        return _bdg;
    }
}
}
