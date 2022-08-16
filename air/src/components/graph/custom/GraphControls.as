/**
 * Created by pepusz on 2014.07.17..
 */
package components.graph.custom {
import com.events.ListElementSelectedEvent;
import com.graphs.YDatas;
import com.ui.controls.BackToLiveButton;
import com.ui.controls.BitmapButton;
import com.ui.controls.GraphDropdown;
import com.ui.controls.ZoomButton;
import com.utils.FontFactory;

import flash.display.Shape;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

public class GraphControls extends Sprite {
    public static const HEADER_OFFSET:uint = 5;
    public static const RIGHT_OFFSET:uint = 5;
    public static const HEIGHT:uint = 20;
    protected var backToLiveBtn:BackToLiveButton;
    private var _zoomInBtn:BitmapButton;
    private var _zoomOutBtn:BitmapButton;
    protected var controlsChild:Sprite;
    protected var graphInstance:GraphInstance;
    protected var yDataSelectorList:GraphDropdown
    protected var _zoomLevelLabel:TextField;
    private var _moveArea:Sprite
    public function GraphControls(graphInstance:GraphInstance) {
        super();
        this.graphInstance = graphInstance;
        generateControls();
    }

    protected function generateControls():void {
        this.y = 5;
        controlsChild = new Sprite();
        this.addChild(controlsChild);
        this._moveArea = new Sprite();
        this.addChild(this._moveArea);
        createZoomLevelLabel();
        createZoomButtons();
        createYDataList();
        createBackToLiveBtn();


    }

    private var _zoomLevelLabelWidth:uint = 85;

    protected function createZoomLevelLabel():void {
        _zoomLevelLabel = FontFactory.getDataAxisFont();
        _zoomLevelLabel.x = 30;
        _zoomLevelLabel.height = 15;
        _zoomLevelLabel.width = _zoomLevelLabelWidth;
        _zoomLevelLabel.textColor = 0xffffff
        this.addChild(_zoomLevelLabel);
    }

    protected function createBackToLiveBtn():void {
        //backToLiveBtn = new MenuElement("back to live", graphInstance.backToLive);
        backToLiveBtn = new BackToLiveButton();
        backToLiveBtn.visible = false;
        backToLiveBtn.y = 0;//yDataSelectorList.buttonHeight() + 5;
        backToLiveBtn.addEventListener(MouseEvent.CLICK, graphInstance.backToLive, false, 0, true);
        this.addChild(backToLiveBtn);
    }


    private function createZoomButtons():void {
        _zoomInBtn = new ZoomButton(null, "+");
//        _zoomInBtn.x = 62;
//        _zoomInBtn.y = 0;
        _zoomInBtn.addEventListener(MouseEvent.CLICK, graphInstance.zoomInBtn_clickHandler, false, 0, true);
        this.addChild(_zoomInBtn);

        _zoomOutBtn = new ZoomButton(null, "-");
//        _zoomOutBtn.x = 32;
//        _zoomOutBtn.y = 0;
        _zoomOutBtn.addEventListener(MouseEvent.CLICK, graphInstance.zoomOutBtn_clickHandler, false, 0, true);
        this.addChild(_zoomOutBtn);
    }


    protected function createYDataList():void {
        yDataSelectorList = new GraphDropdown();

        for (var i:int = 0; i < YDatas.datas.length; i++) {
            yDataSelectorList.addElement(YDatas.datas[i].label, YDatas.datas[i].dataKey)
        }
        yDataSelectorList.setSelectedData(graphInstance.yData);

        yDataSelectorList.addEventListener(ListElementSelectedEvent.SELECT, dropDownList_LIST_ELEMENT_SELECTEDHandler, false, 0, true);
//        yDataSelectorList.x = _zoomLevelLabelWidth + 60;
        yDataSelectorList.scaleDownList();
        this.addChild(yDataSelectorList);
    }

    protected function dropDownList_LIST_ELEMENT_SELECTEDHandler(event:ListElementSelectedEvent):void {
        graphInstance.yDataChange(event.data);
    }

    internal function set enableYDataList(value:Boolean):void {
        yDataSelectorList.enableButton = value;
    }

    internal function resize(w:int, h:int, ready:Boolean):void {
        this.x = graphInstance.frameSprite.leftFrameWidth;
        this.y = graphInstance.frameSprite.topFrameHeight;
        positionControls(w)
        this.graphics.clear();
        this.graphics.beginFill(GraphColors.HEADER_BG_COLOR);
        this.graphics.drawRect(0, 0, w - graphInstance.frameSprite.leftFrameWidth - graphInstance.frameSprite.rightFrameWidth, HEIGHT);
        this.graphics.endFill();
        this._moveArea.graphics.clear();
        this._moveArea.graphics.beginFill(GraphColors.HEADER_BG_COLOR);
        this._moveArea.graphics.drawRect(0, 0, w - graphInstance.frameSprite.leftFrameWidth - graphInstance.frameSprite.rightFrameWidth, HEIGHT);
        this._moveArea.graphics.endFill();
        yDataSelectorList.resize(h - GraphInstance.vAxisWidth - 10);
        if (!ready) {
            yDataSelectorList.scaleDownList()
        }
    }

    public function get moveArea():Sprite {
        return _moveArea;
    }

    private function positionControls(width:int):void {
        yDataSelectorList.x = width - yDataSelectorList.width - RIGHT_OFFSET-graphInstance.frameSprite.rightFrameWidth;
        _zoomInBtn.x = yDataSelectorList.x - _zoomInBtn.width;
        _zoomOutBtn.x = _zoomInBtn.x - _zoomOutBtn.width;
        if (width < (yDataSelectorList.width + _zoomInBtn.width + _zoomOutBtn.width + RIGHT_OFFSET + _zoomLevelLabelWidth + (backToLiveBtn.visible ? backToLiveBtn.width : 0))) {
            backToLiveBtn.x = _zoomOutBtn.x - backToLiveBtn.width;
            _zoomLevelLabel.visible = false;
        } else {
            _zoomLevelLabel.visible = true;
            backToLiveBtn.x = _zoomOutBtn.x - _zoomLevelLabelWidth - backToLiveBtn.width;
        }
        _zoomLevelLabel.x = _zoomOutBtn.x - _zoomLevelLabel.width;

    }

    internal function setBackToLiveVisible(value:Boolean):void {
        if (backToLiveBtn == null) {
            return;
        }
        backToLiveBtn.visible = value;
    }


    internal function disableZoomInBtn():void {
        if (_zoomInBtn == null) {
            return;
        }
        _zoomInBtn.enabled = false;
    }

    internal function enableZoomInBtn():void {
        if (_zoomInBtn == null) {
            return;
        }
        _zoomInBtn.enabled = true;
    }

    internal function disableZoomoutBtn():void {
        if (_zoomOutBtn == null) {
            return;
        }
        _zoomOutBtn.enabled = false;
    }

    internal function enableZoomOutBtn():void {
        if (_zoomOutBtn == null) {
            return;
        }
        _zoomOutBtn.enabled = true;
    }


    internal function get zoomInBtn():BitmapButton {
        return _zoomInBtn;
    }

    internal function get zoomOutBtn():BitmapButton {
        return _zoomOutBtn;
    }

    public function setZoomLevelLabel(text:String):void {
        if (_zoomLevelLabel == null) {
            return;
        }
        _zoomLevelLabel.text = text;
    }
}
}
