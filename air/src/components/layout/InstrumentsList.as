/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.04.18.
 * Time: 18:10
 * To change this template use File | Settings | File Templates.
 */
package components.layout {
import com.common.AppProperties;

import components.InstrumentSelector;
import components.alarm.AlarmView;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

public class InstrumentsList extends Sprite {

    private var _viewContainer:Array = [];
    protected var dragStartDataPoint:Point;
    private var listHeight:int;
    private var listWidth:int

    public function InstrumentsList() {
        super();
        listWidth = InstrumentsWindow.L_WIDTH;
        listHeight = InstrumentsWindow.L_HEIGHT
        this.scrollRect = new Rectangle(0, 0, listWidth, listHeight);
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
        this.x = 17;
        this.y = 37;
        this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
    }


    public function addView(view:InstrumentView):void {
        view.y = _viewContainer.length * AlarmView.DEF_HEIGHT;
        view.x = 0;
        _viewContainer.push(view)
        this.addChild(view);
    }





    public function refreshActualList():void {

    }

    private function removeAllElement():void {
        if (numChildren > 0) {
            this.removeChildren(0, numChildren - 1);
            _viewContainer = [];
        }
    }




    private function addedToStageHandler(event:Event):void {
        stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
    }

    public function mouseDownHandler(event:MouseEvent):void {
        if (event.target is InstrumentSelector) {
            return;
        }
        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
        dragStartDataPoint = new Point(event.stageX, event.stageY);
    }

    private function mouseMoveHandler(event:MouseEvent):void {
        var currDataPoint:Point = new Point(event.stageX, event.stageY);
        var dy:Number = dragStartDataPoint.y - currDataPoint.y;
        scrollBox(dy);
        dragStartDataPoint = currDataPoint;
    }

    private function scrollBox(dy:Number, needSlowDown:Boolean = true):void {
        var rect:Rectangle = this.scrollRect;
        // var slowDown:int = (needSlowDown ? 15 : 1)
        rect.y += dy; /// slowDown;
        if (rect.y < 0) {
            rect.y = 0
        } else if (rect.y >= (_viewContainer.length * AlarmView.DEF_HEIGHT - listHeight)) {
            if (((_viewContainer.length * AlarmView.DEF_HEIGHT) > (listHeight))) {
                rect.y = _viewContainer.length * AlarmView.DEF_HEIGHT - listHeight
            } else {
                // trace("alarmlist scrollbox", AlarmWindow.W_HEIGHT - 85, " ", _viewContainer.length * AlarmView.DEF_HEIGHT)
                rect.y = 0
            }
        }
        this.scrollRect = rect;
    }

    private function scrollToTop():void {
        var rect:Rectangle = this.scrollRect;
        rect.y = 0;
        this.scrollRect = rect;

    }

    private function mouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }

    private function mouseWheelHandler(event:MouseEvent):void {
        scrollBox(-event.delta, false)
    }


    private var rectX:Rectangle

    public function resize():void {
        rectX = this.scrollRect;
        rectX.height = AppProperties.alarmWindow.height - InstrumentsWindow.HEIGHT_OFFSET
        listHeight = rectX.height;
        this.scrollRect = rectX;
    }
}
}
