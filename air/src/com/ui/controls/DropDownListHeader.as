/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/18/13
 * Time: 6:32 PM
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class DropDownListHeader extends Sprite {

    private var _labelText:TextField;
    private var format:TextFormat;

    public function DropDownListHeader(label:String, w:uint, h:uint, font:uint) {
        _labelText = new TextField();
        format = new TextFormat();

        format.color = 0xeac117;
        format.size = font;
        format.align = TextFormatAlign.CENTER;

        _labelText.defaultTextFormat = format;
        _labelText.background = true;
        _labelText.backgroundColor = 0x000000;
        _labelText.text = label;
        _labelText.width = w;
        _labelText.height = h;
        this.addChild(_labelText);
    }

    public function get labelText():TextField {
        return _labelText;
    }

    public function setLabelText(value:String) {
        _labelText.text = value;
    }
}
}
