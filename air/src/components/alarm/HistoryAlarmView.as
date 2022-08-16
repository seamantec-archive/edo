/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.04.02.
 * Time: 19:27
 * To change this template use File | Settings | File Templates.
 */
package components.alarm {
import com.alarm.HistoryAlarm;

import components.windows.FloatWindow;

import flash.display.Sprite;

public class HistoryAlarmView extends Sprite {
    private var _hAlarm:HistoryAlarm;

    public function HistoryAlarmView(hAlarm:HistoryAlarm) {
        super();
        this._hAlarm = hAlarm;
        graphics.beginFill(0xc7c7c7)
        graphics.drawRect(0, 0, FloatWindow.L_WIDTH, AlarmView.DEF_HEIGHT - 1);
        graphics.endFill();
    }
}
}
