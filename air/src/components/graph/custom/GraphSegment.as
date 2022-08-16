/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.07.17.
 * Time: 18:24
 * To change this template use File | Settings | File Templates.
 */
package components.graph.custom {
import flash.display.Shape;

public class GraphSegment {
    protected var _minTime:Number;
    protected var _maxTime:Number;
    protected var _pCoords:Vector.<Number> = new <Number>[];   //Positive coords
    protected var _pCommands:Vector.<int> = new <int>[];       //Positive commands
    protected var _nCoords:Vector.<Number> = new <Number>[];   //Negative coords
    protected var _nCommands:Vector.<int> = new <int>[];       //Negative commands
    protected var _rendered:Boolean = false;
    protected var _lastX:int;
    protected var _sprite:Shape;
    protected var _minValue:Number;
    public var isFirstSegment:Boolean = false;


    public function GraphSegment() {
        _sprite = new Shape();
        _minTime = 0;
        _maxTime = 0;
        clearCoordsAndCommands();

    }

    public function clearCoordsAndCommands():void {
        _pCoords.length = 0;
        _pCommands.length = 0;
        _nCoords.length = 0;
        _nCommands.length = 0;
        isFirstSegment = false;
    }

    public function set sprite(s:Shape):void {
        _sprite = s;
    }

    public function get sprite():Shape {
        return _sprite;
    }

    public function get minTime():Number {
        return _minTime;
    }

    public function set minTime(value:Number):void {
        _minTime = value;
    }

    public function get maxTime():Number {
        return _maxTime;
    }

    public function set maxTime(value:Number):void {
        _maxTime = value;
    }

    public function render():void {

    }

    public function deAlloc():void {
        _sprite = null;
        clearCoordsAndCommands();
    }


    public function get pCoords():Vector.<Number> {
        return _pCoords;
    }

    public function set pCoords(value:Vector.<Number>):void {
        _pCoords = value;
    }

    public function get pCommands():Vector.<int> {
        return _pCommands;
    }

    public function set pCommands(value:Vector.<int>):void {
        _pCommands = value;
    }


    public function get rendered():Boolean {
        return _rendered;
    }

    public function set rendered(value:Boolean):void {
        _rendered = value;
    }


    public function get lastX():int {
        return _lastX;
    }

    public function set lastX(value:int):void {
        _lastX = value;
    }


    public function get nCoords():Vector.<Number> {
        return _nCoords;
    }

    public function set nCoords(value:Vector.<Number>):void {
        _nCoords = value;
    }

    public function get nCommands():Vector.<int> {
        return _nCommands;
    }

    public function set nCommands(value:Vector.<int>):void {
        _nCommands = value;
    }


    public function get minValue():Number {
        return _minValue;
    }

    public function set minValue(value:Number):void {
        _minValue = value;
    }
}
}
