/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.09.
 * Time: 16:08
 * To change this template use File | Settings | File Templates.
 */
package components {
import com.common.AppProperties;
import com.common.InstrumentMouseHandler;
import com.events.UpdateStateEvent;
import com.layout.Layout;
import com.layout.LayoutHandler;
import com.sailing.WindowsHandler;
import com.sailing.instruments.BaseInstrument;
import com.ui.controls.BitmapButton;
import com.ui.controls.ZoomButton;

import components.ais.IAisComponent;
import components.graph.IGraph;
import components.graph.custom.GraphInstance;

import flash.desktop.NativeApplication;
import flash.display.DisplayObject;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.utils.Timer;
import flash.utils.getTimer;

import org.log5f.air.extensions.mouse.events.NativeMouseEvent;

public class ControlWindowAs extends NativeWindow implements IInstrument {

    protected static var options:NativeWindowInitOptions;
    [Embed(source="../../assets/images/Layout pngs/ledit_resizebtn01.png")]
    private static var resizeBtnP:Class;
    [Embed(source="../../assets/images/Layout pngs/ledit_resizebtn02.png")]
    private static var resizeBtnP1:Class;

    [Embed(source="../../assets/images/Layout pngs/ledit_closebtn01.png")]
    private static var closeBtnP:Class;
    [Embed(source="../../assets/images/Layout pngs/ledit_closebtn02.png")]
    private static var closeBtnP1:Class;
    private var _control:*

    private var _controlType:String;
    private var _mouseHandler:InstrumentMouseHandler;
    private var _isChart:Boolean = false;
    private var mousePrevX:int = 0;
    private var mousePrevY:int = 0;
    private var resizeStarted:Boolean = false;
    private var _closeBtn:BitmapButton;
    private var _resizeBtn:BitmapButton;

//    private var _moveButton:BitmapButton;
    private var _controlState:String;
//    include "../com/common/instrumentUtils.as"
    public function ControlWindowAs() {
        createOptions();
        super(options);
        this.stage.align = StageAlign.TOP_LEFT;
        this.stage.scaleMode = StageScaleMode.NO_SCALE;
        this.alwaysInFront = true;
        this.addEventListener(Event.ACTIVATE, initWindow, false, 0, true)
        this.stage.nativeWindow.addEventListener(Event.CLOSING, closeHandler, false, 0, true);

        this.stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, displayStateChangeHandler);
        this.stage.addEventListener(MouseEvent.CLICK, WindowsHandler.instance.application.applicationClickHandler, false, 0, true);
        this.stage.addEventListener(MouseEvent.MOUSE_UP, WindowsHandler.instance.application.applicationClickHandler, false, 0, true);
        LayoutHandler.instance.addEventListener("editModeChanged", editModeChangedHandler, false, 0, true);
        hackTimerForOpen.addEventListener(TimerEvent.TIMER, hackTimerForOpen_timerHandler, false, 0, true);
        //this.stage.nativeWindow.visible = false;
        _mouseHandler = new InstrumentMouseHandler(this);

    }

    public function open(layout:Layout):void {
        this.activate();
//        this.visible = false;
        //trace("open: " + this.x + "," + this.y);
    }

    private function createOptions():void {
        if (options == null) {
            options = new NativeWindowInitOptions();
            options.systemChrome = NativeWindowSystemChrome.NONE
//            options.type = NativeWindowType.NORMAL
//            options.type = NativeWindowType.LIGHTWEIGHT;
            options.type = NativeWindowType.UTILITY;
            options.transparent = true;
            options.resizable = false;
            options.maximizable = false;
            options.minimizable = true;
            options.renderMode = AppProperties.renderMode
            // options.owner = WindowsHandler.instance.application.stage.nativeWindow;


        }
    }

    private function initControlButtons():void {
        _resizeBtn = new BitmapButton(resizeBtnP, resizeBtnP, resizeBtnP1, resizeBtnP, resizeBtnP1);
        _closeBtn = new BitmapButton(closeBtnP, closeBtnP, closeBtnP1, closeBtnP, closeBtnP1);
        _closeBtn.addEventListener(MouseEvent.MOUSE_UP, onClose, false, 0, true);
        _resizeBtn.addEventListener(MouseEvent.MOUSE_DOWN, startResizeCustom, false, 0, true);
        this.stage.addChild(_resizeBtn);
        this.stage.addChild(_closeBtn);

//        if (_control is GraphInstance) {
//            createMoveButton();
//        }
    }

    private function createMoveButton():void {
//        _moveButton = new ZoomButton(null, "<>");
//        _moveButton.x = 6;
        (_control as GraphInstance).controls.moveArea.addEventListener(MouseEvent.MOUSE_DOWN, startMoveCustom, false, 0, true);
//        this.stage.addChild(_moveButton);
    }

    public function onClose(evt:MouseEvent):void {
        stage.nativeWindow.close();
        LayoutHandler.instance.activeLayout.removeWindow(this);
    }

    private function startMoveCustom(evt:MouseEvent):void {
//        if (_control is Polar) {
//            LayoutHandler.instance.activeLayout.closePolarSettings()
//        }
        _mouseHandler.lastClick = getTimer();
        dispatchEvent(new Event("controlMoveStarted"));
        AppProperties.nativeMouse.addEventListener(NativeMouseEvent.NATIVE_MOUSE_MOVE, nativeMouseHandler, false, 0, true);
        AppProperties.nativeMouse.addEventListener(NativeMouseEvent.NATIVE_MOUSE_UP, releaseMouse, false, 0, true);
        AppProperties.nativeMouse.captureMouse()
        mousePrevX = this.stage.mouseX;
        mousePrevY = this.stage.mouseY;

    }

    private function mouseUpHandler(evt:MouseEvent):void {
        _mouseHandler.mouseCustomClick(evt);
    }

    private function startResizeCustom(evt:MouseEvent):void {
        if (LayoutHandler.instance.editMode) {
            var m:Object = AppProperties.nativeMouse.getMouseInfo();
            _mouseHandler.initResizeProperties(width, height, x, y, m.mouseX, m.mouseY, evt.localX, evt.localY)
            _mouseHandler.startResizeNotify()
            resizeStarted = true;
            AppProperties.nativeMouse.addEventListener(NativeMouseEvent.NATIVE_MOUSE_MOVE, mouseMoveResize, false, 0, true);
            AppProperties.nativeMouse.addEventListener(NativeMouseEvent.NATIVE_MOUSE_UP, releaseMouseResize, false, 0, true);
            AppProperties.nativeMouse.captureMouse()
            this.stage.addEventListener(Event.ENTER_FRAME, _mouseHandler.enterFrameHandler, false, 0, true);
        }
    }


    public function getCoordinates():Point {
        if (stage) {
            if (Capabilities.os.match("Windows")) {
                return new Point(stage.nativeWindow.x, stage.nativeWindow.y - 50)
            } else {
                return new Point(stage.nativeWindow.x, stage.nativeWindow.y - 72)
            }
        } else {
            return new Point()
        }
    }

    public function click(e:MouseEvent):void {

    }


    protected function initWindow(event:Event):void {

    }

    protected function activateMainWindow():void {
        var na:NativeApplication = NativeApplication.nativeApplication
        if (!na.openedWindows[0].active) {
            na.openedWindows[0].activate();
        }
    }

    public function customClose():void {
        try {
            _control.removeAllListeners()
        } catch (e:Error) {

        }
        _control = null;
        stage.nativeWindow.close();
    }

    var aMX:int;
    var aMY:int;

    private function nativeMouseHandler(event:NativeMouseEvent):void {
        aMX = event.mouseX - mousePrevX;
        aMY = event.mouseY - mousePrevY
        aMX -= aMX % InstrumentMouseHandler.SNAP_GRID_SIZE;
        aMY -= aMY % InstrumentMouseHandler.SNAP_GRID_SIZE;
        this.move(aMX, aMY);
    }

    public function move(x:int, y:int):void {
        this.x = x;
        this.y = y;
    }

    private function shiftWindow(x:int, y:int):void {
        var tmp:Rectangle = this.bounds;
        tmp.x += x;
        tmp.y += y;
        this.bounds = tmp;
    }

    private function releaseMouse(event:NativeMouseEvent):void {
        AppProperties.nativeMouse.releaseMouse()
        AppProperties.nativeMouse.removeEventListener(NativeMouseEvent.NATIVE_MOUSE_MOVE, nativeMouseHandler);
        AppProperties.nativeMouse.removeEventListener(NativeMouseEvent.NATIVE_MOUSE_UP, releaseMouse);
        activateMainWindow()
    }

    private function releaseMouseResize(event:NativeMouseEvent):void {
        _mouseHandler.stopResizeNotify();
        AppProperties.nativeMouse.releaseMouse()
        AppProperties.nativeMouse.removeEventListener(NativeMouseEvent.NATIVE_MOUSE_MOVE, mouseMoveResize);
        AppProperties.nativeMouse.removeEventListener(NativeMouseEvent.NATIVE_MOUSE_UP, releaseMouseResize);
        this.stage.removeEventListener(Event.ENTER_FRAME, _mouseHandler.enterFrameHandler);

    }


    protected function mouseMoveResize(event:NativeMouseEvent):void {
        _mouseHandler.resizeObject(event.mouseX, event.mouseY);
    }

    private function editModeChangedHandler(event:Event):void {
        setControlButtonsVisibility();
    }

    protected function setControlButtonsVisibility():void {
        if (LayoutHandler.instance.editMode) {
            _closeBtn.visible = true;
            _resizeBtn.visible = true;
            if (_control is GraphInstance) {
                (_control as GraphInstance).enableDisableDropdownList(false);
                //_moveButton.visible = true;
            }
        } else {
            _closeBtn.visible = false;
            _resizeBtn.visible = false;
            if (_control is GraphInstance) {
                (_control as GraphInstance).enableDisableDropdownList(true);
                //_moveButton.visible = true;
            }
        }
    }

    private function addElementTo(element:DisplayObject):void {
        this.stage.addChild(element)
    }

    private function setControllsIndex():void {
        this.stage.setChildIndex(_resizeBtn, this.stage.numChildren - 1)
        this.stage.setChildIndex(_closeBtn, this.stage.numChildren - 2)
    }

    public function addControl(element:*, initWidth:int, initHeight:int):void {
        this.width = initWidth;
        this.height = initHeight;
        _control = element;
        _isChart = _control is GraphInstance;
        if (!_isChart) {
            _control.addEventListener(MouseEvent.MOUSE_DOWN, this.startMoveCustom, false, 0, true);
            _control.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpHandler, false, 0, true);
            _control.addEventListener(MouseEvent.CLICK, this.click, false, 0, true);
            if (_control is BaseInstrument) {
                (_control as BaseInstrument).updateDatas(WindowsHandler.instance.getActualSailData());
            }
        }
        if (_control is IGraph || _control is IAisComponent) {
            _mouseHandler.initControlInitDimensions(_control.originWidth, _control.originHeight);
        } else {
            _mouseHandler.initControlInitDimensions(_control.width, _control.height);
            _control.width = this.width;
            _control.height = this.height;
        }

        this.x = _control.x;
        this.y = _control.y;
        addElementTo(_control);
        initControlButtons();
    }

    var hackTimerForOpen:Timer = new Timer(10, 1);

    public function addToStageControl():void {
        _mouseHandler.repositionControls();
        setControlButtonsVisibility();
        setControllsIndex();

        if (_control is GraphInstance) {
            createMoveButton();
        }

        this.stage.setChildIndex(_control, 0);
        hackTimerForOpen.start();
//        this.visible = true;
//        this.stage.nativeWindow.visible = true;
    }

    public function resize(w:Number, h:Number):void {
        _mouseHandler.resize(w, h);
    }

    public function get closeBtn():BitmapButton {
        return _closeBtn;
    }

    public function get resizeBtn():BitmapButton {
        return _resizeBtn;
    }

