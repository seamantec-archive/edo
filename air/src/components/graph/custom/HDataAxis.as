/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.04.
 * Time: 22:07
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import com.utils.FontFactory;

import flash.display.GraphicsPathCommand;

public class HDataAxis extends VDataAxis {
    public function HDataAxis(minValue:Number, maxValue:Number, graphInstance:GraphInstance) {
        super(minValue, maxValue, graphInstance);
        drawBg(_graphInstance.getScrollBoxWidth() - GraphInstance.vAxisWidth, this._graphInstance.initHeight)
    }

    public override function reDraw():void {
        drawBg(_graphInstance.getScrollBoxWidth() - GraphInstance.vAxisWidth, this._graphInstance.initHeight)
        setTextVisiblesFalse()
        calculateInitValues();
        drawAxis();

    }

    protected override function setInitHeight():void {
        this._initHeight = this._graphInstance.getScrollBoxWidth() - GraphInstance.vAxisWidth - _graphInstance.frameSprite.rightFrameWidth;
    }


    protected override function drawFirstTick(squareCommands:Vector.<int>, k:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
//        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        k++;

        squareCoord[j] = 0  //x
        squareCoord[++j] = 0;  //y
        squareCoord[++j] = _initHeight //x
        squareCoord[++j] = 0 //y
//        squareCoord[++j] = _topZero ? 0 : _firstTickY //x
//        squareCoord[++j] = tickHeight//y
        j++

        return {k: k, j: j};
    }

    protected override function drawSingleTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k++] = GraphicsPathCommand.MOVE_TO;
        squareCommands[k++] = GraphicsPathCommand.LINE_TO;
//        squareCommands[k++] = GraphicsPathCommand.LINE_TO;

        var aDist:int = i * _stepInPixel + (_topZero ? 0 : _firstTickY)//-i*_distanceInPixelCorrectionNumber;
        var lastYOffset:int = 0;
        if (i == _numberOfSteps - 1) {
            lastYOffset = (_stepInPixel - Math.floor(_stepInPixel)) * _numberOfSteps + 1;
        }
        squareCoord[j] = aDist //x
        squareCoord[++j] = 0;  //y
        squareCoord[++j] = aDist   //x
        squareCoord[++j] = 0    //y
//        squareCoord[++j] = aDist + _stepInPixel + lastYOffset //x
//        squareCoord[++j] = 0  //y
        j++
        createLabelText(i, aDist, 0);
        return {k: k, j: j};

    }

    protected override function drawSingleLine(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k++] = GraphicsPathCommand.MOVE_TO;
        squareCommands[k++] = GraphicsPathCommand.LINE_TO;

        var aDist:Number = i * _stepInPixel + (_topZero ? 0 : _firstTickY)//-i*_distanceInPixelCorrectionNumber;
        squareCoord[j] = aDist //x
        squareCoord[++j] = 0;  //y
        squareCoord[++j] = aDist  //x
        squareCoord[++j] = -this._graphInstance.initHeight + GraphInstance.hAxisHeight//y
        j++
        return {k: k, j: j};
    }

    protected override function drawLastLine(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k++] = GraphicsPathCommand.MOVE_TO;
        squareCommands[k++] = GraphicsPathCommand.LINE_TO;

        var aDist:Number = i * _stepInPixel + (_topZero ? 0 : _firstTickY)//-i*_distanceInPixelCorrectionNumber;
        squareCoord[j] = aDist //x
        squareCoord[++j] = 0;  //y
        squareCoord[++j] = aDist  //x
        squareCoord[++j] = -this._graphInstance.initHeight + GraphInstance.hAxisHeight//y
        j++
        return {k: k, j: j};
    }

    protected override function positionateLabel(aDist:Number, isLast:Boolean):void {
        if (isLast) {
            if (GraphInstance.rightOffset == 0) {
                myTextBox.x = aDist - myTextBox.width - 2;
                myTextBox.y = setTickHeight() + 2;
            } else {
                myTextBox.x = aDist - myTextBox.width / 2;
                myTextBox.y = setTickHeight() + 2;
            }
        } else {

            myTextBox.x = aDist - myTextBox.width / 2;
            myTextBox.y = setTickHeight() + 2;
        }
    }

    protected override function createLabelText(i:int, aDist:Number, tickHeight:int):void {
        if (_textLabelsArray.length <= _textLabelsPointer) {
            _textLabelsArray.push(FontFactory.getTimeAxisFont());
        }
        myTextBox = _textLabelsArray[_textLabelsPointer];
        _textLabelsPointer++;
        myTextBox.width = 25;
        myTextBox.height = 9;
        setLabelText(i);
        positionateLabel(aDist, i === _numberOfSteps);
        if (!this.contains(myTextBox)) {
            this.addChild(myTextBox)
        } else {
            myTextBox.visible = true;
        }
    }

    protected override function drawLastTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):void {
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

        squareCoord[j] = aDist //x
        squareCoord[++j] = tickHeight;  //y
        squareCoord[++j] = aDist   //x
        squareCoord[++j] = 0   //y
        squareCoord[++j] = aDist + _firstTickY  //x
        squareCoord[++j] = 0 //y
        j++

        createLabelText(i, aDist, tickHeight);

    }

    protected override function drawZeroLine(tickHeight:int):void {
        //Zero line
        if (_minValue < 0) {
            graphics.lineStyle(1, GraphColors.ZERO_COLOR, GraphColors.ZERO_ALPHA);//set the color
            graphics.moveTo((_maxValue) * _pixelResolution, 0);
            graphics.lineTo((_maxValue) * _pixelResolution, -this._graphInstance.initHeight + GraphInstance.hAxisHeight);
        }
    }

    protected override function setTickHeight():int {
        var tickHeight:int = 0//Math.abs(GraphInstance.hAxisHeight / 7) * 2;
        return tickHeight;
    }


    protected override function setLabelText(i:int):void {
        myTextBox.text = _minValue + i * _stepInValue + restFromMaxVal + "";
    }
}
}
