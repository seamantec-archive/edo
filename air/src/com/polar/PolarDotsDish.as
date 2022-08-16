/**
 * Created by pepusz on 2014.04.01..
 */
package com.polar {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.utils.getTimer;

public class PolarDotsDish extends Sprite {
    private static const FORCE_DOTS_ANGLE:uint = 5;
    public static const DIAMETER_OFFSET:int = 50;
    private var _colorCodes:Vector.<uint>;
    private var _layers:Vector.<PolarDotLayer>;
    private var _forceDots:Vector.<PolarForceDot>;

    private var _texts:Vector.<TextField>;
    private var _prevWind:uint = 0;
    private var _forceDotsSprite:Sprite;
    private var _allCirclesSprite:Sprite;

    private var _circles:Sprite;

    private var _allActive:Boolean = true;
    private var _maxSpeedForAll:Number;

    public function PolarDotsDish() {
        _layers = new Vector.<PolarDotLayer>();
        _texts = new Vector.<TextField>();

        fillColorCodes();
        initDish();
        initForceDots();
        initLayers();
//        setChildIndex(_forceDotsSprite, numChildren - 1);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_EVENT, handleLivePolarData, false, 0, true);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_RESET_EVENT, PolarResetEventHandler, false, 0, true);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_CLOUD_READY, PolarLogReadyEventHandler, false, 0, true);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_FILE_LOADED, PolarFileLoadedEventHandler, false, 0, true);
        this.addEventListener(MouseEvent.CLICK, doubleClickHandler, false, 0, true);
    }

    private function initForceDots():void {
        _forceDotsSprite = new Sprite();
        _forceDotsSprite.visible = false;
        _forceDotsSprite.graphics.beginFill(0xffffff, 0);
        _forceDotsSprite.graphics.drawRect(0, DIAMETER_OFFSET, 2 * PolarLayer.DIAMETER, 2 * PolarLayer.DIAMETER);
        _forceDotsSprite.graphics.endFill();
        this.addChild(_forceDotsSprite);

        _forceDots = new Vector.<PolarForceDot>(360, true);
        for (var i:int = 0; i < 360; i++) {
            var forceDot:PolarForceDot = new PolarForceDot(i, this);
            _forceDots[i] = forceDot;
            _forceDotsSprite.addChildAt(forceDot, 0);
        }
    }

    private function initDish():void {
        this.graphics.beginFill(0xffffff, 0);
        this.graphics.drawCircle(PolarLayer.DIAMETER, PolarLayer.DIAMETER, PolarLayer.DIAMETER);
        this.graphics.endFill();
        this.x = -PolarLayer.DIAMETER;
        this.y = -PolarLayer.DIAMETER + DIAMETER_OFFSET;

        _circles = new Sprite();
        _circles.graphics.beginFill(0xffffff, 0);
        _circles.graphics.drawCircle(PolarLayer.DIAMETER, PolarLayer.DIAMETER, PolarLayer.DIAMETER);
        _circles.graphics.endFill();
        this.addChild(_circles);
    }

    private function initLayers():void {
        for (var i:int = 0; i < PolarTable.MAX_WINDSPEED; i++) {
            var layer:PolarDotLayer = new PolarDotLayer(i, _colorCodes[i], _forceDots);
            layer.loadPointsFromContainer();
            _layers.push(layer);
            _circles.addChild(layer.circle);
            this.addChild(layer);
        }
    }

    public function setFilter(windSpeed:uint):void {
        if(_allActive) {
            _allActive = false;
            _allCirclesSprite.visible = false;
            _forceDotsSprite.visible = false;
            for(var i:int=0; i<_layers.length; i++) {
                _layers[i].deactivate();
            }
        } else {
            _layers[_prevWind].deactivate();
            _forceDotsSprite.visible = true;
        }
        if (windSpeed > 0 && windSpeed < PolarTable.MAX_WINDSPEED) {
            _layers[windSpeed].activate();
            //if(!_layers[windSpeed].empty) {
                _layers[windSpeed].setLabel(_texts);
            //}
        }
        _prevWind = windSpeed;
    }

    public function activateAll():void {
        _allActive = true;
        _forceDotsSprite.visible = false;
        redrawAllCircles();
        for(var i:int=0; i<_layers.length; i++) {
            _layers[i].activate(true, true);
        }
    }

    public function autoArrange():void {
        setLayersChanged();
        _layers[_prevWind].autoArrange();
    }

    public function removeForceDotsAtLayer():void {
        setLayersChanged();
        _layers[_prevWind].removeForceDots();
    }

    public function setLayersChanged():void {
        for(var i:int=0; i<_layers.length; i++) {
            if(i!=_prevWind) {
                _layers[i].changed = true;
            }
        }
    }

    private function clear():void {
        for (var i:int = 0; i < _layers.length; i++) {
            _layers[i].clear(true);
        }
    }

    private function fillColorCodes():void {
        _colorCodes = new <uint>[];
        _colorCodes[0] = 0x0042ff;
        _colorCodes[1] = 0x0059ff;
        _colorCodes[2] = 0x0074ff;
        _colorCodes[3] = 0x0094ff;
        _colorCodes[4] = 0x00b1ff;
        _colorCodes[5] = 0x00ceff;
        _colorCodes[6] = 0x00e7ff;
        _colorCodes[7] = 0x00fcfb;
        _colorCodes[8] = 0x00ffcb;
        _colorCodes[9] = 0x00ffaf;
        _colorCodes[10] = 0x00ff8f;
        _colorCodes[11] = 0x00ff50;
        _colorCodes[12] = 0x00ff00;
        _colorCodes[13] = 0x70ff00;
        _colorCodes[14] = 0x91ff00;
        _colorCodes[15] = 0xb0ff00;
        _colorCodes[16] = 0xcdff00;
        _colorCodes[17] = 0xe6ff00;
        _colorCodes[18] = 0xfcfa00;
        _colorCodes[19] = 0xffdc00;
        _colorCodes[20] = 0xffb900;
        _colorCodes[21] = 0xff9300;
        _colorCodes[22] = 0xff6c00;
        _colorCodes[23] = 0xff4600;
        _colorCodes[24] = 0xff2200;
        _colorCodes[25] = 0xff0504;
        _colorCodes[26] = 0xff0044;
        _colorCodes[27] = 0xff0093;
        _colorCodes[28] = 0xff00bb;
        _colorCodes[29] = 0xff00dd;
        _colorCodes[30] = 0xfd00f9;
    }

    public function get layers():Vector.<PolarDotLayer> {
        return _layers;
    }

    public function get texts():Vector.<TextField> {
        return _texts;
    }

    public function addText(field:TextField):void {
        field.x = 0;
        field.y = 0;
        this.addChildAt(field, this.getChildIndex(_circles)+1);
        _texts.push(field);
    }

    public function sortChildren():void {
        this.setChildIndex(_forceDotsSprite, this.numChildren - 1);
    }

    public function hideTexts():void {
        for (var i:int = 0; i < _texts.length; i++) {
            _texts[i].visible = false;
        }
    }

    private function handleLivePolarData(event:PolarEvent):void {
        if (event.data.windSpeed >= 0 && event.data.windSpeed < PolarTable.MAX_WINDSPEED) {
            _layers[event.data.windSpeed].loadPointsFromContainer();
            if(_prevWind==event.data.windSpeed) {
                if(_allActive) {
                    if(_layers[event.data.windSpeed].maxSpeedForWind>_maxSpeedForAll) {
                        redrawAllCircles();
                        activateAll();
                    }
                } else {
                    _layers[event.data.windSpeed].setLabel(_texts);
                }
            }

        }
    }

    private function PolarLogReadyEventHandler(event:PolarEvent):void {
        for (var i:int = 0; i < _layers.length; i++) {
            _layers[i].loadPointsFromContainer();
        }
        if(_layers[_prevWind].empty) {
            for(var i:int=0; i<_texts.length; i++) {
                _texts[i].visible = false;
            }
        } else {
            _layers[_prevWind].setLabel(_texts);
        }
        if(_allActive) {
            redrawAllCircles();
            activateAll();
        }
    }

    private function PolarResetEventHandler(event:PolarEvent):void {
        clear();
        recalculateLayers();
    }

    private function recalculateLayers():void {
        for (var i:int = 0; i < _layers.length; i++) {
            if(!_layers[i].changed) {
                _layers[i].redrawPolar();
            }
        }
        if(_layers[_prevWind].empty) {
            for(var i:int=0; i<_texts.length; i++) {
                _texts[i].visible = false;
            }
        } else {
            _layers[_prevWind].setLabel(_texts);
        }
        if(_allActive) {
            redrawAllCircles();
            activateAll();
        }
    }

    private function PolarFileLoadedEventHandler(event:PolarEvent):void {
        recalculateLayers();
    }

    private var lastClick:uint = 0;

    private function doubleClickHandler(event:MouseEvent):void {
        if (getTimer() - lastClick < 300) {
            var p:Point = this.globalToLocal(new Point(event.stageX, event.stageY))

            if (event.target is PolarForceDot) {
                _layers[_prevWind].removeForceDot(new Point(Math.round(event.target.x) + PolarForceDot.SIZE, Math.round(event.target.y) + PolarForceDot.SIZE))
            } else {
                _layers[_prevWind].addClickedPoint(p);
            }
        }
        lastClick = getTimer();
    }

    public function redrawAllCircles():void {
        var circles:Vector.<Number> = new Vector.<Number>();
        _maxSpeedForAll = getMaxSpeed();
        var pixelPerSpeed:Number = PolarLayer.DIAMETER/_maxSpeedForAll;
        var max:Number = Math.floor(_maxSpeedForAll);
        if(max<=6) {
            var isFloat:Boolean = false;
            if(max==0) {
                isFloat = true;
                max = 2;
            }
            for (var i=1; i<=max; i++) {
                circles.push((isFloat) ? i/2 : i);
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
                    circles.push(n);
                }

            }
        }

        if(_allCirclesSprite==null) {
            _allCirclesSprite = new Sprite();
            _circles.addChild(_allCirclesSprite);
        }
        _allCirclesSprite.visible = true;
        _allCirclesSprite.graphics.clear();
        _allCirclesSprite.graphics.beginFill(0xffffff, 0);
        _allCirclesSprite.graphics.drawRect(0, DIAMETER_OFFSET, 2 * PolarLayer.DIAMETER, 2 * PolarLayer.DIAMETER);
        _allCirclesSprite.graphics.endFill();
        _allCirclesSprite.graphics.lineStyle(2, 0x333333);
        for (var i = 0; i < circles.length; i++) {
            if((circles[i]*pixelPerSpeed)<=PolarLayer.DIAMETER) {
                _allCirclesSprite.graphics.drawCircle(PolarLayer.DIAMETER, PolarLayer.DIAMETER, circles[i] * pixelPerSpeed);
            }
        }

        var step:Number = (circles.length>1) ? ((Math.abs(circles[0]-circles[1])*pixelPerSpeed)/2) : ((circles[0]*pixelPerSpeed)/2);
        for (var i:int = 0; i < _texts.length; i++) {
            if (circles != null && i < circles.length && (circles[i]*pixelPerSpeed)<=PolarLayer.DIAMETER) {
                _texts[i].visible = true;
                _texts[i].text = (Math.round(circles[i] * 10) / 10).toString();
                _texts[i].x = PolarLayer.DIAMETER + 2;
                _texts[i].y = PolarLayer.DIAMETER - ((circles[i] * pixelPerSpeed) + 14);
            } else {
                _texts[i].visible = false;
            }
        }
    }

    public function get circles():Sprite {
        return _circles;
    }

    public function get maxSpeedForAll():Number {
        return _maxSpeedForAll;
    }

    private function getMaxSpeed():Number {
        var speed:Number = 0;
        for(var i:int=0; i<_layers.length; i++) {
            if(!_layers[i].empty && _layers[i].maxSpeedForWind>speed) {
                speed = _layers[i].maxSpeedForWind;
            }
        }

        return speed;
    }
}
}
