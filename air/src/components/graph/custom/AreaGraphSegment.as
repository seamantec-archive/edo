/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.07.17.
 * Time: 18:26
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import com.graphs.YData;

import flash.display.CapsStyle;
import flash.display.GraphicsPathCommand;
import flash.display.JointStyle;
import flash.display.LineScaleMode;

public class AreaGraphSegment extends GraphSegment {
    public var pLineColor:uint = 0x00aeef;
    public var pLineWidth:int = 1;
    public var pLineAlpha:Number = 0.7;
    public var pAreaColor:uint = 0x00aeef;
    public var pAreaAlpha:Number = 0.7;
    public var nLineColor:uint = 0xff0000;
    public var nLineWidth:int = 1;
    public var nLineAlpha:Number = 0.7;
    public var nAreaColor:uint = 0xff0000;
    public var nAreaAlpha:Number = 0.7;
    private var _minYCoord:int = 0;
    public var startFromPositive:Boolean = false;
    public var startFromNegative:Boolean = false;

    public function AreaGraphSegment(ydata:YData) {
        super();
        this.pLineColor = ydata.pLineColor;
        this.pLineWidth = ydata.pLineWidth;
        this.pLineAlpha = ydata.pLineAlpha;
        this.pAreaColor = ydata.pAreaColor;
        this.pAreaAlpha = ydata.pAreaAlpha;
        this.nLineColor = ydata.nLineColor;
        this.nLineWidth = ydata.nLineWidth;
        this.nLineAlpha = ydata.nLineAlpha;
        this.nAreaColor = ydata.nAreaColor;
        this.nAreaAlpha = ydata.nAreaAlpha;
    }


    public override function render():void {
        if (_rendered) {
            return;
        }
        var cIndex:uint = 0
        var command:uint = 0;
        var commandsLength:uint = _pCommands.length;
        var startfrom:uint = 0;

        _sprite.graphics.clear();
        _sprite.graphics.beginFill(pAreaColor, pAreaAlpha);//set the color
        _sprite.graphics.drawPath(_pCommands, _pCoords)
        _sprite.graphics.endFill();

        if (_minValue < 0) {
            _sprite.graphics.beginFill(nAreaColor, nAreaAlpha);//set the color
            _sprite.graphics.drawPath(_nCommands, _nCoords);
            _sprite.graphics.endFill();

            _sprite.graphics.lineStyle(nLineWidth, nLineColor, nLineAlpha, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.ROUND);//set the color
            startfrom = 0;
            cIndex = 0
            commandsLength = _nCommands.length;
            if (startFromNegative || isFirstSegment) {
                startfrom = 1
                cIndex = 2
                _nCommands[1] = GraphicsPathCommand.MOVE_TO;
            }

            for (var i:int = startfrom; i < commandsLength - 1; i++) {
                command = _nCommands[i]
                drawNCommand(command, cIndex);
                cIndex += 2;
            }
        }


        startfrom = 0;
        cIndex = 0
        commandsLength = _pCommands.length;
        if (startFromPositive || isFirstSegment) {
            startfrom = 1
            cIndex = 2
            _pCommands[1] = GraphicsPathCommand.MOVE_TO;
        }

        _sprite.graphics.lineStyle(pLineWidth, pLineColor, pLineAlpha, false, LineScaleMode.NONE, CapsStyle.NONE, JointStyle.ROUND);//set the color
        for (var i:int = startfrom; i < commandsLength - 1; i++) {
            command = _pCommands[i]
            drawPCommand(command, cIndex);
            cIndex += 2;
        }

        _sprite.visible = true;
        _rendered = true;
    }

    private function drawPCommand(command:uint, cIndex:uint):void {
        if (command === GraphicsPathCommand.MOVE_TO) {
            _sprite.graphics.moveTo(_pCoords[cIndex], _pCoords[cIndex + 1]);
        } else {
            _sprite.graphics.lineTo(_pCoords[cIndex], _pCoords[cIndex + 1]);
        }
    }

    private function drawNCommand(command:uint, cIndex:uint):void {
        if (command === GraphicsPathCommand.MOVE_TO) {
            _sprite.graphics.moveTo(_nCoords[cIndex], _nCoords[cIndex + 1]);
        } else {
            _sprite.graphics.lineTo(_nCoords[cIndex], _nCoords[cIndex + 1]);
        }
    }


    public function get minYCoord():int {
        return _minYCoord;
    }

    public function set minYCoord(value:int):void {
        _minYCoord = value;
    }


    private function exportArrays():void {
        trace("_nCoords = [", _nCoords.toLocaleString(), "]")
        trace("_nCommands = [", _nCommands.toLocaleString(), "]")
    }

    private function closePPathes():void {

    }
}
}
