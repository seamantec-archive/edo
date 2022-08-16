/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.04.18.
 * Time: 17:38
 * To change this template use File | Settings | File Templates.
 */
package components.layout {
import com.common.AppProperties;
import com.ui.controls.AlarmDownBtn;

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
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class InstrumentsWindow extends NativeWindow {


    public static const W_HEIGHT:int = 505;
    public static const W_WIDTH:int = 345;
    public static const L_WIDTH:int = 305;
    public static const L_HEIGHT:int = 406;
    public static const HEIGHT_OFFSET:int = W_HEIGHT - L_HEIGHT;
    public static const W_Y_OFFSET:int = 8;
    public static const W_X_OFFSET:int = 9;
    public static const MIN_HEIGHT:int = 505;
    public static const MIN_WIDTH:int = 345;
    private static var lastHeight:int = -1;

    [Embed(source="../../../assets/images/alarmlist/alarmlist_frame.png")]
    private var frame:Class;
    [Embed(source="../../../assets/images/alarmlist/alarmlist_frame_bottom.png")]
    private var frameBottom:Class;
    [Embed(source="../../../assets/images/alarmlist/alarmlist_frame_left.png")]
    private var frameLeft:Class;
    [Embed(source="../../../assets/images/alarmlist/alarmlist_frame_right.png")]
    private var frameRight:Class;
    [Embed(source="../../../assets/images/alarmlist/alarmlist_frame_top.png")]
    private var frameTop:Class;

    [Embed(source="../../../assets/images/alarmlist/alarmlist_frame_bg.png")]
    private var frameBg:Class;

//
    private static var _instrumentsList:InstrumentsList;
    var header:Sprite;


    public function InstrumentsWindow() {
        var options:NativeWindowInitOptions = new NativeWindowInitOptions();
        options.systemChrome = NativeWindowSystemChrome.NONE
        options.type = NativeWindowType.NORMAL
        options.transparent = true;
        options.resizable = false;
        options.maximizable = false;
        options.renderMode = AppProperties.renderMode

        super(options);
        this.stage.align = StageAlign.TOP_LEFT;
        this.stage.scaleMode = StageScaleMode.NO_SCALE;
        this.width = W_WIDTH;
        if (lastHeight == -1) {
            this.height = W_HEIGHT;
            lastHeight = this.height;
        } else {
            this.height = lastHeight;
        }
        this.alwaysInFront = true;
        if (_instrumentsList == null) {
            _instrumentsList = new InstrumentsList();
        }


        createBg();
        this.stage.addChild(_instrumentsList);
        createFrame();
        createHeader();
        createDownButtons();


        this.addEventListener(Event.ACTIVATE, activateHandler, false, 0, true);
    }

    private function activateHandler(event:Event):void {

    }

    private function createHeader():void {
        header = new Sprite();
        header.graphics.beginFill(0x000000, 0.0);
        header.graphics.drawRect(0, 0, W_WIDTH - 30, 30);
        header.graphics.endFill();
        header.x = W_X_OFFSET;
        header.y = W_Y_OFFSET;
        //TODO ez mobilon ne legyen
        header.addEventListener(MouseEvent.MOUSE_DOWN, header_mouseDownHandler, false, 0, true);

        var alarmListText:TextField = new TextField();
        alarmListText.defaultTextFormat = new TextFormat('Arial', 20, 0xffffff);
        alarmListText.text = "Instruments"
        alarmListText.textColor = 0xffffff;
        alarmListText.selectable = false;
        alarmListText.width = W_WIDTH;
        alarmListText.autoSize = TextFieldAutoSize.CENTER;
        header.addChild(alarmListText)


        this.stage.addChild(header)

    }


    private function createBg():void {
        var bg:Sprite = new Sprite();
        var frameBgBitmap:Bitmap = new frameBg();
        bg.x = 0;
        bg.y = 0;
        bg.addChild(frameBgBitmap);
        this.stage.addChild(bg);
    }

    private var frameSprite:Sprite;
    private var frameBottomBitmap:Bitmap;

    private function createFrame():void {

        frameSprite = new Sprite();
        frameSprite.x = 0;
        frameSprite.y = 0;

        var frameTopBitmap:Bitmap = new frameTop();
        frameTopBitmap.x = 0;
        frameTopBitmap.y = 0;

        var frameLeftBitmap:Bitmap = new frameLeft();
        frameLeftBitmap.x = 0;
        frameLeftBitmap.y = frameTopBitmap.height;

        var frameRightBitmap:Bitmap = new frameRight();
        frameRightBitmap.x = W_WIDTH - frameRightBitmap.width;
        frameRightBitmap.y = frameTopBitmap.height;

        frameBottomBitmap = new frameBottom();
        positionateBottomBitmap();
        frameSprite.addChild(frameTopBitmap);
        frameSprite.addChild(frameLeftBitmap);
        frameSprite.addChild(frameRightBitmap);
        frameSprite.addChild(frameBottomBitmap);
        frameSprite.cacheAsBitmap = true;
        this.stage.addChild(frameSprite);
    }

    private function positionateBottomBitmap():void {
        frameBottomBitmap.x = 0;
        var y:int = this.height === 0 ? W_HEIGHT : this.height

        frameBottomBitmap.y = y - frameBottomBitmap.height;
    }


    private function header_mouseDownHandler(event:MouseEvent):void {
        this.startMove();
    }


    private function close_clickHandler(event:MouseEvent):void {

        this.close();
    }

    private var downButtonsContainer:Sprite;

    private function createDownButtons():void {
        downButtonsContainer = new Sprite();
        positionateDownButtons();
        var saveBtn:AlarmDownBtn = new AlarmDownBtn("Save");
        var alarmY:int = 0
        var alarmXOffset:int = 21
        saveBtn.x = 20 + alarmXOffset;
        saveBtn.y = alarmY;
        saveBtn.addEventListener(MouseEvent.CLICK, saveBtn_clickHandler, false, 0, true);

        downButtonsContainer.addChild(saveBtn);

        var revertBtn:AlarmDownBtn = new AlarmDownBtn("Revert");
        revertBtn.x = 110 + alarmXOffset;
        revertBtn.y = alarmY;
        revertBtn.addEventListener(MouseEvent.CLICK, revertBtn_clickHandler, false, 0, true);
        downButtonsContainer.addChild(revertBtn);

        var cancelBtn:AlarmDownBtn = new AlarmDownBtn("Cancel");
        cancelBtn.x = 200 + alarmXOffset;
        cancelBtn.y = alarmY;
        cancelBtn.addEventListener(MouseEvent.CLICK, cancelBtn_clickHandler, false, 0, true);
        downButtonsContainer.addChild(cancelBtn);

        var y:int = this.height === 0 ? W_HEIGHT : this.height

        var resizeBtn:AlarmDownBtn = new AlarmDownBtn("resizetest");
        resizeBtn.x = 290 + alarmXOffset;
        resizeBtn.y = W_Y_OFFSET * 2 + 40 - resizeBtn.height;
        resizeBtn.addEventListener(MouseEvent.MOUSE_DOWN, resizeBtn_clickHandler, false, 0, true);
        downButtonsContainer.addChild(resizeBtn);
        this.stage.addChild(downButtonsContainer);
    }

    private function positionateDownButtons():void {
        var y:int = this.height === 0 ? W_HEIGHT : this.height
        downButtonsContainer.y = y - W_Y_OFFSET * 2 - 40;
    }


    private function resize(w:int, h:int):void {
        if (h < MIN_HEIGHT) {
            h = MIN_HEIGHT
        }
        if (w < MIN_HEIGHT) {
            w = MIN_WIDTH
        }
        this.height = h;
        this.width = w;
        lastHeight = this.height;
        dispatchEvent(new Event(Event.RESIZE));
        positionateBottomBitmap();
        positionateDownButtons();

    }


    private var resizeBtnClickedAt:Point;

    private function resizeBtn_clickHandler(event:MouseEvent):void {
        resizeBtnClickedAt = new Point(event.localX, event.localY)
        stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, false, 0, true);
        stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
    }

    private function stage_mouseMoveHandler(event:MouseEvent):void {
        resize(W_WIDTH, event.stageY);     //+ resizeBtnClickedAt.y
    }

    private function stage_mouseUpHandler(event:MouseEvent):void {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
    }

    private function saveBtn_clickHandler(event:MouseEvent):void {
    }

    private function revertBtn_clickHandler(event:MouseEvent):void {
    }

    private function cancelBtn_clickHandler(event:MouseEvent):void {
    }


    public static function get instrumentsList():InstrumentsList {
        if (_instrumentsList == null) {
            _instrumentsList = new InstrumentsList();
        }
        return _instrumentsList;
    }

    public static function set instrumentsList(value:InstrumentsList):void {
        _instrumentsList = value;
    }
}
}
