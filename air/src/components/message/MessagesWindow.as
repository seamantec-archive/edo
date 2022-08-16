/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.14.
 * Time: 13:01
 * To change this template use File | Settings | File Templates.
 */
package components.message {
import com.sailing.SailData;
import com.sailing.WindowsHandler;
import com.sailing.datas.BaseSailData;
import com.sailing.socket.SocketDispatcher;
import com.sailing.units.Unit;
import com.ui.controls.AlarmDownBtn;
import com.utils.FontFactory;

import components.alarm.Badge;
import components.list.List;
import components.list.ListHeader;
import components.list.ListOpenCloseButton;
import components.windows.FloatWindow;

import flash.events.Event;
import flash.events.MouseEvent;

public class MessagesWindow extends FloatWindow {

    public static const WIDTH:int = 420;

    private var _list:List;
    private var _button:ListOpenCloseButton;
    private var _isReverse:Boolean;

    private var _allButton:AlarmDownBtn;
    private var _openedButton:AlarmDownBtn;
    private var _validButton:AlarmDownBtn;
    private var _validBubble:Badge;

    private var _filters:Vector.<Function>;

    public function MessagesWindow() {
        super("NMEA messages list");

        _list = new List(0, 0, WIDTH, FloatWindow.L_HEIGHT + 3);
        var header:ListHeader = new ListHeader(_list.width, 23, 0xFFFFFF);
        header.addLabel("NMEA Sentence", FontFactory.getCustomFont({
            size: 12,
            color: 0x000000,
            height: 20
        }), 4, 2).addEventListener(MouseEvent.CLICK, sort, false, 0, true);
        addAllOpenCloseButton(header);
        _list.addHeader(header);
        _list.addScrollBar();
        _content.addChild(_list);

        _filters = new Vector.<Function>();

        fillMessages();

        _isReverse = true;
        sort(null);

        setButtonAlign(BUTTON_ALIGN_LEFT);
        _allButton = this.addDownButton(0, "All", allHandler);
        _openedButton = this.addDownButton(1, "Opened", openedHandler);
        _validButton = this.addDownButton(2, "Valid", validHandler);
        _validBubble = this.addBubble(2);
        disableDownButton(0);
//        var validTimer:Timer = new Timer(3000);
//        validTimer.addEventListener(TimerEvent.TIMER, validCounter, false, 0, true);
//        validTimer.start();

        this.resizeable = false;
        this.resize(WIDTH + _frame.getWidthAndContentDiff(),
                FloatWindow.L_HEIGHT + _frame.getHeightAndContentDiff());
        this.width = _w;
        this.height = _h;
        repositionElements();
        validCounter();

        (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).addEventListener("connectDisconnect", connectDisconnectHandler, false, 0, true);
        (WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).addEventListener("connectDisconnectDemo", connectDisconnectHandler, false, 0, true);
    }

    public function fillMessages():void {
        var sailData:SailData = new SailData();
        var parameters:Array = SailData.ownProperties;
        var key:String;
        var parent:BaseSailData;
        var actualSailData:BaseSailData;
        for (var i:int = 0; i < parameters.length; i++) {
            key = parameters[i];
            if (!(sailData[key] is BaseSailData) || key == "tripdata") {
                continue;
            }
            parent = sailData[key];

            actualSailData = WindowsHandler.instance.actualSailData[key];
            var parentParameters:Array = parent.ownProperties;
            var item:MessageListItem = itemOfKey(key);
            if (item == null) {
                item = new MessageListItem(key, _list, actualSailData.displayName);
                _list.addItem(item);
            }
            for (var j:int = 0; j < parentParameters.length; j++) {
                var ckey:String = parentParameters[j];
                if (isInIgnoreList(ckey)) {
                    continue;
                }
                setValue(actualSailData, item, ckey);

            }
        }
    }

    private function isInIgnoreList(ckey:String):Boolean {
        return ckey === "isInValid" || ckey === "isInPreValid" || ckey === "lastTimestamp";
    }

    public function messageRefreshed(key:String):void {
        if (key == "tripdata") {
            return;
        }

        var actualSailData:BaseSailData = WindowsHandler.instance.actualSailData[key];
        var parentParameters:Array = actualSailData.ownProperties;
        for (var j:int = 0; j < parentParameters.length; j++) {
            var ckey:String = parentParameters[j];
            if (isInIgnoreList(ckey)) {
                continue;
            }

            setValue(actualSailData, itemOfKey(key), ckey);
            _list.filter(_list.getFilters());
        }

        validCounter();
    }

    public function validRefresh():void {
        validCounter();
    }

    private function setValue(actualSailData:BaseSailData, item:MessageListItem, ckey:String):void {
        var label:String = actualSailData.getParameterDisplayName(ckey)
        if (!actualSailData.isValid()) {
            item.setValue(ckey, null, label);
        } else {
            if (actualSailData[ckey] is String) {
                item.setValue(ckey, actualSailData[ckey], label);
            } else {
                var data:Object = actualSailData[ckey];
                var isUnit:Boolean = data is Unit;
                var digit:uint = (isUnit) ? 2 : 5;
                var value:String = "";

                if (data is Number) {
                    value = ( Number(data) % 1 != 0 ? data.toFixed(digit) : String(data));
                } else if (isUnit) {
                    value = (data as Unit).getValueWithShortUnitInString();
                } else {
                    value = String(data)
                }
                item.setValue(ckey, value, label);
            }

        }
    }

    private function itemOfKey(key:String):MessageListItem {
        for (var i:int; i < _list.length; i++) {
            var item:MessageListItem = _list.getItem(i) as MessageListItem;
            if (item.key == key) {
                return item;
            }
        }
        return null;
    }

    private function addAllOpenCloseButton(header:ListHeader):void {
        _button = new ListOpenCloseButton();
        _button.x = MessagesWindow.WIDTH - 30;
        _button.y = 2;
        _button.addEventListener(MouseEvent.CLICK, buttonHandler, false, 0, true);
        header.addChild(_button);
    }

    private function buttonHandler(event:MouseEvent):void {
        _button.isOpen = !_button.isOpen;
        if (_button.isOpen) {
            for (var i:int = 0; i < _list.length; i++) {
                (_list.getItem(i) as MessageListItem).open();
            }
        } else {
            for (var i:int = 0; i < _list.length; i++) {
                (_list.getItem(i) as MessageListItem).close();
            }
        }
        _list.filter(_list.getFilters());
        _list.scrollBox(0);
    }

    private function allHandler(event:MouseEvent):void {
        disableDownButton(0);
        _list.scrollToTop();
        _list.setFilters(null);
        _list.filter(null);
    }

    private function openedHandler(event:MouseEvent):void {
        disableDownButton(1);
        _list.scrollToTop();
        _filters.length = 0;
        _filters.push(openedFilter);
        _list.setFilters(_filters);
        _list.filter(_filters);
    }

    private function validHandler(event:MouseEvent):void {
        if (event != null) {
            _list.scrollToTop();
            disableDownButton(2);
        }
        _filters.length = 0;
        _filters.push(validFilter);
        _list.setFilters(_filters);
        _list.filter(_filters);

    }

    private function sort(event:MouseEvent):void {
        if (_isReverse) {
            _list.sort(ascSort);
            _isReverse = false;

        } else {
            _list.sort(descSort);
            _isReverse = true;
        }
        _list.filter(_list.getFilters());
    }

    private function openedFilter(x:MessageListItem):Boolean {
        return x.content.visible;
    }

    private function validFilter(x:MessageListItem):Boolean {
        var data:BaseSailData = WindowsHandler.instance.actualSailData[x.key];
        var result:Boolean = data.isValid() || data.isPreValid();
        if (result) {
            x.setValid();
        } else {
            x.setInvalid();
        }
        return result;
    }

    private function ascSort(a:MessageListItem, b:MessageListItem):int {
        if (a.key < b.key) {
            return -1
        } else if (a.key > b.key) {
            return 1;
        } else {
            return 0
        }
    }

    private function descSort(a:MessageListItem, b:MessageListItem):int {
        if (a.key > b.key) {
            return -1
        } else if (a.key < b.key) {
            return 1;
        } else {
            return 0
        }
    }

    private function validCounter():void {
        var sum:int = 0;
        for (var i:int; i < _list.length; i++) {
            if (validFilter(_list.getItem(i) as MessageListItem)) {
                sum++;
            }
        }
        _validBubble.setText(sum.toString());

        if (!_validButton.enabled) {
            validHandler(null);
        }
    }

    private function setInvalid():void {
        validCounter();
        allHandler(null);
//        for (var i:int; i < _list.length; i++) {
//            var item:MessageListItem = _list.getItem(i) as MessageListItem;
//            if (!validFilter(item)) {
//                item.setInvalid();
//            }
//        }
    }

    private function connectDisconnectHandler(event:Event):void {
        if ((WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).getStatus() == 0 || !(WindowsHandler.instance.application.socketDispatcher as SocketDispatcher).isDemoConnected) {
            setInvalid();
        }
    }
}
}
