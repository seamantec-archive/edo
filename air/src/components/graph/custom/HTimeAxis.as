/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.26.
 * Time: 15:51
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import com.utils.FontFactory;

import flash.display.GraphicsPathCommand;

public class HTimeAxis extends Axis {
    public static const MIN_STEP_IN_PIXEL:int = 100;
    protected var _hPixelResolution:Number;
    protected var _initWidth:int;
    protected var firstTimeValue:Number;
    protected var _lastTickWidth:int = 0;
    protected var firstTimeX:int;
    protected var stepInTime:Number;
    protected var distanceInTimeCalc:int;
    protected var calcStepInPixel:int;


//    protected var timeFromFirstTimeValue:Number;

    public function HTimeAxis(minValue:Number, maxValue:Number, graphInstance:GraphInstance) {
        super(minValue, maxValue, graphInstance);
//        this.height = GraphInstance.hAxisHeight;
        this.drawBg(100, GraphInstance.hAxisHeight)
    }


    protected function calculateInitValues():void {
        setInitWidth();
        _minValue = this._graphInstance.zoomHandler.minTime / 1000; //don't care about ms
        _maxValue = this._graphInstance.zoomHandler.maxTime / 1000; //don't care about ms

        _distance = (_maxValue - _minValue);

        _pixelResolution = Math.round((_distance / _initWidth) * 1000) / 1000;
        _pixelResolution = _pixelResolution === 0 ? 1 : _pixelResolution;
        stepInTime = 60;
        calcStepsInPixel();
        distanceInTimeCalc = (calcStepInPixel * _pixelResolution) / 60; //in min
        //pixel res example minStepInPixel = 100 and _pixelResolution = 4 than distance in time is 400 sec
        if (distanceInTimeCalc < 5) {
            stepInTime = 60;
        } else if (distanceInTimeCalc >= 5 && distanceInTimeCalc < 15) {
            stepInTime = 5 * 60;
        } else if (distanceInTimeCalc >= 15 && distanceInTimeCalc < 30) {
            stepInTime = 15 * 60;
        } else if (distanceInTimeCalc >= 30 && distanceInTimeCalc < 60) {
            stepInTime = 30 * 60;
        } else {
            stepInTime = 3600;
        }
        firstTimeValue = stepInTime - _minValue % stepInTime;
        firstTimeX = Math.round(firstTimeValue / _pixelResolution)


        _stepInPixel = stepInTime / _pixelResolution;
        if (_stepInPixel < calcStepInPixel) {
            stepInTime = Math.round((calcStepInPixel * _pixelResolution) / stepInTime) * stepInTime;
            _stepInPixel = Math.round(stepInTime / _pixelResolution);
        }


        _numberOfSteps = (_initWidth - firstTimeX) / _stepInPixel;
        _numberOfSteps = isNaN(_numberOfSteps) || _numberOfSteps === Infinity ? 0 : Math.round(_numberOfSteps)
        _lastTickWidth = _initWidth - _numberOfSteps * _stepInPixel - firstTimeX;

    }

    protected function calcStepsInPixel():void {
        var numberOfInitSteps:uint = 4
        if (_graphInstance.getScrollBoxWidth() / MIN_STEP_IN_PIXEL > numberOfInitSteps) {
            calcStepInPixel = _graphInstance.getScrollBoxWidth() / numberOfInitSteps;
        } else {
            calcStepInPixel = MIN_STEP_IN_PIXEL;
        }
    }

    protected function setInitWidth():void {
        this._initWidth = this._graphInstance.graph.possibleMaxWidth;
        _initWidth = _initWidth <= 0 ? this._graphInstance.initWidth : _initWidth;
    }


    public override function reDraw():void {
        this.visible = true;
        setTextVisiblesFalse()
        calculateInitValues()
        this.x = 0;
        this.y = _graphInstance.graphHeightWithoutControlls() - this.height;
//        this.width = _graphInstance.width - GraphInstance.vAxisWidth;
        drawAxis();
    }


