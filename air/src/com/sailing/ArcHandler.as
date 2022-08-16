/**
 * Created by seamantec on 26/02/14.
 */
package com.sailing {
import com.sailing.instruments.BaseInstrument;

import flash.display.CapsStyle;
import flash.display.DisplayObjectContainer;
import flash.display.GraphicsPathCommand;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class ArcHandler {

    private const TORAD:Number = Math.PI/180;
    private const NULLRAD:Number = 2*Math.PI*(-1);
    private const QUARTERRAD:Number = 0.5*Math.PI*(-1);
    private const FPS:Number = 30;
    private const ONEFRAME:Number = 1000/FPS;

    private static var _enableTween:Boolean = true;

    private var _mask:DisplayObjectContainer;
    private var _control:BaseInstrument;
    private var _options:Object;
    private var _min:Number;
    private var _max:Number;
    private var _duration:Number;
    private var _length:Number;
    private var _color:uint;
    private var _alpha:Number;
    private var _clockwise:Boolean;

    private var _arc:Shape;
    private var _center:Number;
    private var _radius:Number;

    private var _commands:Vector.<int>;
    private var _coords:Vector.<Number>;

    private var _timer:Timer;
    private var _from:Number;
    private var _to:Number;
    private var _prevTo:Number;
    private var _currentTo:Number;

    public function ArcHandler(mask:DisplayObjectContainer, control:BaseInstrument, options:Object = null) {
        _mask = mask;
        _control = control;
        _options = options;
        _min = 0;
        _max = 360;
        _duration = 0.5;
        _color = 0xffffff;
        _alpha = 1;
        _clockwise = true;
        if(_options!=null) {
            _min = (options.hasOwnProperty("min")) ? Number(options["min"]) : 0;
            if(_min<0) {
                _min = 0;
            }
            _max = (options.hasOwnProperty("max")) ? Number(options["max"]) : 360;
            if(_max>360) {
                _max = 360;
            }
            _duration = (options.hasOwnProperty("duration")) ? Number(options["duration"]) : 0.5;
            _color = (options.hasOwnProperty("color")) ? uint(options["color"]) : 0xffffff;
            _alpha = (options.hasOwnProperty("alpha")) ? Number(options["alpha"]) : 1;
            _clockwise = (options.hasOwnProperty("clockwise")) ? Boolean(options["clockwise"]) : true;
        }

        _length = (_min<_max) ? _max-_min : 360-_min+_max;

        _center = _mask.width/2;
        _radius = 1;

        while(_mask.numChildren>0) {
            _mask.removeChildAt(0);
        }

        _arc = new Shape();
        _arc.x = -_center;
        _arc.y = -_center;
        _arc.graphics.lineStyle(0, _color, _alpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
        _mask.addChild(_arc);

        _commands = new Vector.<int>();
        _coords = new Vector.<Number>();

        _from = (90-_min)*TORAD;
        _prevTo = _from;
    }

    public function forgat(angle:Number, options:Object = null):void {
        var needTween:Boolean = true;
        var speedFactor:Number = 1;
        if(options!=null) {
            _radius = (options.hasOwnProperty("radius")) ? Number(options["radius"]) : 1;
            needTween = (options.hasOwnProperty("needTween")) ? options["needTween"] : true;
            speedFactor = (options.hasOwnProperty("speedRatio")) ? options["speedRatio"] : 1;
            if(options.hasOwnProperty("color")) {
                _color = uint(options["color"]);
                _arc.graphics.lineStyle(0, _color, _alpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
            }
        }

        if(!_enableTween) {
            needTween = false;
        }

        _to = _min + angle;

        if(angle>_length) {
            _to = _max;
        } else if(angle<0 && _clockwise) {
            _to = _min;
        }
        _to = _to*(-1) + 90;

        _to *= TORAD;

        if(needTween) {
            var t:Number = _duration/speedFactor;
            if(_timer==null) {
                _timer = new Timer(t*ONEFRAME, t*FPS);
                _timer.addEventListener(TimerEvent.TIMER, timerHandler, false, 0, true);
            } else {
                if(_timer.currentCount<_timer.repeatCount) {
                    _prevTo = _currentTo;
                }
                _timer.reset();
                _timer.delay = t*ONEFRAME;
                _timer.repeatCount = t*FPS;
            }
            _timer.start();
        } else {
            moveTo(_to);
        }
    }

    private function timerHandler(event:TimerEvent) {
        _currentTo = _prevTo + (_to - _prevTo)*(_timer.currentCount/_timer.repeatCount)
        moveTo(_currentTo);
        if(_timer.currentCount==_timer.repeatCount) {
            _prevTo = _to;
            _currentTo = _prevTo;
        }
    }

    private function moveTo(to:Number) {
        _commands.length = 0;
        _coords.length = 0;

        _arc.graphics.clear();
        _commands.push(GraphicsPathCommand.MOVE_TO);
        _coords.push(_center);
        _coords.push(_center);

        _arc.graphics.beginFill(_color, _alpha);

        drawTo(to);

        _commands.push(GraphicsPathCommand.LINE_TO);
        _coords.push(_center);
        _coords.push(_center);
        _arc.graphics.drawPath(_commands, _coords);
        _arc.graphics.endFill();
    }

    private function lineTo(i:Number):void {
        _commands.push(GraphicsPathCommand.LINE_TO);
        _coords.push(_center + Math.cos(i)*_radius*_center);
        _coords.push(_center - Math.sin(i)*_radius*_center);
    }

    private function drawTo(to:Number):void {
        var i:Number = _from;
        if(_clockwise) {
            while(i>to) {
                lineTo(i);
                i -= TORAD;
            }
        } else {
            var l:Boolean = to>_from;
            while((l) ? i<to : i>to) {
                lineTo(i);
                i = (l) ? (i + TORAD) : (i - TORAD);
            }
        }
    }

    public function get radius():Number {
        return _radius;
    }

    public function set radius(value:Number):void {
        _radius = value;
    }

    public function get min():Number {
        return _min;
    }

    public function get max():Number {
        return _max;
    }

    public function clear():void {
        _arc.graphics.clear();
        _prevTo = _from;
        if(_timer!=null) {
            _timer.reset();
        }
    }

    public static function get enableTween():Boolean {
        return _enableTween;
    }

    public static function set enableTween(value:Boolean):void {
        _enableTween = value;
    }

}
}
