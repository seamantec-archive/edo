/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.06.26.
 * Time: 11:29
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import com.common.AppProperties;
import com.layout.LayoutHandler;
import com.utils.FontFactory;

import components.InstrumentSelector;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

public class InstrumentsGroup extends Sprite {
    [Embed(source="../../../../assets/images/Layout pngs/add_bg.png")]
    private static var bgClass:Class;
    [Embed(source="../../../../assets/images/Layout pngs/add_less_btn01.png")]
    private static var addLess01Class:Class;
    [Embed(source="../../../../assets/images/Layout pngs/add_less_btn02.png")]
    private static var addLess02Class:Class;
    [Embed(source="../../../../assets/images/Layout pngs/add_more_btn01.png")]
    private static var addMore01Class:Class;
    [Embed(source="../../../../assets/images/Layout pngs/add_more_btn02.png")]
    private static var addMore02Class:Class;

    [Embed(source="../../../../assets/images/Layout pngs/switch_bg.png")]
    private static var _switchBgPNG:Class;
    [Embed(source='../../../../assets/images/Layout pngs/switch_knob.png')]
    private static var switchKnobPNG:Class;

    private static var bgBitmap:Bitmap = new bgClass();


    private static var _initWidth:int = AppProperties.appScreenWidth;
    private static var _initHeight:int = 103;
    private static const DIST_BETWEEN_ICONS:int = 32;
    private static const DIST_FROM_TOP:int = 5;
    private static const RIGHT_CONTROLS_WIDTH:int = 90;
    private static const STEP_BUTTONS_WIDTH:int = InstrumentSelector.BITMAP_HEIGHT + DIST_BETWEEN_ICONS;
    private const LEFT_OFFSET:int = 10;

    private var _stepLeft:BitmapButton;
    private var _stepRight:BitmapButton;
    private static var _bgSwBtn:BitmapButtonTwoState;

    private var _container:Vector.<InstrumentSelector>;
    private var _instruments:Sprite;

    private var _listWidth:int;
    private var _scrollWidth:Number;
    private var _instrumentsPerScroll:int;
    private var _from:int;
    private var _to:int;
    private var bgLabel:TextField

    public function InstrumentsGroup() {
        super();

        this.x = 0;
        initCalculation();
        _from = 0;
        _to = _instrumentsPerScroll - 1;
        drawBg();
        addStepButtons();
        addBgSwitchButton();

        _container = new Vector.<InstrumentSelector>();
        _instruments = new Sprite();
        _instruments.x = LEFT_OFFSET;
        _instruments.y = 0;
        addChild(_instruments);
    }

    private function initCalculation():void {
        _listWidth = _initWidth - RIGHT_CONTROLS_WIDTH - LEFT_OFFSET;
        _instrumentsPerScroll = Math.floor(_listWidth / STEP_BUTTONS_WIDTH);
        _scrollWidth = _instrumentsPerScroll * STEP_BUTTONS_WIDTH;
    }

    public function rePosition():void {
        _initWidth = AppProperties.appScreenWidth;
        initCalculation()
        _to = _instrumentsPerScroll - (_stepLeft.visible ? 3 : 2) + _from;
        setStepRightPosition();
        setBgSwitchPosition();
        refreshInstruments();
    }

    private function drawBg() {
        //this.graphics.clear();
        this.graphics.beginBitmapFill(bgBitmap.bitmapData);
        this.graphics.drawRect(0, 0, _initWidth, _initHeight);
        this.graphics.endFill();
    }

    public function addElement(instrument:InstrumentSelector):void {
        instrument.y = DIST_FROM_TOP;
        instrument.visible = false;
        _container.push(instrument);
        _instruments.addChild(instrument);
        if ((_container.length - _instrumentsPerScroll) == 1) {
            _to--;
            _stepRight.visible = true;
        }
        refreshInstruments();
    }

    private function refreshInstruments():void {
        var instrument:InstrumentSelector
        for (var i:int = 0; i < _container.length; i++) {
            instrument = _container[i];
            if (i < _from || i > _to) {
                instrument.visible = false;
            } else {
                instrument.visible = true;
                instrument.x = (i - _from) * STEP_BUTTONS_WIDTH;
                if (_stepLeft.visible) {
                    instrument.x += STEP_BUTTONS_WIDTH;
                }
            }
        }
    }

    private function addStepButtons():void {
        _stepLeft = new BitmapButton(addLess01Class, addLess02Class, addLess02Class, addLess02Class, addLess02Class);
        _stepLeft.x = LEFT_OFFSET + (InstrumentSelector.BITMAP_HEIGHT / 2) - (_stepLeft.width / 2);
        _stepLeft.y = (_initHeight / 2) - (_stepLeft.height / 2);
        _stepLeft.visible = false;
        _stepLeft.addEventListener(MouseEvent.CLICK, stepLeftHandler, false, 0, true);
        addChild(_stepLeft);
        _stepRight = new BitmapButton(addMore01Class, addMore02Class, addMore02Class, addMore02Class, addMore02Class);
        setStepRightPosition();
        _stepRight.y = (_initHeight / 2) - (_stepRight.height / 2);
        _stepRight.visible = false;
        _stepRight.addEventListener(MouseEvent.CLICK, stepRightHandler, false, 0, true);
        addChild(_stepRight);
    }

    private function setStepRightPosition():void {
        _stepRight.x = LEFT_OFFSET + _scrollWidth - STEP_BUTTONS_WIDTH + (InstrumentSelector.BITMAP_HEIGHT / 2) - (_stepRight.width / 2);
    }

    private function addBgSwitchButton():void {
        _bgSwBtn = new BitmapButtonTwoState(_switchBgPNG, switchKnobPNG);
        _bgSwBtn.y = 30;
        _bgSwBtn.addEventListener(MouseEvent.CLICK, onOffBgBtn_clickHandler, false, 0, true);
        addChild(_bgSwBtn);
        bgLabel = FontFactory.getCenter10BlackTextField()

        bgLabel.y = 63;
        bgLabel.width = 60;
        bgLabel.text = "Background";
        addChild(bgLabel);
        setBgSwitchPosition();

    }

    private function setBgSwitchPosition():void {
        _bgSwBtn.x = _initWidth - 80;
        bgLabel.x = _initWidth - 75;

    }

    private function onOffBgBtn_clickHandler(event:MouseEvent):void {
        _bgSwBtn.switchBtn();
        LayoutHandler.instance.changeFullScreen(event);
    }

    private function stepLeftHandler(event:MouseEvent):void {
        _stepRight.visible = true;
        _to = _from - 1;
        _from = _to - (_instrumentsPerScroll - 2);
        setLeftHandler();
        refreshInstruments();
    }

    private function setLeftHandler():void {
        if (_from > 0) {
            _from++;
        } else {
            _from = 0;
            _to = _instrumentsPerScroll - 2
            _stepLeft.visible = false;
        }
    }

    private function stepRightHandler(event:MouseEvent):void {
        _stepLeft.visible = true;
        _from = _to + 1;
        _to = _from + (_instrumentsPerScroll - 2);
        setRightHandler();
        refreshInstruments();
    }

    private function setRightHandler():void {
        if (_to < _container.length) {
            _to--;
        } else {
            _to = _container.length - 1;
            _stepRight.visible = false;
        }
    }

    public function setSwBtnState(value:Boolean):void {
        _bgSwBtn.state = value;
    }

    public static function get bgSwBtn():BitmapButtonTwoState {
        return _bgSwBtn;
    }

    public static function get width():int {
        return _initWidth;
    }

    public static function get height():int {
        return _initHeight;
    }
}
}
