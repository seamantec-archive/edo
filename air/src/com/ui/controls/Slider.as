/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.06.
 * Time: 12:52
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import com.utils.FontFactory;

import components.alarm.Badge;

import flash.display.Bitmap;
import flash.display.GraphicsPathCommand;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

[Event(name="actualValueChanged", type="flash.events.Event")]
public class Slider extends Sprite {
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
    private var _knob:Knob;
    private var _sliderType:int = 0;
    private var _globalPosition:Point;
    private var _pixelResolution:Number; //how many pixel is one value change
    private var _actualValue:Number;
    private var _roundTo:Number;
    private var _actualAlarmValue:Number;
    private var _actualAlarmMarker:Sprite;
    private var _limitArea:Sprite;
    private var _blackSlider:Bitmap;
    private var _redSlider:Bitmap;
    private var _blackSliderEnd:Bitmap;
    private var _redSliderEnd:Bitmap;
    private var _labelColor:uint;

    private var _enable:Boolean;

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
    //TODO create disable state
    private var actualLabel:Badge;

    private var _isDrag:Boolean = false;

    public function Slider(minValue:Number, maxValue:Number, stepInterval:Number, initWidth:int, sliderType:int, labelColor:uint = 0x000000) {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
//        this.addEventListener(MouseEvent.MOUSE_DOWN, triangle_mouseDownHandler, false, 0, true);
//        this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
        this._minValue = minValue;
        this._maxValue = maxValue;
        this._stepInterval = stepInterval;
        this._initWidth = initWidth
        this._sliderType = sliderType;
        _roundTo = stepInterval;
        _labelColor = labelColor;
        _enable = true;
        calculateInitValues()
        drawTicks();
        drawSliderBack();
        drawLimitArea();
        //drawActualAlarmMarker();
        drawKnob();
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
        _actualAlarmMarker.y = 0;
        addChild(_actualAlarmMarker);
    }

    public function switchSliderBg(to:String):void {
        if (to == "black") {
            _blackSlider.visible = true;
            _redSlider.visible = false;
            if (_sliderType === HIGH_LIMIT) {
                _blackSliderEnd.visible = true;
                _redSliderEnd.visible = false;
            }
        } else if (to == "red") {
            _blackSlider.visible = false;
            _redSlider.visible = true;
            if (_sliderType === HIGH_LIMIT) {
                _blackSliderEnd.visible = false;
                _redSliderEnd.visible = true;
            }
        }

    }

    private function drawLimitArea():void {
        if (_limitArea != null) {
            return;
        }
        _limitArea = new Sprite();
        var rect:Rectangle = new Rectangle(0, 0, 0, _defHeight)
        _blackSlider = new sliderBlack();
        _blackSlider.visible = true;
        _redSlider = new sliderRed();
        _redSlider.visible = false;
        createSliderRoundedEnd();
        _limitArea.addChild(_blackSlider);
        _limitArea.addChild(_redSlider);
        _limitArea.x = -_limitAreaOffset;
        _limitArea.y = (_defHeight - 10) / 2;
//        _limitArea.graphics.beginFill(0x000000)
//        _limitArea.graphics.drawRoundRect(0, (_defHeight-10)/2, this._initWidth, 10, 10)
//        _limitArea.graphics.endFill();
        _limitArea.scrollRect = rect;
        addChild(_limitArea)
    }

