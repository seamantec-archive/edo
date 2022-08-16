/**
 * Created by pepusz on 2014.06.19..
 */
package {
import com.alarm.AlarmHandler;
import com.alarm.speech.SpeechContainer;
import com.alarm.speech.SpeechHandler;
import com.common.AppProperties;
import com.common.TripDataHandler;
import com.events.AppClick;
import com.harbor.PolarFileHandler;
import com.harbor.WebsocketHandler;
import com.layout.LayoutHandler;
import com.logbook.LogBookDataHandler;
import com.loggers.DataLogger;
import com.loggers.LogRegister;
import com.notification.NotificationHandler;
import com.notification.NotificationTypes;
import com.notification.PolarNotification;
import com.polar.PolarContainer;
import com.sailing.ArcHandler;
import com.sailing.ForgatHandler;
import com.sailing.WindowsHandler;
import com.sailing.nmeaParser.utils.NmeaUtil;
import com.sailing.socket.SocketDispatcher;
import com.seamantec.License;
import com.seamantec.LicenseEvent;
import com.seamantec.LicenseManager;
import com.store.SettingsConfigs;
import com.store.Statuses;
import com.ui.SplashScreen;
import com.ui.TopBar;
import com.ui.VersionChecker;
import com.harbor.CloudHandler;
import com.utils.FontFactory;
import com.workers.WorkersHandler;

import components.ControlWindowAs;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.events.TimerEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.net.registerClassAlias;
import flash.system.Capabilities;
import flash.system.Worker;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.Timer;

public class Edo extends Sprite {
    registerClassAlias("com.store", SettingsConfigs);
    registerClassAlias("loggers", DataLogger);
    registerClassAlias("com.loggers.LogRegister", LogRegister);
    NmeaUtil.registerNmeaDatas();
    private var _controlStage:Sprite;
    [Embed(source="../assets/images/bg1.png")]
    private static var _bg:Class;
    private static var _bgBitmap:Bitmap = new _bg();
    public var topBar:TopBar;
    public var firstActivate:Boolean = false;
    public var hasInvoked:Boolean = false;
    public var splashScreen:SplashScreen;
    public var socketDispatcher:SocketDispatcher;
    var newVersionBubble:Sprite = new Sprite();
    var versionBubbleTimer:Timer = new Timer(10000, 1);
    var _appReady:Boolean = false;

    public static const INIT_WIDTH:uint = 1024;
    public static const INIT_HEIGHT:uint = 768;
    public static const LAYOUT_TEST:Boolean = false;

    public function Edo() {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        if (Statuses.instance.isMac()) {
//            this.stage.nativeWindow.maximize()
            setStageDisplayState()
        } else {
            setStageDisplayState()
        }
        this.stage.addEventListener(Event.RESIZE, resizeHandler, false, 0, true);
        preInit();


        NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
        NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyboards)
//        NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitingHandler);
        //this.addEventListener(Event.CLOSING, closingHandler, false, 0, true);
        this.stage.nativeWindow.addEventListener(Event.CLOSING, closeHandler, false, 0, true);
        NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, activateHandler);
        this.stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, displayStateChangeHandler);
