/**
 * Created by seamantec on 31/07/14.
 */
package components.settings {
import com.sailing.WindowsHandler;
import com.store.SettingsConfigs;
import com.ui.controls.AlarmListSmallBtn;
import com.utils.FontFactory;

import components.list.DynamicListItem;
import components.list.List;

import flash.events.MouseEvent;

public class GeneralSettings extends DynamicListItem {

    [Embed(source="../../../assets/images/msglist/closedlist_element.png")]
    private static var closed:Class;
    [Embed(source="../../../assets/images/alarmlist/alarm_off.png")]
    private static var alarmOff:Class;
    [Embed(source="../../../assets/images/alarmlist/alarm_on.png")]
    private static var alarmOn:Class;

    private static var _generalButton:AlarmListSmallBtn;
    private static var _generalLabel;

    public function GeneralSettings(list:List) {
        super(SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT, list);

        this.graphics.beginBitmapFill((new closed()).bitmapData);
        this.graphics.drawRect(0, 0, SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT);
        this.graphics.endFill();

        addLabel("General", FontFactory.nmeaMSGfont(), 2,2);

        createContent();
    }

    private function createContent():void {
        if(_generalButton==null) {
            _generalButton = new AlarmListSmallBtn(alarmOn, alarmOff);
            _generalButton.customEnabled = SettingsConfigs.instance.isEconomicMode;
            _generalButton.x = 10;
            _generalButton.y = 10;
            _generalButton.addEventListener(MouseEvent.CLICK, generalButtonHandler, false, 0, true);
        }
        addContentChild(_generalButton);

        if(_generalLabel==null) {
            _generalLabel = FontFactory.getCustomFont({size: 14, color: 0xFFFFFF});
            _generalLabel.text = "Economic mode";
            _generalLabel.x = 20 + _generalButton.width;
            _generalLabel.y = 13;
            _generalLabel.width = _generalLabel.textWidth + 10;
            _generalLabel.height = _generalButton.height;
        }
        addContentChild(_generalLabel);

        _content.graphics.beginFill(0x3c3c3c);
        _content.graphics.drawRect(0,0, this.width,this.height);
        _content.graphics.endFill();
    }

    private function generalButtonHandler(e:MouseEvent):void {
        SettingsConfigs.instance.isEconomicMode = !SettingsConfigs.instance.isEconomicMode;
        WindowsHandler.instance.application.setEconomicMode();
        _generalButton.customEnabled = SettingsConfigs.instance.isEconomicMode;
    }
}
}
