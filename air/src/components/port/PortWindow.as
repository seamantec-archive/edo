/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 11/11/13
 * Time: 10:57
 * To change this template use File | Settings | File Templates.
 */
package components.port {

import com.sailing.socket.PortScanner;
import com.ui.controls.AlarmDownBtn;
import com.utils.FontFactory;

import components.ToggleButton;
import components.list.ListHeader;
import components.windows.FloatWindow;
import components.windows.WindowFrame;

import flash.events.Event;
import flash.events.MouseEvent;

public class PortWindow extends FloatWindow {

    private static var _portList:PortList;
    private var _button:ToggleButton;
    private var _statusButton:AlarmDownBtn;
    public var serialClosed:Boolean = false;
    public static var WIDTH:Number;
    public static var HEIGHT:Number;

    public function PortWindow(button:ToggleButton) {
        super("Find NMEA");

        WIDTH = this.width - _frame.getWidthAndContentDiff();
        HEIGHT = this.height - _frame.getHeightAndContentDiff();

        _button = button;
        _portList = PortList.getInstance();
        _portList.setWindow(this);

        this.resizeable = false;
        this.addEventListener(Event.CLOSE, closeHandler, false, 0, true);

        if(_portList.header==null) {
            var header:ListHeader = new ListHeader(WIDTH,20);
            header.addLabel("Type", FontFactory.getLeftBlackTextField(), 10);
            header.addLabel("IP/Name", FontFactory.getLeftBlackTextField(), 70);
            header.addLabel("Port/Baud", FontFactory.getLeftBlackTextField(), 150);
            header.graphics.lineStyle(1, 0x000000);
            header.graphics.moveTo(0, 20);
            header.graphics.lineTo(WIDTH, 20);
            _portList.addHeader(header);
            _portList.addScrollBar();
        }
        this._content.addChild(_portList);

        startScanner();

//        this.setButtonAlign(FloatWindow.BUTTON_ALIGN_RIGHT);
//        _statusButton = this.addDownButton(2, "Start", setStatus);
//        if(_portList.isScannerRunning()) {
//            _statusButton.label = "Stop";
//        }
    }
    public function beforeClose():void{
        serialClosed = true;
        PortScanner.getInstance().stopScan();
    }
    private function startScanner():void {
        PortScanner.getInstance().startScan();
        _portList.restart();
    }

    private function closeHandler(event:Event):void {
        if(!serialClosed){
         PortScanner.getInstance().stopScan();
        }
        _portList.close();
    }

    private function setStatus(event:MouseEvent):void {
        if(_statusButton.labelText=="Stop") {
            PortScanner.getInstance().stopScan();
            _portList.close();
            _statusButton.label = "Start";
        } else {
            PortScanner.getInstance().startScan();
            _portList.restart();
            _statusButton.label = "Stop";
        }
    }

    public function getButton():ToggleButton {
        return _button;
    }

    public function getStatusButton():AlarmDownBtn {
        return _statusButton;
    }

    public function get frame():WindowFrame {
        return _frame;
    }

}
}
