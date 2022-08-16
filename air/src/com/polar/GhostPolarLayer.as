/**
 * Created by seamantec on 12/08/14.
 */
package com.polar {
public class GhostPolarLayer extends PolarLayer {

    public function GhostPolarLayer(wind:Number, maxSpeed:Number, color:uint) {
        super(wind, maxSpeed, color);
    }

    public override function activate(active:Boolean = true):void {
        this.visible = true;
        this.alpha = (active) ? 1 : ALPHA;
        _polar.visible = true;
        _vmg.visible = active;
        _wind.visible = active;
        _circle.visible = false;
    }

    public function hideLayer():void{
        this.visible = false;
    }

    public override function setScale():void {
        _pixelPerSpeed = DIAMETER / _maxSpeed;
    }

    public override function drawCircles():void {
        _circles = getCircles(_maxSpeed);

        _circle.graphics.lineStyle(2, 0x333333);
        for (var i = 0; i < _circles.length; i++) {
            _circle.graphics.drawCircle(DIAMETER, DIAMETER, _circles[i] * _pixelPerSpeed);
        }
    }

    public override function addWind(speed:Number, direction:Number, alpha:Number):void {
        if (speed <= _maxSpeed) {
            _wind.graphics.beginFill(_color, alpha);
            _wind.graphics.drawCircle(speed * _pixelPerSpeed * Math.cos((direction - 90) * RAD) + DIAMETER, speed * _pixelPerSpeed * Math.sin((direction - 90) * RAD) + DIAMETER, 2.5);
            _wind.graphics.endFill();
        }
    }
}
}
