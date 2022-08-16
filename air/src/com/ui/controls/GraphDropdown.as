/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.01.
 * Time: 14:58
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import com.events.AppClick;
import com.events.ListElementSelectedEvent;
import com.sailing.WindowsHandler;
import com.store.Statuses;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class GraphDropdown extends Sprite {


    public static const ELEMENT_HEIGHT:int = 22;
    private var _viewContainer:Array = [];
    protected var dragStartDataPoint:Point;
    private var listWidth:int = 129;
    private var _listHeight:int;
    private var dropDownBtn:BitmapButton;
    private var dropDownList:Sprite;
    private var dropDownListContainer:Sprite;
    private var actualY:int = 0;
    private var isDragging:Boolean = false;

    public function GraphDropdown() {
        _listHeight = 100;
        createDropDownBtn();
        createList();
    }

    private function createDropDownBtn():void {
        dropDownBtn = new MedDropDownButton()
        dropDownBtn.addEventListener(MouseEvent.MOUSE_DOWN, dropDownBtn_mouseDownHandler, false, 0, true);
        this.addChild(dropDownBtn);
        WindowsHandler.instance.application.addEventListener(AppClick.APP_CLICK, appClickedHandler, false, 0, true);
    }


    private function setLabelText(text:String):void {
//        dropDownBtn.labelText = text;
//        dropDownBtn.resetStates();
        dropDownBtn.label = text;
    }

    public function resize(h:int) {
        dropDownList.scaleY = 1;
        _listHeight = h;
        setEndingY();
        dropDownList.scrollRect = new Rectangle(0, 0, listWidth, _listHeight);

    }

    public function scaleDownList() {
        dropDownList.scaleY = 0.1;
    }

    public function buttonHeight():Number {
        return dropDownBtn.height;
    }

    public function buttonWidth():Number {
        return dropDownBtn.width;
    }

    private function createList():void {
        dropDownListContainer = new Sprite;

        dropDownListContainer.visible = false;
        dropDownListContainer.y = dropDownBtn.height;
        createBeginning();
        dropDownList = new Sprite();
        dropDownList.graphics.clear();
        dropDownList.graphics.beginFill(0x000000);
        dropDownList.graphics.drawRect(0, 0, listWidth, _listHeight);
        dropDownList.graphics.endFill();
        dropDownList.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
        dropDownList.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
        dropDownList.y = 6;
        dropDownList.scrollRect = new Rectangle(0, 0, listWidth, _listHeight);
        dropDownListContainer.addChild(dropDownList)
        createEnding();
        this.addChild(dropDownListContainer)
    }

    private function mouseWheelHandler(event:MouseEvent):void {
        var delta:Number = -event.delta * 2;
        if (Statuses.isWindows()) {
            delta *= 4;
        }
        scrollBox(delta, false);
    }

    public function elementSelected(data:String, index:int):void {
        if (!isDragging) {
            dispatchEvent(new ListElementSelectedEvent(index, data))
            hideList()
            setLabelText(getLabelByData(data));
        }
    }

    private function hideList():void {
        dropDownListContainer.visible = false;
        dropDownBtn.customEnabled = true;
    }

    //TODO implement
    public function setSelectedIndex(index:int):void {

    }

    public function setSelectedData(data:String):void {
        setLabelText(getLabelByData(data));
    }

    public function getLabelByData(data:String):String {
        for (var i:int = 0; i < _viewContainer.length; i++) {
            if (_viewContainer[i].data === data) {
                return _viewContainer[i].label
                break;
            }

        }
        return "---"
    }

    public function addElement(label:String, data:String):void {
        var view:GraphDropDownElement = new GraphDropDownElement(label, data, this, _viewContainer.length)
        view.y = _viewContainer.length * ELEMENT_HEIGHT;
        view.x = 0;
        _viewContainer.push(view)
        dropDownList.addChild(view);
        setEndingY();
    }

    private function setEndingY():void {
        if (_listHeight < _viewContainer.length * ELEMENT_HEIGHT + 6) {
            ending.y = _listHeight + 6;
        } else {
            ending.y = _viewContainer.length * ELEMENT_HEIGHT + 6
        }
    }

    public function removeElement(data:String):void {
        for (var i:int = 0; i < _viewContainer.length; i++) {
            if (_viewContainer[i].data === data) {
                _viewContainer.splice(i, 1);
                break;
            }
        }
    }

    private function createBeginning():void {
        var b:Sprite = new Sprite();
        b.graphics.clear();
        b.graphics.beginFill(0xc9c9c9);
        b.graphics.drawRoundRectComplex(0, 0, listWidth, 6, 5, 5, 0, 0);
        b.graphics.endFill();
        dropDownListContainer.addChild(b)
    }

    var ending:Sprite

    private function createEnding():void {
        ending = new Sprite();
        ending.graphics.clear();
        ending.graphics.beginFill(0xc9c9c9);
        ending.graphics.drawRoundRectComplex(0, 0, listWidth, 6, 0, 0, 5, 5);
        ending.graphics.endFill();
        ending.y = _listHeight + 6;
        dropDownListContainer.addChild(ending)
    }

    public function mouseDownHandler(event:MouseEvent):void {

        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler), false, 0, true;
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
        dragStartDataPoint = new Point(event.stageX, event.stageY);
    }

    private function mouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        isDragging = false;
    }

    private function mouseMoveHandler(event:MouseEvent):void {
        var currDataPoint:Point = new Point(event.stageX, event.stageY);
        var dy:Number = dragStartDataPoint.y - currDataPoint.y;
        isDragging = true;
        scrollBox(dy);
        dragStartDataPoint = currDataPoint;
    }

    private function scrollBox(dy:Number, needSlowDown:Boolean = true):void {

        var rect:Rectangle = dropDownList.scrollRect;
        // var slowDown:int = (needSlowDown ? 15 : 1)
        rect.y += dy; /// slowDown;
        if (rect.y < 0) {
            rect.y = 0
        } else if (rect.y >= (_viewContainer.length * ELEMENT_HEIGHT - _listHeight)) {
            if (((_viewContainer.length * ELEMENT_HEIGHT) > (_listHeight))) {
                rect.y = _viewContainer.length * ELEMENT_HEIGHT - _listHeight
            } else {
                // trace("alarmlist scrollbox", AlarmWindow.W_HEIGHT - 85, " ", _viewContainer.length * AlarmView.DEF_HEIGHT)
                rect.y = 0
            }
        }
        dropDownList.scrollRect = rect;
    }

    private function dropDownBtn_mouseDownHandler(event:MouseEvent):void {
        dropDownList.scaleY = 1;
        if (dropDownBtn.enabled) {
            dropDownListContainer.visible = !dropDownListContainer.visible;
            if (dropDownListContainer.visible) {
                dropDownBtn.customEnabled = false;
            } else {
                dropDownBtn.customEnabled = true;
            }
        }
    }

    private function appClickedHandler(event:AppClick):void {
        if (event.prevTarget != dropDownBtn) {
            hideList();
        }
    }

    public function set enableButton(value:Boolean):void {
        dropDownBtn.enabled = value;
    }
}
}
