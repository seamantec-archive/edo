/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.06.
 * Time: 12:52
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import com.alarm.AisAlarm;
import com.alarm.Alarm;
import com.utils.FontFactory;

import flash.display.Bitmap;
import flash.display.GraphicsPathCommand;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.utils.Timer;

[Event(name="actualValueChanged", type="flash.events.Event")]
public class AlarmSlider extends Sprite {
    public static const LOW_LIMIT:int = 0;
    public static const HIGH_LIMIT:int = 1;
    public static const _0_1:int = 0;
    public static const _0_01:int = 1;
    public static const _1:int = 2;
    public static const _10:int = 3;
    public static const _100:int = 4;
    public static const _0_5:int = 5;


    private var _minValue:Number;
    private var _maxValue:Number;
    private var _stepInterval:Number;
    private var _initWidth:int;
    private var _defHeight:int = 18;
    private var tickRuler:Sprite;
    private var _distanceInPixel:Number;
    private var _distance:Number;
    private var _distanceInPixelCorrectionNumber:int = 1;
    private var _stepInPixel:int
    private var _numberOfSteps:Number;
    private var _knobAlarm:Knob;
    private var _knobInfo:Knob;
    private var _sliderType:int = 0;
    private var _globalPosition:Point;
    private var _pixelResolution:Number; //how many pixel is one value change
    private var _actualAlertLimit:Number;
    private var _roundTo:Number;
    private var _actualAlarmValue:Number;
    private var _actualInfoLimit:Number;
    private var _actualAlarmMarker:Sprite;
    private var _alarmLimitArea:Sprite;
    private var _infoLimitArea:Sprite;
    private var _blackSlider:Bitmap;
    private var _redSlider:Bitmap;
    private var _blackSliderEnd:Bitmap;
    private var _redSliderEnd:Bitmap;
    private var _blackSliderEndSprite:Sprite;
    private var _redSliderEndSprite:Sprite;
    private var _alertUUID:String;
    private var labelDensity:int = 4;
    private var _alarm:Alarm;
    private static var _markerBlinker:Timer = new Timer(500);
    private static var _markersToBlink:Vector.<Sprite> = new <Sprite>[];
    _markerBlinker.addEventListener(TimerEvent.TIMER, markerBlinker_timerHandler, false, 0, true);
    private static var _markerIsInBlink:Boolean = false;
    private static var _limitAreaOffset:int = 10;

    [Embed(source="../../../../assets/images/alarmlist/slider_bg.png")]
    private static var sliderBg:Class;
    [Embed(source="../../../../assets/images/alarmlist/slider_bl.png")]
    private static var sliderBlack:Class;
    [Embed(source="../../../../assets/images/alarmlist/slider_red.png")]
    private static var sliderRed:Class;
    [Embed(source="../../../../assets/images/alarmlist/slider_bl_end.png")]
    private static var sliderBlackEnd:Class;
    [Embed(source="../../../../assets/images/alarmlist/slider_red_end.png")]
    private static var sliderRedEnd:Class;
    [Embed(source="../../../../assets/images/alarmlist/marker_actual.png")]
    private static var actualMarker:Class;

    [Embed(source="../../../../assets/images/alarmlist/csusz_bal_fekete.png")]
    private static var sliderKnobLeftInfo:Class;
    [Embed(source="../../../../assets/images/alarmlist/csusz_bal_piros.png")]
    private static var sliderKnobLeftAlarm:Class;
    [Embed(source="../../../../assets/images/alarmlist/csusz_jobb_fekete.png")]
    private static var sliderKnobRightInfo:Class;
    [Embed(source="../../../../assets/images/alarmlist/csusz_jobb_piros.png")]
    private static var sliderKnobRightAlarm:Class;
    //TODO create disable state

    public function AlarmSlider(minValue:Number, maxValue:Number, stepInterval:Number, initWidth:int, sliderType:int, alarm:Alarm) {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);

        this._minValue = minValue;
        this._maxValue = maxValue;
        this._stepInterval = stepInterval;
        this._initWidth = initWidth
        this._sliderType = sliderType;
        this._alarm = alarm;

