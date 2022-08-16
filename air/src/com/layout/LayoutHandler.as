package com.layout {
import com.common.AppProperties;
import com.events.EnableDisableEvent;
import com.sailing.WindowsHandler;
import com.store.Statuses;
import com.ui.TopBar;
import com.ui.controls.InstrumentsGroup;
import com.ui.controls.TopButtonCustom;

import flash.desktop.NativeApplication;
import flash.display.NativeWindow;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

public class LayoutHandler extends EventDispatcher {
    private static var _instance:LayoutHandler;
    private var _editMode:Boolean = false;
    private var _editEnabled:Boolean = false;
    private var _activeBtn:TopButtonCustom;
    private var _loadedButtonName:String;
    private var _layoutContainer:Object;
    public var bgAlpha
    //TODO encapsulate this
    private var _activeLayout:Layout;

    public function LayoutHandler() {
        if (_instance != null) {

        } else {
            _instance = this;
            _layoutContainer = new Object();
            initLayouts();
        }
    }

    private function initLayouts():void {
        _layoutContainer["ship"] = new Layout("ship");
        _layoutContainer["wheel"] = new Layout("wheel");
        _layoutContainer["stopwatch"] = new Layout("stopwatch");
        _layoutContainer["usr1"] = new Layout("usr1");
        _layoutContainer["usr2"] = new Layout("usr2");
        _layoutContainer["usr3"] = new Layout("usr3");
        _layoutContainer["usr4"] = new Layout("usr4");
    }


    public function get loadedButtonName():String {
        return _loadedButtonName;
    }

    public function set loadedButtonName(value:String):void {
        _loadedButtonName = value;
    }

    public function changeFullScreen(event:MouseEvent):void {
        _activeLayout.toggleFullScreen();
    }

    public function isFullscreen():Boolean {
        return _activeLayout.isFullscreen;
    }

    public function toggleFullscreen():void {
        if (!_activeLayout.isFullscreen) {
            WindowsHandler.instance.application.setControlStageAlpha(0.0)
            if (Statuses.instance.isMac()) {
                WindowsHandler.instance.application.stage.displayState = StageDisplayState.NORMAL;
                //WindowsHandler.instance.application.setStageDisplayState()
                WindowsHandler.instance.application.stage.nativeWindow.maximize();
                WindowsHandler.instance.application.repositionTopBar()
//                WindowsHandler.instance.application.topBar.y = 22
            }
        } else {
            WindowsHandler.instance.application.setControlStageAlpha(1.0)
            if (Statuses.instance.isMac()) {
//                WindowsHandler.instance.application.topBar.y = 0
                WindowsHandler.instance.application.setStageDisplayState()
                WindowsHandler.instance.application.repositionTopBar()
            }
        }
    }


    public function get editEnabled():Boolean {
        return _editEnabled;
    }

    public function set editEnabled(value:Boolean):void {
        _editEnabled = value;
        if (!value) {
            editMode = false;
        }
    }

    public function get editMode():Boolean {
        return _editMode;
    }

    public function set editMode(value:Boolean):void {
        _editMode = value;
        if (!value) {
            _activeLayout.saveLayout();
            TopBar.controllAddContainer.visible = false;
            TopBar.hideInstrumentsGroup();
        } else {
            TopBar.controllAddContainer.visible = true;
            TopBar.showInstrumentsGroup();
        }
        _activeLayout.deselectVessel(); // maybe just close it and reopen after edit mode
        _activeLayout.closePolarSettings();
        dispatchEvent(new Event("editModeChanged"))
    }

    public function get activeBtn():TopButtonCustom {
        return _activeBtn;
    }


    /**
     * In this method, we change tha layouts.
     * when the user select a different layout button
     * */
    public function switchLayout():void {
//        var filename:String = "";
//        setScreen();
        if (_activeLayout != null) {
            _activeLayout.deactivate();
            setContainer();
        }

        activeLayout = _layoutContainer[_activeBtn.id];

        if (_activeLayout.isFullscreen) {
            InstrumentsGroup.bgSwBtn.state = true;
        } else {
            InstrumentsGroup.bgSwBtn.state = false;
        }
        if (_activeLayout.editEnabled) {
            TopBar.menuList.dispatchEvent(new EnableDisableEvent(EnableDisableEvent.ENABLE, "editLayoutE"))
        } else {
            TopBar.menuList.dispatchEvent(new EnableDisableEvent(EnableDisableEvent.DISABLE, "editLayoutE"))
        }

    }

    private function setContainer():void {
        if (_activeLayout.initWidth != AppProperties.screenWidth || _activeLayout.initHeight != AppProperties.screenHeight) {
            _layoutContainer["ship"] = new Layout("ship");
            _layoutContainer["wheel"] = new Layout("wheel");
            _layoutContainer["stopwatch"] = new Layout("stopwatch");
            _layoutContainer["usr1"] = new Layout("usr1");
            _layoutContainer["usr2"] = new Layout("usr2");
            _layoutContainer["usr3"] = new Layout("usr3");
            _layoutContainer["usr4"] = new Layout("usr4");
        }
    }

    public function set activeBtn(value:TopButtonCustom):void {
        if (_activeBtn) {
            _activeBtn.enabled = true;
        }
        value.enabled = false;
        _activeBtn = value;
    }


    public static function get instance():LayoutHandler {
        if (_instance == null) {
            _instance = new LayoutHandler();
        }
        return _instance;
    }


    public function get activeLayout():Layout {
        return _activeLayout;
    }

    public function set activeLayout(value:Layout):void {
        _activeLayout = value;
        _activeLayout.activate();
    }


    public function get layoutContainer():Object {
        return _layoutContainer;
    }

    public function turnOnOffAlwaysOnTheTop(turnOn:Boolean = true):void {
        if (_activeLayout != null && !_activeLayout.isFullscreen) {
            if (AppProperties.licenseWin != null && !AppProperties.licenseWin.closed) {
                turnOn = false;
                AppProperties.licenseWin.orderToFront()
            }
            WindowsHandler.instance.application.stage.nativeWindow.alwaysInFront = !turnOn;
            try {
                var openedWindows:Vector.<NativeWindow> = NativeApplication.nativeApplication.activeWindow.listOwnedWindows();
                for (var i:int = 0; i < openedWindows.length; i++) {
                    (openedWindows[i]).alwaysInFront = turnOn;
                }
            } catch (e:Error) {

            }

        }
    }
}
}