/**
 * Created by seamantec on 07/03/14.
 */
package components.settings {

import com.common.WindCorrection;
import com.notification.NotificationHandler;
import com.notification.NotificationTypes;
import com.sailing.WindowsHandler;
import com.timeline.LogReplayAS;
import com.ui.TopBar;
import com.ui.controls.Slider;
import com.utils.FontFactory;
import components.list.DynamicListItem;
import components.list.List;
import flash.events.Event;
import flash.filesystem.File;
import flash.text.TextField;

public class WindCorrectionSettings extends DynamicListItem {

    [Embed(source="../../../assets/images/msglist/closedlist_element.png")]
    private static var closed:Class;

    private static var _windLabel:TextField;
    private static var _windSlider:Slider;

    private static var _position:Number;
    private static var _startPosition:Number;

    public function WindCorrectionSettings(list:List) {
        super(SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT, list);

        this.graphics.beginBitmapFill(new closed().bitmapData);
        this.graphics.drawRect(0, 0, SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT);
        this.graphics.endFill();

        addLabel("Wind correction", FontFactory.nmeaMSGfont(), 2,2);

        createContent();
    }

    private function createContent():void {
        addWind();
        _content.graphics.beginFill(0x3c3c3c);
        _content.graphics.drawRect(0,0, this.width,this.height);
        _content.graphics.endFill();

        drawLine(_windLabel);
    }

    private function addWind():void {
        if(_windLabel==null) {
            _windLabel = FontFactory.getLeftTextField();
            _windLabel.text = "True wind angle correction";
            _windLabel.width = _windLabel.textWidth + 10;
            _windLabel.x = (this.width/2) - (_windLabel.width/2);
            _windLabel.y = 10;
        }
        addContentChild(_windLabel);

        if(_windSlider==null) {
            _windSlider = new Slider(-45, 45, 1, 220, Slider._100, 0xeeeeee);
            _windSlider.x = (this.width/2) - 110;
            _windSlider.y = 60;
            _windSlider.addEventListener("actualValueChanged", windSliderHandler, false, 0, true);
            _windSlider.addEventListener("sliderDragStop", windSliderDragHandler, false, 0, true);
        }
        _windSlider.actualValue = WindCorrection.instance.windCorrection;
        _position = _windSlider.actualValue;
        _startPosition = _windSlider.actualValue;
        addContentChild(_windSlider);
    }

    private function windSliderHandler(event:Event):void {
        _position = (event.currentTarget as Slider).actualValue;
        if(WindowsHandler.instance.dataSource!="log") {
            WindCorrection.instance.windCorrection = _position;
        }
    }

    private function windSliderDragHandler(event:Event):void {
        //PolarContainer.instance.resetContainer();
        if(WindowsHandler.instance.dataSource=="log") {
            NotificationHandler.createAlert(NotificationTypes.WIND_CORRECTION_ALERT, NotificationTypes.WIND_CORRECTION_ALERT_TEXT, 0, changeCorrection, resetSlider);
        }
    }

    private function changeCorrection():void {
        WindCorrection.instance.windCorrection = _position;
        _startPosition = _windSlider.actualValue;
        TopBar.timeline.smallTimeline.reloadActualLog();
    }

    private function resetSlider():void {
        _windSlider.actualValue = _startPosition;
    }

    private function drawLine(field:TextField):void {
        _content.graphics.lineStyle(1, 0x767676);
        _content.graphics.moveTo(10, field.y + 8);
        _content.graphics.lineTo(field.x - 10, field.y + 8);
        _content.graphics.moveTo(field.x + field.width + 10, field.y + 8);
        _content.graphics.lineTo(this.width - 10, field.y + 8);
    }
}
}
