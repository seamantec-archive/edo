/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/18/13
 * Time: 10:48 AM
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class DropDownListElement extends Sprite{

    public var label:String;
    public var data:String;

    public var labelText:TextField;
    private var dataText:TextField;

    public var selected:Boolean = false;

    private var format:TextFormat;

    public function DropDownListElement(lbl:String,  dt:String, w:uint,h:uint,font:uint) {

        this.label = lbl;
        this.data  = dt;

        labelText = new TextField();
        dataText = new TextField();

        format = new TextFormat();

        format.color = 0xeac117;
        format.size = font;
        format.align = TextFormatAlign.CENTER;

        labelText.width = w;
        labelText.height = h;
        labelText.defaultTextFormat = format;
        labelText.text = label;
        labelText.background = true;
        labelText.backgroundColor = 0x000000;
        this.addChild(labelText);

        this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
    }

    private function mouseOverHandler(e:MouseEvent){
        if(!selected){
            labelText.backgroundColor = 0x624949;
        }
    }

    private function mouseOutHandler(e:MouseEvent){
        if(!selected){
            labelText.backgroundColor = 0x000000;
        }
    }
}
}
