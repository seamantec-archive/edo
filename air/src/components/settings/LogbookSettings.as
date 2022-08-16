/**
 * Created by seamantec on 21/02/14.
 */
package components.settings {
import com.events.AppClick;
import com.sailing.WindowsHandler;
import com.store.SettingsConfigs;
import com.ui.controls.LongDropDownButton;
import com.ui.controls.ShortDropDownButton;
import com.utils.FontFactory;

import components.list.DynamicListItem;
import components.list.List;

import flash.text.TextField;

public class LogbookSettings extends DynamicListItem {

    [Embed(source="../../../assets/images/msglist/closedlist_element.png")]
    private static var closed:Class;

    private static var _label:TextField;
    private static var _dropdown:SettingsDropdown;

    public function LogbookSettings(list:List) {
        super(SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT, list);

        this.graphics.beginBitmapFill(new closed().bitmapData);
        this.graphics.drawRect(0, 0, SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT);
        this.graphics.endFill();

        addLabel("Logbook", FontFactory.nmeaMSGfont(), 2,2);

        createContent();
        initTime();

        WindowsHandler.instance.application.addEventListener(AppClick.APP_CLICK, appClickHandler, false, 0, true);
        list.addEventListener(AppClick.APP_CLICK, appClickHandler, false, 0, true);
    }

    private function createContent():void {
        if(_label==null) {
            _label = FontFactory.getRightTextField();
            _label.x = this.width/2 - 10;
            _label.y = 10;
            _label.text = "Save log entry every";
        }
        addContentChild(_label);

        if(_dropdown==null) {
            _dropdown = new SettingsDropdown(SettingsDropdown.TYPE_SHORT, null, 7);
            _dropdown.x = this.width/2 + 10;
            _dropdown.y = 10;
            _dropdown.addElement("15 minutes", 15 * 60 * 1000);
            _dropdown.addElement("30 minutes", 30 * 60 * 1000);
            _dropdown.addElement("1 hour", 60 * 60 * 1000);
            _dropdown.addElement("3 hours", 3 * 60 * 60 * 1000);
            _dropdown.addElement("6 hours", 6 * 60 * 60 * 1000);
            _dropdown.addElement("12 hours", 12 * 60 * 60 * 1000);
            _dropdown.addElement("24 hours", 24 * 60 * 60 * 1000);
            _dropdown.addEventListener(SettingsDropdownEvent.SELECT, selectHandler, false, 0, true);
        }
        addContentChild(_dropdown);

        _content.graphics.beginFill(0x3c3c3c);
        _content.graphics.drawRect(0,0, this.width,this.height);
        _content.graphics.endFill();
    }

    private function selectHandler(event:SettingsDropdownEvent):void {
        SettingsConfigs.instance.logBookEventInterval = event.data;
        initTime();
    }

    private function initTime():void {
        switch(SettingsConfigs.instance.logBookEventInterval) {
            case 15 * 60 * 1000:
                _dropdown.label = "15 minutes";
                break;
            case 30 * 60 * 1000:
                _dropdown.label = "15 minutes";
                break;
            case 60 * 60 * 1000:
                _dropdown.label = "1 hour";
                break;
            case 3 * 60 * 60 * 1000:
                _dropdown.label = "3 hours";
                break;
            case 6 * 60 * 60 * 1000:
                _dropdown.label = "6 hours";
                break;
            case 12 * 60 * 60 * 1000:
                _dropdown.label = "12 hours";
                break;
            case 24 * 60 * 60 * 1000:
                _dropdown.label = "24 hours";
                break;
        }
    }

    public function hideLists():void {
        _dropdown.hideList();
    }

    private function appClickHandler(event:AppClick):void {
        if(!(event.prevTarget is ShortDropDownButton) && !(event.prevTarget is LongDropDownButton) && !(event.prevTarget is SettingsDropdownItem) && !(event.prevTarget.parent is SettingsDropdownItem)) {
            hideLists();
        }
        isParent(event.prevTarget);
    }

    private function isParent(target:Object):void {
        while(target.parent!=null) {
            if(target.parent is LogbookSettings) {
                (_list.getItem(1) as UnitSettings).hideLists();
                break;
            }
            if(target.parent is UnitSettings) {
                (_list.getItem(5) as LogbookSettings).hideLists();
                break;
            }
            target = target.parent;
        }
    }
}
}
