/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.04.
 * Time: 22:06
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import com.utils.FontFactory;

import flash.display.GraphicsPathCommand;

public class VTimeAxis extends HTimeAxis {
    public function VTimeAxis(minValue:Number, maxValue:Number, graphInstance:GraphInstance) {
        super(minValue, maxValue, graphInstance);
        drawBg(GraphInstance.vAxisWidth, 100)
    }

    protected override function positionateLabelText(aDist:Number, tickHeight:int):void {
        myTextBox.x = 0;
        myTextBox.y = aDist - 15;
    }

    public override function reDraw():void {
        drawBg(GraphInstance.vAxisWidth, 100)
        setTextVisiblesFalse()
        calculateInitValues()
        this.x = 0;
        this.y = 0;
        drawAxis();
    }

    public override function drawBg(w:int, h:int):void {
        this.graphics.clear();
        this.graphics.beginFill(0x00ff00, 0)
        this.graphics.drawRect(0, 0, w, h)
        this.graphics.endFill();
    }

    protected override function drawFirstTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        k++;

        squareCoord[j] = GraphInstance.vAxisWidth  //x
        squareCoord[++j] = 0;  //y
        squareCoord[++j] = GraphInstance.vAxisWidth   //x
        squareCoord[++j] = _initWidth  //y
        j++
        createLabelText(i, firstTimeX, tickHeight);

        return {k: k, j: j};
    }

    protected override function drawSingleTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):Object {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
//        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
        k++;

        aDist = i * _stepInPixel + firstTimeX;
        squareCoord[j] = GraphInstance.vAxisWidth - 5//tickHeight //x
        squareCoord[++j] = aDist;  //y
        squareCoord[++j] = GraphInstance.vAxisWidth   //x
        squareCoord[++j] = aDist  //y
//        squareCoord[++j] = GraphInstance.vAxisWidth   //x
//        squareCoord[++j] = aDist + _stepInPixel  //y
        j++
        createLabelText(i, aDist, tickHeight);
        return {k: k, j: j};

    }

    protected override function createLabelText(i:int, aDist:Number, tickHeight:int):void {

        var date:Date = new Date((_minValue + firstTimeValue + i * stepInTime) * 1000);
        if (_textLabelsArray.length <= _textLabelsPointer) {
            _textLabelsArray.push(FontFactory.getTimeAxisFont());
        }
        myTextBox = _textLabelsArray[_textLabelsPointer];
        _textLabelsPointer++;
        myTextBox.width = 30;
        myTextBox.height = 18;
        myTextBox.text = formatTime(date)//formatTime(date)
        positionateLabelText(aDist, tickHeight);
        if (!this.contains(myTextBox)) {
            this.addChild(myTextBox)
        } else {
            myTextBox.visible = true;
        }

    }

    protected override function drawLastTick(squareCommands:Vector.<int>, k:int, i:int, squareCoord:Vector.<Number>, j:int, tickHeight:int):void {
        squareCommands[k] = GraphicsPathCommand.MOVE_TO;
        squareCommands[++k] = GraphicsPathCommand.LINE_TO;
//        squareCommands[++k] = GraphicsPathCommand.LINE_TO;

        aDist = i * _stepInPixel + firstTimeX;
        squareCoord[j] = GraphInstance.vAxisWidth - 5//tickHeight //x
        squareCoord[++j] = aDist;  //y
        squareCoord[++j] = GraphInstance.vAxisWidth   //x
        squareCoord[++j] = aDist  //y
//        squareCoord[++j] = GraphInstance.vAxisWidth   //x
//        squareCoord[++j] = aDist + _lastTickWidth  //y

        createLabelText(i, aDist, tickHeight);

    }

    protected override function setInitWidth():void {
        this._initWidth = this._graphInstance.graph.possibleMaxWidth;
        _initWidth = _initWidth <= 0 ? this._graphInstance.initHeight : _initWidth;
    }


    override protected function calcStepsInPixel():void {
        var numberOfInitSteps:uint = 4
        if (_graphInstance.getScrollBoxHeight() / MIN_STEP_IN_PIXEL > numberOfInitSteps) {
            calcStepInPixel = _graphInstance.getScrollBoxHeight() / numberOfInitSteps;
        } else {
            calcStepInPixel = MIN_STEP_IN_PIXEL;
        }
    }
}
}
