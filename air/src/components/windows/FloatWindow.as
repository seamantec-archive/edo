/**
 /**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/3/13
 * Time: 11:57 AM
 * To change this template use File | Settings | File Templates.
 */
package components.windows {

import com.common.AppProperties;
import com.events.AppClick;
import com.ui.controls.AlarmDownBtn;
import com.ui.controls.BitmapButton;
import com.ui.controls.CloseButton;
import com.ui.controls.CloudBtn;
import com.utils.FontFactory;

import components.alarm.Badge;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldType;

public class FloatWindow extends NativeWindow {

    [Embed(source="../../../assets/images/alarmlist/alarmlist_frame_bg.png")]
    private static var frameBg:Class;
    [Embed(source="../../../assets/images/window_resize.png")]
    private static var resizeBtnP:Class;
    [Embed(source="../../../assets/images/window_resize.png")]
    private static var resizeBtnP1:Class;
    [Embed(source="../../../assets/images/inputfield.png")]
    public static var inputfield:Class;

    public static const W_HEIGHT:int = 505;
    public static const W_WIDTH:int = 345;
    public static const L_WIDTH:int = 305;
    public static const L_HEIGHT:int = 409;
    public static const HEIGHT_OFFSET:int = W_HEIGHT - L_HEIGHT;
    public static const WIDTH_OFFSET:int = W_WIDTH - L_WIDTH;
    public static const W_Y_OFFSET:int = 8;
    public static const W_X_OFFSET:int = 9;
    public static const MIN_HEIGHT:int = 200;
    public static const MIN_WIDTH:int = 345;

    protected static const BUTTON_ALIGN_LEFT = 0;
    protected static const BUTTON_ALIGN_CENTER = 1;
    protected static const BUTTON_ALIGN_RIGHT = 2;
    private var _buttonAlign:int = -1;
    private var _buttons:Sprite;
    private const BUTTONSCOUNT:uint = 3;
    private var _buttonsList:Array;
    protected var _frame:WindowFrame;

    private var alarmXOffset:int = 21;

    protected var closeBtn:CloseButton;
    protected var header:Sprite;
    protected var bottom:Sprite;
    protected var _content:Sprite;
    protected var frameSprite:Sprite;
    protected var titleW:TextField;

    protected var _input:Sprite;
    protected var _inputInputField:TextField;
    protected var _inputButtonOk:CloudBtn;
    protected var _inputButtonCancel:CloudBtn;

    protected var _resizeable:Boolean;

    protected var _w:int = W_WIDTH;
    protected var _h:int = W_HEIGHT;
    protected var downButtonsContainer:Sprite;

    protected var resizeBtn:BitmapButton;

    protected var buttonFullPosition:Boolean = false;

    protected var bg:Sprite = new Sprite();
    protected static var options:NativeWindowInitOptions;

    public function FloatWindow(windowTitle:String = "") {
        createOptions();

        super(options);

        this.stage.align = StageAlign.TOP_LEFT;
        this.stage.scaleMode = StageScaleMode.NO_SCALE;
        this.width = W_WIDTH;
        this.height = W_HEIGHT;
        this.minSize = new Point(MIN_WIDTH, MIN_HEIGHT)

        setLastHeight();
        setLastWidth();

        this.alwaysInFront = true;

        createFrame();
        createBg();
        createContent()
        createBottom();
        createHeader(windowTitle);

        createResizeButton();

        _buttons = new Sprite();
        _buttons.y = 12;
        _buttonsList = new Array();
        _frame.windowBottomSprite.addChild(_buttons);

        this.addEventListener(Event.ACTIVATE, activateHandler, false, 0, true);
        this.stage.nativeWindow.addEventListener(Event.CLOSING, closeHandler, false, 0, true);

    }

    private function closeHandler(event:Event):void {
        event.preventDefault();
        NativeApplication.nativeApplication.openedWindows[0].dispatchEvent(new Event(Event.CLOSING));

    }

    protected function createOptions():void {
        if (options == null) {
            options = new NativeWindowInitOptions();
            options.systemChrome = NativeWindowSystemChrome.NONE
            options.type = NativeWindowType.NORMAL;
            options.transparent = true;
            options.resizable = false;
            options.maximizable = false;
            options.renderMode = AppProperties.renderMode
//           options.owner = WindowsHandler.instance.application.stage.nativeWindow
        }
    }

    protected function activateHandler(event:Event):void {
//        initializeView();
    }

    protected function setLastHeight():void {
    }

    protected function setLastWidth():void {
    }

    protected function createResizeButton():void {
        resizeBtn = new BitmapButton(resizeBtnP, resizeBtnP, resizeBtnP1, resizeBtnP, resizeBtnP1);
        resizeBtn.x = this.width - resizeBtn.width - 17;
        resizeBtn.y = this.height - resizeBtn.height - 19;
        resizeBtn.addEventListener(MouseEvent.MOUSE_DOWN, resizeBtn_clickHandler, false, 0, true);
        this.stage.addChild(resizeBtn);
    }

    protected function createBottom():void {
        bottom = new Sprite();
        bottom.x = 0;
        bottom.y = this.height - 61;
        this.stage.addChild(bottom);
    }

    protected function createBg():void {

        var frameBgBitmap:Bitmap = new frameBg();
        bg.x = WindowFrame.CONTENT_TOP_X_ZERO;
        bg.y = WindowFrame.CONTENT_TOP_Y_ZERO;
        frameBgBitmap.width = this.width - _frame.getWidthAndContentDiff();
        frameBgBitmap.height = this.height - _frame.getHeightAndContentDiff();
        bg.addChild(frameBgBitmap);
        this.stage.addChild(bg);

    }

    protected function createFrame():void {
        _frame = new WindowFrame(this.width, this.height);
        _frame.x = 0;
        _frame.y = 0;
        this.stage.addChild(_frame);
    }

    private function createContent():void {
        _content = new Sprite();
        _content.x = WindowFrame.CONTENT_TOP_X_ZERO;
        _content.y = WindowFrame.CONTENT_TOP_Y_ZERO;
        _content.graphics.beginFill(0xFFFFFF, 0);
        _content.graphics.drawRect(0, 0, this.width - _frame.getWidthAndContentDiff(), this.height - _frame.getHeightAndContentDiff());
        _content.graphics.endFill();
        this.stage.addChild(_content);
        this.stage.setChildIndex(_frame, this.stage.numChildren - 1);

    }

    protected function createHeader(windowTitle:String):void {
        header = new Sprite();
        header.graphics.beginFill(0x000000, 0.0);
        header.graphics.drawRect(0, 0, W_WIDTH - 30, 30);
        header.graphics.endFill();
        header.x = W_X_OFFSET;
        header.y = W_Y_OFFSET;
        header.addEventListener(MouseEvent.MOUSE_DOWN, header_mouseDownHandler, false, 0, true);
        header.addEventListener(MouseEvent.MOUSE_UP, header_mouseUpHandler, false, 0, true);

        titleW = FontFactory.getCustomFont({size: 20, color: 0x000000});
        titleW.text = windowTitle;
        titleW.width = titleW.textWidth + 5;//150;//W_WIDTH;
        titleW.height = titleW.textHeight + 5;//30;//W_WIDTH;

        titleW.x = (this.width / 2) - (titleW.width / 2) - 10;
        titleW.y = W_X_OFFSET - 12;
        header.addChild(titleW);

        closeBtn = new CloseButton();
        closeBtn.addEventListener(MouseEvent.CLICK, close_clickHandler, false, 0, true);
        closeBtn.x = this.width - 40 - W_X_OFFSET;
        closeBtn.y = W_X_OFFSET - 7;
        header.addChild(closeBtn);
        this.stage.addChild(header);
    }

    public function setTitle(title:String):void {
        titleW.text = title;
        titleW.width = titleW.textWidth + 5;
        titleW.height = titleW.textHeight + 5;
        titleW.x = (this.width / 2) - (titleW.width / 2) - 10;
    }

    public function setTitleX(value:Number):void {
        titleW.x = value;
    }

    protected function header_mouseDownHandler(event:MouseEvent):void {
        this.startMove();
        dispatchEvent(new AppClick(event.target));
    }

    protected function close_clickHandler(event:MouseEvent):void {
        this.close();
        var na:NativeApplication = NativeApplication.nativeApplication
        if (!na.openedWindows[0].active) {
            na.openedWindows[0].activate();
        }
        dispatchEvent(new AppClick(event.target));
    }

    protected function resize(w:int, h:int):void {
        _w = w;
        _h = h;
    }

    protected var resizeBtnClickedAt:Point;

    protected function resizeBtn_clickHandler(event:MouseEvent):void {
        resizeBtnClickedAt = new Point(event.localX, event.localY)
        this.addEventListener(NativeWindowBoundsEvent.RESIZING, resizingHandler, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
        _w = this.width;
        _h = this.height;
        this.startResize();
        stage.addEventListener(Event.ENTER_FRAME, stage_enterFrameHandler, false, 0, true);

        dispatchEvent(new AppClick(event.target));
    }


    protected function stage_mouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(Event.ENTER_FRAME, stage_enterFrameHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
        repositionElements();

    }

    protected function resizingHandler(event:NativeWindowBoundsEvent):void {
        resize(event.afterBounds.width, event.afterBounds.height);
    }

    protected function stage_enterFrameHandler(event:Event):void {
        repositionElements();
    }

    protected function repositionElements():void {
        _frame.repositionElements(_w, _h);
        header.graphics.clear();
        header.graphics.beginFill(0x000000, 0.0);
        header.graphics.drawRect(0, 0, _w - 30, 30);
        header.graphics.endFill();

        bg.width = _w - _frame.getWidthAndContentDiff();
        bg.height = _h - _frame.getHeightAndContentDiff();

        //titleW.x = _w / 2 - titleW.width / 2 + 10; //_w/2-50;
        //titleW.y = W_X_OFFSET - 12;
        titleW.x = (this.width / 2) - (titleW.width / 2) - 10;
        closeBtn.x = _w - 40 - W_X_OFFSET;
        resizeBtn.x = _w - resizeBtn.width - 17;
        resizeBtn.y = _h - resizeBtn.height - 19;

        _content.graphics.clear();
        _content.graphics.beginFill(0xFFFFFF, 0);
        _content.graphics.drawRect(0, 0, (_w - _frame.getWidthAndContentDiff()), (_h - _frame.getHeightAndContentDiff()));
        _content.graphics.endFill();

        repositionButtons();
    }

    public function get resizeable():Boolean {
        return _resizeable;
    }

    public function set resizeable(value:Boolean):void {
        _resizeable = value;
        if (!_resizeable) {
            this.resizeBtn.visible = false;
        }
    }


    protected function header_mouseUpHandler(event:MouseEvent):void {
    }

    public function setButtonAlign(align:int):void {
        _buttonAlign = align;
    }

    public function addDownButton(index:int, label:String, listener:Function, fontSize:uint = 12, alphaDisabled:Boolean = false):AlarmDownBtn {
        var button = new AlarmDownBtn(label, fontSize, alphaDisabled);
        button.addEventListener(MouseEvent.CLICK, listener, false, 0, true);
        if (_buttonAlign == -1) {
            var buttonLength:Number = _frame.windowBottomSprite.width / BUTTONSCOUNT;
            if (index == 0) {
                button.x = 0;
            } else if (index == (BUTTONSCOUNT - 1)) {
                button.x = _frame.windowBottomSprite.width - button.width;
            } else {
                button.x = index * (buttonLength) + ((buttonLength - button.width) / 2);
            }
        } else {
            button.x = index * (button.width + 12);
            repositionButtons();
        }
        button.y = 0;
        _buttons.addChild(button);
        _buttonsList.push({index: index, button: button});
        return button;
    }

    public function disableDownButton(index:int) {
        for (var i:int = 0; i < _buttonsList.length; i++) {
            var item:Object = _buttonsList[i];
            if (index == item.index) {
                item.button.enabled = false;
            } else {
                item.button.enabled = true;
            }
        }
    }

    public function addBubble(index:int):Badge {
        if (_buttonsList.length <= index) {
            return null;
        }
        var bubble:Badge = new Badge();
        var button:AlarmDownBtn = _buttonsList[index].button as AlarmDownBtn;
        bubble.x = (button.x + button.width) - bubble.width + 10;
        bubble.y = button.y - 5;
        _buttons.addChild(bubble);
        return bubble;
    }

    public function get input():Boolean {
        return (_input != null) ? _input.visible : false;
    }

    public function openInput():void {
        if (_input == null) {
            _input = new Sprite();
            _input.y = 12;
            _frame.windowBottomSprite.addChild(_input);

            var bitmap:Bitmap = new inputfield();
            bitmap.width *= 0.75;
            bitmap.y = 3;
            _input.addChild(bitmap);

            _inputInputField = FontFactory.getCustomFont({
                size: 12,
                selectable: true,
                color: 0x000000,
                bold: true
            });
            _inputInputField.width = bitmap.width - 2;
            _inputInputField.height = bitmap.height - 2;
            _inputInputField.x = 1;
            _inputInputField.y = 5;
            _inputInputField.textColor = 0x000000;
            _inputInputField.type = TextFieldType.INPUT;
            _inputInputField.addEventListener(Event.CHANGE, inputInputField_changeHandler, false, 0, true);
            _input.addChild(_inputInputField);

            _inputButtonOk = new CloudBtn(CloudBtn.TYPE_SIMPLE, "OK", 10);
            _inputButtonOk.x = _frame.windowBottomSprite.width - _inputButtonOk.width;
            _input.addChild(_inputButtonOk);

            _inputButtonCancel = new CloudBtn(CloudBtn.TYPE_SIMPLE, "Cancel", 10);
            _inputButtonCancel.x = _inputButtonOk.x - 5 - _inputButtonCancel.width;
            _input.addChild(_inputButtonCancel);
        }
        _input.visible = true;
        _buttons.visible = false;
    }

    public function closeInput():void {
        if (_input != null) {
            _input.visible = false;
        }
        _buttons.visible = true;
    }

    private function repositionButtons():void {
        if (_buttonAlign == -1) {
            for (var i:int = 0; i < _buttonsList.length; i++) {
                var object:Object = _buttonsList[i];
                var button:AlarmDownBtn = object.button as AlarmDownBtn;
                var buttonLength:Number = _frame.windowBottomSprite.width / BUTTONSCOUNT;
                if (object.index == 0) {
                    button.x = 0;
                } else if (object.index == (BUTTONSCOUNT - 1)) {
                    button.x = _frame.windowBottomSprite.width - button.width;
                } else {
                    button.x = i * (buttonLength) + ((buttonLength - button.width) / 2);
                }
            }
        } else {
            if (_buttonAlign == BUTTON_ALIGN_LEFT) {
                _buttons.x = 0;
            } else if (_buttonAlign == BUTTON_ALIGN_RIGHT) {
                _buttons.x = _frame.windowBottomSprite.width - _buttons.width;
            } else {
                _buttons.x = (_frame.windowBottomSprite.width / 2) - (_buttons.width / 2);
            }
        }
    }

    protected function inputInputField_changeHandler(event:Event):void {
    }
}
}