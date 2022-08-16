package components.port {

import com.common.AppProperties;
import com.sailing.WindowsHandler;
import com.sailing.socket.PortScanner;
import com.sailing.socket.ScannerPort;
import com.store.SettingsConfigs;
import com.ui.controls.AlarmDownBtn;

import components.list.List;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class PortList extends List {

    private static var instance:PortList;

    private var _window:PortWindow;

    private var _refresh:Timer;
    private var _scanner:PortScanner;

    function PortList() {
        super(0,0, PortWindow.WIDTH,PortWindow.HEIGHT);

        _scanner = PortScanner.getInstance();
        //_scanner.startScan();
        _refresh = new Timer(1000);
        _refresh.addEventListener(TimerEvent.TIMER, refresh, false, 0, true);
    }

    public static function getInstance():PortList {
        if (instance == null) {
            instance = new PortList();
        }
        return instance;
    }

    private function refresh(event:TimerEvent):void {
        var percent:Number = Math.floor((_scanner.connectCounter/_scanner.connectSum)*100);
        var label:String = "Find NMEA (" + ((percent>100) ? 100 : percent) + "%)";
        setTitle(label);
        setButtonLabel(label);

        if(_scanner.ports.length>this.length) {
            for(var i:int=this.length; i<_scanner.ports.length; i++) {
                var port:ScannerPort = _scanner.ports[i];
                var item:PortListItem = new PortListItem(port);
                item.button.addEventListener(MouseEvent.CLICK, setPort, false, 0, true);
                addItem(item);
            }
        }

        if(_scanner.connectCounter>=_scanner.connectSum) {
            close();
//            _window.getStatusButton().label = "Start";
        }
    }

    private function setPort(event:MouseEvent):void {
        AppProperties.portWindow.beforeClose();
        AppProperties.portWindow.close();
        WindowsHandler.instance.application.socketDispatcher.close();
        var button:AlarmDownBtn = event.target as AlarmDownBtn;
        var index:uint = button.parent.y/40;
        SettingsConfigs.instance.setPort(_scanner.ports[index]);


    }

    private function setButtonLabel(label:String):void {
        if(_window.getButton()!=null) {
            _window.getButton().label = label;
        }
    }

    private function setTitle(title:String):void {
        if(!_window.closed) {
            _window.setTitle(title);
        }
    }

    public function close():void {
        _refresh.stop();
        setButtonLabel("Find NMEA");
        setTitle("Find NMEA");
    }

    public function restart():void {
        removeAllItem();
        _refresh.start();
    }

    public function set window(window:PortWindow):void {
        _window = window;
    }

    public function setWindow(window:PortWindow):void {
        _window = window;
    }

    public function isScannerRunning():Boolean {
        return _refresh.running;
    }
}
}
