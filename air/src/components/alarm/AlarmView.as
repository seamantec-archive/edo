/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.27.
 * Time: 15:15
 * To change this template use File | Settings | File Templates.
 */
package components.alarm {
import com.alarm.AisAlarm;
import com.alarm.Alarm;
import com.alarm.AlarmHandler;
import com.alarm.AnchorAlarm;
import com.alarm.LimitAlarm;
import com.alarm.ShiftAlarm;
import com.alarm.SystemAlarm;
import com.alarm.Threshold;
import com.events.UnitChangedEvent;
import com.sailing.units.SmallDistance;
import com.ui.controls.AlarmListSmallBtn;
import com.ui.controls.AlarmSlider;
import com.ui.controls.BitmapButton;
import com.utils.FontFactory;

import components.AlarmToggleButtonBar;
import components.list.StaticListItem;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;
import flash.text.TextField;
import flash.utils.Timer;

public class AlarmView extends StaticListItem {

    [Embed(source="../../../assets/images/alarmlist/list_element.png")]
    private static var elementBg:Class;
    [Embed(source="../../../assets/images/alarmlist/voice_off.png")]
    private static var voiceOff:Class;
    [Embed(source="../../../assets/images/alarmlist/voice_on.png")]
    private static var voiceOn:Class;
    [Embed(source="../../../assets/images/alarmlist/alarm_off.png")]
    private static var alarmOff:Class;
    [Embed(source="../../../assets/images/alarmlist/alarm_on.png")]
    private static var alarmOn:Class;
    [Embed(source="../../../assets/images/alarmlist/reset_1.png")]
    private static var reset_1:Class;
    [Embed(source="../../../assets/images/alarmlist/reset_2.png")]
    private static var reset_2:Class;


//    [Embed(source="../../../assets/images/alarmlist/alarmlist_fade.png")]
//    private static var fade:Class;

    private static var blurFilter:BlurFilter = new BlurFilter(4, 4, BitmapFilterQuality.HIGH);
    public static const DEF_HEIGHT:int = 100;//60;
    private var _alarmUID:String;
    private var _enableDisableBtn:AlarmListSmallBtn;
    private var _resetBtn:BitmapButton;
    private var slider:AlarmSlider;
    private var sliderWidth:int = 240;
    private static const SLIDER_OFFSET:int = 90;
    private var _vAlertTimer:Timer;
    private var _alarmViewType:int

    private var bgBitamp:Bitmap;

    private var _alertBubble:AlertBadge
    private var _infoBubble:InfoBadge
    private var _labelUnitAlert:TextField;
//    private var _fadeBitmap:Bitmap;
    private var _thresholdLevelBtnBar:AlarmToggleButtonBar;

    public function AlarmView(alarmUID:String) {
        super(AlarmWindow.WIDTH, DEF_HEIGHT);
        this._alarmUID = alarmUID;
        _vAlertTimer = new Timer(500);
        _vAlertTimer.addEventListener(TimerEvent.TIMER, vAlertTimer_timerHandler, false, 0, true);

//        _fadeBitmap = new fade();
//        _fadeBitmap.alpha = 0.5;

        bgBitamp = new elementBg();
        bgBitamp.height = DEF_HEIGHT;
        bgBitamp.width = AlarmWindow.WIDTH
        addChild(bgBitamp);

        sliderWidth = bgBitamp.width - SLIDER_OFFSET
        _alarmViewType = (AlarmHandler.instance.alarms[_alarmUID] as Alarm).alarmType;

        addLabel(AlarmHandler.instance.alarms[alarmUID].textLabel, FontFactory.getAlarmTitleTextField(), 30, 3);

        createEnableDisableBtn();
        createThresholdLevelBtnBar()
        if (!(AlarmHandler.instance.alarms[_alarmUID] is SystemAlarm)) {
            createSlider();
            createAlertLabelText();
            createInfoLabelText();
            shiftLabelsToXPosition();
            addSlider();
        }
//        this.addChild(_fadeBitmap);
        enableDisableFade();

        AlarmHandler.instance.alarms[_alarmUID].addEventListener("actualValueChanged", actualValueChangedHandler, false, 0, true);
        AlarmHandler.instance.alarms[_alarmUID].addEventListener("infoLimitChangedBySibling", infoLimitChangedBySiblingHandler, false, 0, true);
        AlarmHandler.instance.alarms[_alarmUID].addEventListener("alertLimitChangedBySibling", alertLimitChangedBySiblingHandler, false, 0, true);
        AlarmHandler.instance.alarms[_alarmUID].addEventListener("startVisualAlert", startVisualAlertHandler, false, 0, true);
        AlarmHandler.instance.alarms[_alarmUID].addEventListener("stopVisualAlert", stopVisualAlertHandler, false, 0, true);
        AlarmHandler.instance.alarms[_alarmUID].addEventListener("alarmEnableChanged", alarmEnableChangedHandler, false, 0, true);
        AlarmHandler.instance.alarms[_alarmUID].addEventListener("isValidChanged", isValidChangedHandler, false, 0, true);
        AlarmHandler.instance.alarms[_alarmUID].addEventListener("labelChanged", labelChangedHandler, false, 0, true);
        AlarmHandler.instance.alarms[_alarmUID].addEventListener(UnitChangedEvent.CHANGE, unit_changed_eventHandler, false, 0, true);
        AlarmWindow.alarmList.addEventListener(Event.RESIZE, resizeHandler, false, 0, true);
        AlarmWindow.alarmList.addEventListener("startResize", startResizeHandler, false, 0, true);
        AlarmWindow.alarmList.addEventListener("stopResize", stopResizeHandler, false, 0, true);
    }


    private function createHeaderLabel():void {
        var text2:TextField = FontFactory.getAlarmTitleTextField();
        text2.text = AlarmHandler.instance.alarms[_alarmUID].textLabel;
        text2.y = 3;
        text2.x = 30;
        text2.width = 180;
        addChild(text2);
    }

    private function createAlertLabelText():void {
        if (_alertBubble == null) {
            _alertBubble = new AlertBadge();
            addChild(_alertBubble);
        }
        _labelUnitAlert = FontFactory.getAlarmTitleTextField();
        _labelUnitAlert.y = 3;
        setActualValueText();

        addChild(_labelUnitAlert);

        _alertBubble.setText((AlarmHandler.instance.alarms[_alarmUID] as Alarm).actualAlertLimit + "");
        _alertBubble.y = 24;
    }


    private function createInfoLabelText():void {
        if (_infoBubble == null) {
            _infoBubble = new InfoBadge();
            addChild(_infoBubble);
        }
        _infoBubble.setText((AlarmHandler.instance.alarms[_alarmUID] as Alarm).actualInfoLimit + "");
        _infoBubble.y = 24;

        if (((AlarmHandler.instance.alarms[_alarmUID] as Alarm) is AisAlarm)) {
            _infoBubble.visible = false;
        }
    }

    private function shiftLabelsToXPosition():void {
        setActualValueText();
        setAlertLabelPos();
        setInfoLabelPos();
    }


    private function createSlider():void {
        if ((AlarmHandler.instance.alarms[_alarmUID] is SystemAlarm)) {
            return;
        }
        var alarm:Alarm = (AlarmHandler.instance.alarms[_alarmUID] as Alarm);
        slider = new AlarmSlider(alarm.min, alarm.max, alarm.steps, sliderWidth, alarm.alarmType, alarm);
        slider.x = 60;
        slider.y = 44;
        slider.actualAlertLimit = alarm.actualAlertLimit
        slider.actualInfoLimit = alarm.actualInfoLimit
        slider.actualAlarmValue = alarm.actualValue;
        slider.addEventListener("actualAlarmValueChanged", slider_actualValueChangedHandler, false, 0, true);
        slider.addEventListener("actualInfoValueChanged", slider_actualInfoValueChangedHandler, false, 0, true);
        slider.addEventListener("knobMouseUp", slider_knobMouseUpHandler, false, 0, true);
        slider.addEventListener("knobInfoDown", slider_knobInfoDownHandler, false, 0, true);
        slider.addEventListener("knobAlertDown", slider_knobAlertDownHandler, false, 0, true);
    }

    private function addSlider():void {
        addChild(slider);
    }


    private function createEnableDisableBtn():void {
        _enableDisableBtn = new AlarmListSmallBtn(alarmOn, alarmOff);
        _enableDisableBtn.name = "enableDisableBtn"
        _enableDisableBtn.customEnabled = AlarmHandler.instance.alarms[_alarmUID].enabled
        _enableDisableBtn.x = 5;
        _enableDisableBtn.y = DEF_HEIGHT / 2 - _enableDisableBtn.height / 2;
        _enableDisableBtn.addEventListener(MouseEvent.CLICK, enableDisableBtn_clickHandler, false, 0, true);
        this.addChild(_enableDisableBtn);

        var alarm:Alarm = (AlarmHandler.instance.alarms[_alarmUID] as Alarm);
        if (alarm is AnchorAlarm || alarm is ShiftAlarm) {
            _resetBtn = new BitmapButton(reset_1, reset_2, reset_2, reset_2, reset_2);
            _resetBtn.x = 5;
            _resetBtn.y = DEF_HEIGHT / 2 - _enableDisableBtn.height / 2 - _resetBtn.height - 2;
            _resetBtn.addEventListener(MouseEvent.CLICK, resetBtn_clickHandler, false, 0, true);
            this.addChild(_resetBtn);
        }
    }

    private function createThresholdLevelBtnBar():void {
        var alarm:Alarm = (AlarmHandler.instance.alarms[_alarmUID] as Alarm);
        if (!(alarm is SystemAlarm)) {
            _thresholdLevelBtnBar = new AlarmToggleButtonBar(5, DEF_HEIGHT - 20, ["high", "low"]);
            _thresholdLevelBtnBar.addEventListener(MouseEvent.CLICK, thresholdLevelBtnBar_clickHandler, false, 0, true);
            switch (alarm.actualThresholdLevel) {
                case Threshold.LOW:
                    _thresholdLevelBtnBar.selectedIndex = 1;
                    break;
//                case Threshold.MEDIUM:
//                    _thresholdLevelBtnBar.selectedIndex = 1;
//                    break;
                case Threshold.HIGH:
                    _thresholdLevelBtnBar.selectedIndex = 0;
                    break;
            }
            this.addChild(_thresholdLevelBtnBar)
        }
    }

    private function enableDisableBtn_clickHandler(event:MouseEvent):void {
        _enableDisableBtn.customEnabled = !_enableDisableBtn.customEnabled;
        AlarmHandler.instance.alarms[_alarmUID].enabled = !AlarmHandler.instance.alarms[_alarmUID].enabled;

    }

    private function enableDisableAlarm():void {
        var alarm:Alarm = AlarmHandler.instance.alarms[_alarmUID];
        if (alarm.speechEnabled || alarm.alertEnabled) {
            alarm.enabled = true;
        } else {
            alarm.enabled = false;
        }
    }

    private function slider_actualValueChangedHandler(event:Event):void {
        (AlarmHandler.instance.alarms[_alarmUID] as Alarm).actualAlertLimit = slider.actualAlertLimit;
        setAlertTextValueAndX();
    }

    private function setAlertTextValueAndX():void {
        _alertBubble.setText((AlarmHandler.instance.alarms[_alarmUID] as Alarm).actualAlertLimit + "");
        setAlertLabelPos();
    }

    private function slider_actualInfoValueChangedHandler(event:Event):void {
        var alarm:Alarm = (AlarmHandler.instance.alarms[_alarmUID] as Alarm);
        alarm.actualInfoLimit = slider.actualInfoLimit;
        setInfoTextValueAndX();
    }

    private function setInfoTextValueAndX():void {
        _infoBubble.setText((AlarmHandler.instance.alarms[_alarmUID] as Alarm).actualInfoLimit + "");
        setInfoLabelPos()
    }

    private function actualValueChangedHandler(event:Event):void {
        var actualValue:Number = (AlarmHandler.instance.alarms[_alarmUID] as Alarm).actualValue;
        setActualValueText();
        slider.actualAlarmValue = actualValue;
    }


    private function infoLimitChangedBySiblingHandler(event:Event):void {
        slider.setActualInfoLimitWithoutChange((AlarmHandler.instance.alarms[_alarmUID] as Alarm).actualInfoLimit);
        _infoBubble.setText(slider.actualInfoLimit + "");
        setInfoLabelPos()

    }

    private function alertLimitChangedBySiblingHandler(event:Event):void {
        slider.setActualAlertLimitWithoutChange((AlarmHandler.instance.alarms[_alarmUID] as Alarm).actualAlertLimit);
        _alertBubble.setText(slider.actualAlertLimit + "");
        setAlertLabelPos();
    }

    private function setAlertLabelPos():void {
        if (_alertBubble == null) {
            return;
        }
        if (_alarmViewType === LimitAlarm.LOW) {
            _alertBubble.x = slider.getKnobAlarmX() + slider.x - _alertBubble.width;
        } else if (_alarmViewType === LimitAlarm.HIGH) {
            _alertBubble.x = slider.getKnobAlarmX() + slider.x;
        }
    }

    private function setInfoLabelPos():void {
        if (_infoBubble == null || ((AlarmHandler.instance.alarms[_alarmUID] as Alarm) is AisAlarm)) {
            return
        }
        if (_alarmViewType === LimitAlarm.LOW) {
            _infoBubble.x = slider.getKnobInfoX() + slider.x;
        } else if (_alarmViewType === LimitAlarm.HIGH) {
            _infoBubble.x = slider.getKnobInfoX() + slider.x - _alertBubble.width;
        }
    }


    private function resizeHandler(event:Event):void {
        setActualValueText()
    }

    var resizeCounter:int = 0;
    var sliderBitmap:Bitmap;

    private function startResizeHandler(event:Event):void {
        resizeCounter = 0;
        if (slider != null) {
            slider.startCustomResize();
        }
    }

    private function stopResizeHandler(event:Event):void {
        redrawSlider()
        setActualValueText()
    }

    public function redrawSlider():void {
        if (slider != null) {
            slider.stopCustomResize();
        }
    }


    public function externalResize(lWidth:int):void {
        bgBitamp.width = lWidth;
//        _fadeBitmap.x = 32;
//        _fadeBitmap.width = lWidth - _fadeBitmap.x;
//        _fadeBitmap.y = 23;
        sliderWidth = lWidth - SLIDER_OFFSET;  //- (lWidth/AlarmWindow.L_WIDTH)*SLIDER_OFFSET
        if (slider != null) {
            slider.resize(sliderWidth);
        }
        shiftLabelsToXPosition();
    }


    protected function unit_changed_eventHandler(event:UnitChangedEvent):void {
        var alarm:Alarm = (AlarmHandler.instance.alarms[_alarmUID] as Alarm);
        setActualValueText();
        trace(_labelUnitAlert.text)
        if (slider != null) {
            slider.setMinMax(alarm.min, alarm.max)
            slider.unitChanged();
            slider.actualAlarmValue = alarm.actualValue;
            setAlertTextValueAndX()
            setInfoTextValueAndX();
        }
    }

    private function setActualValueText():void {
        if (_labelUnitAlert != null) {
            var alarm = (AlarmHandler.instance.alarms[_alarmUID] as Alarm);
            var text:String = Math.round(alarm.actualValue * 10) / 10 + " ";

            //TODO dinamikus mertekegyseg valtasnal ez nem lesz jo
            if (alarm is AisAlarm && alarm.actualValue > 300) {
                text = "300+"
            }
            if (alarm.alarmUnitValue is SmallDistance) {
                text = Math.round((alarm.alarmUnitValue as SmallDistance).getDynamicValue() * 10) / 10 + " ";
            }
            _labelUnitAlert.text = ((alarm is ShiftAlarm) ? "+" : "") + text + getAlarmShortUnitString();
            _labelUnitAlert.x = bgBitamp.width - _labelUnitAlert.width - 5;
        }
    }

    private function getAlarmShortUnitString():String {
        var alarm:Alarm = (AlarmHandler.instance.alarms[_alarmUID] as Alarm)
        var alarmShortUnit:String = "";
        if (alarm.alarmUnitValue is SmallDistance) {
            alarmShortUnit = (alarm.alarmUnitValue as SmallDistance).getDynamicShortString();
        } else {
            alarmShortUnit = alarm.alarmUnitValue.getUnitShortString();
            if (alarmShortUnit === "") {
                alarmShortUnit = alarm.listenerKey.listenerParameter.getUnitShortString()
            }
        }
        return alarmShortUnit;
    }

    private function startTimer() {
        _vAlertTimer.start();
    }

    private function stopTimer() {
        _vAlertTimer.stop();
        _labelUnitAlert.textColor = 0x000000;
    }

    private function vAlertTimer_timerHandler(event:TimerEvent):void {
        if (_labelUnitAlert.textColor == 0) {
            _labelUnitAlert.textColor = 0xff0000;
        } else {
            _labelUnitAlert.textColor = 0x000000;
        }
    }

    private function startVisualAlertHandler(event:Event):void {
        startTimer();
    }

    private function stopVisualAlertHandler(event:Event):void {
        stopTimer();
    }

    private function alarmEnableChangedHandler(event:Event):void {
        enableDisableFade();
    }


    private function enableDisableFade():void {
//        _fadeBitmap.visible = !(AlarmHandler.instance.alarms[_alarmUID] as Alarm).enabled;
//        var filters = []
//        if (_fadeBitmap.visible) {
//            filters.push(blurFilter);
//        }
//        if (slider != null) {
//            slider.filters = filters;
//            _infoBubble.filters = filters;
//            _alertBubble.filters = filters;
//        }

    }

    private function isValidChangedHandler(event:Event):void {
        if ((AlarmHandler.instance.alarms[_alarmUID] as Alarm).isValid) {
            slider.showMarker();
        } else {
            slider.hideMarker();
            _labelUnitAlert.text = "---" + getAlarmShortUnitString();
            stopTimer();
        }
    }

    private function resetBtn_clickHandler(event:MouseEvent):void {
        (AlarmHandler.instance.alarms[_alarmUID] as Alarm).resetLockedValue();
    }

    private function slider_knobMouseUpHandler(event:Event):void {
        (AlarmHandler.instance.alarms[_alarmUID] as Alarm).sliderMovedIntoAlertOrInfo();
    }

    private function slider_knobInfoDownHandler(event:Event):void {
        (AlarmHandler.instance.alarms[_alarmUID] as Alarm).infoLimitChangeStarted()
    }

    private function slider_knobAlertDownHandler(event:Event):void {
        (AlarmHandler.instance.alarms[_alarmUID] as Alarm).alertLimitChangeStarted()
    }

    public function enabled():Boolean {
        return (AlarmHandler.instance.alarms[_alarmUID] as Alarm).enabled;
    }

    private function labelChangedHandler(event:Event):void {
        _labels[0].text = (AlarmHandler.instance.alarms[_alarmUID] as Alarm).tempTextLabel;
    }

    private function thresholdLevelBtnBar_clickHandler(event:MouseEvent):void {
        var alarm:Alarm = (AlarmHandler.instance.alarms[_alarmUID] as Alarm);
        var level:uint = 0;
        if (_thresholdLevelBtnBar.selectedIndex === 0) {
            level = Threshold.HIGH;
        } else if (_thresholdLevelBtnBar.selectedIndex === 1) {
            level = Threshold.LOW
        }
//        else {
//            level = Threshold.MEDIUM
//        }
        alarm.setActualThresholdLevelByIndex(level);
    }
}
}
