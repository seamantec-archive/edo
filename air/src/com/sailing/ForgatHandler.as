package com.sailing
{
import com.greensock.*;
import com.greensock.plugins.ShortRotationPlugin;
import com.greensock.plugins.TweenPlugin;
import com.sailing.instruments.BaseInstrument;
import com.utils.Blinker;

import flash.display.DisplayObject;
import flash.events.EventDispatcher;

TweenPlugin.activate([ShortRotationPlugin]);


public class ForgatHandler extends EventDispatcher {

        private static var _enableTween:Boolean = true;

        private var _mutato:DisplayObject;
        private var _control:BaseInstrument;
        private var _options:Object;
        private var _min:Number;
        private var _max:Number;
        private var _offsetToZero:Number;
        private var _duration:Number;
        private var _blinker:Boolean;
        private var _length:Number;

        private var _previousAngle:Number, _relativeAngle:Number;

        public function ForgatHandler(mutato:DisplayObject, control:BaseInstrument, options:Object = null) {
            this._mutato = mutato;
            this._control = control;
            this._options = options;
            _offsetToZero = 0;
            _min = 0;
            _max = 360;
            _duration = 0.5;
            _blinker = false;
            if(options!=null) {
                _offsetToZero = (options.hasOwnProperty("offsetToZero")) ? options["offsetToZero"] : 0;
                _min = (options.hasOwnProperty("min")) ? options["min"] : 0;
                _max = (options.hasOwnProperty("max")) ? options["max"] : 360;
                _blinker = (options.hasOwnProperty("blinker")) ? options["blinker"] : false;
                _duration = (options.hasOwnProperty("duration")) ? options["duration"] : 0.5;
            }
            _length = (_min<_max) ? _max-_min : 360-_min+_max;

            _previousAngle = _min;
        }

        public function forgat(angle:Number, options:Object = null):void {
            _mutato.visible = true;

            var realAngle:Number = 0;

            var needTween:Boolean = true;
            var speedFactor:Number = 1;
            if(options!=null) {
                needTween = (options.hasOwnProperty("needTween")) ? options["needTween"] : true;
                speedFactor = (options.hasOwnProperty("speedRatio")) ? options["speedRatio"] : 1;
            }
            if(!_enableTween) {
                needTween = false;
            }

            if(_length==360) {
                if(angle<0) {
                    angle += 360;
                } else if(angle>=360) {
                    angle -= (Math.floor(angle/360)*360);
                }
            }

            _relativeAngle = angle + _offsetToZero;
            //trace(_control + ": " + _length + ", " + angle + ", " + (angle+_min) + ", " + _relativeAngle);
            if(angle>_length) {
                realAngle = _max;
                _relativeAngle = _max;
                moveTo(_max, speedFactor);
                if(_blinker) {
                    Blinker.addDoubleObject(_mutato);
                } else {
                    _mutato.alpha = 0.5;
                }
            } else if(angle<0) {
                realAngle = _min;
                _relativeAngle = _offsetToZero;
                moveTo(_min, speedFactor);
                if(_blinker) {
                    Blinker.addDoubleObject(_mutato);
                } else {
                    _mutato.alpha = 0.5;
                }
            } else {
                realAngle = angle + _min;
                realAngle -= (Math.round(realAngle/360)*360);
                if(realAngle<0) {
                    realAngle += 360;
                }
                //trace(_control + ": " + angle + ", " + realAngle + ", " + _relativeAngle + ", " + _previousAngle);
                if(_min>_max) {
                    if(realAngle<_min && realAngle>_max) {
                        if( (_min-realAngle) < (realAngle-_max) ) {
                            _relativeAngle = _min + _offsetToZero;
                            if(needTween) {
                                moveTo(_min, speedFactor);
                            } else {
                                withoutTween();
                            }
                        } else {
                            _relativeAngle = _max + _offsetToZero;
                            if(needTween) {
                                moveTo(_max, speedFactor);
                            } else {
                                withoutTween();
                            }
                        }
                        if(_blinker) {
                            Blinker.addDoubleObject(_mutato);
                        } else {
                            _mutato.alpha = 0.5;
                        }
                    } else {
                        if(_blinker) {
                            Blinker.removeDoubleObject(_mutato);
                        } else {
                            _mutato.alpha = 1.0;
                        }
                        if(needTween) {
                            moveTo(realAngle, speedFactor);
                        } else {
                            withoutTween();
                        }
                    }
                } else {
                    if(realAngle<_min) {
                        realAngle = _min;
                        _relativeAngle = _min + _offsetToZero;
                        if(needTween) {
                            moveTo(_min, speedFactor);
                        } else {
                            withoutTween();
                        }
                        if(_blinker) {
                            Blinker.addDoubleObject(_mutato);
                        } else {
                            _mutato.alpha = 0.5;
                        }
                    } else if(realAngle>_max) {
                        realAngle = _max;
                        _relativeAngle = _max + _offsetToZero;
                        if(needTween) {
                            moveTo(_max, speedFactor);
                        } else {
                            withoutTween();
                        }
                        if(_blinker) {
                            Blinker.addDoubleObject(_mutato);
                        } else {
                            _mutato.alpha = 0.5;
                        }
                    } else {
                        if(_blinker) {
                            Blinker.removeDoubleObject(_mutato);
                        } else {
                            _mutato.alpha = 1.0;
                        }
                        if(needTween) {
                            moveTo(realAngle, speedFactor);
                        } else {
                            withoutTween();
                        }
                    }
                }
            }

            _previousAngle = realAngle;
        }

        private function moveTo(angle:Number, speedFactor:Number):void {
            if(_previousAngle!=angle || _previousAngle==_min) {
                if(_min>_max && _offsetToZero!=0) {
                    if(_previousAngle==0 && angle>=_min && _offsetToZero>0) {
                        TweenLite.to(_mutato,  _duration/speedFactor, { rotation: _relativeAngle, onUpdate: dispatch });
                    } else if(_previousAngle<=_max && angle==0 && _offsetToZero>0) {
                        TweenLite.to(_mutato,  _duration/speedFactor, { rotation: -180, onUpdate: dispatch });
                    } else if(_previousAngle<=_max && angle>=_min && _offsetToZero>0) {
                        //TweenLite.to(_mutato,  _duration/speedFactor, { rotation: (angle - 360) - (_min-_offsetToZero), onUpdate: dispatch });
                        TweenLite.to(_mutato,  _duration/speedFactor, { rotation: -360 + _relativeAngle, onUpdate: dispatch });
                    } else if(_previousAngle>=_min && angle<=_max && _offsetToZero>0) {
                        //TweenLite.to(_mutato,  _duration/speedFactor, { rotation: (_min-_offsetToZero) + angle, onUpdate: dispatch });
                        TweenLite.to(_mutato,  _duration/speedFactor, { rotation: _relativeAngle, onUpdate: dispatch });
                    } else {
                        TweenLite.to(_mutato, _duration/speedFactor,  { shortRotation: { rotation: _relativeAngle }, onUpdate: dispatch } );
                    }
                } else {
                    if(angle<=_min) {
                        _relativeAngle = _offsetToZero;
                    } else if(angle>=_max) {
                        _relativeAngle = _offsetToZero*(-1);
                    }

                    TweenLite.to(_mutato, _duration/speedFactor,  { shortRotation: { rotation: _relativeAngle }, onUpdate: dispatch } );
                }
            }
        }

        private function dispatch():void {
            dispatchEvent(new ForgatEvent(_mutato, _control));
        }

        private function withoutTween():void {
            TweenLite.killTweensOf(_mutato);
            _mutato.rotation = _relativeAngle;
            dispatch();
        }

        public function get min():Number {
            return _min;
        }

        public function get max():Number {
            return _max;
        }

        public function get offsetToZero():Number {
            return _offsetToZero;
        }

        public function get duration():Number {
            return _duration;
        }

        public function get previousAngle():Number {
            return _previousAngle;
        }

        public static function get enableTween():Boolean {
            return _enableTween;
        }

        public static function set enableTween(value:Boolean):void {
            _enableTween = value;
        }

        public function get mutato():DisplayObject {
            return _mutato;
        }

    }
}

