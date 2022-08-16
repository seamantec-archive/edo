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

public class VDataAxis extends Axis {
    public static const MIN_STEP_INPIXEL:int = 40;
    protected var _initHeight:int;
    protected var _firstTickY:int = 0;
    protected var restFromMaxVal:Number = 0;
    protected var _stepInValue:Number;
    protected var _minStepPixel:Number;
    protected var _remainedPixels:uint = 0;


    public function VDataAxis(minValue:Number, maxValue:Number, graphInstance:GraphInstance) {
        super(minValue, maxValue, graphInstance);
        drawBg(GraphInstance.vAxisWidth, this._graphInstance.graphHeightWithoutControlls() - GraphInstance.hAxisHeight)
    }

    public override function drawBg(w:int, h:int):void {
        this.graphics.clear();
        this.graphics.beginFill(0x00ff00, 0)
        this.graphics.drawRect(0, 0, w, h)
        this.graphics.endFill();
    }


    protected function calculateInitValues():void {
        setInitHeight();
        _maxValue = this._graphInstance.minMax.max;
        _minValue = this._graphInstance.minMax.min;
        _distance = _maxValue - _minValue;
        if (_initHeight <= 0) {
            _initHeight = 1;
        }
        _pixelResolution = Math.round((_initHeight / _distance) * 1000) / 1000;
        if (_quantalStep <= 1) {
            _minStepPixel = MIN_STEP_INPIXEL
            _numberOfSteps = 4;
            if (_minValue >= 0) {
                while (Math.abs(_initHeight) < _minStepPixel) {
                    _minStepPixel /= 2
                }
            } else {
                _numberOfSteps = _numberOfSteps / 2;
                while (Math.abs(_initHeight) < _minStepPixel / 2) {
                    _minStepPixel /= 2
                }
            }
            _stepInValue = _maxValue / _numberOfSteps;


            var kerekit:Number = 5;
            if (kerekit > _stepInValue) {
                kerekit = 1;
                _stepInValue = 1;
            } else {
                while (kerekit * 2 < Math.abs(_stepInValue)) {
                    kerekit = kerekit * 2;
                }
            }
            _stepInValue = Math.floor(_stepInValue / kerekit) * kerekit;
            _stepInPixel = _stepInValue * _pixelResolution;
            while (_stepInPixel < _minStepPixel) {
                if (kerekit === 1) {
                    kerekit = 5;
                    _stepInValue = 5;
                } else {
                    _stepInValue *= 2;
                }
                _stepInPixel = _stepInValue * _pixelResolution;

            }

            var xy:int
            if (_minValue >= 0) {
                restFromMaxVal = _distance % _stepInValue;
                restFromMaxVal += (_maxValue - restFromMaxVal) % _stepInValue;
                xy = _distance - restFromMaxVal;
            } else {
                restFromMaxVal = _maxValue % _stepInValue;
                xy = _distance - restFromMaxVal * 2;
            }
            _numberOfSteps = xy / _stepInValue;
            _firstTickY = Math.round(restFromMaxVal * _pixelResolution);
        } else {
            restFromMaxVal = 0
            _stepInValue = _quantalStep;
            _numberOfSteps = _distance / _stepInValue;
            _stepInPixel = _stepInValue * _pixelResolution;
            while ((_stepInPixel < MIN_STEP_INPIXEL || _numberOfSteps % 1 != 0) && _stepInValue <= _distance) {
                _stepInValue += _quantalStep;
                _numberOfSteps = _distance / _stepInValue;
                _stepInPixel = _stepInValue * _pixelResolution;

            }
            if (_stepInValue > _maxValue) {
                _stepInValue = distance
                _numberOfSteps = 1;
                _stepInPixel = _stepInValue * _pixelResolution;
            }


            var oddments:int = _initHeight / _numberOfSteps - Math.round(_stepInPixel);
            _stepInPixel += oddments / _numberOfSteps;
            _numberOfSteps = Math.floor(_numberOfSteps);

            if (_stepInPixel * _numberOfSteps != _initHeight) {
                _stepInValue = _distance / _numberOfSteps;
                _stepInPixel = _stepInValue * _pixelResolution;
            }
            _firstTickY = 0;

        }
        if (_numberOfSteps % 1 != 0) {
            _remainedPixels = _stepInPixel * _numberOfSteps * _numberOfSteps % 1
        }
        _numberOfSteps = Math.floor(_numberOfSteps);

    }

    protected function setInitHeight():void {
        this._initHeight = this._graphInstance.graphHeightWithoutControlls() - GraphInstance.hAxisHeight;
    }


