/**
 * Created by seamantec on 07/03/14.
 */
package components.settings {
import com.common.LLNAngle;
import com.common.SpeedToUse;
import com.graphs.GraphHandler;
import com.polar.PolarContainer;
import com.ui.controls.BitmapButtonOptions;
import com.ui.controls.Slider;
import com.utils.FontFactory;

import components.RadioButton;

import components.RadioButtonBar;
import components.list.DynamicListItem;
import components.list.List;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class PerformanceSettings extends DynamicListItem {

    [Embed(source="../../../assets/images/msglist/closedlist_element.png")]
    private static var closed:Class;

    private static var _llnLabel:TextField;
    private static var _llnType:RadioButtonBar;
    private static var _llnUpSlider:Slider;
    private static var _llnUpLabel:TextField;
    private static var _llnDownSlider:Slider;
    private static var _llnDownLabel:TextField;

    private static var _speedLabel:TextField;
    private static var _speedType:RadioButtonBar;

    public function PerformanceSettings(list:List) {
        super(SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT, list);

        this.graphics.beginBitmapFill(new closed().bitmapData);
        this.graphics.drawRect(0,0, SettingsWindow.WIDTH,SettingsWindow.ITEM_HEIGHT);
        this.graphics.endFill();

        addLabel("Sailing performance", FontFactory.nmeaMSGfont(), 2,2);

        createContent();

        enableLLN();

        LLNAngle.instance.addEventListener("llnUpAngleChange", llnUpAngleChangeHandler, false, 0, true);
        LLNAngle.instance.addEventListener("llnDownAngleChange", llnDownAngleChangeHandler, false, 0, true);
        LLNAngle.instance.addEventListener("llnTypeChange", llnTypeChangeHandler, false, 0, true);
    }

    private function createContent():void {
        addLLN();
        addSpeed();
        _content.graphics.beginFill(0x3c3c3c);
        _content.graphics.drawRect(0,0, this.width,this.height);
        _content.graphics.endFill();

        drawLine(_llnLabel);
        drawLine(_speedLabel);
    }

    private function addLLN():void {
        if(_llnLabel==null) {
            _llnLabel = FontFactory.getLeftTextField();
            _llnLabel.text = "Tacking angle markers (Laylines)";
            _llnLabel.width = _llnLabel.textWidth + 10;
            _llnLabel.x = (this.width/2) - (_llnLabel.width/2);
            _llnLabel.y = 10;
        }
        addContentChild(_llnLabel);

        if(_llnType==null) {
            _llnType = new RadioButtonBar(0,0, ["Manual", "Auto (using polar file)"], 12);
            _llnType.x = (this.width/2) - 125;
            _llnType.y = 40;
            _llnType.addEventListener(MouseEvent.CLICK, llnTypeHandler, false, 0, true);
            _llnType.selectedIndex = 0;

            var button:RadioButton = _llnType.getButton(1);
            var options:BitmapButtonOptions = button.options;
            options.margin = 35;
            options.align = "right";
            button.options = options;
        }
        addContentChild(_llnType);

        if(_llnUpLabel==null) {
            _llnUpLabel = FontFactory.getLeftTextField();
            _llnUpLabel.text = "Beat angle";
            _llnUpLabel.width = _llnLabel.textWidth + 10;
            _llnUpLabel.x = 10;
            _llnUpLabel.y = 80;
        }
        addContentChild(_llnUpLabel);

        if(_llnUpSlider==null) {
            _llnUpSlider = new Slider(LLNAngle.LLN_UP_MIN_LIMIT, LLNAngle.LLN_MAX_LIMIT, 1, 220, Slider._100, 0xeeeeee);
            _llnUpSlider.x = (this.width/2) - 110;
            _llnUpSlider.y = 120;
            _llnUpSlider.addEventListener("actualValueChanged", llnUpChangeHandler, false, 0, true);
        }
        _llnUpSlider.actualValue = LLNAngle.instance.llnUpAngle;
        _llnType.selectedIndex = (LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL) ? 0 : 1;
        _llnUpSlider.enable = (LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL);
        addContentChild(_llnUpSlider);

        if(_llnDownLabel==null) {
            _llnDownLabel = FontFactory.getLeftTextField();
            _llnDownLabel.text = "Run angle";
            _llnDownLabel.width = _llnDownLabel.textWidth + 10;
            _llnDownLabel.x = 10;
            _llnDownLabel.y = 180;
        }
        addContentChild(_llnDownLabel);

        if(_llnDownSlider==null) {
            _llnDownSlider = new Slider(LLNAngle.LLN_DOWN_MIN_LIMIT, LLNAngle.LLN_MAX_LIMIT, 1, 220, Slider._100, 0xeeeeee);
            _llnDownSlider.x = (this.width/2) - 110;
            _llnDownSlider.y = 220;
            _llnDownSlider.addEventListener("actualValueChanged", llnDownChangeHandler, false, 0, true);
        }
        _llnDownSlider.actualValue = LLNAngle.instance.llnDownAngle;
        _llnType.selectedIndex = (LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL) ? 0 : 1;
        _llnDownSlider.enable = (LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL);
        addContentChild(_llnDownSlider);
    }

    private function llnTypeHandler(event:MouseEvent):void {
        LLNAngle.instance.llnType = _llnType.selectedIndex;
        _llnUpSlider.enable = (LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL);
        _llnDownSlider.enable = (LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL);
    }

    private function llnUpChangeHandler(event:Event):void {
        if(_llnUpSlider.isDrag) {
            LLNAngle.instance.llnUpAngle = (event.currentTarget as Slider).actualValue;
        }
    }

    private function llnUpAngleChangeHandler(event:Event):void {
        if(!_llnUpSlider.isDrag) {
            _llnUpSlider.actualValue = LLNAngle.instance.llnUpAngle;
        }
    }

    private function llnDownChangeHandler(event:Event):void {
        if(_llnDownSlider.isDrag) {
            LLNAngle.instance.llnDownAngle = (event.currentTarget as Slider).actualValue;
        }
    }

    private function llnDownAngleChangeHandler(event:Event):void {
        if(!_llnDownSlider.isDrag) {
            _llnDownSlider.actualValue = LLNAngle.instance.llnDownAngle;
        }
    }

    private function llnTypeChangeHandler(event:Event):void {
        _llnType.selectedIndex = (LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL) ? 0 : 1;
        _llnUpSlider.enable = (LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL);
        _llnDownSlider.enable = (LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL);
    }

    private function addSpeed():void {
        if(_speedLabel==null) {
            _speedLabel = FontFactory.getLeftTextField();
            _speedLabel.text = "Vessel speed source for performance calculations";
            _speedLabel.width = _speedLabel.textWidth + 10;
            _speedLabel.x = (this.width/2) - (_speedLabel.width/2);
            _speedLabel.y = 270;
        }
        addContentChild(_speedLabel);

        if(_speedType==null) {
            _speedType = new RadioButtonBar(0,0, ["SOG", "STW"], 12);
            _speedType.x = (this.width/2) - 125;
            _speedType.y = 300;
            _speedType.addEventListener(MouseEvent.CLICK, speedTypeHandler, false, 0, true);

            var button:RadioButton = _speedType.getButton(0);
            var options:BitmapButtonOptions = button.options;
            options.margin = -15;
            button.options = options;

            button = _speedType.getButton(1);
            options = button.options;
            options.margin = -15;
            button.options = options;
        }
        _speedType.selectedIndex = SpeedToUse.instance.selected;
        addContentChild(_speedType);
    }

    private function speedTypeHandler(event:MouseEvent):void {
        SpeedToUse.instance.setSelectedAndContainer(_speedType.selectedIndex, GraphHandler.instance.containers);
        //PolarContainer.instance.resetContainer();
    }

    private function drawLine(field:TextField):void {
        _content.graphics.lineStyle(1, 0x767676);
        _content.graphics.moveTo(10, field.y + 8);
        _content.graphics.lineTo(field.x - 10, field.y + 8);
        _content.graphics.moveTo(field.x + field.width + 10, field.y + 8);
        _content.graphics.lineTo(this.width - 10, field.y + 8);
    }

    public function enableLLN():void {
        if(PolarContainer.instance.polarTableName.length>0) {
            _llnType.enabled = true;
            if(LLNAngle.instance.llnType==LLNAngle.LLN_MANUAL) {
                _llnType.selectedIndex = 0;
                _llnUpSlider.enable = true;
                _llnDownSlider.enable = true;
            } else {
                _llnType.selectedIndex = 1;
                _llnUpSlider.enable = false;
                _llnDownSlider.enable = false;
            }

        } else {
            _llnType.enabled = false;
            _llnUpSlider.enable = false;
            _llnDownSlider.enable = false;
        }
    }
}
}
