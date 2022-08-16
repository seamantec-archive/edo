/**
 * Created by seamantec on 14/03/14.
 */
package com.polar {

import flash.display.Graphics;
import flash.display.GraphicsPathCommand;
import flash.display.Sprite;
import flash.text.TextField;

public class PolarLayer extends Sprite {

    public static const MARGIN:Number = 36;
    public static const DIAMETER:Number = 400 - 74;

    public static const ALPHA:Number = 0.2;

    protected const RAD:Number = Math.PI / 180;

    protected var _windSpeed:Number;
    protected var _maxSpeed:Number;
    protected var _maxPolarSpeed:Number;
    protected var _pixelPerSpeed:Number;
    protected var _color:uint;

    protected var _polar:Sprite;
    protected var _vmg:Sprite;
    protected var _wind:Sprite;
    protected var _circle:Sprite;

    protected var _circles:Vector.<Number>;

    protected var _commands:Vector.<int>;
    protected var _coords:Vector.<Number>;

    protected var _exists:Boolean;


    public function PolarLayer(wind:Number, maxSpeed:Number, color:uint) {
        super();
        this.visible = false;

        _circle = newLayer();
        _wind = newLayer();
        _polar = newLayer();
        _vmg = newLayer();

        _commands = new Vector.<int>();
        _coords = new Vector.<Number>();
        _windSpeed = wind;
        _maxSpeed = maxSpeed;
        _color = color;

        init();
    }

    public function reInit(maxSpeed:Number):void {
        _maxSpeed = maxSpeed;
        init();
    }

    private function init():void {
        var max:Object = PolarContainer.instance.polarTableFromFile.findMaxForWind(_windSpeed);
        if (max == null || (max.maxSpeed == 0 || max.maxSpeed == Infinity || isNaN(max.maxSpeed))) {
            _exists = false;
        } else {
            _exists = true;

            _maxPolarSpeed = max.maxSpeed;

            setScale();

            drawPolar();
            drawCircles();
        }
    }

    private function newLayer():Sprite {
        var layer:Sprite = new Sprite();
        layer.graphics.beginFill(0xffffff, 0);
        layer.graphics.drawRect(0, 0, 2 * DIAMETER, 2 * DIAMETER);
        layer.graphics.endFill();
        this.addChild(layer);

        return layer;
    }

    private function drawPolar():void {
        if (_exists) {
            if (_windSpeed >= 0 && _windSpeed < PolarTable.MAX_WINDSPEED) {
                var polarTable:PolarTable = PolarContainer.instance.polarTableFromFile;

                // DRAW POLAR
                beginPolar();
                for (var i:int = 0; i < 360; i++) {
                    var pbs:PolarBoatSpeed = polarTable.getValueForWSpeedAndDirection(_windSpeed, i);
                    if (pbs == null) {
                        continue;
                    }

                    addPolar(pbs.cardinalHardCalculated, i);
                }
                endPolar();

                // DRAW VMG
                for (var i:int = 0; i <= 3; i++) {
                    var vmg:BestVmg = (polarTable.bestVmg[_windSpeed] != null) ? polarTable.bestVmg[_windSpeed][i] : null;
                    if (vmg == null) {
                        continue;
                    }

                    addVmg(vmg.boatSpeed, vmg.angle);
                }
            }
        }
    }

    private function beginPolar():void {
        _polar.graphics.lineStyle(3, _color);

        _commands.push(GraphicsPathCommand.MOVE_TO);

        _coords.push(DIAMETER);
        _coords.push(DIAMETER);
    }

    private function addPolar(speed:Number, direction:Number):void {
        _commands.push(GraphicsPathCommand.LINE_TO);

        _coords.push(speed * _pixelPerSpeed * Math.cos((direction - 90) * RAD) + DIAMETER);
        _coords.push(speed * _pixelPerSpeed * Math.sin((direction - 90) * RAD) + DIAMETER);
    }

    private function endPolar():void {
        _polar.graphics.drawPath(_commands, _coords);
        _commands.length = 0;
        _coords.length = 0;
    }

    private function addVmg(speed:Number, direction:Number):void {
        var vmg:Graphics = _vmg.graphics;
        vmg.lineStyle(2, _color);
        vmg.beginFill(0xffffff);
        vmg.drawCircle(speed * _pixelPerSpeed * Math.cos((direction - 90) * RAD) + DIAMETER, speed * _pixelPerSpeed * Math.sin((direction - 90) * RAD) + DIAMETER, 4);
        vmg.endFill();
    }

    protected function getCircles(max:Number):Vector.<Number> {
        var circles:Vector.<Number> = new Vector.<Number>();
        var max:Number = Math.floor(max);
        var i:int = 6;
        var nearest:Number = Math.abs((max / i) - Math.round(max / i));
        var min:int = i;
        if (max < 4) {
            min = 4;
        } else {
            while (i > 4) {
                i--;
                if (Math.abs((max / i) - Math.round(max / i)) < nearest) {
                    nearest = Math.abs((max / i) - Math.round(max / i));
                    min = i;
                }
            }
        }
        for (i = 0; i < min; i++) {
            var n:Number = max - (i * Math.round(max / min));
            if (n >= 2) {
                circles.push(n);
            }
        }

        return circles;
    }

    public function drawCircles():void {
    }

    public function setLabel(texts:Vector.<TextField>):void {
        for (var i:int = 0; i < texts.length; i++) {
            if (_circles != null && i < _circles.length && (_circles[i] * _pixelPerSpeed) <= PolarLayer.DIAMETER) {
                texts[i].visible = true;
                texts[i].text = (Math.round(_circles[i] * 10) / 10).toString();
                texts[i].x = PolarLayer.DIAMETER + 2;
                texts[i].y = PolarLayer.DIAMETER - ((_circles[i] * _pixelPerSpeed) + 14);
            } else {
                texts[i].visible = false;
            }
        }
    }

    public function activate(active:Boolean = true):void {
    }

    public function deactivate():void {
        activate(false);
    }

//    public function setMaxSpeedFromDots():void {
//        var dots:PolarDataWindLayer = PolarContainer.instance.dataContainer.getPolarDataWindLayerAtWind(_windSpeed);
//        if (dots != null) {
//            if ((dots.maxSpeed > _maxSpeed)) {
//                _maxSpeed = dots.maxSpeed;
//            }
//        }
//    }

    public function drawAllDots():void {
        var dots:PolarDataWindLayer = PolarContainer.instance.dataContainer.getPolarDataWindLayerAtWind(_windSpeed);
        if (dots != null) {
            clearCloud()
            for (var angle:int = 0; angle < 360; angle++) {
                for (var boatSpeed:int = 0; boatSpeed <= PolarDataWindLayer.MAX_BOAT_SPEED * 10; boatSpeed++) {
                    if (dots.container[angle][boatSpeed] != 0) {
                        addWind(boatSpeed / 10, angle, dots.container[angle][boatSpeed] * 0.1);
                    }
                }
            }
        }
    }

    public function addWind(speed:Number, direction:Number, alpha:Number):void {
    }

    public function setScale():void {
    }

    public function clearPolarAndCloudVmgAndCircles():void {
        _polar.graphics.clear();
        _vmg.graphics.clear();
        _wind.graphics.clear();
        _circle.graphics.clear();
    }

    public function clearCloud():void {
        _wind.graphics.clear();
    }


    public function get exists():Boolean {
        return _exists;
    }

    public function set exists(value:Boolean):void {
        _exists = value;
    }

    public function get polar():Sprite {
        return _polar;
    }

    public function get vmg():Sprite {
        return _vmg;
    }

    public function get wind():Sprite {
        return _wind;
    }

    public function get circle():Sprite {
        return _circle;
    }

    public function get maxPolarSpeed():Number {
        return _maxPolarSpeed;
    }

    public function get maxSpeed():Number {
        return _maxSpeed;
    }


    public function get pixelPerSpeed():Number {
        return _pixelPerSpeed;
    }

    public function get windSpeed():Number {
        return _windSpeed;
    }
}
}
