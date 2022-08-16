/**
 * Created by pepusz on 2013.12.16..
 */
package components {

import com.common.AppProperties;
import com.layout.LayoutHandler;
import com.sailing.WindowsHandler;
import com.seamantec.License;
import com.seamantec.LicenseErrorEvent;
import com.seamantec.LicenseEvent;
import com.seamantec.LicenseManager;
import com.store.Statuses;
import com.ui.controls.ProductInfoBtn;
import com.utils.FontFactory;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormatAlign;
import flash.utils.ByteArray;

public class LicenseWindow extends NativeWindow {

    [Embed(source="../../assets/loading.png")]
    private var loadingPng:Class;

    [Embed(source="../../assets/credits.html", mimeType="application/octet-stream")]
    private static var Credits:Class;

    [Embed(source="../../assets/images/emailserial_field.png")]
    private static var emailSerial:Class;
    private var loadingBitmap:Bitmap;

    private var activateBtn:ProductInfoBtn;
    private var activateFromFileBtn:ProductInfoBtn;
    private var okBtn:ProductInfoBtn;
    private var closeAppBtn:ProductInfoBtn
    private var addNewBtn:ProductInfoBtn;
    private var buyNow:ProductInfoBtn;

    private var _formContainer:Sprite;
    private var _offlineContainer:Sprite;
    private var _creditsContainer:Sprite;
    private var containerActivated:Sprite;
    private var demoContainer:Sprite;

    private var _statusContainer:Sprite

//    private static var emailLabel:TextField;
//    private static var serialLabel:TextField;
    private var emailSerialBg:Bitmap = new emailSerial();
    private var emailInput:TextField;
    private var serialInput:TextField;
    private var activatedInfo:TextField;
    private var demoInfo:TextField;
//    private var invalidInfo:TextField;
    private var _credits:TextField;
    private var _dragPoint:Point;

    private var statusLabel:TextField;
    private var errorLabel:TextField;

    private var copyrightText:TextField;

    public function LicenseWindow() {
        var options:NativeWindowInitOptions = new NativeWindowInitOptions();
        options.systemChrome = NativeWindowSystemChrome.NONE
        options.type = NativeWindowType.NORMAL
        options.transparent = true;
        options.resizable = false;
        options.maximizable = true;
        options.renderMode = AppProperties.renderMode

        options.owner = WindowsHandler.instance.application.stage.nativeWindow;
        super(options);
        this.stage.align = StageAlign.TOP_LEFT;
        this.stage.scaleMode = StageScaleMode.NO_SCALE;
//        this.maximize();
        this.width = AppProperties.screenWidth;
        this.height = AppProperties.screenHeight;
        this.x = WindowsHandler.instance.application.stage.nativeWindow.x
        this.y = WindowsHandler.instance.application.stage.nativeWindow.y
        activateHandler();
//        AppProperties.licenseManager.addEventListener(LicenseEvent.DEACTIVATED, licenceMangerDeactivatedHandler, false, 0, true);
        this.addEventListener(Event.CLOSING, closingHandler, false, 0, true);
        this.addEventListener(Event.CLOSE, closeHandler, false, 0, true);

        AppProperties.licenseManager.addEventListener(LicenseEvent.ACTIVATED, licenceManagerHandler, false, 0, true);
        AppProperties.licenseManager.addEventListener(LicenseEvent.DEACTIVATED, licenceManagerHandler, false, 0, true);
    }

    private function activateHandler():void {
//        if (!LayoutHandler.instance.activeLayout.isFullscreen && Statuses.instance.isMac()) {
        this.stage.displayState = StageDisplayState.NORMAL;
//        } else {
//        this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
//        }

        var shapeBg:Shape = new Shape();
        shapeBg.graphics.beginFill(0x000000, 0.6);
        shapeBg.graphics.drawRect(0, 0, AppProperties.screenWidth, AppProperties.screenHeight);
        loadingBitmap = new loadingPng()
        loadingBitmap.x = AppProperties.screenWidth / 2 - loadingBitmap.width / 2;
        loadingBitmap.y = AppProperties.screenHeight / 2 - loadingBitmap.height / 2;
        stage.addChild(shapeBg);
        stage.addChild(loadingBitmap);

        initContainer();
        createActivateBtn();
        createStatusLabel();
        initDemoInfo();
        initActivatedLicense();
        initActivateFields();
        createCreditsField();
        var lic:License = AppProperties.getStrongestLicense()
        setStatusAndErrorLabelText("", "")

        if (lic != null && lic.isLicenseValid()) {

            setFormAndActivatedContainersVisible(false);
        } else {
            if (lic != null) {
                setStatusAndErrorLabelText("", lic.getLicenseValidationString())
            }
            setFormAndActivatedContainersVisible(true);
        }
        okBtn.resetStates();
        LayoutHandler.instance.turnOnOffAlwaysOnTheTop(false)

    }

    private function setFormAndActivatedContainersVisible(formVisible:Boolean):void {
        demoContainer.visible = !formVisible && !AppProperties.hasComHobbyLicense();
        containerActivated.visible = !formVisible;
        _creditsContainer.visible = !formVisible;
        _formContainer.visible = formVisible;
        _offlineContainer.visible = formVisible;
    }

    private function initContainer() {
        if (_formContainer === null) {
            _formContainer = new Sprite();
            _formContainer.x = loadingBitmap.x + 340;
            _formContainer.y = loadingBitmap.y + 40;

            createCreditsContainer();

            _offlineContainer = new Sprite();
            _offlineContainer.x = loadingBitmap.x + 50;
            _offlineContainer.y = loadingBitmap.y + 247;

            demoContainer = new Sprite();
            demoContainer.x = loadingBitmap.x + 50;
            demoContainer.y = loadingBitmap.y + 150;

            containerActivated = new Sprite();
            containerActivated.x = loadingBitmap.x + 50;
            containerActivated.y = loadingBitmap.y + 250;

            _statusContainer = new Sprite();
            _statusContainer.x = loadingBitmap.x + 100;
            _statusContainer.y = loadingBitmap.y + 200;
            _statusContainer.graphics.beginFill(0x000000, 0.7);
            _statusContainer.graphics.drawRect(0, 0, 440, 25)

        }
        setFormAndActivatedContainersVisible(false)
        this.stage.addChild(_formContainer);
        this.stage.addChild(_offlineContainer);
        this.stage.addChild(_creditsContainer);
        this.stage.addChild(demoContainer);
        this.stage.addChild(containerActivated);
        this.stage.addChild(_statusContainer);

        copyrightText = FontFactory.getCustomFont({size: 10, color: 0xffffff, width: 300});
        copyrightText.text = AppProperties.getCopyright() + " Version number: " + AppProperties.getVersionLabel();
        copyrightText.x = loadingBitmap.x + 30;
        copyrightText.y = loadingBitmap.y + 370;
        this.stage.addChild(copyrightText);

    }


    private function createActivateBtn():void {
        if (activateBtn === null) {
            activateBtn = new ProductInfoBtn("Activate now")
            activateBtn.y = 100;
            activateBtn.x = 177;
            activateBtn.addEventListener(MouseEvent.CLICK, activateBtnHandler, false, 0, true)
            activateFromFileBtn = new ProductInfoBtn("Open\nlicense file")
            activateFromFileBtn.y = 70;
            activateFromFileBtn.x = 0;
            activateFromFileBtn.addEventListener(MouseEvent.CLICK, activateFromFileBtn_clickHandler, false, 0, true);
            okBtn = new ProductInfoBtn("Close")
            okBtn.x = loadingBitmap.x + 517;
            okBtn.y = loadingBitmap.y + 320;
            okBtn.addEventListener(MouseEvent.CLICK, okButton_clickHandler, false, 0, true)

            closeAppBtn = new ProductInfoBtn("Exit");
            closeAppBtn.addEventListener(MouseEvent.CLICK, closeApp_clickHandler, false, 0, true);
            closeAppBtn.x = loadingBitmap.x + 517;
            closeAppBtn.y = loadingBitmap.y + 320;
            this.stage.addChild(closeAppBtn)
            this.stage.addChild(okBtn)
            setCloseAppAndOkBtnVisibility()

            addNewBtn = new ProductInfoBtn("New license")
            addNewBtn.addEventListener(MouseEvent.CLICK, addNewBtn_clickHandler, false, 0, true);
            addNewBtn.x = 0;
            addNewBtn.y = 70;

            buyNow = new ProductInfoBtn("Buy it now")
            buyNow.addEventListener(MouseEvent.CLICK, buyItNow_clickHandler, false, 0, true);
            buyNow.x = 221;
            buyNow.y = 70;
            _formContainer.addChild(activateBtn);
            _offlineContainer.addChild(activateFromFileBtn)
//            _formContainer.addChild(activateFromFileBtn)
//            containerActivated.addChild(okBtn)
            containerActivated.addChild(addNewBtn)

        }
        var license:License = AppProperties.getStrongestLicense();
        if (license != null && license.expireAt != null && license.licenseType != License.COMMERCIAL && !containerActivated.contains(buyNow)) {
            containerActivated.addChild(buyNow);
        } else if (!containerActivated.contains(buyNow)) {
            buyNow.visible = false;
        }

    }

    private function setCloseAppAndOkBtnVisibility():void {
        closeAppBtn.visible = !AppProperties.hasComHobbyLicense() && !AppProperties.hasDemoHobbyLicense();
        okBtn.visible = !closeAppBtn.visible;
    }

    private function createStatusLabel():void {
        if (statusLabel === null) {
            errorLabel = FontFactory.getRedFont();
            errorLabel.y = 2;
            errorLabel.x = 10
            statusLabel = FontFactory.getLeftTextField()
            statusLabel.y = 2;
            statusLabel.x = 10;
        }
        _statusContainer.addChild(errorLabel)
        _statusContainer.addChild(statusLabel)

    }


    private function activateBtnHandler(event:MouseEvent):void {
        statusLabel.visible = true;
        serialInput.text = serialInput.text.replace(/[\s\r\n]*/gim, '');
        if (!validateFields()) {
            return;
        }
        activateBtn.enabled = false;
        activateFromFileBtn.enabled = false;
        setStatusAndErrorLabelText("Activating...")
        AppProperties.licenseManager.addEventListener(LicenseEvent.NETWORK_ERROR, networkErrorhandler, false, 0, true);
        AppProperties.licenseManager.addEventListener(LicenseEvent.LICENSE_DOWNLOADED, licenseDownloaded, false, 0, true);
        AppProperties.licenseManager.addEventListener(LicenseErrorEvent.LICENSE_ERROR, license_errorHandler, false, 0, true);
        AppProperties.licenseManager.getLicenseFromServer(emailInput.text.replace(/[\s\r\n]*/gim, ''), serialInput.text.replace(/[\s\r\n]*/gim, ''));
    }

    private function setStatusAndErrorLabelText(statusText:String, errorText:String = ""):void {
        statusLabel.text = "";
        errorLabel.text = "";
        if (statusText == "" && errorText == "") {
            _statusContainer.visible = false;
        } else {
            _statusContainer.visible = true;
        }
        if (errorText == "") {
            statusLabel.htmlText = statusText
        }
        errorLabel.htmlText = errorText;
    }

    private function validateFields():Boolean {
        var emailExpression:RegExp = /^[\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
        var serialExpression:RegExp = /^[a-zA-Z0-9]{5}-[a-zA-Z0-9]{5}-[a-zA-Z0-9]{5}-[a-zA-Z0-9]{5}$/i
        var isEmailOk:Boolean = true;
        var isSerialOk:Boolean = true;
        setStatusAndErrorLabelText("", "")
        if (!emailInput.text.match(emailExpression)) {
            isEmailOk = false;
            setStatusAndErrorLabelText("", "Email is not valid!")

        }

        if (!serialInput.text.match(serialExpression)) {
            isSerialOk = false;
            setStatusAndErrorLabelText("", "Serial is not valid!")
        }
        if (!isEmailOk && !isSerialOk) {
            setStatusAndErrorLabelText("", "Email and Serial is not valid!")
        }

        return isEmailOk && isSerialOk;
    }

    private function createCreditsContainer():void {
        _creditsContainer = new Sprite();
        _creditsContainer.x = loadingBitmap.x + 340;
        _creditsContainer.y = loadingBitmap.y + 40;
        _creditsContainer.scrollRect = new Rectangle(0, 0, 250, 250);
        _creditsContainer.addEventListener(MouseEvent.MOUSE_WHEEL, onCreditsWheel, false, 0, true);
        _creditsContainer.addEventListener(MouseEvent.MOUSE_DOWN, onCreditsDown, false, 0, true);
    }

    private function onCreditsDown(e:MouseEvent):void {
        this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onCreditsMove, false, 0, true);
        this.stage.addEventListener(MouseEvent.MOUSE_UP, onCreditsUp, false, 0, true);
        _dragPoint = new Point(e.stageX, e.stageY);
    }

    private function onCreditsMove(e:MouseEvent):void {
        var currentPoint:Point = new Point(e.stageX, e.stageY);
        var dy:Number = _dragPoint.y - currentPoint.y;
        scrollCredits(dy);
        _dragPoint = currentPoint;
    }

    private function onCreditsUp(e:MouseEvent):void {
        this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onCreditsMove);
        this.stage.removeEventListener(MouseEvent.MOUSE_UP, onCreditsUp);
    }

    private function onCreditsWheel(e:MouseEvent):void {
        scrollCredits(e.delta * ((Statuses.isWindows()) ? -8 : -2));
    }

    private function scrollCredits(y:Number):void {
        y += _creditsContainer.scrollRect.y;
        if (y < 0) {
            _creditsContainer.scrollRect = new Rectangle(0, 0, 250, 250);
        } else if ((y + 250) > _credits.height) {
            _creditsContainer.scrollRect = new Rectangle(0, _credits.height - 250, 250, 250);
        } else {
            _creditsContainer.scrollRect = new Rectangle(0, y, 250, 250);
        }
    }

    private function createCreditsField():void {
        if (_credits == null) {
            _credits = FontFactory.getCustomFont({size: 10, color: 0xffffff, align: "justify", autoSize: "left"});
            _credits.multiline = true;
            _credits.width = 250;
            _credits.wordWrap = true;
            _credits.htmlText = (new Credits() as ByteArray).toString();
            _creditsContainer.addChild(_credits);
        }
    }

    private function initActivateFields():void {
        if (emailInput == null) {
            emailSerialBg.x = 0
            emailSerialBg.y = 0
            _formContainer.addChild(emailSerialBg)
            emailInput = FontFactory.getCustomFont({size: 14, selectable: true, color: 0x000000});

            emailInput.width = 210;
            emailInput.height = 20;
            emailInput.x = emailSerialBg.x + 40;
            emailInput.y = emailSerialBg.y;
            emailInput.type = TextFieldType.INPUT;
            _formContainer.addChild(emailInput);
        }


        if (serialInput == null) {
            serialInput = FontFactory.getCustomFont({size: 14, selectable: true, color: 0x000000});
            serialInput.width = 210;
            serialInput.height = 20;
            serialInput.x = emailSerialBg.x + 40;
            serialInput.y = emailSerialBg.y + 42;
            serialInput.type = TextFieldType.INPUT;
            _formContainer.addChild(serialInput);
        }

        var registrationNotification:TextField = FontFactory.getCustomFont({
            size: 10,
            selectable: true,
            color: 0xff9200,
            align: "right",
            autoSize: "right"
        });
        registrationNotification.text = "If you don't have a serial, you can register at www.seamantec.com";
        registrationNotification.autoSize = TextFieldAutoSize.RIGHT;
        registrationNotification.x = serialInput.x + serialInput.width - registrationNotification.width;
        registrationNotification.y = serialInput.y + 30;
        _formContainer.addChild(registrationNotification);

        var offlineTexts:TextField = FontFactory.getCustomFont({
            size: 12,
            selectable: true,
            color: 0xffffff,
            align: "left",
            autoSize: "left"
        })
        var text:String = "<b>Activate on the web</b> <br>";
        text += "<br>Activation key: " + AppProperties.licenseManager.getHwKey();
        text += "<br>at www.seamantec.com/get_license to get the license file."
        offlineTexts.selectable = true;
        offlineTexts.multiline = true;
        offlineTexts.htmlText = text;
        _offlineContainer.addChild(offlineTexts)

//        var activationKeyLabel:TextField = FontFactory.getCustomFont({size: 10, selectable: true, color: 0xffffff});
//        activationKeyLabel.text = "Activation key: " + AppProperties.licenseManager.getHwKey();
//        activationKeyLabel.width = 260;
//        activationKeyLabel.height = 20;

//        _formContainer.addChild(activationKeyLabel);
//        activationKeyLabel.x = emailSerialBg.x - 4;
//        activationKeyLabel.y = serialInput.y + 30;
    }

    private function initDemoInfo():void {
        if(!AppProperties.hasComHobbyLicense()) {
            if(demoInfo==null) {
                demoInfo = FontFactory.getCustomFont({
                    size: 14,
                    align: TextFormatAlign.CENTER,
                    color: 0xffd200,
                    autoSize: TextFieldAutoSize.LEFT
                });
                demoInfo.multiline = true;
                demoContainer.addChild(demoInfo);
            }

           demoInfo.htmlText = "This time limited demo version is fully<br>functional except that live connection and<br>polar file saving are disabled!";
        }
    }

    private function initActivatedLicense():void {
        var license:License = AppProperties.getStrongestLicense();
        if (activatedInfo === null) {
            activatedInfo = FontFactory.getLeftTextField();
            activatedInfo.x = 0;
            activatedInfo.y = 0;
            activatedInfo.multiline = true;
            containerActivated.addChild(activatedInfo);
        }

        var text:String = ""
        if (license != null && license.expireAt != null) {
            if (license.licenseType != License.COMMERCIAL) {
                text += "Expire at: " + license.expireAt.toDateString() + "<br>"
            }
            text += "Email: " + license.email + "<br>"
            text += "Serial: " + license.serial + "<br>"
            text += license.getLicenseValidationString(); //AppProperties.licenseManager.isLicenseValid()
        }
        activatedInfo.htmlText = text;
    }

    private function networkErrorhandler(event:Event):void {
        setStatusAndErrorLabelText("", "Can't connect to server!")

        removeEventListeners();
    }

    private function licenseDownloaded(event:Event):void {
        if (AppProperties.getStrongestLicense() != null) {
            initActivatedLicense();
            setFormAndActivatedContainersVisible(false)
            okBtn.label = "Thank You!";
            if (closeAppBtn != null) {
                closeAppBtn.visible = false;
            }
            var license:License = AppProperties.getStrongestLicense();
            if (license != null && license.expireAt != null && license.licenseType == License.COMMERCIAL && containerActivated.contains(buyNow)) {
                buyNow.visible = false;
            }
            setStatusAndErrorLabelText("", "")
            if (AppProperties.settingWin != null) {
                AppProperties.settingWin.setConnectionSettings();
            }
        } else {
            setStatusAndErrorLabelText("", "Invalid activation!")
            deactivatedState();
        }
        removeEventListeners();
        setCloseAppAndOkBtnVisibility()

    }

    private function deactivatedState():void {
        setFormAndActivatedContainersVisible(true)
        setStatusAndErrorLabelText("", "")
        setCloseAppAndOkBtnVisibility()
    }

    private function removeEventListeners():void {
        activateBtn.enabled = true;
        activateFromFileBtn.enabled = true;
        AppProperties.licenseManager.removeEventListener(LicenseEvent.NETWORK_ERROR, networkErrorhandler);
        AppProperties.licenseManager.removeEventListener(LicenseEvent.LICENSE_DOWNLOADED, licenseDownloaded);
        AppProperties.licenseManager.removeEventListener(LicenseErrorEvent.LICENSE_ERROR, license_errorHandler);


    }

    private function deActivateBtn_clickHandler(event:MouseEvent):void {
        AppProperties.licenseManager.deactivateAll();
    }

    private function licenceMangerDeactivatedHandler(event:LicenseEvent):void {
        deactivatedState();
        setStatusAndErrorLabelText("", "")
    }

    private function licenceManagerHandler(event:LicenseEvent):void {
        demoContainer.visible = containerActivated && !AppProperties.hasComHobbyLicense();
    }

    private function okButton_clickHandler(event:MouseEvent):void {
        okBtn.label = "Close"
        this.close();
        NativeApplication.nativeApplication.openedWindows[0].activate();
    }

    private function license_errorHandler(event:LicenseErrorEvent):void {
        if (event.errorMessages != "") {
            var json:Object = JSON.parse(event.errorMessages);
            var message:String = "";
            for (var i:int = 0; i < json["errors"].length; i++) {
                message += json["errors"][i];

            }
            setStatusAndErrorLabelText("", message)
        } else {
            setStatusAndErrorLabelText("", "Something went wrong! Please contact us!")
        }
        removeEventListeners();
        setCloseAppAndOkBtnVisibility()
    }


    private function addNewBtn_clickHandler(event:MouseEvent):void {
        setFormAndActivatedContainersVisible(true);
    }

    private function buyItNow_clickHandler(event:MouseEvent):void {
        var url:String = LicenseManager.END_POINT_URI + "/orders/buy_it_now";
        var urlReq:URLRequest = new URLRequest(url);
        navigateToURL(urlReq);
    }


    private function closingHandler(event:Event):void {
        event.preventDefault();
    }

    private function closeApp_clickHandler(event:MouseEvent):void {
        NativeApplication.nativeApplication.exit();
    }

    private function activateFromFileBtn_clickHandler(event:MouseEvent):void {
        statusLabel.visible = true;
        serialInput.text = serialInput.text.replace(/[\s\r\n]*/gim, '');
        if (!validateFields()) {
            return;
        }
        activateBtn.enabled = false;
        activateFromFileBtn.enabled = false;
        setStatusAndErrorLabelText("Activating...")
        var file:File = File.documentsDirectory;
        file.browseForOpen("Open license File");
        file.addEventListener(Event.SELECT, file_selectHandler, false, 0, true);
        file.addEventListener(Event.CANCEL, file_cancelHandler, false, 0, true);
        AppProperties.licenseManager.addEventListener(LicenseErrorEvent.LICENSE_ERROR, license_errorHandler, false, 0, true);

    }

    private function file_selectHandler(event:Event):void {
        var file:File = event.target as File;
        AppProperties.licenseManager.getLicenseFromFile(file, emailInput.text.replace(/[\s\r\n]*/gim, ''), serialInput.text.replace(/[\s\r\n]*/gim, ''))
        licenseDownloaded(new LicenseEvent(LicenseEvent.LICENSE_DOWNLOADED));
        removeEventListeners()
    }

    private function file_cancelHandler(event:Event):void {
        activateBtn.enabled = true;
        activateFromFileBtn.enabled = true;
        setStatusAndErrorLabelText("", "")
        removeEventListeners()
    }

    private function closeHandler(event:Event):void {
        removeEventListeners();
        this.removeEventListener(Event.CLOSING, closingHandler);
        this.removeEventListener(Event.CLOSE, closeHandler);
        stage.removeChildren(0, this.stage.numChildren - 1);
        _formContainer.removeChildren(0, _formContainer.numChildren - 1);
        containerActivated.removeChildren(0, containerActivated.numChildren - 1);
        loadingBitmap.bitmapData.dispose();
        loadingBitmap = null;
        loadingPng = null;
        activateBtn.removeEventListener(MouseEvent.CLICK, activateBtnHandler)
        activateBtn.deAlloc();
        activateBtn = null;
        activateFromFileBtn.removeEventListener(MouseEvent.CLICK, activateFromFileBtn_clickHandler)
        activateFromFileBtn.deAlloc();
        activateFromFileBtn = null;
        okBtn.removeEventListener(MouseEvent.CLICK, okButton_clickHandler)
        okBtn.deAlloc();
        okBtn = null;
        if (closeAppBtn != null) {
            closeAppBtn.removeEventListener(MouseEvent.CLICK, closeApp_clickHandler);
            closeAppBtn.deAlloc();
            closeAppBtn = null;
        }
        addNewBtn.removeEventListener(MouseEvent.CLICK, addNewBtn_clickHandler);
        addNewBtn.deAlloc();
        addNewBtn = null;
        _formContainer = null;
        containerActivated = null;
        emailSerialBg.bitmapData.dispose();
        emailSerialBg = null;
        emailInput = null;
        serialInput = null;
        activatedInfo = null;
        statusLabel = null;
        errorLabel = null;
        LayoutHandler.instance.turnOnOffAlwaysOnTheTop(true);
    }
}
}
