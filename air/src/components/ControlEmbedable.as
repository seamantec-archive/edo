/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.09.
 * Time: 15:02
 * To change this template use File | Settings | File Templates.
 */
package components {
import com.common.InstrumentMouseHandler;
import com.events.UpdateStateEvent;
import com.layout.Layout;
import com.layout.LayoutHandler;
import com.sailing.WindowsHandler;
import com.sailing.instruments.BaseInstrument;
import com.ui.controls.BitmapButton;

import components.ais.IAisComponent;
import components.graph.IGraph;
import components.graph.custom.GraphInstance;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.getTimer;

public class ControlEmbedable extends Sprite implements IInstrument {
    [Embed(source="../../assets/images/Layout pngs/ledit_resizebtn01.png")]
    private static var resizeBtnP:Class;
    [Embed(source="../../assets/images/Layout pngs/ledit_resizebtn02.png")]
    private static var resizeBtnP1:Class;

    [Embed(source="../../assets/images/Layout pngs/ledit_closebtn01.png")]
    private static var closeBtnP:Class;
    [Embed(source="../../assets/images/Layout pngs/ledit_closebtn02.png")]
    private static var closeBtnP1:Class;

    private var _control:*;
    private var _controlType:String;
    private var lastClick:int;
    private var _isChart:Boolean = false;
    private var LayoutHandlerinstance = LayoutHandler.instance;
    private var editMode = LayoutHandlerinstance.editMode;
    private var resizeStarted:Boolean = false;
    private var _globalPosition:Point;
    private var _mouseHandler:InstrumentMouseHandler;
    private var _closeBtn:BitmapButton;
    private var _resizeBtn:BitmapButton;
    private var _controlState:String;
//    private var _moveButton:BitmapButton;
    private var _originWidth:int;
    private var _originHeight:int;

//    include "../com/common/instrumentUtils.as"
    public function ControlEmbedable() {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, initWindow, false, 0, true);
        LayoutHandler.instance.addEventListener("editModeChanged", editModeChangedHandler, false, 0, true);
        _mouseHandler = new InstrumentMouseHandler(this);

    }

    public function move(x:int, y:int):void {
        this.x = x;
        this.y = y;
    }


    public function set controlState(state:String):void {
        _controlState = state;
    }

    private function initControlButtons():void {
        _resizeBtn = new BitmapButton(resizeBtnP, resizeBtnP, resizeBtnP1, resizeBtnP, resizeBtnP1);
        _closeBtn = new BitmapButton(closeBtnP, closeBtnP, closeBtnP1, closeBtnP, closeBtnP1);
        _closeBtn.addEventListener(MouseEvent.MOUSE_UP, onClose, false, 0, true);
        _resizeBtn.addEventListener(MouseEvent.MOUSE_DOWN, startResize, false, 0, true);
        _resizeBtn.addEventListener(MouseEvent.MOUSE_UP, stopResize, false, 0, true);

        this.addChild(_resizeBtn);
        this.addChild(_closeBtn);
    }


    private function createMoveButton():void {
//        _moveButton = new ZoomButton(null, "<>");
//        _moveButton.x = 6;
        (_control as GraphInstance).controls.moveArea.addEventListener(MouseEvent.MOUSE_DOWN, startMove, false, 0, true);
//        this.addChild(_moveButton);
    }

    private function initWindow(event:Event):void {
        _isChart = _control is GraphInstance;
        _control.addEventListener(MouseEvent.MOUSE_DOWN, this.startMove, false, 0, true);
        _control.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpHandler, false, 0, true);
        if (_control is BaseInstrument) {
            (_control as BaseInstrument).updateDatas(WindowsHandler.instance.getActualSailData());
        }


        this.addEventListener(Event.CLOSE, removeWindow, false, 0, true);
        _globalPosition = this.localToGlobal(new Point());
        this.removeEventListener(Event.ADDED_TO_STAGE, initWindow);
    }

    private function onClose(evt:MouseEvent):void {
        var parent:Layout = this.parent as Layout;
        parent.removeWindow(this);
    }

    var localPosition:Point = new Point();

    private function startMove(evt:MouseEvent):void {
        _mouseHandler.lastClick = getTimer();
        if (LayoutHandler.instance.editMode) {
            bringToFront();
            //this.startDrag();
            localPosition = globalToLocal(new Point(evt.stageX, evt.stageY));

            stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
            stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
        }


    }

    private function stage_mouseUpHandler(event:MouseEvent):void {
        if (this.stage != null) {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler)
            stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler)
        }
    }

    var xX:int;
    var yY:int;
    //TODO megvizsgalni a kiemelhetoseget
    private function stage_mouseMoveHandler(event:MouseEvent):void {
        xX = event.stageX - localPosition.x * this.scaleX;
        yY = event.stageY - localPosition.y * this.scaleY;
        xX = xX - xX % InstrumentMouseHandler.SNAP_GRID_SIZE;
        yY = yY - yY % InstrumentMouseHandler.SNAP_GRID_SIZE;
        this.x = xX;
        this.y = yY;

    }

    private function mouseUpHandler(evt:MouseEvent):void {
        mouseHandler.mouseCustomClick(evt);
        _control.dispatchEvent(new Event("stop-move"));
    }


    public function getCoordinates():Point {
        if (stage) {
            return new Point(this.x, this.y);
        } else {
            return new Point();
        }
    }


    private function removeWindow(e:Event):void {
        var parent = this.parent as Layout;
        parent.removeWindow(this);

    }

    public function customClose():void {
        var parent:Layout = this.parent as Layout;
        try {
            _control.removeAllListeners()
        } catch (e:Error) {

        }
        _control = null;
        parent.removeChild(this);
    }

    public function open(parentContainer:Layout):void {
        parentContainer.addChild(this);
    }

    private function startResize(evt:MouseEvent):void {
        bringToFront();
        if (control is IGraph || control is IAisComponent) {
            _mouseHandler.initResizeProperties(control.originWidth, control.originHeight, x, y, evt.stageX, evt.stageY, evt.localX, evt.localY)
        } else {
            _mouseHandler.initResizeProperties(_originWidth, _originHeight, x, y, evt.stageX, evt.stageY, evt.localX, evt.localY)
        }
        _mouseHandler.startResizeNotify();
        resizeStarted = true;
        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveR, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, stopResize, false, 0, true);

        addEventListener(Event.ENTER_FRAME, _mouseHandler.enterFrameHandler, false, 0, true);
