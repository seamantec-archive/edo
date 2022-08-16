package components.message {
import com.utils.FontFactory;

import flash.display.BitmapData;
import flash.display.Sprite;

public class MessageListDetail extends Sprite {

    [Embed(source="../../../assets/images/msglist/openedlist_element.png")]
    private static var opened:Class;

    private var _background:BitmapData;

    private var _details:Vector.<MessageDetail>;

    public function MessageListDetail() {
        _details = new Vector.<MessageDetail>();

        _background = new opened().bitmapData;
    }

    public function push(key:String, value:String, label:String) {
        var detail:Object = new MessageDetail(key, FontFactory.getRightTextField(), FontFactory.getLeftTextField());
        _details.push(detail);

        var row:Sprite = new Sprite();
        row.y = this.height;
        row.graphics.beginBitmapFill(_background);
        row.graphics.drawRect(0, 0, MessagesWindow.WIDTH, MessageListItem.HEIGHT);
        row.graphics.endFill();
        detail.label.width = MessagesWindow.WIDTH / 4;
        detail.label.text = label;
        detail.label.y = 4;
        detail.value.x = MessagesWindow.WIDTH / 2;
        detail.value.text = value;
        detail.value.y = 4;
        row.addChild(detail.label);
        row.addChild(detail.value);
        this.addChild(row);
    }

    public function getDetailOfIndex(index:int):MessageDetail {
        return (index >= 0 && index < _details.length) ? _details[index] : null;
    }

    public function getDetailOfKey(key:String):MessageDetail {
        for (var i = 0; i < _details.length; i++) {
            var detail:MessageDetail = _details[i];
            if (detail.key == key) {
                return detail;
            }
        }
        return null;
    }

    public function getKey(index:int):String {
        var detail:MessageDetail = getDetailOfIndex(index);
        return (detail != null) ? detail.key : null;
    }

    public function setValueOfIndex(index:int, value:String):void {
        var detail:MessageDetail = getDetailOfIndex(index);
        if (detail != null) {
            detail.value.text = value;
        }
    }

    public function setValueOfKey(key:String, value:String):void {
        var detail:MessageDetail = getDetailOfKey(key);
        if (detail != null) {
            detail.value.text = value;
        }
    }


    public function get details():Vector.<MessageDetail> {
        return _details;
    }

}
}
