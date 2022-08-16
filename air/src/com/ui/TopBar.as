/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.03.21.
 * Time: 15:17
 * To change this template use File | Settings | File Templates.
 */
package com.ui {
import com.common.AppProperties;
import com.events.UnitChangedEvent;
import com.layout.LayoutHandler;
import com.sailing.WindowsHandler;
import com.sailing.socket.SocketDispatcher;
import com.sailing.units.Direction;
import com.sailing.units.UnitHandler;
import com.store.Statuses;
import com.timeline.LogReplayAS;
import com.ui.controls.BitmapButton;
import com.ui.controls.CloseButton;
import com.ui.controls.ControllAddButton;
import com.ui.controls.InstrumentsGroup;
import com.ui.controls.Menu;
import com.utils.Blinker;
import com.utils.FontFactory;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

//import com.ui.controls.DropDownListSVE;
//import components.menu.Menu;
//import components.menu.MenuList;

public class TopBar extends Sprite {
    public static const barHeight:int = 30;
    public static const leftContentWidth:int = 258;
    public static const rightContentWidth:int = 80;
    public static var logReplayWidth:int;

    //[Embed(source='../../../assets/images/bar_image.png')] var bgPng:Class;
    [Embed(source='../../../assets/images/logo.png')] var logoPng:Class;
    [Embed(source='../../../assets/images/Layout pngs/menu_btn01.png')] var menuPng01:Class;
    [Embed(source='../../../assets/images/Layout pngs/menu_btn02.png')] var menuPng02:Class;
    [Embed(source='../../../assets/images/Layout pngs/ledit_closebtn01.png')] var closePng01:Class;
    [Embed(source='../../../assets/images/Layout pngs/ledit_closebtn02.png')] var closePng02:Class;
    [Embed(source='../../../assets/images/Layout pngs/window_minim_down.png')] var minimize_down:Class;
    [Embed(source='../../../assets/images/Layout pngs/window_minim_up.png')] var minimize_up:Class;
    [Embed(source='../../../assets/images/Layout pngs/add_btn_down01.png')]
    static var addBtnDown1:Class;
    [Embed(source='../../../assets/images/Layout pngs/add_btn_down02.png')]
    static var addBtnDown2:Class;
    [Embed(source='../../../assets/images/Layout pngs/add_btn_up01.png')]
    static var addBtnUp01:Class;
    [Embed(source='../../../assets/images/Layout pngs/add_btn_up02.png')]
    static var addBtnUp02:Class;

    private static var _menuList:Menu;
    private static var _menuBtn:BitmapButton

    private static var _timeline:LogReplayAS;
    private static var _controllAddContainer:Sprite;
    private static var _instrumentsGroup:InstrumentsGroup;

    private static var _rightContainer:Sprite;
    private static var addBtnDown:BitmapButton;// = new BitmapButton(addBtnDown1,addBtnDown1,addBtnDown2,addBtnDown1,addBtnDown2, 49, 21);;
    private static var addBtnUp:BitmapButton;

    private static var _connectionState:Sprite;
    private static var _directionLabel:TextField;
    private static var _simulationLabel:TextField;
    public var id:String = "topBar"

    public function TopBar() {
        this.x = 0;
        this.y = 0;
        logReplayWidth = AppProperties.screenWidth - leftContentWidth - 5 - rightContentWidth;
        _instrumentsGroup = new InstrumentsGroup();

        addChild(_instrumentsGroup);
        createControllAddContainer();
        drawBg();
        //createLeftIcon();
        createMenu();
        createMenuList();
        createLayoutButtons();
        createConnectionState();
        createSimulationLabel();
        createLogReplay();
        createExitBtn();
        createDirectionLabel();

        //addDDL(); Add DropDownListMenu , ListMenu
    }


    public function reDraw():void {
        logReplayWidth = AppProperties.appScreenWidth - leftContentWidth - 5 - rightContentWidth;
        _timeline.width = logReplayWidth;
        _rightContainer.x = AppProperties.appScreenWidth - rightContentWidth;
        _instrumentsGroup.rePosition();
        positionOpenCloseBtn()
    }

    private function createControllAddContainer():void {
        _controllAddContainer = new Sprite();
        _controllAddContainer.visible = false;
        positionOpenCloseBtn();
        _controllAddContainer.y = barHeight;
        addBtnDown = new BitmapButton(addBtnDown1, addBtnDown1, addBtnDown2, addBtnDown1, addBtnDown2);
        addBtnDown.addEventListener(MouseEvent.CLICK, addNewListHandler, false, 0, true);

        addBtnUp = new BitmapButton(addBtnUp01, addBtnUp01, addBtnUp02, addBtnUp01, addBtnUp02);
        addBtnUp.addEventListener(MouseEvent.CLICK, addNewListHandler, false, 0, true);
        addBtnUp.y = 95;
        addBtnUp.visible = false;

        _controllAddContainer.addChild(addBtnDown);
        _controllAddContainer.addChild(addBtnUp);
        this.addChild(_controllAddContainer)
    }

    private function positionOpenCloseBtn():void {
        _controllAddContainer.x = AppProperties.appScreenWidth - 49; //leftContentWidth;
    }

    public static function hideInstrumentsGroup():void {
        addBtnUp.visible = false;
        instrumentsGroup.visible = false;
        addBtnDown.visible = true;
    }

    public static function showInstrumentsGroup():void {
        addBtnDown.visible = false;
        instrumentsGroup.visible = true;
        addBtnUp.visible = true;
        instrumentsGroup.setSwBtnState(LayoutHandler.instance.isFullscreen());
    }

    protected function addNewListHandler(event:MouseEvent):void {
        if (instrumentsGroup.visible) {
            hideInstrumentsGroup();
        } else {
            showInstrumentsGroup();
        }
    }

    private function createMenuList():void {
        _menuList = new Menu();

        _menuList.x = 10;
        _menuList.y = barHeight + 2;
        _menuList.currentState = "closed";
//        _menuList.depth = 100;

        addChild(_menuList);
    }

    private function createConnectionState():void {
        _connectionState = new Sprite;
        setConnectionStatusColor();
        _connectionState.x = leftContentWidth + 3;
        _connectionState.y = 5;
        addChild(_connectionState);

        WindowsHandler.instance.application.socketDispatcher.addEventListener("connectDisconnect", connectDisconnectHandler, false, 0, true);
    }

    private function connectDisconnectHandler(e:Event):void {
        _connectionState.graphics.clear();
        setConnectionStatusColor();
    }

    private function setConnectionStatusColor():void {
        if (Statuses.instance.socketStatus && !WindowsHandler.instance.application.socketDispatcher.isDemoConnected) {
            _connectionState.graphics.beginFill(0x00ff00);
            _connectionState.graphics.drawCircle(0, 0, 3);
            _connectionState.graphics.endFill();
        } else {
            _connectionState.graphics.beginFill(0x000000);
            _connectionState.graphics.drawCircle(0, 0, 3);
            _connectionState.graphics.endFill();
        }
    }

    private function createDirectionLabel():void {
        //var element:Sprite = new Sprite();
        _directionLabel = FontFactory.getCustomFont({ align: "left", autoSize: "left", size: 16, color: 0xffffff, bold:true });
        _directionLabel.x = 5;
        _directionLabel.y = 3;
        setDirectionUnit();
        //element.addChild(_directionLabel);
        _rightContainer.addChild(_directionLabel);

        UnitHandler.instance.addEventListener(UnitChangedEvent.CHANGE, unitChangeHandler, false, 0, true);
    }

    private function setDirectionUnit():void {
        switch (UnitHandler.instance.direction) {
            case Direction.TRUE:
                _directionLabel.text = "T";
                _directionLabel.textColor = 0xffffff;
                break;
            case Direction.MAGNETIC:
                _directionLabel.text = "M";
                _directionLabel.textColor = 0xffffff;
                break;
            case Direction.FORCED_MAGNETIC:
                _directionLabel.text = "M";
                _directionLabel.textColor = 0xff0000;
                break;
        }
    }

    private function unitChangeHandler(e:UnitChangedEvent):void {
        if (e.typeKlass == Direction) {
            setDirectionUnit();
        }
    }

    private function createSimulationLabel():void {
        //var element:Sprite = new Sprite();
//        _simulationLabel = FontFactory.getLeftTextField();
//        _simulationLabel.textColor = 0xff0000;
        _simulationLabel = FontFactory.getCustomFont({ align: "left", autoSize: "left", size: 16, color: 0xffffff });
        _simulationLabel.text = "Simulation";
        _simulationLabel.x = leftContentWidth + 5;
        _simulationLabel.y = 3;
        _simulationLabel.visible = false;
        //element.addChild(_simulationLabel);
        //addChild(element);
        addChild(_simulationLabel);
        //Blinker.addObject(element);
        //Blinker.addObject(_simulationLabel);
    }

    public static function visibleSimulationLabel(value:Boolean):void {
        if (_simulationLabel != null) {
            if (value) {
                Blinker.addObject(_simulationLabel);
            } else {
                Blinker.removeObject(_simulationLabel);
            }
            _simulationLabel.visible = value;
        }
    }

    private function createLogReplay():void {
        _timeline = new LogReplayAS();
        _timeline.currentState = "closed";
        _timeline.visible = false;
        _timeline.x = leftContentWidth;
        addChild(_timeline);
    }

    protected function toggleMenuHandler(event:MouseEvent):void {
        if (_menuList.currentState == "opened") {
            _menuList.setCurrentState("closed");
        } else {
            _menuList.setCurrentState("opened");
            _menuBtn.enabled = false;
        }

    }

//
    private function drawBg():void {
//        var bar:Shape = new Shape();
        //bar.graphics.beginBitmapFill((new bgPng() as Bitmap).bitmapData);
        this.graphics.clear();
        this.graphics.beginFill(0x7b7b7b);
        this.graphics.drawRect(0, 0, AppProperties.screenWidth, barHeight);
        this.graphics.endFill();
//        addChild(bar)
    }

//
////    private function createLeftIcon():void {
////        var logoBitmap:Bitmap = new logoPng();
////
////        var logo:Sprite = new Sprite()
////        logo.width = 52;
////        logo.height = 37;
////        logo.x = 5;
////        logo.y = 0;
////        logo.addChild(logoBitmap)
////        addElement(logo);
////    }
//
//
    private function createMenu():void {

        _menuBtn = new BitmapButton(menuPng01, menuPng01, menuPng02, menuPng01, menuPng02);
        _menuBtn.id = "menuLabel";
        _menuBtn.addEventListener(MouseEvent.CLICK, toggleMenuHandler, false, 0, true);
        var menuSp:Sprite = new Sprite();
        menuSp.addChild(_menuBtn);
        this.addChild(menuSp);
    }

//
    private function createExitBtn():void {
        _rightContainer = new Sprite();
        _rightContainer.x = AppProperties.screenWidth - rightContentWidth;
        _rightContainer.y = 0;
        var exitBtn:CloseButton = new CloseButton();
        exitBtn.x = rightContentWidth - 24;
        exitBtn.y = 6;
        exitBtn.addEventListener(MouseEvent.CLICK, exitBtn_clickHandler, false, 0, true);
        _rightContainer.addChild(exitBtn)
        var minimizeBtn:BitmapButton = new BitmapButton(minimize_up, minimize_down, minimize_down, minimize_down, minimize_down);
        minimizeBtn.x = rightContentWidth - 48;
        minimizeBtn.y = 7;
        minimizeBtn.addEventListener(MouseEvent.MOUSE_UP, minimizeBtn_mouseUpHandler, false, 0, true);
        _rightContainer.addChild(minimizeBtn)
        addChild(_rightContainer);
    }

    private function createLayoutButtons():void {
        addChild(new LayoutChangeBar(45));
    }

    private function menuClickHandler(event:MouseEvent):void {
        //TODO implement menu open
    }

    public static function get menuList():Menu {
        return _menuList;
    }

    public static function get timeline():LogReplayAS {
        return _timeline;
    }

    public static function get controllAddContainer():Sprite {
        return _controllAddContainer;
    }


    public static function get instrumentsGroup():InstrumentsGroup {
        return _instrumentsGroup;
    }

    private function exitBtn_clickHandler(event:MouseEvent):void {
        //NativeApplication.nativeApplication.exit();
        this.stage.nativeWindow.dispatchEvent(new Event(Event.CLOSING));
    }

    private function onOffBgBtn_clickHandler(event:MouseEvent):void {
        LayoutHandler.instance.changeFullScreen(event)
    }


    public static function get menuBtn():BitmapButton {
        return _menuBtn;
    }

    private function minimizeBtn_mouseUpHandler(event:MouseEvent):void {
        NativeApplication.nativeApplication.activeWindow.minimize();
    }
}
}