//    public function get moveButton():BitmapButton {
//        return _moveButton;
//    }

    public function get isChart():Boolean {
        return _isChart;
    }


    public function get mouseHandler():InstrumentMouseHandler {
        return _mouseHandler;
    }


    public function get controlType():String {
        return _controlType;
    }

    public function set controlType(value:String):void {
        _controlType = value;
    }


    public function get control():* {
        return _control;
    }


    public function set controlState(state:String):void {
        _controlState = state;
    }

    private function hackTimerForOpen_timerHandler(event:TimerEvent):void {
        if (_controlState != null) {
            if (_control is IGraph || _control is IAisComponent) {
                control.dispatchEvent(new UpdateStateEvent(_controlState));
            } else {
                control.updateState(_controlState);
            }
        }
    }


    public function get scaleX():Number {
        return 1;
    }

    public function get scaleY():Number {
        return 1;
    }

    public function drawBg(width:uint, height:uint):void {
        this.width = width;
        this.height = height;
    }


    private function displayStateChangeHandler(event:NativeWindowDisplayStateEvent):void {
        trace("control window display state changed");
    }


    public function set originWidth(value:int):void {
        this.width = value;
    }

    public function set originHeight(value:int):void {
        this.height = value;
    }

    public function get originHeight():int {
        return height;
    }

    public function get originWidth():int {
        return width;
    }

    private function closeHandler(event:Event):void {
        event.preventDefault();
        NativeApplication.nativeApplication.openedWindows[0].dispatchEvent(new Event(Event.CLOSING));
    }
}
}