    private function createSliderRoundedEnd():void {
        if (_sliderType === HIGH_LIMIT) {
            _redSliderEnd = new sliderRedEnd();
            _blackSliderEnd = new sliderBlackEnd();
            _redSliderEnd.visible = false;
            _blackSliderEnd.visible = true;
            _redSliderEnd.x = _initWidth - 1;
            _redSliderEnd.y = (_defHeight - 10) / 2;
            _blackSliderEnd.x = _initWidth - 1;
            _blackSliderEnd.y = (_defHeight - 10) / 2;
            addChild(_redSliderEnd)
            addChild(_blackSliderEnd)
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
        if (_stepInterval != _roundTo) {
            _roundTo = _stepInterval;
            if (_roundTo < 1 && _distance > 1000) {
                _roundTo = 1;
            }
        }
    }

    private function addedToStageHandler(event:Event):void {
        _globalPosition = this.localToGlobal(new Point());
    }

    [Embed(source="../../../../assets/images/alarmlist/slider_knob.png")]
    private static var sliderKnob:Class;

    private function drawKnob():void {

        var knobBitmap:Bitmap = new sliderKnob();
        knobBitmap.x = -knobBitmap.width / 2;
        knobBitmap.y = -knobBitmap.height / 2;
        if (_knob == null) {
            _knob = new Knob();
            actualLabel = new Badge()

            addChild(actualLabel)
            addChild(_knob)
            _knob.addEventListener(MouseEvent.CLICK, triangle_clickHandler, false, 0, true);
            _knob.addEventListener(MouseEvent.MOUSE_DOWN, triangle_mouseDownHandler, false, 0, true);
        }

        _knob.addChild(knobBitmap);

        _knob.y = (knobBitmap.width / 2);
        actualLabel.y = _knob.y - actualLabel.height - 10;
        _knob.x = 0;

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
        tickRuler.graphics.lineStyle(1, _labelColor);//set the color
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
            myTextBox.textColor = _labelColor;//0x000000;
            tickRuler.addChild(myTextBox);
        }
    }


    private function triangle_clickHandler(event:MouseEvent):void {
//          if(_sliderType === LOW_LIMIT){
//              _sliderType = HIGH_LIMIT;
//              drawTriangle();
//          }else if(_sliderType === HIGH_LIMIT){
//              _sliderType = LOW_LIMIT;
//               drawTriangle();
//          }
    }

    private function triangle_mouseDownHandler(event:MouseEvent):void {
        if(_enable) {
            _isDrag = true;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
        }
    }

    private function stage_mouseUpHandler(event:MouseEvent):void {
//        _triangle.stopDrag();
        _isDrag = false;
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
        dispatchEvent(new Event("sliderDragStop"));
    }

    public function get isDrag():Boolean {
        return _isDrag;
    }

    private function stage_mouseMoveHandler(event:MouseEvent):void {
        moveKnob(mouseX);
    }

    private function moveKnob(stageX:Number):void {
        var newX:Number =stageX //stageX - _globalPosition.x;

        if (newX < 0) {
            newX = 0
        } else if (newX > _initWidth) {
            newX = _initWidth;
        }
//        if (_roundTo < 1) {
            actualValue = Math.round((newX * _pixelResolution + _minValue) / _roundTo) * _roundTo;
//        } else {
//            actualValue = Math.round((newX * _pixelResolution + _minValue) * _roundTo) / _roundTo;
//        }


    }

    private function calculateActualX():Number {
        return (actualValue - _minValue) / _pixelResolution;
    }

    private function setTriangleX(value:Number):void {
        _knob.x = value;
        actualLabel.x = value - actualLabel.width / 2;
        //var triangleHeight:int = _defHeight + 4
//        if (_sliderType === LOW_LIMIT) {
//            _knob.x = value - triangleHeight / 2;
//        } else if (_sliderType === HIGH_LIMIT) {
//            _knob.x = value;
//        }
    }

    private function clickHandler(event:MouseEvent):void {
        moveKnob(event.stageX);
    }


    public function get actualValue():Number {
        return _actualValue;
    }

    public function set actualValue(value:Number):void {
        _actualValue = Math.round(value * 100) / 100;
        var calcX:Number = calculateActualX();


        setTriangleX(calcX)
        var rect:Rectangle = _limitArea.scrollRect;
        if (_sliderType === LOW_LIMIT) {
            rect.x = 0;
            rect.width = calcX + _limitAreaOffset;

        } else if (_sliderType === HIGH_LIMIT) {
            _limitArea.x = calcX;
            rect.width = this._initWidth - calcX;
            rect.x = 0;
        }
        _limitArea.scrollRect = rect;
        actualLabel.setText(_actualValue.toString());
        dispatchEvent(new Event("actualValueChanged"))
    }

    public function set actualAlarmValue(value:Number):void {
        _actualAlarmValue = value;
        _actualAlarmMarker.x = (value - _minValue) / _pixelResolution;
    }

    public function set enable(value:Boolean):void {
        _knob.alpha = (value) ? 1 : 0.5;
        _enable = value;
    }
}

}
