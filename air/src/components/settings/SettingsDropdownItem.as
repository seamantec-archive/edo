/**
 * Created by seamantec on 25/02/14.
 */
package components.settings {
import com.utils.FontFactory;

import components.list.StaticListItem;

import flash.events.MouseEvent;

public class SettingsDropdownItem extends StaticListItem {

    private var _label:String;
    private var _data:Number;

    private var _w:Number;
    private var _h:Number;

    public function SettingsDropdownItem(label:String, data:Number, width:Number, height:Number, color:uint=0xFFFFFF, alpha:Number=0) {
        super(width,height, color, alpha);

        _w = width;
        _h = height;

        addLabel(label, FontFactory.getLeftBlackTextField(), 3);
        _label = label;
        _data = data;

        this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
    }

    public function get label():String {
        return _label;
    }

    public function get data():Number {
        return _data;
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
        this.graphics.beginFill(color);
        this.graphics.drawRect(0,0, _w,_h);
        this.graphics.endFill();
        _labels[0].textColor = 0x0;
    }
}
}