    public override function reDraw():void {
//        this.height = this._graphInstance.graphHeightWithoutControlls();
//        this.width = _graphInstance.width - GraphInstance.vAxisWidth;
        setTextVisiblesFalse();
        this.graphics.clear();
        calculateInitValues()
        drawAxis();

//        this.height = this._graphInstance.graphHeightWithoutControlls();

    }


    protected function drawAxis():void {
        if (this._initHeight == 0) {
            return;
        }

        needSec = true//tickSizeInMSec < 60000;
        graphics.clear();
//        if (numChildren > 0) {
//            this.removeChildren(0, numChildren - 1);
//        }

        _textLabelsPointer = 0;
        for (var tlpi:int = 0; tlpi < _textLabelsArray.length; tlpi++) {
            _textLabelsArray[tlpi].visible = false;
        }
        graphics.lineStyle(3, GraphColors.AXIS_COLOR);//set the color
        var squareCommands:Vector.<int> = new Vector.<int>((_numberOfSteps + 3) * 3, true);
        var squareCoord:Vector.<Number> = new Vector.<Number>((_numberOfSteps + 3) * 6, true);


        var j:int = 0;
        var k:int = 0;
        var tickHeight:int = setTickHeight();
        var __ret:Object
        __ret = drawFirstTick(squareCommands, k, squareCoord, j, tickHeight)
        k = __ret.k;
        j = __ret.j;
        for (var i:int = 0; i < _numberOfSteps; i++) {
            __ret = drawSingleTick(squareCommands, k, i, squareCoord, j, tickHeight);
            k = __ret.k;
            j = __ret.j;
        }
        drawLastTick(squareCommands, k, i, squareCoord, j, tickHeight)
        //drawRemainedLine(squareCommands, k, squareCoord, j)
        graphics.drawPath(squareCommands, squareCoord);
        drawGrid();

    }

    protected function setTickHeight():int {
        var tickHeight:int = GraphInstance.vAxisWidth//Math.abs(GraphInstance.vAxisWidth / 7) * 5;
        return tickHeight;
    }

    protected function drawGrid():void {
        if (this._initHeight == 0) {
            return;
        }
        graphics.lineStyle(1, GraphColors.GRID_COLOR, GraphColors.GRID_ALPHA);//set the color
        var squareCommands:Vector.<int> = new Vector.<int>((_numberOfSteps + 2) * 2 + 2, true);
        var squareCoord:Vector.<Number> = new Vector.<Number>((_numberOfSteps + 2) * 4 + 4, true);
        var j:int = 0;
        var k:int = 0;
        var tickHeight:int = GraphInstance.vAxisWidth;
        var __ret:Object

        for (var i:int = 0; i < _numberOfSteps; i++) {
            __ret = drawSingleLine(squareCommands, k, i, squareCoord, j, tickHeight);
            k = __ret.k;
            j = __ret.j;
        }
        if (_minValue < 0) {
            drawLastLine(squareCommands, k, i, squareCoord, j, tickHeight)
        }
        graphics.drawPath(squareCommands, squareCoord);
        drawZeroLine(tickHeight);
    }

    protected function drawZeroLine(tickHeight:int):void {
//Zero line
        if (_minValue < 0) {
            graphics.lineStyle(1, GraphColors.ZERO_COLOR, GraphColors.ZERO_ALPHA);//set the color
            graphics.moveTo(tickHeight, (_maxValue) * _pixelResolution);
            graphics.lineTo(this._graphInstance.initWidth, (_maxValue) * _pixelResolution);
        }
    }


    protected function drawFirstTick(squareCommands:Vector.<int>, k:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        k++;

        squareCoord[j] = GraphInstance.vAxisWidth  //x
        squareCoord[++j] = 0;  //y
        squareCoord[++j] = GraphInstance.vAxisWidth  //x
        squareCoord[++j] = _topZero ? 0 : _firstTickY //y
        squareCoord[++j] = tickHeight //x
        squareCoord[++j] = _topZero ? 0 : _firstTickY //y
        j++

        return {k: k, j: j};
    }


