/**
 * Created by seamantec on 28/07/14.
 */
package components.digital {
import com.sailing.units.Unit;
import com.utils.FontFactory;

import components.list.StaticListItem;

import flash.desktop.NativeApplication;

import flash.events.MouseEvent;

public class DigitalDropdownListItem extends StaticListItem {

    private var _label:String;
    private var _key:String;
    private var _data:String;
    private var _value:Unit;
    private var _hasMinMax:Boolean;



    private var _w:Number;
    private var _h:Number;

    public function DigitalDropdownListItem(key:String, data:String, label:String, width:Number, hasMinMax:Boolean = true) {
        super(width,DigitalDropdownList.ITEM_HEIGHT, 0xc9c9c9, 1);

        _w = width;
        _h = height;

        addLabel(label, FontFactory.getCustomFont({ size: 42, bold: true, width: width, height: DigitalDropdownList.ITEM_HEIGHT }), 3);
        _label = label;
        _key = key;
        _data = data;
        _value = new Unit();
        _hasMinMax = hasMinMax;

        this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
    }

    public function get label():String {
        return _label;
    }

    public function get key():String {
        return _key;
    }

    public function get data():String {
        return _data;
    }

    public function get value():Unit {
        return _value;
    }

    public function set value(value:Unit):void {
        _value = value;
    }

    public function get hasMinMax():Boolean {
        return _hasMinMax;
    }

    protected function mouseOverHandler(event:MouseEvent):void {
        this.graphics.clear();
        this.graphics.beginFill(0x023abd);
        this.graphics.drawRect(0,0, _w,_h);
        this.graphics.endFill();
        _labels[0].textColor = 0xffffff;
    }

    protected function mouseOutHandler(event:MouseEvent):void {
        this.graphics.clear();
        this.graphics.beginFill(this.color);
        this.graphics.drawRect(0,0, _w,_h);
        this.graphics.endFill();
        _labels[0].textColor = 0x0;
    }
}
}
