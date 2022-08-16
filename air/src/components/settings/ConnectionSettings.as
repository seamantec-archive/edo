/**
 * Created by seamantec on 21/02/14.
 */
package components.settings {
import com.common.AppProperties;
import com.notification.NotificationHandler;
import com.notification.NotificationTypes;
import com.sailing.WindowsHandler;
import com.sailing.socket.SocketDispatcher;
import com.store.SettingsConfigs;
import com.store.Statuses;
import com.ui.controls.AlarmDownBtn;
import com.ui.controls.BitmapButtonOptions;
import com.utils.FontFactory;

import components.RadioButton;

import components.RadioButtonBar;
import components.ToggleButton;
import components.list.DynamicListItem;
import components.list.List;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;

public class ConnectionSettings extends DynamicListItem {

    [Embed(source="../../../assets/images/msglist/closedlist_element.png")]
    private static var closed:Class;

    [Embed(source="../../../assets/images/inputfield.png")]
    public static var inputfield:Class;

    private static var _connectionType:RadioButtonBar;
    private static var _udpType:RadioButtonBar;

    private static var _hostLabel:TextField;
    private static var _hostInput:TextField;
    private static var _portLabel:TextField;
    private static var _portInput:TextField;
    private static var _udpHostLabel:TextField;
    private static var _udpHostInput:TextField;
    private static var _udpPortLabel:TextField;
    private static var _udpPortInput:TextField;
    private static var _nameLabel:TextField;
    private static var _nameInput:TextField;
    private static var _baudLabel:TextField;
    private static var _baudInput:TextField;

    private static var _demoLabel:TextField;

    private static var _connectButton:AlarmDownBtn;
    private static var _scannerButton:AlarmDownBtn;

    private static var _bitmap1:Bitmap = new inputfield();
    private static var _bitmap2:Bitmap = new inputfield();

    private var _x:Number;


    public function ConnectionSettings(list:List) {
        super(SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT, list);

        this.graphics.beginBitmapFill((new closed()).bitmapData);
        this.graphics.drawRect(0, 0, SettingsWindow.WIDTH, SettingsWindow.ITEM_HEIGHT);
        this.graphics.endFill();

        addLabel("Connection", FontFactory.nmeaMSGfont(), 2, 2);

        createContent();

        _scannerButton.enabled = true;

        isDemoVersion();
    }

    private function createContent():void {
        if (_connectionType == null) {
            _connectionType = new RadioButtonBar(20, 150, ["TCP Socket", "Serial port", "UDP Socket"], 12);
            _connectionType.x = (this.width / 2) - 150;
            _connectionType.y = 8;
            _connectionType.addEventListener(MouseEvent.CLICK, connectionTypeHandler, false, 0, true);
            _connectionType.selectedIndex = SettingsConfigs.instance.connectionType;

            var button:RadioButton = _connectionType.getButton(0);
            var options:BitmapButtonOptions = button.options;
            options.margin = 5;
            button.options = options;

            button = _connectionType.getButton(1);
            options = button.options;
            options.margin = 5;
            button.options = options;

            button = _connectionType.getButton(2);
            options = button.options;
            options.margin = 5;
            button.options = options;
        }
        addContentChild(_connectionType);

        _x = (this.width / 2) - (_bitmap1.width / 2);

        _bitmap1.x = _x;
        _bitmap1.y = 69;
        addContentChild(_bitmap1);
        _bitmap2.x = _x;
        _bitmap2.y = 119;
        addContentChild(_bitmap2);

        addHostAndPort();
        addNameAndBaud();
        addUdp();
        addConnect();
        addScanner();

        _content.graphics.beginFill(0x3c3c3c);
        _content.graphics.drawRect(0, 0, this.width, this.height);
        _content.graphics.endFill();
    }

    private function setDemoVersion(isDemo:Boolean):void {
        _connectionType.enabled = !isDemo;
        _hostInput.selectable = !isDemo;
        _portInput.selectable = !isDemo;
        _udpPortInput.selectable = !isDemo;
        _hostInput.alpha = (isDemo) ? 0.5 : 1;
        _portInput.alpha = (isDemo) ? 0.5 : 1;
        _udpPortInput.alpha = (isDemo) ? 0.5 : 1;
        _connectButton.enabled = !isDemo;
        _scannerButton.enabled = !isDemo;

        if (isDemo) {
            if (_demoLabel == null) {
                _demoLabel = FontFactory.getCustomFont({color: 0xff0000, size: 12, bold: true, width: 300});
                _demoLabel.text = "Connection is not available in demo version!";
                _demoLabel.x = _x - 15;
                _demoLabel.y = 150;
                _demoLabel.height = 13;
                addContentChild(_demoLabel);
            }
        } else {
            if (_demoLabel != null) {
                _content.removeChild(_demoLabel);
                _demoLabel = null;
            }
        }
    }

    public function isDemoVersion():void {
        if (AppProperties.isDemoProduct()) {
            setDemoVersion(true);
        } else {
            setDemoVersion(false);
            (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).addEventListener("connectDisconnect", connectDisconnectHandler, false, 0, true);
            SettingsConfigs.instance.addEventListener("setConnection", setConnectionHandler, false, 0, true);
            refreshConnectionTypeButtons();
        }
    }

    private function addHostAndPort():void {
        if (_hostLabel == null) {
            _hostLabel = FontFactory.getCustomFont({size: 14, bold: true, color: 0xFFFFFF});
            _hostLabel.text = "Hostname";
            _hostLabel.x = _x;
            _hostLabel.y = 50;
        }
        _hostLabel.visible = SettingsConfigs.instance.isTcp;
        addContentChild(_hostLabel);

        if (_hostInput == null) {
            _hostInput = FontFactory.getCustomFont({size: 12, selectable: true, color: 0x000000});
            _hostInput.width = _bitmap1.width - 2;
            _hostInput.height = _bitmap1.height - 2;
            _hostInput.x = _x + 1;
            _hostInput.y = 70 + 1;
            _hostInput.textColor = 0x000000;
            _hostInput.type = TextFieldType.INPUT;
            _hostInput.addEventListener(FocusEvent.FOCUS_OUT, hostHandler, false, 0, true);
        }
        _hostInput.text = SettingsConfigs.instance.host;
        _hostInput.visible = SettingsConfigs.instance.isTcp;
        addContentChild(_hostInput);

        if (_portLabel == null) {
            _portLabel = FontFactory.getCustomFont({size: 14, bold: true, color: 0xFFFFFF});
            _portLabel.text = "Port number";
            _portLabel.x = _x;
            _portLabel.y = 100;
        }
        _portLabel.visible = SettingsConfigs.instance.isTcp;
        addContentChild(_portLabel);

        if (_portInput == null) {
            _portInput = FontFactory.getCustomFont({size: 12, selectable: true, color: 0x000000});
            _portInput.width = _bitmap2.width - 2;
            _portInput.height = _bitmap2.height - 2;
            _portInput.x = _x + 1;
            _portInput.y = 120 + 1;
            _portInput.textColor = 0x000000;
            _portInput.type = TextFieldType.INPUT;
            _portInput.addEventListener(FocusEvent.FOCUS_OUT, portHandler, false, 0, true);
        }
        _portInput.text = SettingsConfigs.instance.port.toString();
        _portInput.visible = SettingsConfigs.instance.isTcp;
        addContentChild(_portInput);
    }

    private function addUdp():void {
        if (_udpType == null) {
            _udpType = new RadioButtonBar(_x, 50, ["Unicast", "Broadcast"], 12);

            _udpType.x = _x;
            _udpType.y = 30;
            _udpType.addEventListener(MouseEvent.CLICK, connectionTypeHandler, false, 0, true);

            var button:RadioButton = _udpType.getButton(0);
            var options:BitmapButtonOptions = button.options;
            options.margin = 5;
            button.options = options;
            button.resetStates();

            button = _udpType.getButton(1);
            options = button.options;
            options.margin = 5;
            options.align = "right";
            button.options = options;
            button.resetStates();

            _udpType.selectedIndex = SettingsConfigs.instance.udpType;




        }
        addContentChild(_udpType);



        if (_udpHostLabel == null) {
            _udpHostLabel = FontFactory.getCustomFont({size: 14, bold: true, color: 0xFFFFFF});
            _udpHostLabel.width = 130;
            _udpHostLabel.text = "UDP Hostname";
            _udpHostLabel.x = _x;
            _udpHostLabel.y = 50;
        }
        _udpHostLabel.visible = SettingsConfigs.instance.isUnicastUdp();
        addContentChild(_udpHostLabel);

        if (_udpHostInput == null) {
            _udpHostInput = FontFactory.getCustomFont({size: 12, selectable: true, color: 0x000000});
            _udpHostInput.width = _bitmap1.width - 2;
            _udpHostInput.height = _bitmap1.height - 2;
            _udpHostInput.x = _x + 1;
            _udpHostInput.y = 70 + 1;
            _udpHostInput.textColor = 0x000000;
            _udpHostInput.type = TextFieldType.INPUT;
            _udpHostInput.addEventListener(FocusEvent.FOCUS_OUT, udpHostHandler, false, 0, true);
        }
        _udpHostInput.text = SettingsConfigs.instance.udpHost;
        _udpHostInput.visible = SettingsConfigs.instance.isUnicastUdp();
        addContentChild(_udpHostInput);

        if (_udpPortLabel == null) {
            _udpPortLabel = FontFactory.getCustomFont({size: 14, bold: true, color: 0xFFFFFF});
            _udpPortLabel.text = "UDP Port";
            _udpPortLabel.x = _x;
            _udpPortLabel.y = 100;
        }
        _udpPortLabel.visible = SettingsConfigs.instance.isUdp;
        addContentChild(_udpPortLabel);

        if (_udpPortInput == null) {
            _udpPortInput = FontFactory.getCustomFont({size: 12, selectable: true, color: 0x000000});
            _udpPortInput.width = _bitmap2.width - 2;
            _udpPortInput.height = _bitmap2.height - 2;
            _udpPortInput.x = _x + 1;
            _udpPortInput.y = 120 + 1;
            _udpPortInput.textColor = 0x000000;
            _udpPortInput.type = TextFieldType.INPUT;
            _udpPortInput.addEventListener(FocusEvent.FOCUS_OUT, udpPortHandler, false, 0, true);
        }
        _udpPortInput.text = SettingsConfigs.instance.udpPort.toString();
        _udpPortInput.visible = SettingsConfigs.instance.isUdp;
        addContentChild(_udpPortInput);

    }

    private function addNameAndBaud():void {
        if (_nameLabel == null) {
            _nameLabel = FontFactory.getCustomFont({size: 14, bold: true, color: 0xFFFFFF});
            _nameLabel.text = "Serial port name";
            _nameLabel.width = _nameLabel.textWidth + 10;
            _nameLabel.x = _x;
            _nameLabel.y = 50;
        }
        _nameLabel.visible = SettingsConfigs.instance.isSerial;
        addContentChild(_nameLabel);

        if (_nameInput == null) {
            _nameInput = FontFactory.getCustomFont({size: 12, selectable: true, color: 0x000000});
            _nameInput.width = _bitmap1.width - 2;
            _nameInput.height = _bitmap1.height - 2;
            _nameInput.x = _x + 1;
            _nameInput.y = 70 + 1;
            _nameInput.textColor = 0x000000;
            _nameInput.type = TextFieldType.INPUT;
            _nameInput.addEventListener(FocusEvent.FOCUS_OUT, nameHandler, false, 0, true);
        }
        _nameInput.text = SettingsConfigs.instance.portName;
        _nameInput.visible = SettingsConfigs.instance.isSerial;
        addContentChild(_nameInput);

        if (_baudLabel == null) {
            _baudLabel = FontFactory.getCustomFont({size: 14, bold: true, color: 0xFFFFFF});
            _baudLabel.text = "Serial port baud";
            _baudLabel.width = _baudLabel.textWidth + 10;
            _baudLabel.x = _x;
            _baudLabel.y = 100;
        }
        _baudLabel.visible = SettingsConfigs.instance.isSerial;
        addContentChild(_baudLabel);

        if (_baudInput == null) {
            _baudInput = FontFactory.getCustomFont({size: 12, selectable: true, color: 0x000000});
            _baudInput.width = _bitmap2.width - 2;
            _baudInput.height = _bitmap2.height - 2;
            _baudInput.x = _x + 1;
            _baudInput.y = 120 + 1;
            _baudInput.textColor = 0x000000;
            _baudInput.type = TextFieldType.INPUT;
            _baudInput.addEventListener(FocusEvent.FOCUS_OUT, baudHandler, false, 0, true);
        }
        _baudInput.text = SettingsConfigs.instance.portBaud.toString();
        _baudInput.visible = SettingsConfigs.instance.isSerial;
        addContentChild(_baudInput);
    }

    private function addConnect():void {
        if (_connectButton == null) {
            _connectButton = new AlarmDownBtn("Connect");
            _connectButton.x = (this.width / 2) + 10;
            _connectButton.y = 170;
            _connectButton.addEventListener(MouseEvent.CLICK, connectHandler, false, 0, true);
        }
        refreshConnectDisconnectButton();
        addContentChild(_connectButton);
    }

    private function addScanner():void {
        if (_scannerButton == null) {
            _scannerButton = new AlarmDownBtn("Find NMEA");
            _scannerButton.x = (this.width / 2) - (_scannerButton.width) - 10;
            _scannerButton.y = 170;
            _scannerButton.addEventListener(MouseEvent.CLICK, scannerHandler, false, 0, true);
        }
        addContentChild(_scannerButton);
    }

    private function connectionTypeHandler(event:MouseEvent):void {
        if (Statuses.instance.socketStatus && !WindowsHandler.instance.application.socketDispatcher.isDemoConnected) {
            NotificationHandler.createAlert(NotificationTypes.USER_CONNECTION_CLOSE_ALERT, NotificationTypes.USER_CONNECTION_CLOSE_ALERT_TEXT, 0, changeConnectionType, cancelChangeConnectionType);
        } else {
            changeConnectionType();
        }
    }

    private function changeConnectionType():void {
        var socketDispatcher:SocketDispatcher = (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher);
        socketDispatcher.close(false);
        socketDispatcher.stopDemoConnect();
        socketDispatcher.initComponentsForConnect();
        SettingsConfigs.instance.connectionType = _connectionType.selectedIndex;
        SettingsConfigs.instance.udpType = _udpType.selectedIndex;
        setConnectionTypeVisible();
    }

    private function cancelChangeConnectionType():void {
        _connectionType.selectedIndex = SettingsConfigs.instance.connectionType;
        _udpType.selectedIndex = SettingsConfigs.instance.udpType;

    }

    private function setConnectionTypeVisible():void {
        var isTcp:Boolean = SettingsConfigs.instance.isTcp;
        var isSerial:Boolean = SettingsConfigs.instance.isSerial;
        var isUdp:Boolean = SettingsConfigs.instance.isUdp;
        var isUnicastUdp:Boolean = SettingsConfigs.instance.isUnicastUdp();
        _hostLabel.visible = isTcp;
        _hostInput.visible = isTcp;
        _portLabel.visible = isTcp;
        _portInput.visible = isTcp;
        _nameLabel.visible = isSerial;
        _nameInput.visible = isSerial;
        _baudLabel.visible = isSerial;
        _baudInput.visible = isSerial;
        _udpPortInput.visible = isUdp;
        _udpPortLabel.visible = isUdp;
        _udpHostInput.visible = isUnicastUdp;
        _udpHostLabel.visible = isUnicastUdp;
        _udpType.visible = isUdp;
        _bitmap1.visible = isTcp || isSerial || isUnicastUdp;
        _bitmap2.visible = isTcp || isSerial || isUdp;
    }

    private function hostHandler(event:FocusEvent) {
        SettingsConfigs.instance.host = _hostInput.text;
    }

    private function portHandler(event:FocusEvent) {
        SettingsConfigs.instance.port = Number(_portInput.text);
    }

    private function nameHandler(event:FocusEvent) {
        SettingsConfigs.instance.portName = _nameInput.text;
    }

    private function baudHandler(event:FocusEvent) {
        SettingsConfigs.instance.portBaud = int(_baudInput.text);
    }

    private function connectHandler(event:MouseEvent) {
        WindowsHandler.instance.application.socketDispatcher.connectDisconnect();
    }

    private function scannerHandler(event:MouseEvent):void {
        if (Statuses.instance.socketStatus && !WindowsHandler.instance.application.socketDispatcher.isDemoConnected) {
            NotificationHandler.createAlert(NotificationTypes.USER_CONNECTION_CLOSE_ALERT, NotificationTypes.USER_CONNECTION_CLOSE_ALERT_TEXT, 0, openPortWindow);
        } else {
            openPortWindow();
        }
    }

    private function openPortWindow():void {
        AppProperties.openPortWindow(null);
    }

    private function refreshConnectDisconnectButton() {
        if (Statuses.instance.socketStatus && !WindowsHandler.instance.application.socketDispatcher.isDemoConnected) {
            _connectButton.label = "Disconnect";
        } else {
            _connectButton.label = "Connect";
        }
    }

    private function refreshConnectionTypeButtons() {
        _connectionType.selectedIndex = SettingsConfigs.instance.connectionType;
        setConnectionTypeVisible();
    }

    private function initButtons() {
        refreshConnectDisconnectButton();
        refreshConnectionTypeButtons();
    }

    private function connectDisconnectHandler(event:Event):void {
        refreshConnectDisconnectButton();
    }

    private function setConnectionHandler(event:Event):void {
        _hostInput.text = SettingsConfigs.instance.host;
        _portInput.text = SettingsConfigs.instance.port.toString();
        _nameInput.text = SettingsConfigs.instance.portName;
        _baudInput.text = SettingsConfigs.instance.portBaud.toString();

        WindowsHandler.instance.application.socketDispatcher.close();
        WindowsHandler.instance.application.socketDispatcher.connect();
        initButtons();
    }


    private function udpPortHandler(event:FocusEvent):void {
        SettingsConfigs.instance.udpPort = int(_udpPortInput.text);
    }


    private function udpHostHandler(event:FocusEvent):void {
        SettingsConfigs.instance.udpHost = _udpHostInput.text;
    }


}
}
