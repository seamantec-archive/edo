/**
 * Created by seamantec on 04/02/15.
 */
package components.cloud {

import com.common.AppProperties;
import com.harbor.CloudHandler;
import com.harbor.PolarFile;
import com.harbor.PolarFileEvent;
import com.harbor.PolarFileHandler;
import com.harbor.PolarHandlerEvent;
import com.notification.NotificationHandler;
import com.notification.NotificationTypes;
import com.polar.PolarContainer;
import com.polar.PolarEvent;
import com.seamantec.LicenseEvent;
import com.ui.controls.AlarmDownBtn;

import components.list.List;
import components.windows.FloatWindow;

import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;

public class PolarWindow extends FloatWindow {

    public static var WIDTH:Number;
    public static var HEIGHT:Number;

    private static var _list:List;
    private static var _led:Shape;

    private var _uploadButton:AlarmDownBtn;
    private var _deleteButton:AlarmDownBtn;

    private static var _selected:PolarFile;

    public function PolarWindow() {
        super("My polar files");

        WIDTH = this.width - _frame.getWidthAndContentDiff();
        HEIGHT = this.height - _frame.getHeightAndContentDiff();

        this.resizeable = false;

        if (_list == null) {
            _list = new List(0, 0, WIDTH, HEIGHT);
            _list.addScrollBar();
        }
        _content.addChild(_list);

        _uploadButton = this.addDownButton(1, "Upload current", uploadPolarHandler, 10, true);
        _deleteButton = this.addDownButton(2, "Delete", deletePolarHandler, 10, true);

        setButtons();
        setPolarList();

        setLed();

        PolarFileHandler.instance.addEventListener(PolarHandlerEvent.POLAR_LIST_READY, polarListReadyHandler, false, 0, true);
        PolarFileHandler.instance.addEventListener(PolarHandlerEvent.POLAR_LIST_STATUS_CHANGE, polarListStatusChangeHandler, false, 0, true);
        PolarContainer.instance.addEventListener(PolarEvent.POLAR_CHANGED, polarChangedHandler, false, 0, true);

        AppProperties.licenseManager.addEventListener(LicenseEvent.ACTIVATED, licenceManagerHandler, false, 0, true);
        AppProperties.licenseManager.addEventListener(LicenseEvent.DEACTIVATED, licenceManagerHandler, false, 0, true);
    }

    public function get selected():PolarFile {
        return _selected;
    }

    public function set selected(value:PolarFile):void {
        _selected = value;
    }

    public function setButtons():void {
        var hasSelected:Boolean = (_selected != null);
        _uploadButton.enabled = (AppProperties.hasComHobbyLicense()) ? true : false;
        _deleteButton.enabled = hasSelected;
    }

    public function deactivate():void {
        if (_selected != null) {
            _selected = null;

            var length:int = _list.length;
            var item:PolarListItem;
            for (var i:int = 0; i < length; i++) {
                item = _list.getItem(i) as PolarListItem;
                if (item.active) {
                    item.deactivate();
                }
            }
        }

        setButtons();
    }

    private function setLed():void {
        if (_led == null) {
            _led = new Shape();
            _led.x = 5;
        }
        try {
            header.getChildIndex(_led);
        } catch(e:ArgumentError) {
            header.addChild(_led);
        }
        _led.graphics.clear();
        switch (PolarFileHandler.instance.status) {
            case PolarFileHandler.STATUS_SYNCED:
                _led.graphics.beginFill(0x00cc00);
                _led.graphics.drawCircle(12, 12, 4);
                break;

            case PolarFileHandler.STATUS_NOT_SYNCED:
                _led.graphics.beginFill(0xff0000);
                _led.graphics.drawCircle(12, 12, 4);
                break;

            case PolarFileHandler.STATUS_SYNCING:
                _led.graphics.beginFill(0xfefe00);
                _led.graphics.drawCircle(12, 12, 4);
                break;

            default:
                _led.graphics.beginFill(0xff0000);
                _led.graphics.drawCircle(12, 12, 4);
        }
        _led.graphics.endFill();
    }

    private function setPolarList():void {
        //delete items
        var item:PolarListItem;
        for (var i:int = _list.length - 1; i >= 0; i--) {
            item = _list.getItem(i) as PolarListItem;
            if (!PolarFileHandler.instance.hasId(item.id)) {
                if(_selected==item.polarFile) {
                    _selected = null;
                }
                _list.removeIndex(i);
            }
        }
        //Add/refresh items
        var length:int = PolarFileHandler.instance.container.length;
        var polarFile:PolarFile;

        for (var i:int = 0; i < length; i++) {
            polarFile = PolarFileHandler.instance.container[i];
            if (!hasItemById(polarFile.id)) {
                item = new PolarListItem(polarFile);
                _list.addItem(item);
                if(!polarFile.hasFile()) {
                    polarFile.addEventListener(PolarFileEvent.FILE_READY, polarFileReadyHandler, false, 0, true);
                    item.getLabel(0).textColor = 0x999999;
                }
            }
        }

        _list.scrollBox(0);

        setButtons();
    }

    private function hasItemById(id:String):Boolean {
        for (var i:int = _list.length - 1; i >= 0; i--) {
            if ((_list.getItem(i) as PolarListItem).id == id) {
                return true;
            }
        }
        return false;
    }

    private function getPolarListItemById(index:String):PolarListItem {
        var length:int = _list.length;
        var item:PolarListItem;
        for (var i:int = 0; i < length; i++) {
            item = _list.getItem(i) as PolarListItem;
            if (index == item.id) {
                return item;
            }
        }

        return null;
    }

    private function polarFileReadyHandler(event:PolarFileEvent):void {
        var polarFile:PolarFile = event.currentTarget as PolarFile;
        if(polarFile!=null) {
            getPolarListItemById(polarFile.id).getLabel(0).textColor = 0x000000;
        }
    }

    private function polarListReadyHandler(event:PolarHandlerEvent):void {
        setPolarList();
        setLed();
    }

    private function polarListStatusChangeHandler(event:PolarHandlerEvent):void {
        setLed();
    }

    private function polarChangedHandler(event:PolarEvent):void {
        deactivate();
    }

    private function uploadPolarHandler(event:MouseEvent):void {
        if (_selected == null) {
            openInput();
            _inputInputField.text = "polar";
            setOkBtnEnabled()
            _inputButtonOk.addEventListener(MouseEvent.CLICK, inputButtonOkHandler, false, 0, true);
            _inputButtonCancel.addEventListener(MouseEvent.CLICK, inputButtonCancelHandler, false, 0, true);
        }
    }


    override protected function inputInputField_changeHandler(event:Event):void {
        setOkBtnEnabled()
    }

    private function inputButtonOkHandler(event:MouseEvent):void {
        _inputButtonOk.removeEventListener(MouseEvent.CLICK, inputButtonOkHandler);
        _inputButtonCancel.removeEventListener(MouseEvent.CLICK, inputButtonCancelHandler);
        CloudHandler.instance.savePolar(_inputInputField.text, PolarContainer.instance.polarTableFromFile.content);
        closeInput();
    }

    private function inputButtonCancelHandler(event:MouseEvent):void {
        _inputButtonOk.removeEventListener(MouseEvent.CLICK, inputButtonOkHandler);
        _inputButtonCancel.removeEventListener(MouseEvent.CLICK, inputButtonCancelHandler);
        _inputButtonOk.enabled = true;
        closeInput();
    }

    private function setOkBtnEnabled():void {
        _inputButtonOk.enabled = _inputInputField.text.length > 0;
    }

//    private function activatePolarHandler(event:MouseEvent):void {
//        if (_selected != null) {
//            var p:Array = _selected.filePath.split(".");
//            PolarContainer.instance.openPolarFromFile(new File(_selected.filePath), false, _selected.name + "." + p[p.length - 1]);
//        }
//    }

    private function deletePolarHandler(event:MouseEvent):void {
        NotificationHandler.createAlert(NotificationTypes.DELETE_POLAR, NotificationTypes.DELETE_POLAR_TEXT, 0, deletePolar);
    }

    private function deletePolar():void {
        if (_selected != null) {
            _list.removeItem(getPolarListItemById(_selected.id));
            _selected.deletePolar();
            _selected = null;
        }
    }

    private function licenceManagerHandler(event:LicenseEvent):void {
        setButtons();
    }
}
}
