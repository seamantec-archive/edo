/**
 * Created by seamantec on 25/06/14.
 */
package com.ui.controls {
import com.utils.FontFactory;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;

public class BitmapButtonState extends Sprite {

    private var _stateBitmap:Bitmap;
    private var _options:BitmapButtonOptions;

    private var _width:Number;
    private var _height:Number;

    private var _label:TextField;
    var icon:Bitmap

    public function BitmapButtonState(stateBitmap:Bitmap, options:BitmapButtonOptions) {
        _stateBitmap = stateBitmap;
        _options = options;

        _width = _stateBitmap.width;
        _height = _stateBitmap.height;

        draw();
    }

    private function draw():void {
        this.addChild(_stateBitmap);

        _label = FontFactory.getCustomFont({
            align: _options.align,
            color: _options.color,
            size: _options.fontSize,
            bold: _options.bold,
            autoSize: (_options.align!="center" || _options.align!="none" || _options.align!="left" || _options.align!="right") ? "center" : _options.align
        });
        _label.x = _options.margin;
        _label.width = _width;
        _label.text = _options.text;
        _label.y = (_height - _label.height) / 2;
        this.addChild(_label);

        if (_options.icon != null) {
            icon = new _options.icon();
            icon.x = (_width / 2) - (icon.width / 2);
            icon.y = (_height / 2) - (icon.height / 2);
            this.addChild(icon)
        }
    }

    public function dealloc():void {
        _stateBitmap.bitmapData.dispose();
        _stateBitmap = null;
        _label = null;
        icon = null;
        this.removeChildren(0, this.numChildren - 1);
    }


    public function get label():String {
        return _options.text;
    }

    public function set label(value:String):void {
        _options.text = value;
        _label.text = value;
        _label.y = (_height - _label.height) / 2;

    }

    public function get stateBitmap():Bitmap {
        return _stateBitmap;
    }

    public function get options():BitmapButtonOptions {
        return _options;
    }

    public function set stateBitmap(value:Bitmap):void {
        _stateBitmap = value;
    }

    public function set options(value:BitmapButtonOptions):void {
        _options = value;
    }

    public function set color(color:uint):void {
        var format:TextFormat = _label.getTextFormat();
        format.color = color;
        _label.setTextFormat(format);
    }

    override public function get width():Number {
        return _width;
    }

    override public function get height():Number {
        return _height;
    }
}
}
