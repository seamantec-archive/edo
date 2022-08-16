/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.04.
 * Time: 21:56
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;

public class Axis extends Sprite {
    protected var _minValue:Number;
    protected var _maxValue:Number;
    protected var _graphInstance:GraphInstance;
    protected var myTextBox:TextField;
    protected var _textLabelsArray:Vector.<TextField> = new <TextField>[];
    protected var _textLabelsPointer = 0;
    protected var _labelColor:uint = GraphColors.AXIS_COLOR;
    protected var _distance:Number;
    protected var _stepInPixel:Number
    protected var _numberOfSteps:Number;
    protected var _pixelResolution:Number; //how many pixel is one value change
    protected var needSec:Boolean;


    //DATA AXIS parameters
    protected var _topZero:Boolean = false;
    protected var _quantalStep:int = -1;
    protected var _yOffset:int = 0;

    public function Axis(minValue:Number, maxValue:Number, graphInstance:GraphInstance) {
        super();
        this._minValue = minValue;
        this._maxValue = maxValue;
        this._graphInstance = graphInstance;
        this._graphInstance.addEventListener(Event.RESIZE, resizeHandler, false, 0, true);

    }

    public function drawBg(w:int, h:int):void {
        this.graphics.clear();
        this.graphics.beginFill(0x00ff00, 0)
        this.graphics.drawRect(0, 0, w, h)
        this.graphics.endFill();
    }

    public function resetTextLabelsContainer():void {
        for (var i:int = _textLabelsArray.length - 1; i >= 0; i--) {
            this.removeChild(_textLabelsArray[i])
            _textLabelsArray[i] = null;
        }
        _textLabelsPointer = 0
        _textLabelsArray.length = 0;
    }

    protected function formatTime(date:Date):String {
        return ((date.getUTCHours() < 10 ? "0" + date.getUTCHours() : date.getUTCHours()) +
                ":" + ( date.getUTCMinutes() < 10 ? "0" + date.getUTCMinutes() : date.getUTCMinutes() + "") +
                (needSec ? (date.getUTCSeconds() < 10 ? ":0" + date.getUTCSeconds() : ":" + date.getUTCSeconds() + "" ) : ""));
    }

    protected function setTextVisiblesFalse():void {
        for (var i:int = _textLabelsArray.length - 1; i >= 0; i--) {
            _textLabelsArray[i].y = 0;
            _textLabelsArray[i].visible = false;

        }
    }

    protected function resizeHandler(event:Event):void {
        reDraw();
    }

    public function reDraw():void {

    }

    public function get pixelResolution():Number {
        return _pixelResolution;
    }

    public function get distance():Number {
        return _distance;
    }


    public function get stepInPixel():Number {
        return _stepInPixel;
    }

    public function get numberOfSteps():int {
        return _numberOfSteps;
    }

    public function get topZero():Boolean {
        return _topZero;
    }

    public function set topZero(value:Boolean):void {
        _topZero = value;
    }


    public function get quantalStep():int {
        return _quantalStep;
    }

    public function set quantalStep(value:int):void {
        _quantalStep = value;
    }

    public function get yOffset():int {
        return _yOffset;
    }


}
}