//        _mouseHandler.resizeObject(evt.stageX, evt.stageY);
    }

    private function bringToFront():void {
        var parent:Layout = this.parent as Layout;
        parent.bringControlToFront(this)
    }




    protected function stopResize(event:MouseEvent):void {
        _mouseHandler.stopResizeNotify();
        if (stage == null) {
            return;
        }
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveR);
        stage.removeEventListener(MouseEvent.MOUSE_UP, stopResize);
        removeEventListener(Event.ENTER_FRAME, _mouseHandler.enterFrameHandler);
        resizeStarted = false;
    }


    protected function mouseMoveR(event:MouseEvent):void {
        var needSnap:Boolean = false//event.shiftKey && event.ctrlKey;
        _mouseHandler.resizeObject(event.stageX, event.stageY);
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
//                _moveButton.visible = true;
            }
        } else {
            _closeBtn.visible = false;
            _resizeBtn.visible = false;
            if (_control is GraphInstance) {
                (_control as GraphInstance).enableDisableDropdownList(true);
//                _moveButton.visible = false;
            }
        }
    }

    private function addElementTo(element:DisplayObject):void {
        this.addChild(element);

    }

    private function setControllsIndex():void {
        this.setChildIndex(_resizeBtn, this.numChildren - 1);
        this.setChildIndex(_closeBtn, this.numChildren - 2);
    }

    public function resize(w:Number, h:Number):void {
        _mouseHandler.resize(w, h);
    }

    public function addControl(element:*, initWidth:int, initHeight:int):void {
        _control = element;
        _mouseHandler.initControlInitDimensions(_control.width, _control.height);
//        _control.width = initWidth;
//        _control.height = initHeight;
        drawBg(initWidth, initHeight);
        addElementTo(_control);
        initControlButtons();
        _mouseHandler.repositionControls();
    }

    public function drawBg(w:uint, h:uint):void {
        this.graphics.clear();
        this.graphics.beginFill(0xf2f2f2, 0);
        this.graphics.drawRect(0, 0, w, h);
        this.graphics.endFill()
    }

    public function addToStageControl():void {

        setControlButtonsVisibility();
        setControllsIndex();
        if (_control is GraphInstance) {
            createMoveButton();
        }
        if (_controlState != null) {
            if (_control is IGraph || _control is IAisComponent) {
                _control.dispatchEvent(new UpdateStateEvent(_controlState));
            } else {
                _control.updateState(_controlState);
            }
        }
    }


    public function get mouseHandler():InstrumentMouseHandler {
        return _mouseHandler;
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


    public function get controlType():String {
        return _controlType;
    }

    public function set controlType(value:String):void {
        _controlType = value;
    }


    public function get control():* {
        return _control;
    }


    public function set originHeight(value:int):void {
        _originHeight = value;
    }

    public function set originWidth(value:int):void {
        _originWidth = value;
    }


    public function get originWidth():int {
        return _originWidth;
    }

    public function get originHeight():int {
        return _originHeight;
    }

//    override public function get width():Number {
//        return _width;
//    }


//    override public function get height():Number {
//        return _height;
//    }
}
}
