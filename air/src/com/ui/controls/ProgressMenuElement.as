/**
 * Created by seamantec on 28/05/14.
 */
package com.ui.controls {
import com.utils.FontFactory;

import flash.text.TextField;
import flash.text.TextFormat;

public class ProgressMenuElement extends MenuElement {

    private var _color:uint;
    private var _progress:Number;
    private var _coloredLabelFormatter:TextFormat;
    private var _coloredLabelText:TextField;
    private var _coloredLabel:String = "";

    public function ProgressMenuElement(label:String, click:Function, color:uint = 0x023abd, w:int = -1, h:int = 22) {
        super(label, click, w, h);

        _enabled = true;

        _color = color;

        _labelFormatter.color = 0x000000;
        _labelText.defaultTextFormat = _labelFormatter;

        _coloredLabelText = FontFactory.getLeftTextField()
        _coloredLabelFormatter = _labelText.defaultTextFormat;
        _coloredLabelFormatter.color = 0xffffff;
        _coloredLabelFormatter.size = 12;
        _coloredLabelFormatter.underline = false;
        _coloredLabelFormatter.italic = false;
        _coloredLabelFormatter.bold = true;
        _coloredLabelText.defaultTextFormat = _coloredLabelFormatter;
        _coloredLabelText.x = 2;
        _coloredLabelText.y = 2;
        _coloredLabelText.width = 0;
        _coloredLabelText.text = _coloredLabel;
        addChild(_coloredLabelText);
    }

    // progress: 0-100
    public function setProgress(progress:Number):void {
        _enabled = false;
        _progress = this._w * (progress / 100);
        this.graphics.clear();
        this.graphics.beginFill(0x89c8e6);
        this.graphics.drawRect(0, 0, _progress, this._h);
        this.graphics.beginFill(0xc9c9c9);
        this.graphics.drawRect(_progress, 0, this._w - _progress, this._h);
        this.graphics.endFill();
//        setLabelColor();

    }

    public function progressOff():void {
        _enabled = true;
        this.graphics.clear();
        this.graphics.beginFill(0xc9c9c9);
        this.graphics.drawRect(0, 0, this._w, this._h);
        this.graphics.endFill();

        initLabel();
    }

    private function setLabelColor():void {
        if (_progress == 0) {
            initLabel();
        } else if (_progress >= (_coloredLabelText.x + _coloredLabelText.width)) {
            if (_labelText.text.length > 0) {
                _coloredLabel += _label.charAt(_coloredLabel.length);
                _labelText.text = _label.substring(_coloredLabel.length, _label.length);

                _coloredLabelText.text = _coloredLabel;

                _labelText.x = _coloredLabelText.x + _coloredLabelText.textWidth;
            }
        }
    }

    private function initLabel():void {
        _coloredLabel = "";
        _coloredLabelText.text = _coloredLabel;

        _labelText.text = _label;
        _labelText.x = _coloredLabelText.x;
    }
}
}
