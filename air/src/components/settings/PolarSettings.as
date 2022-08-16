/**
 * Created by seamantec on 07/03/14.
 */
package components.settings {

import com.common.WindCorrection;
import com.polar.PolarContainer;
import com.polar.PolarTable;
import com.ui.controls.Slider;
import com.utils.FontFactory;

import components.list.DynamicListItem;
import components.list.List;

import flash.events.Event;
import flash.text.TextField;

public class PolarSettings extends DynamicListItem {

    [Embed(source="../../../assets/images/msglist/closedlist_element.png")]
    private static var closed:Class;

    private static var _tensionLabel:TextField;
    private static var _tensionSlider:Slider;



    public function PolarSettings(list:List) {
        super(SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT, list);

        this.graphics.beginBitmapFill(new closed().bitmapData);
        this.graphics.drawRect(0, 0, SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT);
        this.graphics.endFill();

        addLabel("Polar settings", FontFactory.nmeaMSGfont(), 2, 2);

        createContent();
    }

    private function createContent():void {
        addTension();
        _content.graphics.beginFill(0x3c3c3c);
        _content.graphics.drawRect(0, 0, this.width, this.height);
        _content.graphics.endFill();

        drawLine(_tensionLabel);
    }

    private function addTension():void {
        if (_tensionLabel == null) {
            _tensionLabel = FontFactory.getLeftTextField();
            _tensionLabel.text = "Tension";
            _tensionLabel.width = _tensionLabel.textWidth + 10;
            _tensionLabel.x = (this.width / 2) - (_tensionLabel.width / 2);
            _tensionLabel.y = 10;
        }
        addContentChild(_tensionLabel);

        if (_tensionSlider == null) {
            _tensionSlider = new Slider(0, 2, 0.01, 220, Slider._100, 0xeeeeee);
            _tensionSlider.x = (this.width / 2) - 110;
            _tensionSlider.y = 60;
            _tensionSlider.addEventListener("sliderDragStop", windSliderDragHandler, false, 0, true);
        }
        _tensionSlider.actualValue = PolarTable.tension;
        addContentChild(_tensionSlider);
    }


    private function windSliderDragHandler(event:Event):void {
        PolarContainer.instance.setTension(_tensionSlider.actualValue);

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
