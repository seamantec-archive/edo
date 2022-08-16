/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.05.09.
 * Time: 16:46
 * To change this template use File | Settings | File Templates.
 */
package com.timeline {
import com.utils.FontFactory;

import flash.display.GraphicsPathCommand;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.text.TextField;

public class Ruller extends Sprite {
    private var _minValue:Number;
    private var _maxValue:Number;
    private var _hPixelResolution:Number;
    private var _distance:Number;
    private var _stepInPixel:Number
    private var _numberOfSteps:Number;
    private var _distanceInPixelCorrectionNumber:int = 1;
    private var _pixelResolution:Number; //how many pixel is one value change
    private var _initWidth:Number;
    private var _labelColor:uint = 0x000000; //0xffffff;
    private var _textLabelColor:uint = 0xffffff;
    private var firstTimeValue:Number;
    private var distFromFirtsTimeValue:Number;
    private var _textLabelsArray:Array = [];
    private var _textLabelsPointer = 0;
    private var _maxWidth:int = 0;
    //    private var timeFromFirstTimeValue:Number;

    public function Ruller(minValue:Number, maxValue:Number, height:int, width:int) {
        super();
        this._minValue = minValue;
        this._maxValue = maxValue;
        //this.height = height;

        this.graphics.beginFill(0xffffff, 0);
        this.graphics.drawRect(0,0, width,height);
        this.graphics.endFill();

        this.scrollRect = new Rectangle(0, 0, width, height);
        this._maxWidth = width;
//        this.width = width;

    }


    private var firstTimeX:int;
    private var stepInTime:Number;

    private function calculateInitValues():void {
        var minStepInPixel:int = 100;

        this._initWidth = _maxWidth;


        _minValue = _minValue / 1000; //don't care about ms
        _maxValue = _maxValue / 1000; //don't care about ms

        _distance = (_maxValue - _minValue);
        _pixelResolution = Math.round((_distance / _initWidth) * 1000) / 1000;
        _pixelResolution = _pixelResolution === 0 ? 1 : _pixelResolution;
        stepInTime = 60;
        if (_pixelResolution > 40) {
            stepInTime = 3600;
        }
        firstTimeValue = stepInTime - _minValue % stepInTime;
        firstTimeX = Math.round(firstTimeValue / _pixelResolution)


        _stepInPixel = stepInTime / _pixelResolution;
        if (_stepInPixel < minStepInPixel) {
            stepInTime = Math.round((minStepInPixel * _pixelResolution) / stepInTime) * stepInTime;
            _stepInPixel = Math.round(stepInTime / _pixelResolution);
        }


        _numberOfSteps = (_initWidth - firstTimeX) / _stepInPixel;
        _numberOfSteps = isNaN(_numberOfSteps) || _numberOfSteps === Infinity ? 0 : Math.round(_numberOfSteps)

    }


    public function reDraw(ratio:Number, sWidth:Number, minValue:Number = -1, maxValue:Number = -1):void {
        if (minValue != -1) {
            _minValue = minValue;
        }

        if (maxValue != -1) {
            _maxValue = maxValue;
        }
        _maxWidth = sWidth * ratio;
        calculateInitValues()
        this.x = 0;
        drawAxis();
    }

    private var needSec:Boolean;

    private function drawAxis():void {
        if (this._initWidth === 0 || _numberOfSteps === 0) {
            return;
        }

        _hPixelResolution = 100//this.width / distance ;
        var tickSizeInMSec:Number = _stepInPixel * _pixelResolution;
        needSec = false//tickSizeInMSec < 60000;
        graphics.clear();
        if (numChildren > 0) {
            this.removeChildren(0, numChildren - 1);
        }
        _textLabelsPointer = 0;
        graphics.lineStyle(1, _labelColor);//set the color
        var squareCommands:Vector.<int> = new Vector.<int>((_numberOfSteps + 2) * 3, true);
        var squareCoord:Vector.<Number> = new Vector.<Number>((_numberOfSteps + 2) * 6, true);


        var j:int = 0;
        var k:int = 0;
        var tickHeight:int = this.height / 6;
        var __ret:Object
        __ret = drawFirstTick(squareCommands, k, i, squareCoord, j, tickHeight)
        k = __ret.k;
        j = __ret.j;
        for (var i:int = 0; i < _numberOfSteps; i++) {
            __ret = drawSingleTick(squareCommands, k, i, squareCoord, j, tickHeight);
            k = __ret.k;
            j = __ret.j;
        }
        //  drawLastTick(squareCommands, k, i, squareCoord, j, tickHeight)
        graphics.drawPath(squareCommands, squareCoord);
    }

    private function drawFirstTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
        squareCommands[++k] = GraphicsPathCommand.MOVE_TO;
        k++;

        squareCoord[j] = 0  //x
        squareCoord[++j] = 0;  //y
        squareCoord[++j] = firstTimeX   //x
        squareCoord[++j] = 0  //y
        j++
        createLabelText(i, firstTimeX, tickHeight);

        return {k: k, j: j};
    }

    private function drawSingleTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        squareCommands[++k] = GraphicsPathCommand.MOVE_TO;
        k++;

        var aDist:Number = i * _stepInPixel + firstTimeX;
        squareCoord[j] = aDist  //x
        squareCoord[++j] = tickHeight;  //y
        squareCoord[++j] = aDist   //x
        squareCoord[++j] = 9  //0 //y
        squareCoord[++j] = aDist + _stepInPixel   //x
        squareCoord[++j] = 0 //0  //y
        j++
        createLabelText(i, aDist, tickHeight);
        return {k: k, j: j};

    }

    var myTextBox:TextField;

    private function createLabelText(i:int, aDist:Number, tickHeight:int):void {
        var date:Date = new Date((_minValue + firstTimeValue + i * stepInTime) * 1000);
        if (_textLabelsArray.length <= _textLabelsPointer) {
            _textLabelsArray.push(FontFactory.getLeftTextField());
        }
        myTextBox = _textLabelsArray[_textLabelsPointer];
        _textLabelsPointer++;
        myTextBox.text = formatTime(date)//formatTime(date)
        myTextBox.x = aDist - 15;
        myTextBox.y = tickHeight + 6;
        myTextBox.width = 46;
        myTextBox.height = 15;
        myTextBox.textColor = _textLabelColor;
        myTextBox.selectable = false;

        if (myTextBox.x > 15) {
            this.addChild(myTextBox)
        }

    }


    private function formatTime(date:Date):String {
        return ((date.getUTCHours() < 10 ? "0" + date.getUTCHours() : date.getUTCHours()) +
                ":" + ( date.getUTCMinutes() < 10 ? "0" + date.getUTCMinutes() : date.getUTCMinutes() + "") +
                (needSec ? (date.getUTCSeconds() < 10 ? ":0" + date.getUTCSeconds() : ":" + date.getUTCSeconds() + "" ) : ""));
    }

//    private function resizeHandler(event:Event):void {
//        reDraw();
//    }


    public function get distance():Number {
        return _distance;
    }

    var rect:Rectangle;

    public function moveToActualMin(x:Number):void {
        rect = this.scrollRect;
        rect.x = x;
        this.scrollRect = rect;

    }
}
}
