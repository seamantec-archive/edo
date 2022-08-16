/**
 * Created by seamantec on 25/02/14.
 */
package components.settings {

import com.ui.controls.BitmapButton;
import com.ui.controls.LongDropDownButton;
import com.ui.controls.ShortDropDownButton;

import components.list.List;

import flash.display.Sprite;
import flash.events.MouseEvent;

public class SettingsDropdown extends Sprite {

    public static const TYPE_SHORT:int = 0;
    public static const TYPE_LONG:int = 1;

    private const ITEM_HEIGHT:Number = 20;

    private var _type:int;
    private var _parent:UnitSettings;
    private var _button:BitmapButton;
    private var _list:List;

    public function SettingsDropdown(type:int, parent:UnitSettings, length:int, isDown:Boolean = true, color:uint = 0xc9c9c9, alpha:Number = 1)  {
        _type = type;
        _parent = parent;

        createButton();
        createList(length, color, alpha);
    }

    public function addElement(label:String, data:Number):void {
        var item:SettingsDropdownItem = new SettingsDropdownItem(label, data, _button.width, ITEM_HEIGHT, _list.color);
        item.addEventListener(MouseEvent.CLICK, selectHandler, false, 0, true);
        _list.addItem(item);
    }

    private function createButton():void {
        if(_type==TYPE_SHORT) {
            _button = new ShortDropDownButton(3);
        } else {
            _button = new LongDropDownButton(3);
        }
        _button.addEventListener(MouseEvent.CLICK, buttonHandler, false, 0, true);
        this.addChild(_button);
    }

    private function createList(length:int, color:uint, alpha:Number):void {
        _list = new List(0, _button.height, _button.width, length*ITEM_HEIGHT, color, alpha);
        _list.visible = false;
        this.addChild(_list);
    }

    private function buttonHandler(event:MouseEvent):void {
        if(!_list.visible) {
            if(_parent!=null) {
                _parent.hideLists();
                _parent.content.setChildIndex(this, _parent.content.numChildren-1);
            }
            _list.visible = true;
        } else {
            _list.visible = false;
        }
    }

    private function selectHandler(event:MouseEvent):void {
        var item:SettingsDropdownItem = event.currentTarget as SettingsDropdownItem;
        dispatchEvent(new SettingsDropdownEvent(item.data));
        _list.visible = false;
//        _button.label = item.label;
    }

    public function set label(label:String):void {
        _button.label = label;
    }

    public function set color(color:uint):void {
        _button.color = color;
    }

    public function hideList():void {
        if(_parent!=null) {
            _parent.content.setChildIndex(this, 0);
        }
        _list.visible = false;
    }
}
}
