/**
 * Created by seamantec on 29/07/14.
 */
package components.digital {

import com.events.AppClick;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

public class DigitalDropdownList extends Sprite {

    public static const ITEM_HEIGHT:int = 60;
    private const VISIBLE_ITEM_COUNT:int = 5;

    private var _container:Vector.<DigitalDropdownListItem>;
    private var _mY:Number;
    private var _dragPoint:Point;
    private var _prevPosition:Number;
    private var _scrollBar:Sprite;
    public function DigitalDropdownList(x:Number, y:Number, width:Number) {
        _container = new Vector.<DigitalDropdownListItem>();
        _mY = 0;
        _prevPosition = 0;

        this.x = x;
        this.y = y;

        this.graphics.beginFill(0xffffff, 1);
        this.graphics.drawRect(0,0, width,ITEM_HEIGHT*VISIBLE_ITEM_COUNT);
        this.graphics.endFill();

        _scrollBar = new Sprite();
        _scrollBar.x = this.width - 18;
        this.addChild(_scrollBar);

        this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
    }


    public function addItem(item:DigitalDropdownListItem):void {
        if(_container.length<VISIBLE_ITEM_COUNT) {
            item.y = _container.length*ITEM_HEIGHT;
            this.addChild(item);
        }
        _container.push(item);

        drawScrollBar();
    }

    private function scrollBox(dy:Number):void {
        _mY += dy;
        if(_mY<0) {
            _mY = 0;
        } else if(_mY>=(_container.length*ITEM_HEIGHT)) {
            _mY = _container.length*ITEM_HEIGHT;
        }

        var position:Number = Math.floor(_mY/ITEM_HEIGHT);
        if(_container.length<=VISIBLE_ITEM_COUNT) {
            position = 0;
        } else if(position>=(_container.length-VISIBLE_ITEM_COUNT)) {
            position = _container.length - VISIBLE_ITEM_COUNT;
        }

        if(_prevPosition!=position) {
            for (var i:int = 0; i < VISIBLE_ITEM_COUNT; i++) {
                if(this.getChildAt(i)!=_scrollBar) {
                    this.removeChildAt(i);
                }
                _container[position + i].y = i * ITEM_HEIGHT;
                this.addChildAt(_container[position + i], i);
            }
        }

        _prevPosition = position;

        drawScrollBar();
    }

    public function getItem(index:int):DigitalDropdownListItem {
        return _container[index];
    }

    public function getIndexOfItem(item:DigitalDropdownListItem):int {
        for(var i:int=0; i<_container.length; i++) {
            if(item==_container[i]) {
                return i;
            }
        }

        return -1;
    }

    public function get length():int {
        return _container.length;
    }

    private function drawScrollBar() {
        var listHeight:Number = _container.length*ITEM_HEIGHT;
        var rectHeight:Number = VISIBLE_ITEM_COUNT*ITEM_HEIGHT;
        if (listHeight > rectHeight) {
            var height:Number = rectHeight * (rectHeight / listHeight);

            _scrollBar.graphics.clear();
            _scrollBar.graphics.beginFill(0x0E0E0E, 0.5);
            _scrollBar.graphics.drawRoundRect(0, 0, 18, height, 6);
            _scrollBar.graphics.endFill();

            _scrollBar.y = rectHeight * ((_prevPosition*ITEM_HEIGHT) / listHeight);

            this.setChildIndex(_scrollBar, this.numChildren - 1);
        } else {
            _scrollBar.graphics.clear();
        }
    }

    private function mouseDownHandler(e:MouseEvent):void {
        this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
        this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
        _dragPoint = new Point(e.stageX, e.stageY);

//        dispatchEvent(new AppClick(e.target));
    }

    private function mouseMoveHandler(e:MouseEvent):void {
        var currentPoint:Point = new Point(e.stageX, e.stageY);
        var dy:Number = _dragPoint.y - currentPoint.y;
        scrollBox(dy);
        _dragPoint = currentPoint;
    }

    private function mouseUpHandler(e:MouseEvent):void {
        this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }

    private function mouseWheelHandler(e:MouseEvent):void {
        scrollBox(sgn(-e.delta)*ITEM_HEIGHT);
    }


    private function sgn(value:Number):int {
        return (value<0) ? -1 : 1;
    }

}
}
