/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.02.27.
 * Time: 15:14
 * To change this template use File | Settings | File Templates.
 */
package components.alarm {
import com.alarm.AlarmHandler;
import com.common.AppProperties;
import com.layout.LayoutHandler;
import com.sailing.WindowsHandler;

import components.windows.FloatWindow;

import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

public class AlarmWindow extends FloatWindow {

    public static var WIDTH:Number;
    public static var HEIGHT:Number;
    public static const W_WIDTH:int = 400;
    public static const MIN_WIDTH:int = 400;

    protected static var lastHeight:int = -1;
    protected static var lastWidth:int = -1;
    protected static var lastX:int = -1;
    protected static var lastY:int = -1;
    private static var _alarmList:AlarmList;

    private var _activeAlarmBubble:Badge;

    public function AlarmWindow() {
        super("Alarms");
//        if (LayoutHandler.instance.activeLayout != null && !LayoutHandler.instance.activeLayout.isFullscreen) {
//            this.alwaysInFront = true;
//        }
        WIDTH = this.width - _frame.getWidthAndContentDiff();
        HEIGHT = this.height - _frame.getHeightAndContentDiff();
        this.minSize = new Point(MIN_WIDTH, MIN_HEIGHT)
        setLastWidth();
        setLastHeight();

        if (lastX > -1) {
            this.x = lastX;
        }
        if (lastY > -1) {
            this.y = lastY;
        }

        if (_alarmList == null) {
            _alarmList = new AlarmList();
        }
        _alarmList.refreshList();
        _alarmList.resizeList(lastWidth - _frame.getWidthAndContentDiff(), lastHeight - _frame.getHeightAndContentDiff());

        _content.addChild(_alarmList);
        createDownButtons();
        if (!_alarmList.isActiveState()) {
            disableDownButton(0);
        } else {
            disableDownButton(1);
        }
        AlarmHandler.instance.addEventListener("activeAlarmCounterChanged", activeAlarmCounterChangedHandler, false, 0, true);
    }

//    protected override function createOptions():void {
//        if (options == null) {
//            options = new NativeWindowInitOptions();
//            options.systemChrome = NativeWindowSystemChrome.NONE
//            options.type = NativeWindowType.NORMAL;
//            options.transparent = true;
//            options.resizable = false;
//            options.maximizable = false;
//            options.renderMode = AppProperties.renderMode
////            if (LayoutHandler.instance.activeLayout != null && LayoutHandler.instance.activeLayout.isFullscreen) {
////                options.owner = WindowsHandler.instance.application.stage.nativeWindow;
////            } else {
////                options.owner = null;
////            }
//        }
//    }

    protected override function setLastHeight():void {
        if (lastHeight == -1) {
            this.height = W_HEIGHT;
            lastHeight = this.height;
        } else {
            this.height = lastHeight;
        }
    }


    override protected function setLastWidth():void {
        if (lastWidth == -1) {
            this.width = W_WIDTH;
            lastWidth = this.width;
        } else {
            this.width = lastWidth;
        }

    }

    private function createDownButtons():void {
        this.setButtonAlign(BUTTON_ALIGN_LEFT);
        this.addDownButton(0, "All alarms", allAlarms_clickHandler);
        this.addDownButton(1, "Active", activeAlarms_clickHandler);
        _activeAlarmBubble = this.addBubble(1);
    }

    private function activeAlarms_clickHandler(event:MouseEvent):void {
        selectActiveAlarms();
    }

    public function selectActiveAlarms():void {
        disableDownButton(1);
        _alarmList.activeAlarms();
    }

    private function allAlarms_clickHandler(event:MouseEvent):void {
        disableDownButton(0);
        _alarmList.allAlarms();
    }

    public static function get alarmList():AlarmList {
        return _alarmList;
    }

    protected override function resizeBtn_clickHandler(event:MouseEvent):void {
        super.resizeBtn_clickHandler(event)
        _alarmList.startCustomResize();
    }

    protected override function stage_mouseUpHandler(event:MouseEvent):void {
        super.stage_mouseUpHandler(event);
        _alarmList.stopResize();
    }

    protected override function repositionElements():void {
        super.repositionElements();
        lastWidth = this.width;
        lastHeight = this.height;

        _alarmList.resizeList(this.width - _frame.getWidthAndContentDiff(), this.height - _frame.getHeightAndContentDiff());
    }

    private function activeAlarmCounterChangedHandler(event:Event):void {
        _activeAlarmBubble.setText(AlarmHandler.instance.activeAlarmCounter.toString());
        if (_alarmList.isActiveState()) {
            _alarmList.activeAlarms(false);
        }
    }


    protected override function header_mouseUpHandler(event:MouseEvent):void {
        lastX = this.x;
        lastY = this.y;
    }


    override protected function close_clickHandler(event:MouseEvent):void {
        AlarmHandler.instance.exportAlarms();
        super.close_clickHandler(event);
    }
}
}
