/**
 * Created by seamantec on 21/03/14.
 */
package com.polar {

import flash.display.GraphicsPathCommand;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

public class PolarDotLayer extends Sprite {

    public static const SPEED_THRESHOLD:Number = 1.1;
    public static const SPEED_MIN:int = 1;
    public static const SPEED_MAX:int = 50;

    private const RAD:Number = Math.PI / 180;

    private const AUTO:Array = new Array(45, 75, 105, 135, 165);

    private var _windSpeed:Number;
    private var _maxSpeedForWind:Number;
    private var _pixelPerSpeed:Number;
    private var _color:uint;
    protected var _polar:Sprite;
    protected var _vmg:Sprite;
    private var _circle:Sprite;
    private var _wind:Sprite;
    private var _dot:Sprite;
    private var _empty:Boolean = true;
    private var _circles:Vector.<Number>;
    protected var _commands:Vector.<int>;
    protected var _coords:Vector.<Number>;
    private var _forceDots:Vector.<PolarForceDot>;

    private var _changed:Boolean;

    public function PolarDotLayer(wind:Number, color:uint, forceDots:Vector.<PolarForceDot>) {
        super();
        this.visible = false;
        _circle = newLayer();
        _wind = newLayer();
        _dot = newLayer();
        _polar = newLayer();
        _vmg = newLayer();
        _forceDots = forceDots;
        _windSpeed = wind;
        _maxSpeedForWind = _windSpeed * SPEED_THRESHOLD;
        _commands = new Vector.<int>();
        _coords = new Vector.<Number>();
        _color = color;
        loadPointsFromContainer();

        _changed = false;
    }

    public function loadPointsFromContainer():void {
        clear();
        init();
        var dots:PolarDataWindLayer = PolarContainer.instance.dataContainer.getPolarDataWindLayerAtWind(_windSpeed);
        if (dots != null) {
            var maxBoatSpeed:uint = _maxSpeedForWind*10;
            if(maxBoatSpeed > 300){
                maxBoatSpeed = 300;
            }
            for (var angle:int = 0; angle < 360; angle++) {
                for (var boatSpeed:int = 0; boatSpeed <= maxBoatSpeed; boatSpeed++) {
                    if ( dots.container[angle][boatSpeed] != 0) {
                        addWind(boatSpeed / 10, angle, dots.container[angle][boatSpeed] * 0.1);
                    }
                }
            }
        }
        if (!_empty) {
            drawPolar();
            drawCircles();
        }
    }

    public function redrawPolar():void {
        loadPointsFromContainer()
    }

    private function newLayer():Sprite {
        var layer:Sprite = new Sprite();
        layer.graphics.beginFill(0xffffff, 0);
        layer.graphics.drawCircle(PolarLayer.DIAMETER, PolarLayer.DIAMETER, PolarLayer.DIAMETER);
        layer.graphics.endFill();
        this.addChild(layer);

        return layer;
    }

    public function setBoatSpeedForActualLayer(boatSpeed:Number, windDirection:Number):void {
        if (windDirection <= 0) {
            return;
        }
        if (PolarContainer.instance.polarTableFromFile != null) {
            (this.parent as PolarDotsDish).setLayersChanged();
            PolarContainer.instance.polarFileDataChange(boatSpeed, windDirection, _windSpeed);
            PolarContainer.instance.setChanged();
        }
    }

    public function activate(active:Boolean = true, all:Boolean = false):void {
        if(_changed) {
            _changed = false;
            redrawPolar();
        }
        if(all) {
            _circle.visible = false;
            _vmg.visible = false;
            _polar.visible = false;
            var scale:Number = 1;
            if(_maxSpeedForWind<(this.parent as PolarDotsDish).maxSpeedForAll) {
                scale = _maxSpeedForWind / (this.parent as PolarDotsDish).maxSpeedForAll;
            }
            this.scaleX = scale;
            this.scaleY = scale;
            var position:Number = PolarLayer.DIAMETER - (PolarLayer.DIAMETER*scale);
            this.x = position;
            this.y = position;
        } else {
            _circle.visible = active;
            _vmg.visible = true;
            _polar.visible = true;
            this.scaleX = 1;
            this.scaleY = 1;
            this.x = 0;
            this.y = 0;
            setForceDots();
        }
        this.visible = active;
    }

    public function deactivate():void {
        activate(false);
    }

    private function clearForceDots():void {
        for (var i:int = 0; i < _forceDots.length; i++) {
            _forceDots[i].visible = false;
        }
    }

    private function setForceDots():void {
        clearForceDots();
        var container:Vector.<PolarBoatSpeed> = PolarContainer.instance.polarTableFromFile.table[_windSpeed];
        for (var i:int = 0; i < container.length; i++) {
            var pbs:PolarBoatSpeed = container[i];
            if (pbs == null || pbs.baseCalculated === 0) {
                continue;
            }
            _forceDots[i].setSpeed(pbs.baseCalculated, this);
        }
    }

    public function removeForceDots():void {
        if (PolarContainer.instance.polarTableFromFile != null) {
            PolarContainer.instance.clearTableAtSpeed(_windSpeed);
        }
    }

    public function autoArrange():void {
        var measuredDegree:Vector.<int> = new Vector.<int>();
        var measuredValue:Vector.<Number> = new Vector.<Number>();

        var dots:PolarDataWindLayer = PolarContainer.instance.dataContainer.getPolarDataWindLayerAtWind(_windSpeed);
        if(dots!=null) {
//            for(var i:int=AUTO_MIN; i<180; i++) {
//                var max:Number = dots.getMaxSpeedForAngle(i);
//                if(max>0 && i>=(prevDegree+AUTO_STEP)) {
//                    measuredDegree.push(i);
//                    measuredValue.push(max);
//                    prevDegree = i;
//                }
//            }
            for(var i=0; i<AUTO.length; i++) {
                var max:Number = dots.getMaxSpeedForAngle(AUTO[i]);
                if(max>0) {
                    measuredDegree.push(AUTO[i]);
                    measuredValue.push(max);
                } else {
                    var j:int = 1;
                    while(j<15) {
                        max = dots.getMaxSpeedForAngle(AUTO[i]+j);
                        if(max>0) {
                            measuredDegree.push(AUTO[i]);
                            measuredValue.push(max);
                            break;
                        }
                        max = dots.getMaxSpeedForAngle(AUTO[i]-j);
                        if(max>0) {
                            measuredDegree.push(AUTO[i]);
                            measuredValue.push(max);
                            break;
                        }
                        j++;
                    }
                }
            }

            var polarTableFromFile:Vector.<PolarBoatSpeed> = PolarContainer.instance.polarTableFromFile.table[_windSpeed];
            for (var i:int = 0; i < polarTableFromFile.length; i++) {
                var pbs:PolarBoatSpeed = polarTableFromFile[i];
                if(pbs == null) {
                    continue;
                }
                pbs.baseCalculated = 0;
                _forceDots[i].visible = false;

                var index:int = measuredDegree.indexOf(i);
                if(index>=0) {
                    pbs.baseCalculated = measuredValue[index];
                    _forceDots[i].setSpeed(pbs.baseCalculated, this);
                }
                pbs.isFromFile = true;
            }
            PolarContainer.instance.setChanged();
            PolarContainer.instance.restartPolarCalculatorTimer();
        }
    }

    public function addWind(boatSpeed:Number, direction:Number, alpha:Number):void {
        _wind.graphics.beginFill(_color, alpha);
        _wind.graphics.drawCircle(boatSpeed * _pixelPerSpeed * Math.cos((direction - 90) * RAD) + PolarLayer.DIAMETER, boatSpeed * _pixelPerSpeed * Math.sin((direction - 90) * RAD) + PolarLayer.DIAMETER, 2.5);
        _wind.graphics.endFill();
    }

    public function addCalculatedDots(pbs:PolarBoatSpeed, direction:Number):void {
        direction = (direction - 90) * RAD;
        //vertical pink
        if (pbs.verticalInterpolated != 0) {
            _dot.graphics.beginFill(0xed145b, PolarTable.vInterpolatedWeight / PolarTable.MAX_INTERPOLATIONW);

            _dot.graphics.drawCircle(pbs.verticalInterpolated * _pixelPerSpeed * Math.cos(direction) + PolarLayer.DIAMETER, pbs.verticalInterpolated * _pixelPerSpeed * Math.sin(direction) + PolarLayer.DIAMETER, 6);
        }
        //horizontal orange
        if (pbs.horizontalInterpolated != 0) {
            _dot.graphics.beginFill(0xff9c00, PolarTable.hInterpolatedWeight / PolarTable.MAX_INTERPOLATIONW);
            _dot.graphics.drawCircle(pbs.horizontalInterpolated * _pixelPerSpeed * Math.cos(direction) + PolarLayer.DIAMETER, pbs.horizontalInterpolated * _pixelPerSpeed * Math.sin(direction) + PolarLayer.DIAMETER, 5);
        }
//        //combinedMeasured cian
        if (pbs.combinedMeasured != 0) {
            _dot.graphics.beginFill(0x0DFFEC);
            _dot.graphics.drawCircle(pbs.combinedMeasured * _pixelPerSpeed * Math.cos(direction) + PolarLayer.DIAMETER, pbs.combinedMeasured * _pixelPerSpeed * Math.sin(direction) + PolarLayer.DIAMETER, 4);
        }
        //measured white
        if (pbs.measured != 0) {
            _dot.graphics.beginFill(0xffffff);
            _dot.graphics.drawCircle(pbs.measured * _pixelPerSpeed * Math.cos(direction) + PolarLayer.DIAMETER, pbs.measured * _pixelPerSpeed * Math.sin(direction) + PolarLayer.DIAMETER, 3);
        }
    }


    public function clear(justWind:Boolean = false):void {
        _wind.graphics.clear();
        if(!justWind) {
            clearPolarAndVmg();
        }
    }

    private function init():void {
        var max:Object = PolarContainer.instance.polarTableFromFile.findMaxForWind(_windSpeed);
        var polarDataWindLayer:PolarDataWindLayer = PolarContainer.instance.dataContainer.getPolarDataWindLayerAtWind(_windSpeed);
        var dotsMax:Number = polarDataWindLayer != null ? polarDataWindLayer.maxSpeed : 0;
        var maxSpeed:Number = 0;
        if (max != null && dotsMax != 0) {
            maxSpeed = Math.max(max.maxSpeed, dotsMax);
        } else if (max != null) {
            maxSpeed = max.maxSpeed;
        }

        if (maxSpeed == 0 || maxSpeed == Infinity || isNaN(maxSpeed)) {
            _empty = true;
            clearForceDots();
            _circle.graphics.clear();
        } else {
            _empty = false;
            _maxSpeedForWind = maxSpeed * SPEED_THRESHOLD;
        }
        setScale();
    }

    public function setScale():void {
        _pixelPerSpeed = PolarLayer.DIAMETER / _maxSpeedForWind;
    }

    private function calculateCircles():void {
        _circles = new Vector.<Number>();
        var max:Number = Math.floor(_maxSpeedForWind);
        if(max<=6) {
            var isFloat:Boolean = false;
            if(max==0) {
                isFloat = true;
                max = 2;
            }
            for (var i=1; i<=max; i++) {
                _circles.push((isFloat) ? i/2 : i);
            }
        } else {
            var div:int = 6;
            var realDiv:int = div;
            var nearest:Number = Math.abs((max/div) - Math.round(max/div));
            while(div>4) {
                div--;
                if(Math.abs((max/div) - Math.round(max/div))<nearest) {
                    nearest = Math.abs((max/div) - Math.round(max/div));
                    realDiv = div;
                }
            }
            for (var i=0; i<realDiv; i++) {
                var n:Number = max - (i*Math.round(max/realDiv));
                if(realDiv==4 || (realDiv>4 && n>=2)) {
                    _circles.push(n);
                }

            }
        }
//        var i:int = 6;
//        var nearest:Number = Math.abs((max / i) - Math.round(max / i));
//        var min:int = i;
//        if (max < 2) {
//            max = 2;
//            min = 2;
//        } else {
//            while (i > 4) {
//                i--;
//                if (Math.abs((max / i) - Math.round(max / i)) < nearest) {
//                    nearest = Math.abs((max / i) - Math.round(max / i));
//                    min = i;
//                }
//            }
//        }
//        for (i = 0; i < min; i++) {
//            trace(_windSpeed, ":", max, min, i, Math.round(max / min));
//            var n:Number = max - (i * Math.round(max / min));
//            if (n >= 1) {
//                _circles.push(n);
//            }
//        }
    }

    public function drawCircles():void {
        _circle.graphics.clear();
        calculateCircles();
        _circle.graphics.lineStyle(2, 0x333333);
        for (var i = 0; i < _circles.length; i++) {
            if((_circles[i]*_pixelPerSpeed)<=PolarLayer.DIAMETER) {
                _circle.graphics.drawCircle(PolarLayer.DIAMETER, PolarLayer.DIAMETER, _circles[i] * _pixelPerSpeed);
            }
        }
    }

    public function setLabel(texts:Vector.<TextField>):void {
        for (var i:int = 0; i < texts.length; i++) {
            if (_circles != null && i < _circles.length && (_circles[i]*_pixelPerSpeed)<=PolarLayer.DIAMETER) {
                texts[i].visible = true;
                texts[i].text = (Math.round(_circles[i] * 10) / 10).toString();
                texts[i].x = PolarLayer.DIAMETER + 2;
                texts[i].y = PolarLayer.DIAMETER - ((_circles[i] * _pixelPerSpeed) + 14);
            } else {
                texts[i].visible = false;
            }
        }
    }

    public function get wind():Sprite {
        return _wind;
    }

    public function get dot():Sprite {
        return _dot;
    }

    public function get circle():Sprite {
        return _circle;
    }

    public function get maxSpeedForWind():Number {
        return _maxSpeedForWind;
    }

    public function get pixelPerSpeed():Number {
        return _pixelPerSpeed;
    }

    public function resetTimer():void {
        PolarContainer.instance.resetPolarCalculatorTimer();
    }

    public function get changed():Boolean {
        return _changed;
    }

    public function set changed(value:Boolean):void {
        _changed = value;
    }

    public function drawPolar():void {
        clearPolarAndVmg();
        if (visible) {
            setForceDots();
        }
        if (_windSpeed >= 0 && _windSpeed < PolarTable.MAX_WINDSPEED) {
            var polarTable:PolarTable = PolarContainer.instance.polarTableFromFile;

            // DRAW POLAR
            beginPolar();
            for (var angle:int = 0; angle < 360; angle++) {
                var pbs:PolarBoatSpeed = polarTable.getValueForWSpeedAndDirection(_windSpeed, angle);
                if (pbs == null) {
                    continue;
                }
                addPolar(pbs.cardinalHardCalculated, angle);
//                addCalculatedDots(pbs, angle);
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

    private function clearPolarAndVmg():void {
        _polar.graphics.clear();
        _vmg.graphics.clear();
        _dot.graphics.clear();
    }

    protected function beginPolar():void {
        _polar.graphics.lineStyle(3, _color);
        _commands.push(GraphicsPathCommand.MOVE_TO);
        _coords.push(PolarLayer.DIAMETER);
        _coords.push(PolarLayer.DIAMETER);
    }

    protected function addPolar(speed:Number, direction:Number):void {
        if (speed === 0 || direction === 0) {
            return;
        }
        _commands.push(GraphicsPathCommand.LINE_TO);
        var x:Number = speed * _pixelPerSpeed * Math.cos((direction - 90) * RAD) + PolarLayer.DIAMETER;
        var y:Number = speed * _pixelPerSpeed * Math.sin((direction - 90) * RAD) + PolarLayer.DIAMETER;
        _coords.push(x);
        _coords.push(y);
    }

    protected function endPolar():void {
        _polar.graphics.drawPath(_commands, _coords);
        _commands.length = 0;
        _coords.length = 0;
    }

    protected function addVmg(speed:Number, direction:Number):void {
        _vmg.graphics.lineStyle(2, _color);
        _vmg.graphics.beginFill(0xffffff);
        _vmg.graphics.drawCircle(speed * _pixelPerSpeed * Math.cos((direction - 90) * RAD) + PolarLayer.DIAMETER, speed * _pixelPerSpeed * Math.sin((direction - 90) * RAD) + PolarLayer.DIAMETER, 4);
        _vmg.graphics.endFill();
    }


    public function get empty():Boolean {
        return _empty;
    }


    public function addClickedPoint(p:Point):void {
        this._empty = false;
        var tempWidth:Number = p.x - PolarLayer.DIAMETER;
        var tempHeight:Number = p.y - PolarLayer.DIAMETER;
        var dist:Number = Math.sqrt(Math.pow(tempWidth, 2) + Math.pow(tempHeight, 2));
        var speed:Number = Math.round((dist / _pixelPerSpeed) * 100) / 100;
        var angle:Number = calculateAngle(tempHeight, tempWidth);
        angle -= angle % 5;
        if (speed <= _maxSpeedForWind && speed>=SPEED_MIN && speed<=SPEED_MAX) {
            setBoatSpeedForActualLayer(speed, angle);
        }
    }

    private function calculateAngle(tempHeight:Number, tempWidth:Number):Number {
        var angle:Number = Math.atan2(tempHeight, tempWidth);
        if (tempWidth >= 0 && tempHeight >= 0) {
            angle = 90 + angle / (Math.PI / 180)
        } else if (tempWidth < 0 && tempHeight < 0) {
            angle = 450 + angle / (Math.PI / 180)
        } else if (tempWidth < 0 && tempHeight >= 0) {
            angle = 90 + angle / (Math.PI / 180)
        } else {
            angle = 90 + angle / (Math.PI / 180)
        }
        return Math.floor(angle);
    }

    public function removeForceDot(p:Point):void {
        var tempWidth:Number = p.x - PolarLayer.DIAMETER;
        var tempHeight:Number = p.y - PolarLayer.DIAMETER;
        var angle:Number = calculateAngle(tempHeight, tempWidth);
        var pbs:PolarBoatSpeed = PolarContainer.instance.polarTableFromFile.table[_windSpeed][angle]
        if (pbs.baseCalculated == 0) {
            for (var i:int = angle - 2; i <= angle + 1; i++) {
                pbs = PolarContainer.instance.polarTableFromFile.table[_windSpeed][i]
                if (pbs.baseCalculated != 0) {
                    setBoatSpeedForActualLayer(0, i);
                    break;
                }
            }
        } else {
            setBoatSpeedForActualLayer(0, angle);
        }
    }
}
}
