package com.polar {

import com.common.SpeedToUse;
import com.sailing.SailData;
import com.utils.Blinker;

import flash.display.Sprite;
import flash.text.TextField;

public class PolarInstrument extends Sprite {
    public static const GHOST_MODE:int = 0;
    public static const AUTO_MODE:int = 1;
    private const RAD:Number = Math.PI / 180;

    private var _instrument:Polar;
    private var _colorCodes:Vector.<uint>;
    private var _texts:Vector.<TextField>;
    private var _ghostLayers:Vector.<GhostPolarLayer>;
    private var _autoLayers:Vector.<AutoPolarLayer>;

    private var _circles:Sprite;

    private var _maxBoatSpeed:Number;
    private var _maxWindLayerIndex:int;

    private var _windSpeed:Number;
    private var _prevWindSpeed:Number;

    private var _pointer:Sprite;

    private var _vhw:Number;
    private var _sog:Number;
    private var _speed:Number;
    private var _direction:Number;

    private var _mode:int = GHOST_MODE;

    private var _hasData:Boolean = false;
    private var _ready:Boolean = false;

    public function PolarInstrument(instrument:Polar) {
        super();

        _instrument = instrument;
        _texts = new Vector.<TextField>();
        _ghostLayers = new Vector.<GhostPolarLayer>();
        _autoLayers = new Vector.<AutoPolarLayer>();

        this.graphics.beginFill(0xffffff, 0);
        this.graphics.drawRect(0, 0, 2 * PolarLayer.DIAMETER, 2 * PolarLayer.DIAMETER);
        this.graphics.endFill();
        this.x = -PolarLayer.DIAMETER;
        this.y = -PolarLayer.DIAMETER;

        _circles = new Sprite();
        _circles.graphics.beginFill(0xffffff, 0);
        _circles.graphics.drawCircle(PolarLayer.DIAMETER, PolarLayer.DIAMETER, PolarLayer.DIAMETER);
        _circles.graphics.endFill();
        this.addChild(_circles);

        _maxWindLayerIndex = -1;
        _windSpeed = -1;
        _prevWindSpeed = -1;

        fillColorCodes();

        if (PolarContainer.instance.polarTableFromFile != null) {
            addPolarFromFile();
        }
        setMode();

        _ready = true;
    }

    private function addPolarFromFile():void {
        var ghostLayer:GhostPolarLayer;
        var autoLayer:AutoPolarLayer;
        var tempMaxForWind:Number = setMaxBoatSpeed();
        clearLayers();
        for (var wind:int = 0; wind < PolarTable.MAX_WINDSPEED; wind++) {
            if (hasLayersWindLayer(wind)) {
                ghostLayer = _ghostLayers[wind];
                ghostLayer.reInit(_maxBoatSpeed);
                autoLayer = _autoLayers[wind];
                autoLayer.reInit(_maxBoatSpeed);
            } else {
                ghostLayer = new GhostPolarLayer(wind, _maxBoatSpeed, _colorCodes[wind]);
                _ghostLayers.push(ghostLayer);
                autoLayer = new AutoPolarLayer(wind, _maxBoatSpeed, _colorCodes[wind]);
                _autoLayers.push(autoLayer);
                _circles.addChild(autoLayer.circle);
            }
            if (ghostLayer.exists) {
                _ghostLayers[wind].drawAllDots();
                _autoLayers[wind].drawAllDots();
                if (!hasInstrumentWindLayer(wind)) {
                    this.addChild(ghostLayer);
                    this.addChild(autoLayer);
                }
                if (ghostLayer.maxPolarSpeed == tempMaxForWind) {
                    _maxWindLayerIndex = wind;
                    var circle:Sprite = new Sprite();
                    circle.graphics.copyFrom(ghostLayer.circle.graphics);
                    _circles.addChildAt(circle, 0);
                }
            }
        }

        setMode();

    }

    private function setMaxBoatSpeed():Number {
        _maxBoatSpeed = PolarContainer.instance.polarTableFromFile.getAbsoluteMax();
        var tempMaxForWind:Number = _maxBoatSpeed;

        for (var wind:int = 0; wind < PolarTable.MAX_WINDSPEED; wind++) {
            if (_maxBoatSpeed < setMaxBoatSpeedFromDotsLayer(wind)) {
                _maxBoatSpeed = setMaxBoatSpeedFromDotsLayer(wind);
            }
        }
        return tempMaxForWind;
    }

    private function setMaxBoatSpeedFromDotsLayer(wind:int):Number {
        var dots:PolarDataWindLayer = PolarContainer.instance.dataContainer.getPolarDataWindLayerAtWind(wind);
        if (dots != null) {
            if ((dots.maxSpeed > _maxBoatSpeed)) {
                return dots.maxSpeed;
            }
        }
        return 0;
    }

    //TODO refactor
    private function lineTo(speed:Number, direction:Number):void {
        if (_pointer == null) {
            _pointer = new Sprite();
            this.addChild(_pointer);
        }

        if (_windSpeed >= 0 && _windSpeed < PolarTable.MAX_WINDSPEED && _ghostLayers.length > 0 && _ghostLayers[_windSpeed].exists && _ghostLayers[_maxWindLayerIndex].exists) {
            _pointer.visible = true;
            _pointer.graphics.clear();
            _pointer.graphics.lineStyle(4, 0xffd200);
            _pointer.graphics.moveTo(PolarLayer.DIAMETER, PolarLayer.DIAMETER);
            var layer:PolarLayer;
            if (_mode == GHOST_MODE) {
                layer = _ghostLayers[_maxWindLayerIndex];
                layer.setScale();
            } else {
                layer = _autoLayers[_windSpeed];
            }
            var v:Number = speed * layer.pixelPerSpeed;
            if (v > PolarLayer.DIAMETER) {
                v = PolarLayer.DIAMETER;
                _instrument.setBigyo(true, direction);
            } else {
                _instrument.setBigyo(false);
            }

            _pointer.graphics.lineTo(v * Math.cos((direction - 90) * RAD) + PolarLayer.DIAMETER, v * Math.sin((direction - 90) * RAD) + PolarLayer.DIAMETER);
        } else {
            _pointer.visible = false;
            _instrument.setBigyo(false);
        }
    }

    public function lineToCurrent():void {
        lineTo(_speed, _direction);
    }

    public function loadPolar():void {

        if (_pointer != null) {
            Blinker.removeObject(_pointer);
            _pointer.graphics.clear();
        }

        addPolarFromFile();
        if (hasLayersWindLayer(_windSpeed)) {
            lineToCurrent();
        }
    }

    //TODO megvizsgalni azt az esetet amikor nincs adat de van szel kivalasztva...
    public function setMode():void {
//        if (_hasData) {
        for (var i:int = 0; i < _ghostLayers.length; i++) {
            if (_ghostLayers[i].exists) {
                if (i == _windSpeed) {
                    activateLayer(i)
                } else {
                    deactivateLayer(i);
                }
            }
        }
//        } else {
//            deactivateAllLayer();
//        }
        setCircles();
        setLayerLabel();
    }

    private function setCircles():void {
        if (_mode == GHOST_MODE) {
            setGhostCircle(true);
        } else {
            setGhostCircle(false);
        }
    }


//    public function logLoadReady():void {
//        resetCloud();
//        _speed = (SpeedToUse.instance.selected == SpeedToUse.STW) ? _vhw : _sog;
//        for (var i:int = 0; i < PolarTable.MAX_WINDSPEED; i++) {
//            logLoadReadyForWind(i);
//            if (_pointer != null && _pointer.visible && _ghostLayers[i].exists) {
////                lineTo(_speed, _direction);
//                lineToCurrent();
//            }
//        }
//    }

    public function cloudReadyHandler():void {
        resetCloud();
        setMaxBoatSpeed();
        clearGhostLayers();
        for (var wind:int = 0; wind < PolarTable.MAX_WINDSPEED; wind++) {
            _ghostLayers[wind].reInit(_maxBoatSpeed);
            _ghostLayers[wind].drawAllDots();
            _autoLayers[wind].drawAllDots();
        }
        setMode();
    }

//
//    public function logLoadReadyForWind(wind:int):void {
//        if (_ready && wind >= 0 && wind < PolarTable.MAX_WINDSPEED && _ghostLayers[wind].exists) {
//            drawAllDotsForWind(wind);
//        }
//    }

    public function handleLiveData(wind:int):void {
        if (_ready && wind >= 0 && wind < PolarTable.MAX_WINDSPEED && _ghostLayers[wind].exists) {
            var tempMaxSpeed:Number = _maxBoatSpeed;
            setMaxBoatSpeed();
            if (tempMaxSpeed < _maxBoatSpeed) {
                cloudReadyHandler();
            } else {
                _ghostLayers[wind].drawAllDots();
                _autoLayers[wind].drawAllDots();
            }

        }
    }

    private function setGhostCircle(enable:Boolean):void {
        if (enable) {
            _circles.getChildAt(0).visible = true;
            for (var i:int = 1; i < _circles.numChildren; i++) {
                _circles.getChildAt(i).visible = false;
            }
        } else {
            _circles.getChildAt(0).visible = false;
        }
    }

//    private function drawAllDotsForWind(wind:int):void {
//        if (_ghostLayers[wind].maxSpeed > _maxBoatSpeed) {
////            _ghostLayers[wind].setMaxSpeedFromDots();
//            _maxBoatSpeed = _ghostLayers[wind].maxSpeed;
//            clearLayers();
//            for (var i:int = 0; i < PolarTable.MAX_WINDSPEED; i++) {
//                _ghostLayers[i].reInit(_maxBoatSpeed);
//                _autoLayers[i].reInit(_maxBoatSpeed);
//            }
//
//        }
//        _ghostLayers[wind].drawAllDots();
//        _autoLayers[wind].drawAllDots();
//
//    }

    private function clearLayers():void {
        clearAutoLayers();
        clearGhostLayers();
    }


    private function clearAutoLayers():void {
        for (var i:int = 0; i < _ghostLayers.length; i++) {
            if (_ghostLayers[i].exists) {
                _autoLayers[i].clearPolarAndCloudVmgAndCircles();
            }
        }
    }

    private function clearGhostLayers():void {
        for (var i:int = 0; i < _ghostLayers.length; i++) {
            if (_ghostLayers[i].exists) {
                _ghostLayers[i].clearPolarAndCloudVmgAndCircles();
            }
        }
    }


    public function resetCloud():void {
        for (var i:int = 0; i < _ghostLayers.length; i++) {
            if (_ghostLayers[i].exists) {
                _ghostLayers[i].wind.graphics.clear();
                _autoLayers[i].wind.graphics.clear();
            }
        }
    }

    private function hasLayersWindLayer(windSpeed:Number):Boolean {
        for (var i:int = 0; i < _ghostLayers.length; i++) {
            if (_ghostLayers[i].windSpeed === windSpeed) {
                return true;
            }
        }
        return false;
    }

    private function hasInstrumentWindLayer(windSpeed:Number):Boolean {
        for (var i:int = 0; i < this.numChildren; i++) {
            var l:PolarLayer = this.getChildAt(i) as PolarLayer;
            if (l != null && l.windSpeed === windSpeed) {
                return true;
            }
        }
        return false;
    }

    private function deactivateAllLayer():void {
        for (var i = 0; i < _ghostLayers.length; i++) {
            if (_ghostLayers[i].exists) {
                deactivateLayer(i);
            }
        }

        if (_mode == GHOST_MODE) {
            setGhostCircle(true);
        }
    }

    public function addText(field:TextField):void {
        field.x = 0;
        field.y = 0;
        this.addChildAt(field, this.getChildIndex(_circles) + 1);
        _texts.push(field);
    }

    public function clearLabel():void {
        for (var i:int = 0; i < _texts.length; i++) {
            _texts[i].visible = false;
        }
    }

    public function setLayerLabel():void {
        if (_mode == GHOST_MODE) {
            setMaxLabel();
        } else {
            if (_windSpeed >= 0 && _windSpeed < PolarTable.MAX_WINDSPEED && _ghostLayers[_windSpeed].exists) {
                _autoLayers[_windSpeed].setLabel(_texts);
            } else {
                clearLabel();
            }
        }
    }

    private function setMaxLabel():void {
        if (_maxWindLayerIndex >= 0) {
            _ghostLayers[_maxWindLayerIndex].setLabel(_texts);
        }
    }

    public function updateDatas(datas:SailData):void {
        _hasData = datas.truewindc.isValid() && datas.truewindc.isPreValid() && ((SpeedToUse.instance.selected == SpeedToUse.STW) ? (datas.vhw.isValid() && datas.vhw.isPreValid()) : (datas.positionandspeed.isValid() && datas.positionandspeed.isPreValid()));
        if (_hasData) {
            Blinker.removeObject(_pointer);
            Blinker.removeObject(_instrument.analog.bigyo);

            _prevWindSpeed = _windSpeed;
            _windSpeed = Math.round(datas.truewindc.windSpeed.getPureData());

            if (datas.vhw != null) {
                _vhw = datas.vhw.waterSpeed.getPureData();
            }
            if (datas.positionandspeed != null) {
                _sog = datas.positionandspeed.sog.getPureData();
            }
            _speed = (SpeedToUse.instance.selected == SpeedToUse.STW) ? _vhw : _sog;
            _direction = datas.truewindc.windDirection.getPureData();
//            trace("speed and direction", _speed, _direction)
//            lineTo(_speed, _direction);
            lineToCurrent();

            setFilter();
        }
    }

    public function setFilter():void {
        if (_windSpeed != _prevWindSpeed) {
            if (_prevWindSpeed >= 0 && _prevWindSpeed < PolarTable.MAX_WINDSPEED && _ghostLayers[_prevWindSpeed].exists) {
                deactivateLayer(_prevWindSpeed)
            }
            if (_windSpeed >= 0 && _windSpeed < PolarTable.MAX_WINDSPEED && _ghostLayers[_windSpeed].exists) {
                activateLayer(_windSpeed);
            } else {
                if (_mode == GHOST_MODE) {
                    setMaxLabel();
                } else {
                    clearLabel();
                }
            }
        }
    }

    private function activateLayer(wind:int):void {
        if (_mode == GHOST_MODE) {
            _ghostLayers[wind].activate();
            _autoLayers[wind].deactivate();
        } else {
            _ghostLayers[wind].hideLayer()
            _autoLayers[wind].activate();
        }
        setLayerLabel();

    }

    private function deactivateLayer(wind:int):void {
        if (_mode == GHOST_MODE) {
            _ghostLayers[wind].deactivate();
        } else {
            _ghostLayers[wind].hideLayer();
        }
        _autoLayers[wind].deactivate();
    }

    public function setInvalid():void {
        Blinker.removeObject(_pointer);

        _pointer.graphics.clear();
        _hasData = false;
        _prevWindSpeed = -1;
        _windSpeed = -1;

        deactivateAllLayer();
        if (_mode == AUTO_MODE) {
            clearLabel();
        }
    }

    public function setPreInvalid():void {
        Blinker.addObject(_pointer);
    }

    public function set mode(value:int):void {
        _mode = value;
    }

    public function get mode():int {
        return _mode;
    }

    public function get ready():Boolean {
        return _ready;
    }

    public function get hasData():Boolean {
        return _hasData;
    }

    public function get windSpeed():Number {
        return _windSpeed;
    }

    public function get prevWindSpeed():Number {
        return _prevWindSpeed;
    }

    public function get pointer():Sprite {
        return _pointer;
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
}
}
