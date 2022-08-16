/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/18/13
 * Time: 10:46 AM
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import com.events.ListElementSelectedEvent;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;

public class DropDownList extends Sprite {


    private var header:DropDownListHeader;
    private var _elementsList:DropDownListElementVector;

    private var elementsListSprite:Sprite;

    var upSprt:Sprite = new Sprite();
    var downSprt:Sprite = new Sprite();
    private var scrollTimer:Timer = new Timer(30);

    public function DropDownList(list:DropDownListElementVector, x:uint = 0, y:uint = 0) {
        this.x = x;
        this.y = y;

        this._elementsList = list;

        addSprites();
        _elementsList.addEventListener(ListElementSelectedEvent.SELECT, selectHandler, false, 0, true);
        scrollTimer.addEventListener(TimerEvent.TIMER, scrollTimer_timerHandler, false, 0, true);
    }

    private function selectHandler(e:ListElementSelectedEvent):void {
        header.setLabelText(_elementsList.listElementsVector[_elementsList.selectedIndex].label);
        elementsListSprite.visible = !elementsListSprite.visible;
        header.labelText.backgroundColor = 0x000000;
        hideDownSprt();
        hideUpSprt();
        dispatchEvent(new ListElementSelectedEvent(0,""));
    }

    private function clickHeaderHandler(e:MouseEvent):void {
        elementsListSprite.visible = !elementsListSprite.visible;
        header.labelText.backgroundColor = 0x000003;
        if (!elementsListSprite.visible) {
            hideDownSprt();
            hideUpSprt();
        } else {
            scrollBox(0);
        }
    }

    private function addSprites() {
        header = new DropDownListHeader(
                _elementsList.listElementsVector[_elementsList.selectedIndex].label,
                _elementsList.elementWidth, _elementsList.elementHeight,
                _elementsList.elementFontSize);

        fillElementsListSprite();
        header.visible = true;
        header.x = 0;
        header.y = 0;
        header.addEventListener(MouseEvent.CLICK, clickHeaderHandler, false, 0, true);
        this.addChild(header);
        this.addChild(elementsListSprite);
        initUpAndDown();
    }

    private function fillElementsListSprite() {
        elementsListSprite = new Sprite();
        for (var i:uint = 0; i < _elementsList.listElementsVector.length; i++) {
            _elementsList.listElementsVector[i].x = 0;
            _elementsList.listElementsVector[i].y = i * _elementsList.listElementsVector[i].height;
            elementsListSprite.addChild(_elementsList.listElementsVector[i]);
        }
        elementsListSprite.x = 0;
        elementsListSprite.y = 20;
        elementsListSprite.scrollRect = new Rectangle(0, 10,
                _elementsList.elementWidth, _elementsList.elementHeight * _elementsList.elements_in_ScrollRect);
        elementsListSprite.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
        elementsListSprite.visible = false;
    }

    private function mouseWheelHandler(event:MouseEvent):void {
        scrollBox(-event.delta);
    }

    private function scrollBox(dy:Number):void {
        var rect:Rectangle = elementsListSprite.scrollRect;
        rect.y += dy;
        if (rect.y < elementsListSprite.y - _elementsList.elementHeight) {
            rect.y = elementsListSprite.y - _elementsList.elementHeight;
        } else if (rect.y > _elementsList.elementHeight * (_elementsList.elements_in_ScrollRect - 1)) {
            rect.y = _elementsList.elementHeight * (_elementsList.elements_in_ScrollRect - 1);
        }

        if (rect.y > elementsListSprite.y - upSprt.height * 1.5) {
            showUpSprt();
        } else {
            hideUpSprt();
        }

        if (rect.y < _elementsList.elementHeight * (_elementsList.elements_in_ScrollRect - 2) + downSprt.height) {
            showDownSprt();
        } else {
            hideDownSprt();
        }

        elementsListSprite.scrollRect = rect;
    }

    private function addUp():void {
        upSprt.x = 0;
        upSprt.y = header.height;
        upSprt.graphics.beginFill(0xffffff, 1)
        upSprt.graphics.drawRect(0, 0, _elementsList.elementWidth, 7)
        upSprt.graphics.endFill();
        upSprt.addEventListener(MouseEvent.MOUSE_OVER, upSprt_mouseOverHandler, false, 0, true);
        upSprt.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
        addUpArrow();
        this.addChild(upSprt);
    }

    private function showUpSprt():void {
        upSprt.visible = true;
    }

    private function hideUpSprt():void {
        upSprt.visible = false;
    }

    private function addDown():void {
        downSprt.x = 0;
        downSprt.y = _elementsList.elementHeight * _elementsList.elements_in_ScrollRect + header.height - 7;
        downSprt.graphics.beginFill(0xffffff, 1)
        downSprt.graphics.drawRect(0, 0, _elementsList.elementWidth, 7)
        downSprt.graphics.endFill();
        downSprt.addEventListener(MouseEvent.MOUSE_OVER, downSprt_mouseOverHandler, false, 0, true);
        downSprt.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0, true);
        addDownArrow();
        this.addChild(downSprt);
    }

    private function showDownSprt():void {
        downSprt.visible = true;
    }

    private function hideDownSprt():void {
        downSprt.visible = false;
    }

    private function addUpArrow():void {
        var sp:Sprite = new Sprite();
        var v:Vector.<Number> = new Vector.<Number>();
        v.push(0, 6, 3.5, 1, 7, 6);
        sp.graphics.beginFill(0x000000, 1);
        sp.graphics.drawTriangles(v);
        sp.graphics.endFill();
        sp.x = _elementsList.elementWidth / 2 - sp.width / 2;
        upSprt.addChild(sp);
    }

    private function addDownArrow():void {
        var sp:Sprite = new Sprite();
        var v:Vector.<Number> = new Vector.<Number>();
        v.push(0, 1, 3.5, 6, 7, 1);
        sp.graphics.beginFill(0x000000, 1);
        sp.graphics.drawTriangles(v);
        sp.graphics.endFill();
        sp.x = _elementsList.elementWidth / 2 - sp.width / 2;
        downSprt.addChild(sp);
    }

    private function initUpAndDown() {
        addUp();
        hideUpSprt();
        addDown();
        hideDownSprt();
    }

    private var scrollTo:String;

    private function upSprt_mouseOverHandler(event:MouseEvent):void {
        scrollTo = "up";
        if (!scrollTimer.running) {
            scrollTimer.start();
        }
    }

    private function scrollTimer_timerHandler(event:TimerEvent):void {
        if (scrollTo === "up") {
            scrollBox(-10);
        } else {
            scrollBox(10);
        }
    }

    private function mouseOutHandler(event:MouseEvent):void {
        scrollTimer.stop();
        scrollTimer.reset();
    }

    private function downSprt_mouseOverHandler(event:MouseEvent):void {
        scrollTo = "down";
        if (!scrollTimer.running) {
            scrollTimer.start();
        }
    }


    public function get elementsList():DropDownListElementVector {
        return _elementsList;
    }
}
}
