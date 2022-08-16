/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.08.30.
 * Time: 16:45
 * To change this template use File | Settings | File Templates.
 */
package components.alarm {
import com.utils.FontFactory;

import flash.text.TextFormatAlign;

public class InfoBadge extends Badge {
    [Embed(source="../../../assets/images/alarmlist/info_badge.png")]
    public static var BACKGROUND:Class;

    public function InfoBadge() {
        super();
    }

    protected override function createBg():void {
        _iconBitmap = new BACKGROUND();
        _iconBitmap.x = 0;
        _iconBitmap.y = 0;
    }

    override protected function createLabel():void {
        label = FontFactory.getCustomFont({size: 12, color: 0xffffff, align: "center", autoSize: "center", width: _iconBitmap.width, height: _iconBitmap.height})
    }
}
}