    protected function drawSingleTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k++] = GraphicsPathCommand.MOVE_TO;
        squareCommands[k++] = GraphicsPathCommand.LINE_TO;
        squareCommands[k++] = GraphicsPathCommand.LINE_TO;

        var aDist:int = i * _stepInPixel + (_topZero ? 0 : _firstTickY)//-i*_distanceInPixelCorrectionNumber;
        var lastYOffset:int = 0;
        if (i == _numberOfSteps - 1) {
            lastYOffset = (_stepInPixel - Math.floor(_stepInPixel)) * _numberOfSteps + 1;
        }
        var lastY:uint = aDist + _stepInPixel + lastYOffset
        if (lastY > _initHeight) {
            lastY = _initHeight;
        }
        squareCoord[j] = tickHeight //x
        squareCoord[++j] = aDist;  //y
        squareCoord[++j] = GraphInstance.vAxisWidth    //x
        squareCoord[++j] = aDist   //y
        squareCoord[++j] = GraphInstance.vAxisWidth  //x
        squareCoord[++j] = lastY//y
        j++
        createLabelText(i, aDist, tickHeight);
        return {k: k, j: j};

    }

    protected function drawRemainedLine(squareCommands:Vector.<int>, k:int, squareCoord:Vector.<Number>, j:int):void {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        squareCoord[j] = GraphInstance.vAxisWidth  //x
        squareCoord[++j] = Math.floor(_numberOfSteps * _stepInPixel);  //y
        squareCoord[++j] = GraphInstance.vAxisWidth  //x
        squareCoord[++j] = _initHeight//y

    }

    protected function drawSingleLine(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k++] = GraphicsPathCommand.MOVE_TO;
        squareCommands[k++] = GraphicsPathCommand.LINE_TO;

        var aDist:Number = i * _stepInPixel + (_topZero ? 0 : _firstTickY)//-i*_distanceInPixelCorrectionNumber;
        squareCoord[j] = tickHeight //x
        squareCoord[++j] = aDist;  //y
        squareCoord[++j] = this._graphInstance.initWidth    //x
        squareCoord[++j] = aDist   //y
        j++
        return {k: k, j: j};
    }

    protected function drawLastLine(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k++] = GraphicsPathCommand.MOVE_TO;
        squareCommands[k++] = GraphicsPathCommand.LINE_TO;

        var aDist:Number = i * _stepInPixel + (_topZero ? 0 : _firstTickY)//-i*_distanceInPixelCorrectionNumber;
        squareCoord[j] = tickHeight //x
        squareCoord[++j] = aDist;  //y
        squareCoord[++j] = this._graphInstance.initWidth    //x
        squareCoord[++j] = aDist   //y
        j++
        return {k: k, j: j};
    }

    protected function createLabelText(i:int, aDist:Number, tickHeight:int):void {
        if (_textLabelsArray.length <= _textLabelsPointer) {
            _textLabelsArray.push(FontFactory.getDataAxisFont());
        }
        myTextBox = _textLabelsArray[_textLabelsPointer];
        _textLabelsPointer++;
        positionateLabel(aDist, i === _numberOfSteps && restFromMaxVal === 0);
        myTextBox.width = 25;
        myTextBox.height = 9;
        setLabelText(i);
        if (!this.contains(myTextBox)) {
            this.addChild(myTextBox)
        } else {
            myTextBox.visible = true;
        }
    }


    protected function setLabelText(i:int):void {
        if (_topZero) {
            myTextBox.text = _minValue + i * _stepInValue + "";

        } else {
            myTextBox.text = _maxValue - i * _stepInValue - restFromMaxVal + "";
        }
    }

    protected function positionateLabel(aDist:Number, isLast:Boolean):void {
        myTextBox.x = 5
        myTextBox.y = aDist - 9;
    }

    protected function drawLastTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):void {
        var aDist:int = i * _stepInPixel + (_topZero ? 0 : _firstTickY)

        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        if (_topZero) {
            if (_maxValue > i * _stepInValue) {
                squareCommands[++k] = GraphicsPathCommand.LINE_TO;
            } else {
                squareCommands[++k] = GraphicsPathCommand.MOVE_TO;
            }

        } else {
            if (_minValue < 0) {
                squareCommands[++k] = GraphicsPathCommand.LINE_TO;
            } else {
                squareCommands[++k] = GraphicsPathCommand.MOVE_TO;
            }
        }
        var lastYOffset = (_stepInPixel - Math.floor(_stepInPixel)) * _numberOfSteps + 1;

        squareCoord[j] = tickHeight //x
        squareCoord[++j] = aDist;  //y
        squareCoord[++j] = GraphInstance.vAxisWidth    //x
        squareCoord[++j] = aDist   //y
        squareCoord[++j] = GraphInstance.vAxisWidth  //x
        squareCoord[++j] = aDist + _firstTickY //y
        j++
        k++
        createLabelText(i, aDist, tickHeight);
        drawRemainedLine(squareCommands, k, squareCoord, j)

    }


    public function get stepInValue():Number {
        return _stepInValue;
    }


}

}