//        this.stage.quality = StageQuality.HIGH;
//        this.stage.frameRate = 30;
    }

    private function initControlStage():void {
        _controlStage = new Sprite()
        _controlStage.graphics.beginBitmapFill(_bgBitmap.bitmapData, null, true, true)
        _controlStage.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight)
        _controlStage.graphics.endFill();
        addChild(_controlStage);
    }

    public function setEconomicMode():void {
        if (SettingsConfigs.instance.isEconomicMode) {
            this.stage.quality = StageQuality.LOW;
            this.stage.frameRate = 5;
            ForgatHandler.enableTween = false;
            ArcHandler.enableTween = false;
        } else {
            this.stage.quality = StageQuality.HIGH;
            this.stage.frameRate = 25;
            ForgatHandler.enableTween = true;
            ArcHandler.enableTween = true;
        }
    }

    public function setControlStageAlpha(value:Number):void {
        _controlStage.alpha = value;
    }

    var splashScreenCloseTimer:Timer = new Timer(3000, 1);

    private function invokeHandler(event:InvokeEvent):void {
        if (hasInvoked) {
            return;
        }


        SpeechContainer.loadConfigs();
        LogBookDataHandler.instance;
        WindowsHandler.instance.loadSwcsByLoaderMax();

        hasInvoked = true

    }

    public function allLoadComplete():void {
        AppProperties.screenHeight = this.stage.stageHeight;
        AppProperties.appScreenWidth = this.stage.stageWidth;
        AppProperties.screenWidth = this.stage.stageWidth;
        if (Capabilities.isDebugger && LAYOUT_TEST) {
            AppProperties.screenHeight = INIT_HEIGHT;
            AppProperties.appScreenWidth = INIT_WIDTH;
            AppProperties.screenWidth = INIT_WIDTH;
        }
        if (!SettingsConfigs.instance.isSerial) {
            socketDispatcher.connect();
        }

        initControlStage();
        topBar = new TopBar();
        topBar.x = 0;
        topBar.y = 0;
        addChild(topBar)
        WindowsHandler.instance.initInstrumentsSelector();
        TopBar.hideInstrumentsGroup();
        splashScreenCloseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, splashScreenCloseTimer_timerCompleteHandler, false, 0, true);
        splashScreenCloseTimer.start()
    }

    private function splashScreenCloseTimer_timerCompleteHandler(event:TimerEvent):void {
        splashScreen.close();
        appReady();
        splashScreenCloseTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, splashScreenCloseTimer_timerCompleteHandler)
        splashScreenCloseTimer = null;
    }

    public function setTopBarTop():void {
        if (topBar != null && this.contains(topBar)) {
            this.setChildIndex(topBar, numChildren - 1);
        }
    }


    [cppcall]
    override public function addChild(child:DisplayObject):DisplayObject {
        var _do:DisplayObject = super.addChild(child);
        setTopBarTop();
        return _do
    }

    private function activateHandler(event:Event):void {
        var na:NativeApplication = NativeApplication.nativeApplication
        var window:NativeWindow
        for (var i:int = 1; i < na.openedWindows.length; i++) {
            window = na.openedWindows[i];
            if (!window.active) {
                window.activate()
            }
        }
        if (firstActivate) {
            return;
        }

    }

    public function appReady():void {
        visible = true;
        stage.nativeWindow.visible = true;
        NativeApplication.nativeApplication.activate(this.stage.nativeWindow)
        setStageDisplayState();
        VersionChecker.instance.addEventListener("new-version", new_versionHandler, false, 0, true);
        VersionChecker.instance.checkVersion();
        LayoutHandler.instance.switchLayout();
        showActivationModal();
        _appReady = true;
    }

    private function closingHandler(event:Event):void {
        trace("closing...");
    }

    private function closeHandler(event:Event):void {
        event.preventDefault();
        if (Statuses.instance.socketStatus && !socketDispatcher.isDemoConnected) {
            NotificationHandler.createAlert(NotificationTypes.USER_CONNECTION_CLOSE_ALERT, NotificationTypes.USER_CONNECTION_CLOSE_ALERT_TEXT, 0, exit);
        } else {

            exit();
        }
    }

    private function exit():void {
        trace("close");
        socketDispatcher.close(false);
        AlarmHandler.instance.exportAlarms();
        SpeechHandler.instance.stopAll();
        SettingsConfigs.saveInstance();
        TripDataHandler.instance().save();
        LayoutHandler.instance.activeLayout.closeAllWindows();
        this.stage.nativeWindow.close();
        if (AppProperties.licenseWin != null) {
            AppProperties.licenseWin.close()
        }
        if (AppProperties.alarmWindow != null && !AppProperties.alarmWindow.closed) {
            AppProperties.alarmWindow.close();
        }
        if (AppProperties.messagesWin != null && !AppProperties.messagesWin.closed) {
            AppProperties.messagesWin.close();
        }
        if (AppProperties.logBookWindow != null && !AppProperties.logBookWindow.closed) {
            AppProperties.logBookWindow.close();
        }
        if (AppProperties.settingWin != null && !AppProperties.settingWin.closed) {
            AppProperties.settingWin.close();
        }
        if (AppProperties.aisWin != null && !AppProperties.aisWin.closed) {
            AppProperties.aisWin.close();
        }
        if (AppProperties.portWindow != null && !AppProperties.portWindow.closed) {
            AppProperties.portWindow.close();
        }
        var openedWindows:Array = NativeApplication.nativeApplication.openedWindows;
        for (var i:int = 0; i < openedWindows.length; i++) {
            (openedWindows[i] as NativeWindow).close();
        }

    }

    private function preInit():void {
        trace("preinit")
        splashScreen = new SplashScreen();
        splashScreen.activate();
        AppProperties.initEnvProps();

        this.visible = false;

        SettingsConfigs.loadBackInstance();
        CloudHandler.instance.load();
        WebsocketHandler.instance.connect();
        PolarContainer.instance.load();
        AppProperties.licenseManager.addEventListener(LicenseEvent.ACTIVATED, licenseActivatedHandler, false, 0, true);
        AppProperties.licenseManager.addEventListener(LicenseEvent.DEACTIVATED, licenseDeActivatedHandler, false, 0, true);
        socketDispatcher = new SocketDispatcher();
        WindowsHandler.instance.application = this;
        TripDataHandler.instance().load();
        PolarNotification.instance;

        setEconomicMode();

        trace("isdebugger", Capabilities.isDebugger);

        WorkersHandler.instance.mainWorker = Worker.current;
        DataLogger.instance.checkDirectories();
        WindowsHandler.instance.application = this;
        LogRegister.instance;
        PolarFileHandler.instance;
        this.addEventListener(MouseEvent.CLICK, applicationClickHandler, false, 0, true);
        this.addEventListener(MouseEvent.MOUSE_UP, applicationClickHandler, false, 0, true);
        AlarmHandler.instance.importAlarms();
        trace("preinitend")

    }

    private function handleKeyboards(event:KeyboardEvent):void {
        if (event.keyCode == Keyboard.ESCAPE || event.keyCode == Keyboard.TAB) {
            event.preventDefault();
            return;
        }
        switch (event.charCode) {
            case 97:
            {
                if (event.ctrlKey) {
//                            AppProperties.openAisWindow();
                }
            }
            case 108:
            {
                //                    LayoutHandler.instance.editEnabled = !LayoutHandler.instance.editEnabled;
                //trace("turnonoff edit");
                break;
            }
            case 107:
            {
                //LayoutHandler.instance.saveLayout();
                //trace("save layout");
                break;
            }

            case 115:
            {
//                AppProperties.openSettingsWindow()
                break;
            }

            case 120:
            {
                if (Capabilities.isDebugger) {
//                            setScreenEnabled = !setScreenEnabled;
                }
                //trace("settings open");
                break;
            }


        }

    }


    public function repositionTopBar():void {
        if ((Capabilities.isDebugger && LAYOUT_TEST)) {
            return;
        }
        AppProperties.appScreenWidth = this.stage.stageWidth;
        topBar.reDraw();
    }

    private function showActivationModal():void {
        if (AppProperties.hasComHobbyLicense() || AppProperties.hasDemoHobbyLicense()) {//AppProperties.licenseManager.isLicenseValid()) {
            trace("license valid");
            var license:License = AppProperties.getStrongestLicense();
            if (license != null && license.expireAt != null && license.licenseType != License.COMMERCIAL) {
                AppProperties.openLicenseWindow();
            }
        } else {
            socketDispatcher.close(false);
            socketDispatcher.stopDemoConnect();
            AppProperties.openLicenseWindow()
        }
    }

    private function licenseActivatedHandler(event:LicenseEvent):void {
        showActivationModal();
    }

    private function licenseDeActivatedHandler(event:LicenseEvent):void {
        socketDispatcher.close(false);
        socketDispatcher.stopDemoConnect();
        showActivationModal();
    }

    private function new_versionHandler(event:Event):void {
        newVersionBubble.graphics.clear();
        newVersionBubble.graphics.beginFill(0xfff799)
        newVersionBubble.graphics.drawRoundRect(0, 0, 500, 30, 10, 10);
        newVersionBubble.x = AppProperties.screenWidth / 2 - 250;
        newVersionBubble.y = TopBar.barHeight - 10;
        var tf:TextField = FontFactory.getCustomFont({
            color: 0x000000,
            size: 10,
            width: 480,
            bold: true,
            align: "center",
            autoSize: "center"
        });
        tf.htmlText = "New update found! Pleas download it from " + LicenseManager.END_POINT_URI + "/download. Click here to open!"
        tf.y = 12;
        tf.height = 20;
        tf.x = 250 - tf.width / 2;
        newVersionBubble.addEventListener(MouseEvent.CLICK, tf_clickHandler, false, 0, true);
        newVersionBubble.addChild(tf)
        this.addChild(newVersionBubble);
        versionBubbleTimer.addEventListener(TimerEvent.TIMER_COMPLETE, versionBubbleTimer_timerCompleteHandler, false, 0, true);
        versionBubbleTimer.start();
    }

    private function versionBubbleTimer_timerCompleteHandler(event:TimerEvent):void {
        newVersionBubble.visible = false;
    }

    private function tf_clickHandler(event:MouseEvent):void {
        var url:String = LicenseManager.END_POINT_URI + "/download";
        var urlReq:URLRequest = new URLRequest(url);
        navigateToURL(urlReq);
    }

    public function applicationClickHandler(event:MouseEvent):void {
        if (!event.target.hasOwnProperty("id") || event.target.id != "menuLabel") {
            TopBar.menuList.setCurrentState("closed");
            TopBar.menuBtn.enabled = true;
            if (event.target.hasOwnProperty("id") && event.target.id == "topBar") {
                if (LayoutHandler.instance.activeLayout != null && !LayoutHandler.instance.activeLayout.isFullscreen && LayoutHandler.instance.editMode) {
                    LayoutHandler.instance.turnOnOffAlwaysOnTheTop(false);
                }
            }
        }
        dispatchEvent(new AppClick(event.target))
    }


    private function displayStateChangeHandler(event:NativeWindowDisplayStateEvent):void {
        if (!firstActivate && _appReady) {
            LayoutHandler.instance.switchLayout();
            firstActivate = true;
        }

        if (event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED && (event.afterDisplayState == NativeWindowDisplayState.NORMAL || event.afterDisplayState == NativeWindowDisplayState.MAXIMIZED)) {
            this.stage.nativeWindow.maximize();
            if (LayoutHandler.instance.activeLayout.isFullscreen || !Statuses.instance.isMac()) {
                setStageDisplayState()
            }

            showAllInstrument();
            activateOpenedFloatWindows()
        }

        if (event.afterDisplayState === NativeWindowDisplayState.MINIMIZED) {
            minimizeOpenedFloatWindows();
            hideAllInstrument();
        }

        //TODO if minimized set fps low
    }

    private function minimizeOpenedFloatWindows() {
        if (AppProperties.licenseWin != null && !AppProperties.licenseWin.closed) {
            AppProperties.licenseWin.minimize()
        }
        if (AppProperties.alarmWindow != null && !AppProperties.alarmWindow.closed) {
            AppProperties.alarmWindow.minimize();
        }
        if (AppProperties.messagesWin != null && !AppProperties.messagesWin.closed) {
            AppProperties.messagesWin.minimize();
        }
        if (AppProperties.logBookWindow != null && !AppProperties.logBookWindow.closed) {
            AppProperties.logBookWindow.minimize();
        }
        if (AppProperties.settingWin != null && !AppProperties.settingWin.closed) {
            AppProperties.settingWin.minimize();
        }
        if (AppProperties.aisWin != null && !AppProperties.aisWin.closed) {
            AppProperties.aisWin.minimize();
        }
        if (AppProperties.portWindow != null && !AppProperties.portWindow.closed) {
            AppProperties.portWindow.minimize();
        }
        if (AppProperties.logInWin != null && !AppProperties.logInWin.closed) {
            AppProperties.logInWin.minimize();
        }
        if (AppProperties.polarWin != null && !AppProperties.polarWin.closed) {
            AppProperties.polarWin.minimize();
        }
    }

    private function activateOpenedFloatWindows() {
        if (AppProperties.licenseWin != null && !AppProperties.licenseWin.closed) {
            AppProperties.licenseWin.activate()
        }
        if (AppProperties.alarmWindow != null && !AppProperties.alarmWindow.closed) {
            AppProperties.alarmWindow.activate();
        }
        if (AppProperties.messagesWin != null && !AppProperties.messagesWin.closed) {
            AppProperties.messagesWin.activate();
        }
        if (AppProperties.logBookWindow != null && !AppProperties.logBookWindow.closed) {
            AppProperties.logBookWindow.activate();
        }
        if (AppProperties.settingWin != null && !AppProperties.settingWin.closed) {
            AppProperties.settingWin.activate();
        }
        if (AppProperties.aisWin != null && !AppProperties.aisWin.closed) {
            AppProperties.aisWin.activate();
        }
        if (AppProperties.portWindow != null && !AppProperties.portWindow.closed) {
            AppProperties.portWindow.activate();
        }
        if (AppProperties.logInWin != null && !AppProperties.logInWin.closed) {
            AppProperties.logInWin.activate();
        }
        if (AppProperties.polarWin != null && !AppProperties.polarWin.closed) {
            AppProperties.polarWin.activate();
        }
    }

    public function hideAllInstrument():void {
        setInstrumentsVisibility(false);
    }

    public function showAllInstrument():void {
        setInstrumentsVisibility(true);
    }

    public function setStageDisplayState():void {
        if ((Capabilities.isDebugger && LAYOUT_TEST)) {
            this.stage.displayState = StageDisplayState.NORMAL;
            this.width = INIT_WIDTH;
            this.height = INIT_HEIGHT;
            return;
        }
        if (Statuses.instance.isMac()) {
            //            this.stage.nativeWindow.maximize();
//            this.stage.displayState = StageDisplayState.NORMAL;
            this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
        } else {
            this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
        }
    }

    private function setInstrumentsVisibility(visible:Boolean):void {
        var na:NativeApplication = NativeApplication.nativeApplication
        var window:NativeWindow
        for (var i:int = 1; i < na.openedWindows.length; i++) {
            window = na.openedWindows[i];
            if (window is ControlWindowAs) {
                window.visible = visible;
            }
        }
    }

    private function resizeHandler(event:Event):void {
        trace("resize")
    }
}
}
