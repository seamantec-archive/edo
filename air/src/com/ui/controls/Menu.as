/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.06.27.
 * Time: 14:33
 * To change this template use File | Settings | File Templates.
 */
package com.ui.controls {
import com.alarm.AlarmHandler;
import com.common.AppProperties;
import com.events.CloudEvent;
import com.events.EnableDisableEvent;
import com.layout.LayoutHandler;
import com.notification.NotificationHandler;
import com.notification.NotificationTypes;
import com.polar.PolarContainer;
import com.sailing.WindowsHandler;
import com.sailing.socket.SocketDispatcher;
import com.seamantec.LicenseEvent;
import com.store.SettingsConfigs;
import com.store.Statuses;
import com.ui.TopBar;
import com.harbor.CloudHandler;

import components.cloud.LogInWindow;

import components.cloud.PolarWindow;

import components.message.MessagesWindow;
import components.settings.SettingsWindow;
import components.windows.FloatWindow;

import flash.display.GradientType;
import flash.display.InterpolationMethod;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;

public class Menu extends Sprite {
    public static const MENU_WIDTH:uint = 170;
    [Embed(source="../../../../assets/icons/grey_icon.png")]
    private static var ICON:Class;
    private static var closeLog:MenuElement;
    private static var alarmsE:MenuElement;
    private static var editLayoutE:MenuElement;
    private static var connectDisconnectE:MenuElement;
    private static var openPolarE:MenuElement;
    private static var logInE:MenuElement;
    private static var recordLogE:MenuElement;
    private static var activateLicense:MenuElement;
    private static var loadLog:MenuElement;
    private static var nmeaMessagesE:MenuElement;
    private static var demoConnect:MenuElement;
    private static var loadPolar:MenuElement;
    private static var settings:MenuElement;
    private static var ais:MenuElement;

    public function Menu() {
        AppProperties.licenseManager.addEventListener(LicenseEvent.ACTIVATED, licenceMangerActivatedHandler, false, 0, true);
        AppProperties.licenseManager.addEventListener(LicenseEvent.DEACTIVATED, licenceMangerDeactivatedHandler, false, 0, true);
        demoConnect = new MenuElement("Start Simulation", simulateConnection);
        CloudHandler.instance.addEventListener(CloudEvent.SIGNIN_COMPLETE, signInHandler, false, 0, true);
        CloudHandler.instance.addEventListener(CloudEvent.SIGNOUT, signInHandler, false, 0, true);

        closeLog = new MenuElement("Close NMEA log", closeLogClickHandler);
        closeLog.enabled = false;
        alarmsE = new MenuElement("Alarms...", alarmsClickHandler);
        alarmsE.addBadge();

        editLayoutE = new MenuElement("Edit Layout", editModeClickHandler);
        connectDisconnectE = new MenuElement("Connect", connectDisconnect);
        recordLogE = new MenuElement("Record NMEA log", recordLogClickHandler);
        recordLogE.addIcon(ICON);
        loadLog = new MenuElement("Load NMEA Log...", loadLogClickHandler);
        setIconVisibility();

        nmeaMessagesE = new MenuElement("NMEA messages list...", openMessagesClickHandler);

        activateLicense = new MenuElement("Product info...", licenseClickHandler);
        loadPolar = new MenuElement("Load polar table...", loadPolarHandler);
        settings = new MenuElement("Settings...", settingsClickHandler);
        ais = new MenuElement("AIS vessel list...", openAisList);
        AlarmHandler.instance.addEventListener("activeAlarmCounterChanged", activeAlarmCounterChangedHandler, false, 0, true);


        openPolarE = new MenuElement("Polar files...", openPolarHandler);
        openPolarE.enabled = CloudHandler.instance.email!=null && CloudHandler.instance.token!=null;
        logInE = new MenuElement((openPolarE.enabled) ? CloudHandler.instance.email : "Log in...", logInHandler);

        createBegining();
        addMenuElement(demoConnect);
        addMenuElement(connectDisconnectE);
        addSeparator(new MenuSeparator());
        addMenuElement(editLayoutE);
        addSeparator(new MenuSeparator());
        addMenuElement(loadLog);
        addMenuElement(closeLog);
        //addMenuElement(new MenuElement("Record Log", recordLogClickHandler));
        addMenuElement(recordLogE);

        addSeparator(new MenuSeparator());

        addMenuElement(loadPolar);
        addSeparator(new MenuSeparator());
        addMenuElement(alarmsE);
        addMenuElement(new MenuElement("Logbook...", openLogBook));
        addMenuElement(ais)
        addMenuElement(nmeaMessagesE);
        addSeparator(new MenuSeparator());

        addMenuElement(settings);
        addMenuElement(activateLicense);
        addSeparator(new MenuSeparator());
        addMenuElement(logInE);
        addMenuElement(openPolarE);
        addSeparator(new MenuSeparator());
        addMenuElement(new MenuElement("Exit", exitClickHandler));

        createEnding()
        dropShadow();

        (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).addEventListener("connectDisconnect", connectDisconnectHandler, false, 0, true);
        (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).addEventListener("connectDisconnectDemo", connectDisconnectDemoHandler, false, 0, true);
        getConnectionLabel();
        getEnableDisableAis();
        this.addEventListener(EnableDisableEvent.ENABLE_DISABLE, enableDisableElementHandler, false, 0, true);
//        createGradiens()
        setElementsEnableOrDisableByLicense();
    }


    private var actualY:int = 6;

    private var _currentState:String = "closed";

    public function get currentState():String {
        return _currentState;
    }

    public function set currentState(state:String):void {
        setCurrentState(state);
    }

    public function addMenuElement(element:MenuElement):void {
        element.y = actualY;
        element.x = 0;
        this.addChild(element);
        actualY += element.height;
    }

    public function addSeparator(separator:MenuSeparator):void {
        separator.y = actualY;
        separator.x = 0;
        this.addChild(separator);
        actualY += separator.height;
    }

    public function setCurrentState(state:String):void {
        if (state == "opened") {
            this.visible = true;
            LayoutHandler.instance.turnOnOffAlwaysOnTheTop(false);

        } else if (state == "closed") {
            this.visible = false;
            LayoutHandler.instance.turnOnOffAlwaysOnTheTop(true);
        }

    }

    private function setIconVisibility():void {
        SettingsConfigs.instance.logging ? recordLogE.showIcon() : recordLogE.hideIcon();
    }

    private function dropShadow():void {
        var shadow:DropShadowFilter = new DropShadowFilter();
        shadow.distance = 7;
        shadow.alpha = 0.5
        shadow.angle = 30;

        this.filters = [shadow];
    }

    private function createBegining():void {
        var b:Sprite = new Sprite();
        b.graphics.clear();
        b.graphics.beginFill(0xc9c9c9);
        b.graphics.drawRoundRectComplex(0, 0, Menu.MENU_WIDTH, 6, 5, 5, 0, 0);
        b.graphics.endFill();
        addChild(b)
    }

    private function createEnding():void {
        var b:Sprite = new Sprite();
        b.graphics.clear();
        b.graphics.beginFill(0xc9c9c9);
        b.graphics.drawRoundRectComplex(0, actualY, Menu.MENU_WIDTH, 6, 0, 0, 5, 5);
        b.graphics.endFill();
        addChild(b)
        actualY += 6;
    }

    private function createGradiens():void {
        var gradientBoxMatrix:Matrix = new Matrix();
        gradientBoxMatrix.createGradientBox(10, 300, 0, -5, 0);
        var b:Sprite = new Sprite();
        b.x = 130;
        b.graphics.clear();
        b.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0xFFFFFF], [0.7, 0], [0, 255], gradientBoxMatrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB)
        b.graphics.drawRect(0, 0, 20, 300);
        b.graphics.endFill();
        addChildAt(b, 0)
        var gradientBoxMatrix2:Matrix = new Matrix();
        gradientBoxMatrix2.createGradientBox(130, 10, Math.PI / 2, 0, -5);
        var b2:Sprite = new Sprite();
        b2.x = 0;
        b2.y = 300;
        b2.graphics.clear();
        b2.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0xFFFFFF], [0.7, 0], [0, 255], gradientBoxMatrix2, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB)
        //        b2.graphics.beginFill(0xff0000);
        b2.graphics.drawRect(0, 0, 130, 20);
        b2.graphics.endFill();
        addChildAt(b2, 1)

    }

    private function getConnectionLabel():void {
        if (Statuses.instance.socketStatus && !WindowsHandler.instance.application.socketDispatcher.isDemoConnected) {
            connectDisconnectE.label = "Disconnect";
        } else {
            connectDisconnectE.label = "Connect";

        }
    }

    private function getEnableDisableAis():void {
        if (Statuses.instance.socketStatus) {
            ais.enabled = true;
        } else {
            ais.enabled = false;

        }
    }

    private function editLabel():void {
        editLayoutE.label = (LayoutHandler.instance.editMode ? 'Done Editing' : 'Edit Layout')
    }

    private function activeAlarmCounterChangedHandler(event:Event):void {
        alarmsE.changeBadgeLabel(AlarmHandler.instance.activeAlarmCounter.toString());
    }

    private function enableDisableElementHandler(event:EnableDisableEvent):void {
        if (Menu[event.elementId] == null) {
            return;
        }
        Menu[event.elementId].enabled = event.methodType === EnableDisableEvent.ENABLE ? true : false;
        if (event.elementId === "editLayoutE") {
            editLabel();
        }
        if (!nmeaMessagesE.enabled && AppProperties.messagesWin != null && !AppProperties.messagesWin.closed) {
            AppProperties.messagesWin.close();
        }
    }

    private function menuElementClickHandler(event:MouseEvent):void {
    }

    private function connectDisconnect(event:MouseEvent):void {
        WindowsHandler.instance.application.socketDispatcher.connectDisconnect();

    }

    private function simulateConnection(event:MouseEvent):void {
        if ((WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).isDemoConnected) {
            (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).stopDemoConnect();
        } else {
            (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).connectDemo();
        }
    }

    private function setDemoConnectLabel():void {
        if ((WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).isDemoConnected) {
            demoConnect.label = "Stop Simulation";
        } else {
            demoConnect.label = "Start Simulation";
        }

    }


    private function loadLogClickHandler(event:MouseEvent):void {
        TopBar.timeline.openLogReplay();
    }

    private function recordLogClickHandler(event:MouseEvent):void {
        SettingsConfigs.instance.logging = !SettingsConfigs.instance.logging;
        setIconVisibility();
    }

    private function openMessagesClickHandler(event:MouseEvent):void {
        if (AppProperties.messagesWin == null || AppProperties.messagesWin.closed) {
            AppProperties.messagesWin = new MessagesWindow();
        }

        AppProperties.messagesWin.activate();
    }

    private function closeLogClickHandler(event:MouseEvent):void {
        TopBar.timeline.hideLogReplay();
        TopBar.timeline.resetSpeed();
        enableAlarms(true);
        nmeaMessagesE.enabled = true;
//        if(AppProperties.settingWin!=null) {
//            AppProperties.settingWin.enableLLN();
//        }
    }

    private function editModeClickHandler(event:MouseEvent):void {
        if (LayoutHandler.instance.editMode) {
            TopBar.hideInstrumentsGroup();
        }
        LayoutHandler.instance.editMode = !LayoutHandler.instance.editMode;
        editLabel();
    }

    private function alarmsClickHandler(event:MouseEvent):void {
        AppProperties.openAlarmWindow();
    }

    private function settingsClickHandler(event:MouseEvent):void {
        if (AppProperties.settingWin == null || AppProperties.settingWin.closed) {
//            AppProperties.settingWin = new SettingsWindowAS();
            AppProperties.settingWin = new SettingsWindow();
        }
        AppProperties.settingWin.activate();
    }

    private function exitClickHandler(event:MouseEvent):void {
//        NativeApplication.nativeApplication.exit()
        this.stage.nativeWindow.dispatchEvent(new Event(Event.CLOSING));
    }

    private function openAisList(event:MouseEvent):void {
        AppProperties.openAisWindow();
    }

    private function loadPolarHandler(event:MouseEvent):void {
        PolarContainer.instance.loadFromFile();
    }

    private function licenseClickHandler(event:MouseEvent):void {
        AppProperties.openLicenseWindow();
    }

    private function openLogBook(event:MouseEvent):void {
        AppProperties.openLogBookWindow();
    }

    private function licenceMangerActivatedHandler(event:LicenseEvent):void {
        setElementsEnableOrDisableByLicense()
    }

    private function licenceMangerDeactivatedHandler(event:LicenseEvent):void {
        setElementsEnableOrDisableByLicense()
    }


    private function setElementsEnableOrDisableByLicense():void {
        disableComElements()

        if (AppProperties.getStrongestLicense() != null) {
            if (AppProperties.isDemoProduct()) {
                enableDemoElements();
            } else {
                enableComElements();
            }
        }
    }

    private function disableDemoElements():void {
        loadLog.disableByLicense()
        demoConnect.disableByLicense()
    }

    private function enableDemoElements():void {
        demoConnect.enableByLicense();
        loadLog.enableByLicense();
    }

    private function disableComElements():void {
        recordLogE.disableByLicense();
//        loadPolar.disableByLicense();
        connectDisconnectE.disableByLicense();
        disableDemoElements()
    }

    private function enableComElements():void {
        enableDemoElements();
        recordLogE.enableByLicense();
//        loadPolar.enableByLicense();
        connectDisconnectE.enableByLicense();
    }

    public static function enableAlarms(value:Boolean):void {
        alarmsE.enabled = value;
        if (value) {
            alarmsE.badge.visible = true;
        } else {
            alarmsE.badge.visible = false;
            if (AppProperties.alarmWindow != null && !AppProperties.alarmWindow.closed) {
                AppProperties.alarmWindow.close();
            }
        }
    }

    private function connectDisconnectHandler(event:Event):void {
        getConnectionLabel();
        getEnableDisableAis();
        enableAlarms(true);
        TopBar.visibleSimulationLabel(false);
        if (Statuses.instance.socketStatus) {
            demoConnect.enabled = false;
        } else {
            demoConnect.enabled = true;
        }

    }

    private function connectDisconnectDemoHandler(event:Event):void {
        getEnableDisableAis();
        setDemoConnectLabel();
        enableAlarms(true);
    }

    private function logInHandler(event:Event):void {
        if(openPolarE.enabled) {
            NotificationHandler.createAlert(NotificationTypes.SIGN_OUT, NotificationTypes.SIGN_OUT_TEXT, 0, signOutHandler);
        } else {
            if (AppProperties.logInWin == null || AppProperties.logInWin.closed) {
                AppProperties.logInWin = new LogInWindow();
            }
            AppProperties.logInWin.activate();
        }
    }

    private function openPolarHandler(event:Event):void {
        if (AppProperties.polarWin == null || AppProperties.polarWin.closed) {
            AppProperties.polarWin = new PolarWindow();
        }
        AppProperties.polarWin.activate();
    }

    private function signInHandler(event:Event):void {
        var loggedIn:Boolean = CloudHandler.instance.email!=null && CloudHandler.instance.token!=null;
        logInE.label = (loggedIn) ? CloudHandler.instance.email : "Log in...";
        openPolarE.enabled = loggedIn;
    }

    private function signOutHandler():void {
        if (AppProperties.polarWin!=null && !AppProperties.polarWin.closed) {
            AppProperties.polarWin.close();
        }
        CloudHandler.instance.remove(true);

    }
}
}
