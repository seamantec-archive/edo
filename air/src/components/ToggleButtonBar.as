/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/8/13
 * Time: 10:42 AM
 * To change this template use File | Settings | File Templates.
 */
package components {

import flash.display.Sprite;
import flash.events.MouseEvent;

public class ToggleButtonBar extends Sprite {

    protected var _labelsArray:Array;
    protected var _buttonsArray:Array;
    protected var _selectedIndex:int = 0;
    protected var _labelFontSize:int = 12;
    protected var _enableFlag:Boolean = true;
    protected var _shortBtns:Boolean = true;
    protected var _eventContainer:Array;


    public function ToggleButtonBar(xIn:int, yIn:int, labelIn:Array = null, lblFontSize:int = 12, short:Boolean = true) {
        _labelFontSize = lblFontSize;
        _labelsArray = labelIn;
        _buttonsArray = new Array();
        _shortBtns = short;
        if (_labelsArray != null) {
            for (var i:int; i < _labelsArray.length; i++) {
                addButton(_labelsArray[i]);
            }
        }
        this.x = xIn;
        this.y = yIn;
        this.visible = true;

        _eventContainer = new Array();
    }

    public function addButton(lbl:String) {
        lbl == "" ? _enableFlag = false : _enableFlag = true;
        _buttonsArray.push(new ToggleButton(_buttonsArray.length, lbl, labelFontSize, _enableFlag, _shortBtns));
        _buttonsArray[_buttonsArray.length - 1].addEventListener(MouseEvent.CLICK, mouseClickHandler, false, 0, true);
        _buttonsArray[_buttonsArray.length - 1].x = (_buttonsArray.length - 1) * _buttonsArray[_buttonsArray.length - 1].width;
        this.addChild(_buttonsArray[_buttonsArray.length - 1]);
    }

    public function get selectedIndex():int {
        return _selectedIndex;
    }

    public function set selectedIndex(value:int):void {
        _buttonsArray[_selectedIndex].enabled = true;
        _selectedIndex = value;
        _buttonsArray[_selectedIndex].enabled = false;
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        _eventContainer.push({ type: type, listener: listener, useCapture: useCapture, priority: priority, useWeakReference: useWeakReference });
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        for (var i:int = 0; i < _eventContainer.length; i++) {
            var item:Object = _eventContainer[i];
            if (item.type == type && item.listener == listener && item.useCapture == useCapture) {
                _eventContainer.splice(i, 1);
            }
        }
        super.removeEventListener(type, listener, useCapture);
    }

    protected function mouseClickHandler(event:MouseEvent):void {
        if (_buttonsArray[event.target.index].clickable == true) {
            selectedIndex = event.target.index;
        }
    }

    public function get labelFontSize():int {
        return _labelFontSize;
    }


    public function set labelFontSize(value:int):void {
        _labelFontSize = value;
    }

    public function set enabled(value:Boolean):void {
        if (value) {
            selectedIndex = _selectedIndex;

            for (var i:int = 0; i < _eventContainer.length; i++) {
                var event:Object = _eventContainer[i];
                if (!this.hasEventListener(event.type)) {
                    super.addEventListener(event.type, event.listener, event.useCapture, event.priority, event.useWeakReference);
                }
            }
            this.alpha = 1
        } else {
            for (var i:int = 0; i < _eventContainer.length; i++) {
                var event:Object = _eventContainer[i];
                super.removeEventListener(event.type, event.listener, event.useCapture);
            }

            this.alpha = 0.5
        }
        for (var i:int = 0; i < _buttonsArray.length; i++) {
            _buttonsArray[i].enabled = value;
        }
    }
}
}