        calculateInitValues()
        drawTicks();
        drawSliderBack();
        drawLimitArea();
        drawActualAlarmMarker();
        drawKnobInfo();
        drawKnobAlarm();
    }

    private function drawActualAlarmMarker():void {
        if (_actualAlarmMarker != null) {
            return;
        }
        _actualAlarmMarker = new Sprite();
        var markerBitmap:Bitmap = new actualMarker();
        markerBitmap.y = -2;
        markerBitmap.x = -markerBitmap.width / 2;
        _actualAlarmMarker.addChild(markerBitmap);

        _actualAlarmMarker.x = 0;
        _actualAlarmMarker.y = 4;
        addChild(_actualAlarmMarker);
    }

    public function setMinMax(min:Number, max:Number):void {
        this._minValue = min;
        this._maxValue = max;
        resize(_initWidth);
        drawTicks()
    }

    private function drawLimitArea():void {
        drawInfoLimitArea()

        if (_alarmLimitArea == null) {
            _alarmLimitArea = new Sprite();
            var rect:Rectangle = new Rectangle(0, 0, 0, _defHeight)
            _alarmLimitArea.scrollRect = rect;
        }
        createSliderRoundedEnd(); //---
        if (_alarm is AisAlarm) {
            _alarmLimitArea.graphics.clear();
            _alarmLimitArea.graphics.beginFill(0x000000);
            _alarmLimitArea.graphics.drawRoundRectComplex(0, 0, _initWidth + _limitAreaOffset, _defHeight / 2, 10, 0, 10, 0)
            _alarmLimitArea.graphics.beginFill(0xff001a);
            _alarmLimitArea.graphics.drawRoundRectComplex(1, 3, _initWidth + _limitAreaOffset, _defHeight / 2-6, 10, 0, 10, 0);
        } else {
            _alarmLimitArea.graphics.clear();
            _alarmLimitArea.graphics.beginFill(0xff001a);
            _alarmLimitArea.graphics.drawRoundRectComplex(1, 3, _initWidth + _limitAreaOffset, _defHeight / 2 - 6, 10, 0, 10, 0)
            _alarmLimitArea.x = -_limitAreaOffset;
            _alarmLimitArea.y = (_defHeight - 10) / 2;


        }
        _alarmLimitArea.x = -_limitAreaOffset;
        _alarmLimitArea.y = (_defHeight - 10) / 2;
        addChild(_alarmLimitArea)
    }

    private function drawInfoLimitArea():void {
        if (_infoLimitArea == null) {
            _infoLimitArea = new Sprite();
            var rect:Rectangle = new Rectangle(0, 0, 0, _defHeight)
            _infoLimitArea.scrollRect = rect;
            if ((_alarm is AisAlarm)) {
                _infoLimitArea.visible = false;
            }
        }
        _infoLimitArea.graphics.clear();
        _infoLimitArea.graphics.beginFill(0x000000);
        _infoLimitArea.graphics.drawRoundRectComplex(0, 0, _initWidth + _limitAreaOffset + 1, _defHeight / 2, 10, 0, 10, 0)

        _infoLimitArea.x = -_limitAreaOffset;
        _infoLimitArea.y = (_defHeight - 10) / 2;
        addChild(_infoLimitArea);

    }

    private function createSliderRoundedEnd():void {
        if (_sliderType === HIGH_LIMIT) {
            if (_blackSliderEndSprite == null) {
                _blackSliderEndSprite = new Sprite();
                _blackSliderEndSprite.graphics.beginFill(0x000000);
                _blackSliderEndSprite.graphics.drawRoundRectComplex(0, 0, _limitAreaOffset + 2, _defHeight / 2, 0, 10, 0, 10);
                addChild(_blackSliderEndSprite);
            }
            if (_redSliderEndSprite == null) {
                _redSliderEndSprite = new Sprite();
                _redSliderEndSprite.graphics.beginFill(0xff001a);
                _redSliderEndSprite.graphics.drawRoundRectComplex(0, 3, _limitAreaOffset - 1, _defHeight / 2 - 6, 0, 10, 0, 10);
                _redSliderEndSprite.graphics.endFill();
                addChild(_redSliderEndSprite);
            }

            _blackSliderEndSprite.visible = true;
            _redSliderEndSprite.visible = true;
            positionSliderEnd();
        }
    }

    private function positionSliderEnd():void {
        if (_sliderType === HIGH_LIMIT) {
            _redSliderEndSprite.x = _initWidth - 1;
            _redSliderEndSprite.y = (_defHeight - 10) / 2;
            _blackSliderEndSprite.x = _initWidth - 1;
            _blackSliderEndSprite.y = (_defHeight - 10) / 2;
        }
    }

    private var _stepInValue:Number = 0;
    private var mPlier:int = 4;
    private var labelNumberOfSteps:int = 6;
    private var labelStepInPixel:int = 0
    private var labelStepInValue:Number = 0

    private function calculateInitValues():void {
        mPlier = 4;
        _distance = _maxValue - _minValue;
        _pixelResolution = _distance / _initWidth;
        while (_distance % labelNumberOfSteps != 0) {
            labelNumberOfSteps--;
        }
        _stepInValue = _distance / labelNumberOfSteps;
        labelStepInPixel = _initWidth / labelNumberOfSteps;
        labelStepInValue = _distance / labelNumberOfSteps;
        var oszto:int = 5;
        var _minStepInPixel = 60;
        while (oszto > 0 && labelStepInPixel / oszto < _minStepInPixel) {
            oszto--;
        }
        //inner small steps
        _numberOfSteps = oszto;
        _stepInPixel = labelStepInPixel / oszto;

        _roundTo = 1;
        if (_distance < 4) {
            _roundTo = 0.1;
        }
        if(_stepInterval != _roundTo){
            _roundTo = _stepInterval;
            if(_roundTo < 1 && _distance>1000){
                _roundTo = 1;
            }
        }

    }

    private function addedToStageHandler(event:Event):void {
        _globalPosition = this.localToGlobal(new Point());
    }

    private function reDrawKnobAlarm():void {
        try {
            removeChild(_knobAlarm);
        } catch (e:Error) {
            trace(e.message);
        }
        _knobAlarm = null;
        drawKnobAlarm();
    }

    private function reDrawKnobInfo():void {
        try {
            removeChild(_knobInfo);
        } catch (e:Error) {
            trace(e.message);
        }
        _knobInfo = null;
        drawKnobInfo();
    }

    private function drawKnobAlarm():void {
        this._sliderType === LOW_LIMIT ? drawKnobLeftAlarm() : drawKnobRightAlarm();
    }

    private function drawKnobLeftAlarm():void {
        var knobBitmap:Bitmap = new sliderKnobLeftAlarm();
        knobBitmap.x = -knobBitmap.width + 4;
        knobBitmap.y = 0;//-knobBitmap.height / 2;

        if (_knobAlarm == null) {
            _knobAlarm = new Knob();

            addChild(_knobAlarm)
            _knobAlarm.addEventListener(MouseEvent.MOUSE_DOWN, knobAlarm_mouseDownHandler, false, 0, true);
        }

        _knobAlarm.addChild(knobBitmap);

        _knobAlarm.x = 0;
        _knobAlarm.y = -1; //(knobBitmap.height / 2);

    }

    private function drawKnobRightAlarm():void {
        var knobBitmap:Bitmap = new sliderKnobRightAlarm();
        knobBitmap.x = -3; // -knobBitmap.width / 2;
        knobBitmap.y = 0; // -knobBitmap.height / 2;

        if (_knobAlarm == null) {
            _knobAlarm = new Knob();

            addChild(_knobAlarm)
            _knobAlarm.addEventListener(MouseEvent.MOUSE_DOWN, knobAlarm_mouseDownHandler, false, 0, true);
        }

        _knobAlarm.addChild(knobBitmap);

        _knobAlarm.x = 0;
        _knobAlarm.y = -1; //(knobBitmap.height / 2);

    }

    private function drawKnobInfo():void {
        this._sliderType === HIGH_LIMIT ? drawKnobLeftInfo() : drawKnobRightInfo();
    }

    private function drawKnobLeftInfo():void {

        var knobBitmap:Bitmap = new sliderKnobLeftInfo();
        knobBitmap.x = -knobBitmap.width + 4;
        knobBitmap.y = 0; //-knobBitmap.height / 2;

        if (_knobInfo == null) {
            _knobInfo = new Knob();
            if ((_alarm is AisAlarm)) {
                _knobInfo.visible = false;
            }
            addChild(_knobInfo)
            _knobInfo.addEventListener(MouseEvent.MOUSE_DOWN, knobInfo_mouseDownHandler, false, 0, true);
        }

        _knobInfo.addChild(knobBitmap);

        _knobInfo.x = 0;
        _knobInfo.y = -1; //(knobBitmap.height / 2);

    }

    private function drawKnobRightInfo():void {

        var knobBitmap:Bitmap = new sliderKnobRightInfo();
        knobBitmap.x = -3;//-knobBitmap.width / 2;
        knobBitmap.y = 0;//-knobBitmap.height / 2;

        if (_knobInfo == null) {
            _knobInfo = new Knob();
            if ((_alarm is AisAlarm)) {
                _knobInfo.visible = false;
            }
            addChild(_knobInfo)
            _knobInfo.addEventListener(MouseEvent.MOUSE_DOWN, knobInfo_mouseDownHandler, false, 0, true);
        }

        _knobInfo.addChild(knobBitmap);

        _knobInfo.x = 0;
        _knobInfo.y = -1;//(knobBitmap.height / 2);

    }

    private var sliderBgBitmap:Shape;

    private function drawSliderBack():void {
        sliderBgBitmap = new Shape();
        drawSliderBgBitmap();
        sliderBgBitmap.x = -10;
        sliderBgBitmap.y = (_defHeight - sliderBgBitmap.height) / 2;
        addChild(sliderBgBitmap);
    }

    private function drawSliderBgBitmap():void {
        sliderBgBitmap.graphics.clear();
        sliderBgBitmap.graphics.lineStyle(1, 0xf2f2f2);
        sliderBgBitmap.graphics.moveTo(0, 0);
        sliderBgBitmap.graphics.lineTo(_initWidth + 20, 0);
        sliderBgBitmap.graphics.endFill();
    }

    private function drawTicks():void {
        if (tickRuler == null) {
            tickRuler = new Sprite();
            tickRuler.x = 0;
            tickRuler.y = _defHeight
            addChild(tickRuler)
        }
        if (this._distance == 0) {
            return;
        }
        if (tickRuler.numChildren > 0) {
            tickRuler.removeChildren(0, tickRuler.numChildren - 1);
        }
        tickRuler.graphics.clear();
        tickRuler.graphics.lineStyle(1, 0x000000);//set the color
        var squareCommands:Vector.<int> = new Vector.<int>();
        var squareCoord:Vector.<Number> = new Vector.<Number>();

        var tickHeight:int = (_defHeight / 4);
        for (var i:int = 0; i < labelNumberOfSteps + 1; i++) {
            drawSingleBigTick(squareCommands, i, squareCoord, tickHeight);
            for (var j:int = 0; j < _numberOfSteps; j++) {
                drawSingleTick(squareCommands, i, j, squareCoord, tickHeight);
            }
        }
//        drawLastTick(squareCommands, k, i, squareCoord, j, tickHeight)
        tickRuler.graphics.drawPath(squareCommands, squareCoord);
        drawLabels(tickHeight);
    }

    private function drawSingleTick(squareCommands:Vector.<int>, i:int, j:int, squareCoord:Vector.<Number>, tickHeight:int):void {
        squareCommands.push(GraphicsPathCommand.MOVE_TO);
        squareCommands.push(GraphicsPathCommand.LINE_TO);
        squareCommands.push(GraphicsPathCommand.MOVE_TO);

        var aDist:Number = i * labelStepInPixel + j * _stepInPixel;
        squareCoord.push(aDist)  //x
        squareCoord.push(tickHeight);  //y
        squareCoord.push(aDist)   //x
        squareCoord.push(0)  //y
        squareCoord.push(aDist + _stepInPixel)   //x
        squareCoord.push(0)  //y
    }

    private function drawSingleBigTick(squareCommands:Vector.<int>, i:int, squareCoord:Vector.<Number>, tickHeight:int):void {
        squareCommands.push(GraphicsPathCommand.MOVE_TO);
        squareCommands.push(GraphicsPathCommand.LINE_TO);
        squareCommands.push(GraphicsPathCommand.MOVE_TO);

        var aDist:Number = i * labelStepInPixel;
        squareCoord.push(aDist)  //x
        squareCoord.push(tickHeight);  //y
        squareCoord.push(aDist)   //x
        squareCoord.push(0)  //y
        squareCoord.push(aDist + labelStepInPixel)   //x
        squareCoord.push(0)  //y

    }


    private function drawLabels(tickHeight:int):void {
        for (var i:int = 0; i < labelNumberOfSteps + 1; i++) {
            var myTextBox:TextField = FontFactory.getLeftTextField();
            myTextBox.text = Math.round(_minValue + labelStepInValue * i) + ""
            myTextBox.x = labelStepInPixel * i - myTextBox.width / 2;
            myTextBox.y = tickHeight - 2;
            myTextBox.selectable = false;
            myTextBox.textColor = 0x000000;
            tickRuler.addChild(myTextBox);
        }
    }

    private var alarmKnobClickX:int = 0;
    private var infoKnobClickX:int = 0;

    private function knobAlarm_mouseDownHandler(event:MouseEvent):void {
        alarmKnobClickX = event.localX;
        stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
        dispatchEvent(new Event("knobAlertDown"))
    }

    private function stage_mouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler)
        stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler)
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageInfo_mouseMoveHandler);
        dispatchEvent(new Event("knobMouseUp"))
    }

    private function stage_mouseMoveHandler(event:MouseEvent):void {
        moveKnobAlarmTo(event.stageX - alarmKnobClickX);
    }

    private function moveKnobAlarmTo(stageX:Number):void {
        var newX:Number = stageX - _globalPosition.x;

        if (newX < 0) {
            newX = 0
        } else if (newX > _initWidth) {
            newX = _initWidth;
        }
        if (_roundTo >= 1) {
            actualAlertLimit = Math.round((newX * _pixelResolution + _minValue) * _roundTo) / _roundTo;
        } else {
            actualAlertLimit = Math.round((newX * _pixelResolution + _minValue) / _roundTo) * _roundTo
        }


    }


    private function moveKnobInfoTo(stageX:Number):void {
        var newX:Number = stageX - _globalPosition.x;

        if (newX < 0) {
            newX = 0
        } else if (newX > _initWidth) {
            newX = _initWidth;
        }

        if (_roundTo >= 1) {
            actualInfoLimit = Math.round((newX * _pixelResolution + _minValue) * _roundTo) / _roundTo;
        } else {
            actualInfoLimit = Math.round((newX * _pixelResolution + _minValue) / _roundTo) * _roundTo;
        }

    }

    private function blockInfoKnobAtAlarmKnob(newX:Number):Number {
        //block info knob at alarm knob
        if ((_sliderType === LOW_LIMIT && newX <= _knobAlarm.x) || (_sliderType === HIGH_LIMIT && newX >= _knobAlarm.x)) {
            newX = _knobAlarm.x
        }
        return newX;
    }

    private function calculateActualAlarmX():Number {
        return (_actualAlertLimit - _minValue) / _pixelResolution;
    }

    private function calculateActualInfoX():Number {
        return (_actualInfoLimit - _minValue) / _pixelResolution;
    }

    private function setKnobAlarmX(value:Number):void {
        _knobAlarm.x = value;
    }

    private function clickHandler(event:MouseEvent):void {
        moveKnobAlarmTo(event.stageX);
    }


    public function get actualAlertLimit():Number {
        return _actualAlertLimit;
    }

    public function set actualAlertLimit(value:Number):void {
        _actualAlertLimit = value;
        setAlertLimitPosition();
        dispatchEvent(new Event("actualAlarmValueChanged"))

    }

    private function setAlertLimitPosition():void {
        var calcX:Number = calculateActualAlarmX();
        //alarmKnobPushInfoKnob(calcX);

        _knobAlarm.x = calcX
        var rect:Rectangle = _alarmLimitArea.scrollRect;
        if (_sliderType === LOW_LIMIT) {
            rect.x = 0;
            rect.width = calcX + _limitAreaOffset;

        } else if (_sliderType === HIGH_LIMIT) {
            _alarmLimitArea.x = calcX;
            rect.width = this._initWidth - calcX + 2;
            rect.x = 0;
        }
        _alarmLimitArea.scrollRect = rect;
    }


    public function get actualInfoLimit():Number {
        return _actualInfoLimit;
    }

    public function set actualInfoLimit(value:Number):void {
        _actualInfoLimit = _alarm.getPossibleInfoLimit(value);
        setInfoLimitPosition();
        dispatchEvent(new Event("actualInfoValueChanged"))
    }

    public function setActualInfoLimitWithoutChange(value:Number):void {
        _actualInfoLimit = value;
        setInfoLimitPosition();

    }

    public function setActualAlertLimitWithoutChange(value:Number):void {
        _actualAlertLimit = value;
        setAlertLimitPosition();
    }

    public function unitChanged():void {
        _actualInfoLimit = _alarm.actualInfoLimit;
        setInfoLimitPosition();
        _actualAlertLimit = _alarm.actualAlertLimit;
        setAlertLimitPosition();
    }

    private function setInfoLimitPosition():void {

        var calcX:Number = calculateActualInfoX();
        //calcX = blockInfoKnobAtAlarmKnob(calcX);
        _knobInfo.x = calcX;
        var rect:Rectangle = _infoLimitArea.scrollRect;
        if (_sliderType === LOW_LIMIT) {
            rect.x = 0;
            rect.width = calcX + _limitAreaOffset;

        } else if (_sliderType === HIGH_LIMIT) {
            _infoLimitArea.x = calcX;
            rect.width = this._initWidth - calcX;
            rect.x = 0;
        }
        _infoLimitArea.scrollRect = rect;

    }

    public function set actualAlarmValue(value:Number):void {
        _actualAlarmValue = value;
        setActualValuePositionX();
    }

    private function setActualValuePositionX():void {
        if (_actualAlarmValue > _maxValue) {
            _actualAlarmMarker.x = (_maxValue - _minValue) / _pixelResolution;
            startMarkerBlinking();
            return;
        }

        if (_actualAlarmValue < _minValue) {
            _actualAlarmMarker.x = 0;
            startMarkerBlinking();
            return;
        }
        stopMarkerBlinking();
        _actualAlarmMarker.x = (_actualAlarmValue - _minValue) / _pixelResolution;
    }

    private function stopMarkerBlinking():void {
        for (var i:int = 0; i < _markersToBlink.length; i++) {
            if (_markersToBlink[i] == _actualAlarmMarker) {
                _actualAlarmMarker.visible = true;
                _markersToBlink.splice(i, 1);
                break;
            }
        }
        if (_markersToBlink.length === 0) {
            _markerBlinker.stop();
            _markerIsInBlink = false;
        }
    }

    private function startMarkerBlinking():void {
        var needTopush:Boolean = true;
        for (var i:int = 0; i < _markersToBlink.length; i++) {
            if (_markersToBlink[i] == _actualAlarmMarker) {
                needTopush = false;
                break;
            }
        }
        if (needTopush) {
            _markersToBlink.push(_actualAlarmMarker);
        }
        if (!_markerBlinker.running) {
            _markerBlinker.start();
        }
    }

    private function knobInfo_mouseDownHandler(event:MouseEvent):void {
        infoKnobClickX = event.localX;
        stage.addEventListener(MouseEvent.MOUSE_MOVE, stageInfo_mouseMoveHandler, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
        dispatchEvent(new Event("knobInfoDown"))
    }

    private function stageInfo_mouseMoveHandler(event:MouseEvent):void {
        moveKnobInfoTo(event.stageX - infoKnobClickX);
    }


    public function get alertUUID():String {
        return _alertUUID;
    }

    public function set alertUUID(value:String):void {
        _alertUUID = value;
    }

    public function resize(newWidth:int):void {
        _initWidth = newWidth;
        calculateInitValues();
        //positionSliderEnd();
        drawSliderBgBitmap();
        drawLimitArea();
        reDrawKnobAlarm();
        reDrawKnobInfo();
        setInfoLimitPosition();
        setAlertLimitPosition();
        setActualValuePositionX();
        this.setChildIndex(_actualAlarmMarker, this.numChildren - 1 - 2);
    }

    public function startCustomResize():void {
        tickRuler.visible = false;
    }

    public function stopCustomResize():void {
        drawTicks()
        tickRuler.visible = true;

    }

    public function getKnobAlarmX():Number {
        return _knobAlarm.x;
    }

    public function getKnobInfoX():Number {
        return _knobInfo.x;
    }


    public function get roundTo():Number {
        return _roundTo;
    }

    public function hideMarker():void {
        _actualAlarmMarker.visible = false;
    }

    public function showMarker():void {
        _actualAlarmMarker.visible = true;
    }

    private static function markerBlinker_timerHandler(event:TimerEvent):void {
        for (var i:int = 0; i < _markersToBlink.length; i++) {
            _markersToBlink[i].visible = _markerIsInBlink;
        }
        _markerIsInBlink = !_markerIsInBlink;

    }
}

}
