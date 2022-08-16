/**
 * Created with IntelliJ IDEA.
 * User: seamantec
 * Date: 7/11/13
 * Time: 2:53 PM
 * To change this template use File | Settings | File Templates.
 */
package components.alarm {
import com.alarm.AlarmHandler;
import com.utils.FontFactory;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormatAlign;

public class Badge extends Sprite {

    [Embed(source="../../../assets/images/badge_bg.png")]
    public static var BACKGROUND:Class;

    protected var label:TextField;
    protected var _iconBitmap:Bitmap;

    public function Badge() {

        createBg();
        this.addChild(_iconBitmap);
        createLabel();
        label.x = _iconBitmap.width / 2 - label.width / 2;
        label.y = 0;
        label.text = AlarmHandler.instance.activeAlarmCounter.toString();

        label.visible = true;

        this.addChild(label);
        this.visible = true;
    }

    protected function createLabel():void {
        label = FontFactory.getCustomFont({size: 14, color: 0xffffff, align: "center", autoSize: "center", width: _iconBitmap.width, height: _iconBitmap.height})
    }

    protected function createBg():void {
        _iconBitmap = new BACKGROUND();
        _iconBitmap.x = 0;
        _iconBitmap.y = 0;
    }

    public function setText(str:String):void {
        this.label.text = str;
        label.x = _iconBitmap.width / 2 - label.width / 2;
    }
}
}