    protected function drawAxis():void {
        if (this._initWidth === 0 && _numberOfSteps === 0) {
            return;
        }

        _hPixelResolution = 100//this.width / distance ;
        needSec = false//tickSizeInMSec < 60000;
        graphics.clear();
        _textLabelsPointer = 0;
        for (var tlpi:int = 0; tlpi < _textLabelsArray.length; tlpi++) {
            _textLabelsArray[tlpi].visible = false;

        }
        graphics.lineStyle(3, GraphColors.AXIS_COLOR);//set the color
        var squareCommands:Vector.<int> = new Vector.<int>();     //(_numberOfSteps + 2) * 3, true
        var squareCoord:Vector.<Number> = new Vector.<Number>();   //(_numberOfSteps + 2) * 6, true


        var j:int = 0;
        var k:int = 0;
        var tickHeight:int = 5;
        var __ret:Object
        drawFirstTick(squareCommands, k, i, squareCoord, j, tickHeight)
        graphics.drawPath(squareCommands, squareCoord);
        squareCommands.length = 0;
        squareCoord.length = 0;

        k = 0;
        j = 0;
        graphics.lineStyle(3, GraphColors.TICK_COLOR);//set the color

        for (var i:int = 0; i < _numberOfSteps; i++) {
            __ret = drawSingleTick(squareCommands, k, i, squareCoord, j, tickHeight);
            k = __ret.k;
            j = __ret.j;
        }
        drawLastTick(squareCommands, k, i, squareCoord, j, tickHeight);
        graphics.drawPath(squareCommands, squareCoord);

    }

    protected function drawFirstTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        k++;

        squareCoord[j] = 0  //x
        squareCoord[++j] = 0;  //y
        squareCoord[++j] = _initWidth   //x
        squareCoord[++j] = 0  //y
        j++
        createLabelText(i, firstTimeX, tickHeight);

        return {k: k, j: j};
    }

    var aDist:Number

    protected function drawSingleTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
//        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        k++;

        aDist = i * _stepInPixel + firstTimeX;
        squareCoord[j] = aDist  //x
        squareCoord[++j] = tickHeight;  //y
        squareCoord[++j] = aDist   //x
        squareCoord[++j] = 0  //y
//        squareCoord[++j] = aDist + _stepInPixel   //x
//        squareCoord[++j] = 0  //y
        j++
        createLabelText(i, aDist, tickHeight);
        return {k: k, j: j};

    }


    protected function createLabelText(i:int, aDist:Number, tickHeight:int):void {

        var date:Date = new Date((_minValue + firstTimeValue + i * stepInTime) * 1000);
        if (_textLabelsArray.length <= _textLabelsPointer) {
            _textLabelsArray.push(FontFactory.getTimeAxisFont());
        }
        myTextBox = _textLabelsArray[_textLabelsPointer];
        _textLabelsPointer++;
        myTextBox.width = 46;
        myTextBox.height = 18;
        myTextBox.text = formatTime(date)//formatTime(date)
        positionateLabelText(aDist, tickHeight);
        if (!this.contains(myTextBox)) {
            this.addChild(myTextBox)
        } else {
            myTextBox.visible = true;
        }

    }

    protected function positionateLabelText(aDist:Number, tickHeight:int):void {
        myTextBox.x = aDist - 18;
        myTextBox.y = tickHeight;
    }

    protected function drawLastTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):void {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
//        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;

        aDist = i * _stepInPixel + firstTimeX;
        squareCoord[j] = aDist  //x
        squareCoord[++j] = tickHeight;  //y
        squareCoord[++j] = aDist   //x
        squareCoord[++j] = 0  //y
//        squareCoord[++j] = aDist + _lastTickWidth   //x
//        squareCoord[++j] = 0  //y

        createLabelText(i, aDist, tickHeight);

    }





}
}
