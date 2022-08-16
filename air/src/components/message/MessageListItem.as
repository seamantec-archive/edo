/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.14.
 * Time: 13:29
 * To change this template use File | Settings | File Templates.
 */
package components.message {

import com.utils.FontFactory;

import components.list.DynamicListItem;
import components.list.List;

import flash.display.Bitmap;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class MessageListItem extends DynamicListItem {

    [Embed(source="../../../assets/images/msglist/closedlist_element.png")]
    private static var closed:Class;

    [Embed(source="../../../assets/images/msglist/led_on.png")]
    private static var ledOn:Class;

    [Embed(source="../../../assets/images/msglist/led_off.png")]
    private static var ledOff:Class;

    [Embed(source="../../../assets/images/msglist/led_m.png")]
    private static var ledMiddle:Class;

    public static const HEIGHT:int = 24;

    private var _changeTimer:Timer;

    private var _ledOn:Bitmap;
    private var _ledOff:Bitmap;
    private var _ledMiddle:Bitmap;

    private var _key:String;

    private var _details:MessageListDetail;


    public function MessageListItem(key:String, list:List = null, label:String = "") {
        super(MessagesWindow.WIDTH, HEIGHT, list, 0x4242ff);

        this.graphics.beginBitmapFill(new closed().bitmapData);
        this.graphics.drawRect(0, 0, MessagesWindow.WIDTH, HEIGHT);
        this.graphics.endFill();
        if (label == "") {
            label = key.toUpperCase()
        }
        addLabel(label, FontFactory.nmeaMSGfont(), 30, 2);

        _key = key;
        _details = new MessageListDetail();
        _ledOff = new ledOff();
        _ledOff.x = 4;
        _ledOff.y = 2;
        _ledOn = new ledOn();
        _ledOn.x = 4;
        _ledOn.y = 2;
        _ledOn.alpha = 0;
        _ledMiddle = new ledMiddle();
        _ledMiddle.x = 4;
        _ledMiddle.y = 2;
        _ledMiddle.visible = false;
        _changeTimer = new Timer(33, 16);
        _changeTimer.addEventListener(TimerEvent.TIMER, changeTimerHandler, false, 0, true);
    }

    public function setValue(key:String, value:String, label:String = "", defaultValue:String = "---"):void {
        var detail:Object = _details.getDetailOfKey(key);
        if (value == null) {
            value = defaultValue;
        }
        if (detail == null) {
            if (content.height == 0) {
                addChild(_ledOff);
                addChild(_ledMiddle);
                addChild(_ledOn);
            }
            if (label == "") {
                label = key;
            }
            _details.push(key, value, label);
            addContentChild(_details)

        } else {
            _details.setValueOfKey(key, value);
            if (value != defaultValue) {
                dataChanged();
            }
        }
    }

    public function get key():String {
        return _key;
    }

    private function dataChanged():void {
        _changeTimer.reset();
        if (!_changeTimer.running) {
            _changeTimer.start();
        }
    }

    private function changeTimerHandler(event:TimerEvent):void {
        _ledOff.visible = false;
        _ledMiddle.visible = true;
        if (_changeTimer.currentCount <= 11) {
            _ledOn.alpha = 1;
        } else {
            _ledOn.alpha = 1 - (_changeTimer.currentCount / _changeTimer.repeatCount);
        }
    }

    public function setValid():void {
        if (!_changeTimer.running) {
//            _changeTimer.stop();


//            _ledOff.visible = false;
            _ledOn.alpha = 0;
        }
        _ledOff.visible = false;
        _ledMiddle.visible = true;

    }

    public function setInvalid():void {
        _changeTimer.reset();
        _ledOff.visible = true;
        _ledMiddle.visible = false;
        _ledOn.alpha = 0;
        for (var i:int = 0; i < _details.details.length; i++) {
            setValue(_details.details[i].key, null);
        }
    }
}
}
